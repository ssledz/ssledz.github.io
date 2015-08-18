---
layout: post
title: "Context free grammar will help where regex pattern fail - Is this well formed array ?"
date: 2015-08-17 00:04:55 +0200
comments: true
categories: [java, pattern, context free grammar]
---

###Preface
Some times ago I was scanning Stackoverflow to find a puzzle to solve, and I found one guy was trying to write a piece of software which had needed to answer on one simple question. Is given expression a well formed array ? He was searching for a ready to use regular expression but he failed, because this puzzle can't be solved using regex engine. Why, I will explain later but now I can say that this puzzle can be easily solved using 'Context free grammar'. 

###Well formed array
You can ask what does the well formed array mean ? I will try to answer by providing some positive and negative examples of such arrays.
```
[1 2 [-34 7] 34]
[1 2 [-34] [7] 34]
[1 2 [-34 [7] 34]]
[1 2[-34[7]34]]
[]
```
Above are well formed arrays. In opposite below are expressions which are not syntactically consistent with the definition of well formed array.
```
[1 2 -34 7] 34]
[1 2 [-34 [7] 34]
[][]

```
Studying those examples we can try to answer on this question. So well formed array is an expression which fulfills following requirements
* first, no blank, character is an open brace ``'['``
* the last no blank character needs to be a closed brace
* inside array, integers and other well formed arrays can appear
* integers are separated with at least one blank character
###Why not regex ?

