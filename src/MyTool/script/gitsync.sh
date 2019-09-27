#!/bin/bash 
### author:brian
### date:19.09.27
### use this script when you push code conflit

git reset --hard HEAD^^^^
git pull
git cherry-pick $1

