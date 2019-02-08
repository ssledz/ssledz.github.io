---
layout: post
title: "About Monads - a gentle introduction"
date: 2019-01-28 00:23:36 +0100
comments: true
categories: [scala, functional-programming, monads]
---

In functional programming monad is a design pattern which is used to
express how states of computations are changing. It can take a form of some
abstract data type constructor with two function defined for it.

In `scala` we can define this contract using `Monad` type class
```scala
trait Monad[M[_]] {

  def pure[A](x: A): M[A]

  def flatMap[A, B](xs: M[A])(f: A => M[B]): M[B]

}
```

Functions `pure` and `flatMap` for a given monad `M[A]` have to follow
some laws - I will talk about them later.

We can think about `M[A]` like about some smart container
for a value (values) of type `A`. This container abstracts away from how this value
is kept. We can have many flavors of them like container:
* aware of whether or not the value exists
* with more then one value
* for which getting the value would trigger some kind of `IO` operation
* with value which eventually could appear in future
* with value or error
* with value dependent on some kind of state
* with value and some logging information
* etc
Monad let us focus on what we want to do with the contained value.

### Laws
```
```

### Resources

* [What are monads in functional programming and why are they useful?](https://www.quora.com/What-are-monads-in-functional-programming-and-why-are-they-useful-Are-they-a-generic-solution-to-the-problem-of-state-in-FP-or-Haskell-specific-Are-they-specific-to-Haskell-or-are-they-encountered-in-other-FP-languages)
* [You Could Have Invented Monads!](http://blog.sigfpe.com/2006/08/you-could-have-invented-monads-and.html)
* [Explain Monads Like I'm five](https://dev.to/theodesp/explain-monads-like-im-five)
* [All About Monads](https://wiki.haskell.org/All_About_Monads)
* [A Gentle Introduction to Haskell](https://www.haskell.org/tutorial/monads.html)
* [A Fistful of Monads](http://learnyouahaskell.com/a-fistful-of-monads)