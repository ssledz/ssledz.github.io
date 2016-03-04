---
layout: post
title: "Vim for programmers - folding"
date: 2016-02-17 00:33:05 +0100
comments: true
categories: [vim]
---

This is a first post in a series of how **Vim** can make programmer's life easier. **Vim** strikes a nice compromise between
simple editor and monolithic **IDEs**. I find this tool very helpful during my day to day developers tasks. I don't
treat it as a replacement for my favorite **IDE** but rather as a supporting tool. In this post I would like to
introduce folding - very nice and useful feature.

###Folding
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

|Command        |                                                                                                |
|---------------|------------------------------------------------------------------------------------------------|
|**zA**         |Toggle the state of folds, recursively                                                          |
|**zC**         |Close folds, recursively                                                                        |
|**zD**         |Delete folds, recursively                                                                       |
|**zO**         |Open folds, recursively                                                                         |
|**zE**         |Eliminate all folds                                                                             |
|**zf**         |Create a fold from the current line to the one where the following motion command takes a cursor|
|count**zF**    |Create a fold covering _count_ lines, starting with the current line                            |
|**zM**         |Set option *foldlevel* to 0                                                                     |
|**zN**, **zn** |Set (zN) or reset (zn) the *foldenable* option                                                  |
|**za**         |Toggle the state of one fold                                                                    |
|**zc**         |Close one fold                                                                                  |
|**zd**         |Delete one fold                                                                                 |
|**zi**         |Toggle the value of the *foldenable* option                                                     |
|**zj** ,**zk** |Move cursor to the start (zj) of the fold or to the end (zk) of the previous fold               |
|**zm**, **zr** |Decrement (zm) or increment (zr) the value of the *foldlevel* option by one                     |
|**zo**         |Open one fold                                                                                   |

###Manual folding

Suppose we want to hide 3 lines of the if statement in a fold

```java
public static long fibonacci(int n) {

  if (n == 0 || n == 1) {
    return n;
  }

  return fibonacci(n - 1) + fibonacci(n - 2);

}
```

To do this just move cursor to the beginning of ```if``` statement and execute:

```
3zf
```

The result should be similar to the one shown below

{% img center /images/custom/vim/vim-folding2.png %}


Let's try more sofisticated command - fold block of code. Position the cursor over the beginning or ending brace of a
block of code and type:

```
zf%
```

{% img center /images/custom/vim/vim-folding3.png %}

There is a one thing to note. Character following ```zf``` command - ```%``` is a motion command that moves cursor to the matching brace.

To learn more about folding and generally about vim, I recommend to read [Learning the Vi and Vim Editors](https://www.goodreads.com/book/show/27390007-learning-the-vi-and-vim-editors-7-e?from_search=true&search_version=service)
