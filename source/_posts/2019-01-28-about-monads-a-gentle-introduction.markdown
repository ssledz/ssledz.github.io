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

  def map[A, B](xs: M[A])(f: A => B): M[B] = flatMap(xs)(x => pure(f(x)))

}
```

Functions `pure` and `flatMap` for a given monad `M[_]` have to follow
some laws - I will talk about them later. Function `map` can be defined
in terms of `flatMap` and `pure` and this is a bonus which we get for a free
when we provide an instance of a Monad for a type `M[_]`.

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
Monad let us focus on what we want to do with the contained value. It is
like a context in which the value exists. When we want to do some computation
we are abstracting over the context so we aren't disrupted whether or
not the value exists, we have many of them or the value may appear in a future.
We want just to get the value out of the container for a moment to make
some computation and then put it again. The context is important only when
we want to pull out a value permanently.

Another advantage of the monad is an ability of sequencing the computations.
Having let's say two computations we can very easily make dependence
between them saying that the computations of the second depends on
a result of the first. Of course this can be scaled to more than two.
At first glance, it may seem to be not so impressive because it is
very common to make such things during coding. But be aware that monad
frees us from thinking about the context in which the value exists. The context
can be for example an asynchronous computation. Dealing with concurrency
is challenging - we have to be very careful to not make a hard to spot mistake.
Monad takes care about this complexity, providing a result of the
first computation as soon as possible giving us possibility to
spawn another computation in asynchronous manner.

### Laws
Each monad needs to follow three laws
* Left identity: `return a >>= f ≡ f a`
* Right identity: `m >>= return ≡ m`
* Associativity: `(m >>= f) >>= g ≡ m >>= (\x -> f x >>= g)`
These laws was taken from haskell because expressions there are very compact and
easy to follow. Function `>>=` in scala maps to `flatMap`, `return` is
just a `pure`, `f x` is an application of function `f` to `x` and the
last one `\x -> ...` is a lambda expression.

Laws in scala can be written in a following way (using ScalaCheck)
```scala
val monad = implicitly[Monad[M]]

property("Left identity: return a >>= f ≡ f a") = forAll { (a: A, f: A => M[B]) =>
  (`return`(a) >>= f) === f(a)
}

property("Right identity: m >>= return ≡ m") = forAll { m: M[A] =>
  (m >>= `return`) === m
}

property("Associativity: (m >>= f) >>= g ≡ m >>= (\\x -> f x >>= g)") = forAll { (m: M[A], f: A => M[B], g: B => M[C]) =>
  ((m >>= f) >>= g) === (m >>= (x => f(x) >>= g))
}

val `return`: A => M[A] = monad.pure _

private implicit class MonadOps[A](m: M[A]) {
  def >>=[B](f: A => M[B]): M[B] = monad.flatMap(m)(f)
}
```
If you are curious about implementation details take a look on this [class](https://raw.githubusercontent.com/ssledz/ssledz.github.io-src/master/monad-gentle-introduction/src/test/scala/monad/intro/AbstractMonadProperties.scala)

### Monads

This section is a placeholder for a list of posts about monads mentioned in
this article. I will try my best to deliver a missing content. Watch my blog
for an update.

Monads:
* Option
* Either
* Id
* Writer
* Reader
* State
* Try
* IO
* List

### Resources

* [What are monads in functional programming and why are they useful?](https://www.quora.com/What-are-monads-in-functional-programming-and-why-are-they-useful-Are-they-a-generic-solution-to-the-problem-of-state-in-FP-or-Haskell-specific-Are-they-specific-to-Haskell-or-are-they-encountered-in-other-FP-languages)
* [You Could Have Invented Monads!](http://blog.sigfpe.com/2006/08/you-could-have-invented-monads-and.html)
* [Explain Monads Like I'm five](https://dev.to/theodesp/explain-monads-like-im-five)
* [All About Monads](https://wiki.haskell.org/All_About_Monads)
* [A Gentle Introduction to Haskell](https://www.haskell.org/tutorial/monads.html)
* [A Fistful of Monads](http://learnyouahaskell.com/a-fistful-of-monads)