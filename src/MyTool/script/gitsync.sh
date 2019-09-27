#!/bin/bash 
### author:brian
### date:19.09.27
### use this script when you push code conflit
echo "========reset start========"
git reset --hard HEAD^^^^
echo "========pull start========="
git pull
echo "========cherry-pick start========"
git cherry-pick $1

