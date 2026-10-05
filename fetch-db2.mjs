// Azeroth Exchange: downloads the WoW game data (DB2) files that the
// shatari-data scripts read, straight from Blizzard's public CDN, for all
// 10 site languages. No WoW install needed.
//
// Usage (from the shatari-data folder):  node fetch-db2.mjs
//
// Files land in current/<locale>/DBFilesClient/<Table>.db2, which is where
// src/incl.php's getReader() looks for them. Downloads are cached in ./cache.

import { CASCClient } from '@rhyster/wow-casc-dbc';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));

// Every table the src/*.php scripts open with getReader().
const TABLES = [
    'BattlePetSpecies', 'BattlePetSpeciesState', 'ContentTuning', 'CraftingQuality',
    'CraftingQualityAtlasSet', 'Creature', 'CurvePoint', 'GlobalStrings',
    'ImportPriceArmor', 'ImportPriceQuality', 'ImportPriceShield', 'ImportPriceWeapon',
    'Item', 'ItemAppearance', 'ItemBonus', 'ItemClass', 'ItemModifiedAppearance',
    'ItemNameDescription', 'ItemOffsetCurve', 'ItemPriceBase', 'ItemScalingConfig',
    'ItemSparse', 'ItemSquishEra', 'ItemSubClass', 'ManifestInterfaceData',
    'UiTextureAtlasElement',
];

// The site's 10 languages, spelled the way getReader() builds folder names.
const LOCALES = ['enUS', 'deDE', 'esES', 'frFR', 'itIT', 'koKR', 'ptBR', 'ruRU', 'zhTW', 'esMX'];

// WoWDBDefs' manifest maps each table name to its file ID in the game files.
const manifestPath = path.join(here, '..', 'dbdefs', 'manifest.json');
const manifest = JSON.parse(await fs.readFile(manifestPath, 'utf8'));
const fileIdByTable = new Map(manifest.map(m => [m.tableName.toLowerCase(), m.db2FileDataID]));

console.log('Asking Blizzard for the current retail version...');
const version = await CASCClient.getProductVersion('us', 'wow');
if (!version) {
    throw new Error('Could not get the current WoW version from Blizzard. Check your internet connection and try again.');
}
console.log(`Current retail build: ${version.VersionsName}`);

const client = new CASCClient('us', 'wow', version, CASCClient.LogLevel.warn);
console.log('Loading the game file index (this takes a minute the first time)...');
await client.init();
await client.loadRemoteTACTKeys();

const downloaded = new Map(); // content key -> file contents, so shared files download once
let written = 0;
const problems = [];

for (const table of TABLES) {
    const fileId = fileIdByTable.get(table.toLowerCase());
    if (!fileId) {
        problems.push(`${table}: not listed in dbdefs/manifest.json`);
        continue;
    }
    const entries = client.getContentKeysByFileDataID(fileId);
    if (!entries || entries.length === 0) {
        problems.push(`${table}: not found in this game build`);
        continue;
    }

    for (const locale of LOCALES) {
        const flag = CASCClient.LocaleFlags[locale];
        const entry = entries.find(e => (e.localeFlags & flag) !== 0) ?? entries[0];

        if (!downloaded.has(entry.cKey)) {
            const result = await client.getFileByContentKey(entry.cKey, true);
            if (result.type === 'partial') {
                problems.push(`${table} (${locale}): some encrypted parts could not be unlocked`);
            }
            downloaded.set(entry.cKey, result.buffer);
        }

        const dir = path.join(here, 'current', locale, 'DBFilesClient');
        await fs.mkdir(dir, { recursive: true });
        await fs.writeFile(path.join(dir, `${table}.db2`), downloaded.get(entry.cKey));
        written++;
    }
    console.log(`  ${table}: done`);
}

// Note which build these files came from, for when a patch comes out.
await fs.writeFile(path.join(here, 'current', 'BUILD.txt'), `${version.VersionsName}\n`);

console.log(`\nSaved ${written} files for build ${version.VersionsName}.`);
if (problems.length) {
    console.log('\nThings to tell Claude about:');
    problems.forEach(p => console.log(`  - ${p}`));
} else {
    console.log('No problems.');
}
