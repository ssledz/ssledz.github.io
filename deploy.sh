#!/bin/bash
cd _deploy
git reset --hard origin/master
cd ..
rake generate
rake deploy
