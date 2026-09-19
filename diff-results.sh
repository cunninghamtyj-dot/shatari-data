#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

echo "--- battlepets.json"
php src/non-patch/jsondiff.php ../shatari/battlepets.json out/mainline/battlepets.json

echo "--- bonuses.json"
php src/non-patch/jsondiff.php ../shatari/bonuses.json out/mainline/bonuses.json

echo "--- items.all.json"
php src/non-patch/jsondiff.php ../shatari/items.all.json out/mainline/items.all.json

echo "--- names.bound.enus.json"
php src/non-patch/jsondiff.php ../shatari/names.bound.enus.json out/mainline/names.bound.enus.json

echo "--- craftingQualities.json"
php src/non-patch/jsondiff.php ../shatari-front/json/craftingQualities.json out/mainline/craftingQualities.json

echo "--- categories.enus.json"
php src/non-patch/jsondiff.php ../shatari-front/json/categories.enus.json out/mainline/categories.enus.json

echo "--- name-suffixes.enus.json"
php src/non-patch/jsondiff.php ../shatari-front/json/name-suffixes.enus.json out/mainline/name-suffixes.enus.json

echo "--- bonusToStats.json"
php src/non-patch/jsondiff.php ../shatari-front/json/bonusToStats.json out/mainline/bonusToStats.json

echo "--- bonusToSockets.json"
php src/non-patch/jsondiff.php ../shatari-front/json/bonusToSockets.json out/mainline/bonusToSockets.json

