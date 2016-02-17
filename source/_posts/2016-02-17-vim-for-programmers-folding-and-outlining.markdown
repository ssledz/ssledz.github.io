---
layout: post
title: "Vim for programmers - folding and outlining"
date: 2016-02-17 00:33:05 +0100
comments: true
categories: [vim]
---

This is a first post in a series of how **Vim** can make programmer's life easier. **Vim** strikes a nice compromise between
simple editor and monolithic **IDEs**. I find this tool very helpful during my day to day developers tasks. I don't
treat it as a replacement for my favorite **IDE** but rather as a supporting tool. In this post I would like to
introduce folding - very nice and useful feature.

###Folding and outlining
Folding lets you define which parts of the file you can see. For example in a method you can hide everything inside
curly braces letting only definition of function be visible.

{% img center /images/custom/vim/vim-folding1.png %}

When you use fold command, **Vim** hides given text and leaves in its place a one-line placeholder. The hidden text now
can be managed by this placeholder. In a screenshot above, you can spot four folded methods~(there are four one-line
placeholders). The first one - *fibonacci*, consists of 15 rows, takes an int as a parameter and returns a long.
There is no limit on how many folds you can create. You can even create folds within folds~(nested folds).

**Vim** offers six ways to create folds:

* manual - using **Vim** commands
* indent - corresponding to the text indentation
* expr - define folds with regular expressions
* syntax - based on the file's language syntax
* diff - a difference between two files define folds
* marker 

###The fold commands

|Command|                                      |
|-------|--------------------------------------|
|**zA**     |Toggle the state of folds, recursively|
|**zC**     |Close folds, recursively              |
|**zD**     |Delete folds, recursively             |
|**zE**     |Eliminate all folds                   |
|**zf**     |Create fold from the current line to the one where the following motion command takes a cursor|
|count**zF**||
|**zM**||
|**zN**, **zn**||
|**zO**||
|**za**||
|**zc**||
|**zd**||
|**zi**||
|**zj** ,**zk**||
|**zm**, **zr**||
|**zo**||

###Manual folding
