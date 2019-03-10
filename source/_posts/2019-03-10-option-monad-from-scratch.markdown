---
layout: post
title: "Option Monad - from scratch"
date: 2019-03-10 11:28:42 +0100
comments: true
categories: [scala, functional-programming, monads]
---

In a post [About Monads - a gentle introduction]({% post_url 2019-01-28-about-monads-a-gentle-introduction %})
I have introduced a concept of `monad`. Since now we should have a good
intuition what `monad` is and be aware of the situations where 
they can be used to simplify the code and make it more readable. 

In this post we will focus on an `Option` monad which wraps value with a context 
aware of whether or not the value exists. We will start with a problem and solution
not exactly suiting our needs and adapting `Option` monad we will try to fix this.

## Problem

There are 3 streams of numbers given as a string. 
```scala
val xs = List("0", "9", "9")
val ys = List("3", "3", "1")
val zs = List("2", "3", "2")
```
After merging operation we got a stream  caled `data` containing tuples
of 3 strings 
```scala
val data : List[(String, String, String)] = flatten(xs.zip(ys).zip(zs))
```
Our task is to build a pipeline that generates a stream of `Doubles` 
which is a result of division one number by the next one in the 
context of the same tuple.

So following stream
```
[(x1,y1,z1), (x2,y2,z2),...(xn,yn,zn)]
```
should generate
```
[(x1/y1/z1), (x2/y2/z2),... (xn/yn/zn)]
```
This problem can be solved using following scala code
```scala
def pipeline = data
    .map((DivModule.div _).tupled(_))
```
where `DivModule` consist of `div` and `parse` functions. 
```scala
object DivModule {

  def parse(x: String): Double = {

    if (x == null) {
      throw new IllegalArgumentException("arg can't be null")
    }

    x.toDouble

  }

  def div(x: String, y: String, z: String): Double = {

    if (x == null || y == null || z == null) {
      throw new IllegalArgumentException("(x | y | z) can't be null")
    }

    val xx = parse(x)

    val yy = parse(y)

    val zz = parse(z)

    if (yy == 0 || zz == 0) {
      throw new IllegalArgumentException("y or z can't be 0")
    }

    xx / yy / zz

  }

}
```
For a given streams of numbers (defined at the beginning) we should get
```
0.0, 1.0, 4.5
``` 
The numbers are correct, but take a look on implementations of `parse`
and `div` functions. Those functions are `partial` - they don't cover
the whole domain. And for following streams of numbers 
```scala
val xs = List("11", "22", "0" , "9", "9", null)
val ys = List("11", "0" , "33", "3", "3", "1")
val zs = List("0" , "22", "33", "2", "3", "2")
```
after running pipeline we get an `Exception`
```
Exception in thread "main" java.lang.IllegalArgumentException: y or z can't be 0
  at learning.monad.example.DivModule$.div(DivModule.scala:28)
  at learning.monad.example.MonadOption$.$anonfun$pipeline$2(MonadOption.scala:25)
  at learning.monad.example.MonadOption$.$anonfun$pipeline$2$adapted(MonadOption.scala:25)
```
We can easily fix this by lifting partial function to function. Let's add `lift`
function to the `DivModule`
```scala
type Fun3 = (String, String, String) => Double

def lift(f: Fun3, defaultValue: Double): Fun3 = (x, y, z) =>
  try {
    f(x, y, z)
  } catch {
    case e: Throwable => defaultValue
  }
```
and modify the `pipeline` accordingly
```scala
def pipeline: List[Double] = data
  .map((DivModule.lift(DivModule.div, -1)).tupled(_))
```
Now `pipeline` generates streams of numbers
```
-1.0, -1.0, 0.0, 1.5, 1.0, -1.0
```
We can spot that for each undefined value we get `-1` because of `lift` 
function which maps all undefined values to the default one - in our case `-1`.

In order to get only a valid numbers let's apply a filter  
```scala
def pipeline: List[Double] = data
  .map((DivModule.lift(DivModule.div, -1)).tupled(_))
  .filter(_ != -1)
```

and our result is

```
0.0, 1.5, 1.0
```

For a first look this solution would seem to be good, but what about all 
operations which could return `-1` as a correct result ?

When we change fifth number in `zs` from `3` to `-3`
```scala
val xs = List("11", "22", "0" , "9", "9", null)
val ys = List("11", "0" , "33", "3", "3", "1")
val zs = List("0" , "22", "33", "2", "-3", "2")
```

our pipeline will generate

```
0.0, 1.5
```

instead of

```
0.0, 1.5, -1.0
```

This is wrong and changing default value in `lift` function doesn't
fix this, because co-domain of `div` function covers whole domain of `Double`.

`Option` monad comes to the rescue.

## Option monad

In order to implement an `Option` monad we start with defining a data type
constructor
```scala
trait Option[+A]
```

`Option` is an algebraic data type constructor parametrized with `A` in a `co-variant`
position. We can think of an `Option[_]` like about container keeping
a value. For now it has no context. 

Let's assigned a context to it by defining a first value constructor called `Some`
```scala
case class Some[A](get: A) extends Option[A]
```
This constructor introduced a context of container with a value within.

A context meaning no value (empty container) can be defined with `None`
```scala
case object None extends Option[Nothing]
```
`None` reveals why we need a type parameter `A` to be in `co-variant` position -
we simply requires `None` to be cast to any `Option[A]`.  

Recalling a definition of Monad we know that it consists of three parts:

* type constructor `M[A]`
* type converter (called `unit`, `pure` or `return`)
* combinator (called `bind`, `>>=` or `flatMap`)

First part is fulfilled. Now we have to implement type converter - `pure`
```scala
object Option {

  def pure[A](a: A): Option[A] = if (a == null) None else Some(a)
  
}
```
`pure` is a function which is responsible for putting a given value
to the minimal meaningful context. For `Option` we requires that each
non `null` value should be bind to the `Some`, in other case
it should be `None`.

The toughest to implement is a combinator function called `flatMap`. For
an `Option` it is very easy task however.
```scala
trait Option[+A] {
  def flatMap[B](f: A => Option[B]): Option[B] = this match {
    case Some(a) => f(a)
    case None => None
  }
}
```
This higher order function is very powerful and can be used as a primitive
to implement for example `map` and `filter` in a following way
```scala
trait Option[+A] {
  def flatMap[B](f: A => Option[B]): Option[B] = this match {
    case Some(a) => f(a)
    case None => None
  }

  def map[B](f: A => B): Option[B] = flatMap(a => Option.pure(f(a)))
  
  def filter(p : A => Boolean) : Option[A] = flatMap(a => if(p(a)) Option.pure(a) else None)
}
```
TODO