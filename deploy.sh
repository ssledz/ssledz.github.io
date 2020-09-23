#!/bin/bash
cd _deploy
git reset --hard origin/master
cd ..
bundle exec rake generate
bundle exec rake deploy
