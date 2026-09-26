#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

cd out/mainline
cp -v battlepets.json bonuses.json items.all.json names.bound.*.json ../../../shatari/game/mainline
cp -v craftingQualities.json battlepets.json battlepets.*.json categories.*.json items.unbound.json names.unbound.*.json name-suffixes.*.json vendor.json bonusToStats.json bonusToSockets.json ../../../shatari-front/json/mainline

cd ../forever
cp -v battlepets.json bonuses.json items.all.json names.bound.*.json ../../../shatari/game/forever
cp -v craftingQualities.json battlepets.json battlepets.*.json categories.*.json items.unbound.json names.unbound.*.json name-suffixes.*.json vendor.json bonusToStats.json bonusToSockets.json ../../../shatari-front/json/forever
