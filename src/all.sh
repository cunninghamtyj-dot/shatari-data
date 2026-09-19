#!/bin/bash
set -e

echo Battle Pets
php battlepets.php
sleep 5
echo Bonuses
php bonuses.php
sleep 5
echo Categories
./categories.sh
echo Crafting Quality
php crafting-quality.php
sleep 5
echo Items
php items.php

