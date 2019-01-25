---
layout: post
title: "Monad transformers - part 2"
date: 2019-01-24 21:46:06 +0100
comments: true
categories: [scala, functional-programming, monads, monad-transformers]
---

In a previous [post]({% post_url 2018-12-18-monad-transformers-a-quick-recap %})
I introduced monad transformers and since now we should have a good feeling
about their usage and how they can be helpful.

Constructing monad transformer we decided to fix inner most monad. This
decision was dictated by the fact that we couldn't replace code dependent
on internal representation of that monad.