#!/bin/bash

rbenv install 1.9.3-p0
rbenv local 1.9.3-p0
rbenv rehash
gem install bundler
bundle install
rake install

[[ ! -e _deploy ]] && rake setup_github_pages

