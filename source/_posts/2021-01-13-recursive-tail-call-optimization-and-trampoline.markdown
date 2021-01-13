---
layout: post
title: "Recursive tail call optimization and trampoline"
date: 2021-01-13 14:04:26 +0100
comments: true
categories: 
---

Tail call optimization (or tail call elimination) allows recursive functions to re-use the stack frame instead of creating new frames on every call.

Thanks to that an author of recursive function in tail position is not constrained by the stack size. 
More over such a function runs faster than the function without optimization, because calling a function doesn’t create a new stack frame which is time 
and resource consuming operation.

The article can be found [here](https://iiit.pl/7743-2/)