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

Designing a monad transformer we decided to fix inner most monad. This
decision was dictated by the fact that we couldn't replace code dependent
on internal representation of that inner most monad. I think that this step
could not be as obvious as I expected to be. And now I will try to
make it more clear.

Let's try to bite the problem from different side. Assume that we can write
a monad transformer and know nothing about monads internal representation.
Let's call it `CMonad` (shorthand from `ComposedMonad`).

Such a class could look like
```scala
case class CMonad[F[_], G[_], A](value: F[G[A]]) {

 def flatMap[B](f: A => CMonad[F, G, B])(implicit F: Monad[F], G: Monad[G]): CMonad[F, G, B] =
   ???

 def map[B](f: A => B): CMonad[F, G, B] = ???

}
```
Here `F[_]` and `G[_]` are higher kinded type representing outer and inner most monad.

Then a problem introduced in a previous post could be solved following
```scala
def findStreetByLogin(login: String): CMonad[Future, Option, String] =
  for {
    user <- CMonad(findUserByLogin(login))
    address <- CMonad(findAddressByUserId(user.id))
  } yield address.street
```

Of course it doesn't work because we haven't yet provided implementation for `flatMap` and `map`

Let's start with `flatMap`. To make things clear a little I introduced a new
method `flatMapF` and defined `flatMap` in terms of `flatMapF`
```scala
case class CMonad[F[_], G[_], A](value: F[G[A]]) {

 def flatMapF[B](f: A => F[G[B]])(implicit F: Monad[F], G: Monad[G]): CMonad[F, G, B] =
   ???

 def flatMap[B](f: A => CMonad[F, G, B])(implicit F: Monad[F], G: Monad[G]): CMonad[F, G, B] =
   flatMapF(a => f(a).value)

 def map[B](f: A => B): CMonad[F, G, B] = ???

}
```
In order to apply `f : A => F[G[B]]` we need to extract `A` from `value: F[G[A]]`

One attempt could end with following code
```scala
case class CMonad[F[_], G[_], A](value: F[G[A]]) {

 def flatMapF[B](f: A => F[G[B]])(implicit F: Monad[F], G: Monad[G]): CMonad[F, G, B] =
   CMonad[F, G, B] {
     F.flatMap(value) { ga: G[A] =>
       val gb: G[B] = G.flatMap(ga) { a: A =>
         ???
       }
       F.pure(gb)
     }
   }

 def flatMap[B](f: A => CMonad[F, G, B])(implicit F: Monad[F], G: Monad[G]): CMonad[F, G, B] =
   flatMapF(a => f(a).value)

 def map[B](f: A => B): ComposedMonad[F, G, B] = ???

}
```
Now we can apply `f` with `A` and we will get `fgb : F[G[B]]`
```scala
 def flatMapF[B](f: A => F[G[B]])(implicit F: Monad[F], G: Monad[G]): CMonad[F, G, B] =
   CMonad[F, G, B] {
     F.flatMap(value) { ga: G[A] =>
       val gb: G[B] = G.flatMap(ga) { a: A =>
         val fgb: F[G[B]] = f(a)
         ???
       }
       F.pure(gb)
     }
   }
```
In order to make compiler happy we need to take one step more - extract
`G[B]` from `F[G[B]]` and return that value from inner most `flatMap`.
This of course is not possible knowing only that `F` and `G` form a monad.

Another attempt can lead us to the code like
```scala
 def flatMapF[B](f: A => F[G[B]])(implicit F: Monad[F], G: Monad[G]): CMonad[F, G, B] =
   CMonad[F, G, B] {
     F.flatMap(value) { ga: G[A] =>
       val gfgb: G[F[G[B]]] = G.map(ga) { a: A =>
         f(a)
       }
       ???
     }
   }
```
And now we need to extract `F[G[B]]` from `G[F[G[B]]]`. This also is not possible
if we know nothing about internal representation of `G`.

All this leads us to the conclusion that we can't write a monad transformer
if we know nothing, about the monads.