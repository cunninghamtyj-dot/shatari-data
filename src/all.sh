#!/bin/bash
set -e

here="$(pwd)"
export DBDEFS_DIR="$(realpath ../dbdefs)"
echo "Using definitions path: $DBDEFS_DIR"
cd "$DBDEFS_DIR"
git pull origin master
cd "$here"

echo Battle Pets
php battlepets.php
echo Bonuses
php bonuses.php
echo Categories
./categories.sh
echo Crafting Quality
php crafting-quality.php
echo Items
php items.php

