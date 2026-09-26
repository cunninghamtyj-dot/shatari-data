#!/bin/bash

set -euo pipefail

# safe_copy [--compress] SRC [SRC ...] DEST_DIR
#
# For each SRC file, copies it into DEST_DIR unless:
#   - SRC's size is <= 90% of the existing destination file's size, or
#   - SRC's md5 matches the existing destination file's md5
#
# Copies are done atomically (copy to a temp file in the destination
# directory, then `mv` it into place).
#
# With --compress, after a file is actually copied (not skipped), also
# produces DEST.gz (gzip --best) and DEST.br (brotli), each built
# atomically via a temp file and timestamped to match DEST.
#
# written by Claude because I can't be bothered.
safe_copy() {
    local compress=0

    # Parse leading flags.
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --compress)
                compress=1
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                echo "safe_copy: unknown option '$1'" >&2
                return 1
                ;;
            *)
                break
                ;;
        esac
    done

    if [[ $# -lt 2 ]]; then
        echo "safe_copy: need at least one source and a destination directory" >&2
        return 1
    fi

    local dest_dir="${*: -1}"        # last argument
    local srcs=("${@:1:$#-1}")       # everything except the last argument

    if [[ ! -d "$dest_dir" ]]; then
        echo "safe_copy: destination '$dest_dir' is not a directory" >&2
        return 1
    fi
    realDest=$(realpath "$dest_dir")
    echo ""
    echo "safe_copy: Copying into '$realDest'"

    local src base dest
    for src in "${srcs[@]}"; do
        if [[ ! -f "$src" ]]; then
            echo "safe_copy: skipping '$src' (not a file)" >&2
            continue
        fi

        base=$(basename -- "$src")
        dest="$dest_dir/$base"

        if [[ -f "$dest" ]]; then
            local src_size dest_size
            src_size=$(stat -c%s -- "$src")
            dest_size=$(stat -c%s -- "$dest")

            # Skip if new file size <= 90% of original size.
            # i.e. src_size * 10 <= dest_size * 9  (integer-safe form of src <= 0.9*dest)
            if (( src_size * 10 <= dest_size * 9 )); then
                echo "safe_copy: SKIP '$base' (new file is <=90% of original size: ${src_size} vs ${dest_size})"
                continue
            fi

            local src_md5 dest_md5
            src_md5=$(md5sum -- "$src" | awk '{print $1}')
            dest_md5=$(md5sum -- "$dest" | awk '{print $1}')

            if [[ "$src_md5" == "$dest_md5" ]]; then
                echo "safe_copy: SKIP '$base' (md5 unchanged)"
                continue
            fi
        fi

        # Atomic copy: temp file in the same directory, then rename.
        local tmp
        tmp=$(mktemp "$dest_dir/.${base}.XXXXXX")
        cp -- "$src" "$tmp"
        chmod 0664 -- "$tmp"
        mv -- "$tmp" "$dest"
        echo "safe_copy: copied '$base'"

        if [[ "$compress" -eq 1 ]]; then
            local gz_tmp br_tmp
            gz_tmp=$(mktemp "$dest_dir/.${base}.gz.XXXXXX")
            gzip --best -c -- "$dest" > "$gz_tmp"
            chmod 0664 -- "$gz_tmp"
            touch -r "$dest" "$gz_tmp"
            mv -f -- "$gz_tmp" "${dest}.gz"

            br_tmp=$(mktemp "$dest_dir/.${base}.br.XXXXXX")
            brotli -f -o "$br_tmp" -- "$dest"
            chmod 0664 -- "$br_tmp"
            touch -r "$dest" "$br_tmp"
            mv -f -- "$br_tmp" "${dest}.br"

            echo "safe_copy: compressed '$base'"
        fi
    done
}

cd "$( dirname "${BASH_SOURCE[0]}" )"

cd out/mainline
safe_copy battlepets.json bonuses.json items.all.json names.bound.*.json ../../../shatari/game/mainline
safe_copy --compress craftingQualities.json battlepets.json battlepets.*.json categories.*.json items.unbound.json names.unbound.*.json name-suffixes.*.json vendor.json bonusToStats.json bonusToSockets.json ../../../shatari-front/json/mainline

cd ../forever
safe_copy battlepets.json bonuses.json items.all.json names.bound.*.json ../../../shatari/game/forever
safe_copy --compress craftingQualities.json battlepets.json battlepets.*.json categories.*.json items.unbound.json names.unbound.*.json name-suffixes.*.json vendor.json bonusToStats.json bonusToSockets.json ../../../shatari-front/json/forever
