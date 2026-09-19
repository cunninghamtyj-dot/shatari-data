#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

cd out/mainline
cp -v battlepets.json bonuses.json items.all.json names.bound.*.json ../../../shatari/
cp -v craftingQualities.json battlepets.json battlepets.*.json categories.*.json items.unbound.json names.unbound.*.json name-suffixes.*.json vendor.json bonusToStats.json bonusToSockets.json ../../../shatari-front/json/
