---
layout: post
title: "Playing with scala - writing function : flatten"
date: 2016-07-25 00:25:57 +0200
comments: true
categories: [scala, functional-programming]
---

Few weeks ago since now :) I started participating in a course __'Functional Programming Principles in Scala'__ by 
**Martin Odersky**. I have already completed 4 weeks (course consists of 6 weeks) and I can tell honestly that this is 
the best course I've ever been doing. 

My knowledge about scala is still increasing ! 

Below you can find a sample of what I can now do. The problem is to implement function
`flatten(xs: List[Any]): List[Any]` which takes a list of anything an tries to flatten it. For example
  
```scala
flatten(List(List(1, 1), 2, List(3, List(5, 8))))
```

should return a following list

```scala
List[Any] = List(1, 1, 2, 3, 5, 8)
```

{% gist fa5227685dda83e8b895ac9578a206b6 %}

At the end I would like to say __'thank you'__ to **[Atlassian](https://www.atlassian.com/)** company for paying a half 
for this course ! 