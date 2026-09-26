#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

for locale in enus dede eses frfr itit ptbr ruru zhtw kokr esmx; do
  echo "Starting $locale..."
  php categories.php $locale
  if [ "$DBDEFS_DIR" == "" ]; then
    echo "Sleeping..."
    sleep 5
  fi
done
echo "Done"
