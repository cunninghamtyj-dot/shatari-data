#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

for product in mainline forever; do

echo "--- $product battlepets.json"
php src/non-patch/jsondiff.php ../shatari/game/$product/battlepets.json out/$product/battlepets.json

echo "--- $product bonuses.json"
php src/non-patch/jsondiff.php ../shatari/game/$product/bonuses.json out/$product/bonuses.json

echo "--- $product items.all.json"
php src/non-patch/jsondiff.php ../shatari/game/$product/items.all.json out/$product/items.all.json

echo "--- $product names.bound.enus.json"
php src/non-patch/jsondiff.php ../shatari/game/$product/names.bound.enus.json out/$product/names.bound.enus.json

echo "--- $product craftingQualities.json"
php src/non-patch/jsondiff.php ../shatari-front/json/$product/craftingQualities.json out/$product/craftingQualities.json

echo "--- $product categories.enus.json"
php src/non-patch/jsondiff.php ../shatari-front/json/$product/categories.enus.json out/$product/categories.enus.json

echo "--- $product name-suffixes.enus.json"
php src/non-patch/jsondiff.php ../shatari-front/json/$product/name-suffixes.enus.json out/$product/name-suffixes.enus.json

echo "--- $product globalStrings.enus.json"
php src/non-patch/jsondiff.php ../shatari-front/json/$product/globalStrings.enus.json out/$product/globalStrings.enus.json

echo "--- $product bonusToStats.json"
php src/non-patch/jsondiff.php ../shatari-front/json/$product/bonusToStats.json out/$product/bonusToStats.json

echo "--- $product bonusToSockets.json"
php src/non-patch/jsondiff.php ../shatari-front/json/$product/bonusToSockets.json out/$product/bonusToSockets.json

done
