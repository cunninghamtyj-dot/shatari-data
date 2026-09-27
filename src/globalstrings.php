<?php

require_once __DIR__ . '/incl.php';

$outPath = getOutPath();

$tags = [
    'PROFESSIONS_SPECIALIZATION_VIEW_DETAILS' => 'Click to view details',
    'REALM_LOCKED' => 'Locked',
    'LOAD_NEW' => 'New',
    'LOAD_RECOMMENDED' => 'New Players',
    'LOAD_LOW' => 'Low',
    'LOAD_MEDIUM' => 'Medium',
    'LOAD_HIGH' => 'High',
    'LOAD_FULL' => 'Full',
    'FACTION_ALLIANCE' => 'Alliance',
    'FACTION_HORDE' => 'Horde',
    'FACTION_NEUTRAL' => 'Neutral',
];

foreach (LOCALES as $locale) {
    echo "Opening {$locale} Global Strings reader...\n";
    $globalStringsReader = getReader("GlobalStrings", $locale);
    $globalStringsReader->fetchColumnNames();
    $globalStrings = [];
    foreach ($globalStringsReader->generateRecords() as $rec) {
        $globalStrings[$rec['BaseTag']] = $rec['TagText_lang'];
    }
    unset($globalStringsReader);

    $localized = [];
    foreach ($tags as $tagName => $fallback) {
        $localized[$tagName] = $globalStrings[$tagName] ?? $fallback;
    }

    file_put_contents("{$outPath}/globalStrings.{$locale}.json", json_encode($localized, OE_JSON_FLAGS));
}

echo "Done.\n";
