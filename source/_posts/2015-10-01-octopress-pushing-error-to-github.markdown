---
layout: post
title: "Octopress pushing error to GitHub"
date: 2015-10-01 00:40:41 +0200
comments: true
categories: [octopress, github]
---

When You get something like that
```
## Pushing generated _deploy website
To git@github.com:ssledz/ssledz.github.io.git
 ! [rejected]        master -> master (non-fast-forward)
error: failed to push some refs to 'git@github.com:ssledz/ssledz.github.io.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. Integrate the remote changes (e.g.
hint: 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```
just do following
```bash
cd _deploy
git reset --hard origin/master
cd ..
```
and try again
```
rake generate
rake deploy
```
