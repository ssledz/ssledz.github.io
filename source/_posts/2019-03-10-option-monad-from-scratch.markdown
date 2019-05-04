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
it can be used to simplify the code and make it more readable. 

In this post we will focus on an `Option` monad which wraps value in a context 
aware of whether or not the value exists. We will start with a problem and solution
not exactly suiting our needs and by adapting `Option` monad we will try to fix this.

## Problem

There are 3 streams of numbers given as a strings. 
```scala
val xs = List("0", "9", "9")
val ys = List("3", "3", "1")
val zs = List("2", "3", "2")
```
After zipping and flattening we got a stream  called `data` containing tuples
of 3 strings 
```scala
val data : List[(String, String, String)] = flatten(xs.zip(ys).zip(zs))
```
Our task is to build a pipeline that generates a stream of `Doubles` 
which is a result of division one number by another in a sequence in the 
context of the same tuple.

It means that the pipeline for a stream described as
```
[(x1,y1,z1), (x2,y2,z2),...(xn,yn,zn)]
```
should generate a stream of numbers given by formula mentioned below
```
[(x1/y1/z1), (x2/y2/z2),... (xn/yn/zn)]
```
This problem can be solved using following scala code
```scala
def pipeline = data
    .map((DivModule.div _).tupled(_))
```
`div` function is defined in `DivModule`  
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
For a streams of numbers defined at the beginning we should get
```
0.0, 1.0, 4.5
``` 
The numbers are correct, but take a look on implementation of a `parse`
and `div` functions. Those functions are not `total`. In functional world a function 
which is not `total` is called `partial`. A `partial` function is not defined 
for all values passed as its arguments.  

And for following streams of numbers 
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
We can easily fix this by lifting a partial function to a total function. 
Let's add `lift` function to the `DivModule`
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
Now `pipeline` generates streams of numbers like
```
-1.0, -1.0, 0.0, 1.5, 1.0, -1.0
```
We can spot that for each undefined value we get `-1` because of `lift` 
function which maps all undefined values to the default one, in our case `-1`.

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
variations of streams for which pipeline could return `-1` as a correct result ?

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
Thanks to the `flatMap` we are able to get a value from container, abstracting
whether or not the value is in container or not, and make a `map` transformation
deciding if we want to put again transformed value or replace container with 
the empty one.

Putting all parts together we can define `Option` monad in scala in the following way
```scala
sealed trait Option[+A] {
  
  def flatMap[B](f: A => Option[B]): Option[B] = this match {
    case Some(a) => f(a)
    case None => None
  }
  
  def map[B](f: A => B): Option[B] = flatMap(a => Option.pure(f(a)))
  
}

object Option {
  
  def pure[A](a: A): Option[A] = if (a == null) None else Some(a)
  
}  

case class Some[A](get: A) extends Option[A]

case object None extends Option[Nothing]
```

## Building new version of pipeline

Let's return to our problem. First we need to reimplement `parse`
```scala
def parse(x: Option[String]): Option[Double] = x.flatMap { str =>
  try {
    Option.pure(str.toDouble)
  } catch {
    case e: Throwable => None
  }
}
```
Argument and return type has been lifted respectively to 
the `Option[String]` and `Option[Double]` type. You can spot
that we use `flatMap` to have an access to the `String` value and
based on the `toDouble` operation we return some `Double` value or nothing -
in case of parse exception. When an argument `x` is `None` the function
passed to `flatMap` is not executed - so we are sure that `String` passed
to monadic function is not `null`.

Next we need to take care of `div`
```scala
def div(x: Option[String], y: Option[String], z: Option[String]): Option[Double] = {
  def zeroToNone(n: Double) = if (n == 0) None else Some(n)
  
  for {
    xx <- parse(x)
    yy <- parse(y).flatMap(zeroToNone)
    zz <- parse(z).flatMap(zeroToNone)
  } yield xx / yy / zz
}
```

`String` arguments has been lifted to the `Option[String]` and return type
is now `Option[Double]`. 

An `x` argument is passed to the `parse` and finally we have `Double` 
value in `xx` variable. If `parse` returns `None` then
the whole function `div` is evaluated to `None`. 

For `y` and `z` things works almost the same with one difference - we additionally requires that
`yy` an `zz` must be not equal to zero. This is expressed by calling `flatMap`
with function `zeroToNone`. For `0` value `zeroToNone` returns an empty 
container `None` which causes that the whole expression `parse(y).flatMap(zeroToNone)`
is evaluated to `None` what moves `div` function to return `None`.

Finally pipeline could look following
```scala
def pipeline2 = data
  .map(x => map3(x)(Option.pure))
  .map(z => (DivModuleWithOption.div _).tupled(z))
```

This pipeline generates
```
List(None, None, Some(0.0), Some(1.5), Some(-1.0), None)
```

At the end we need only to filter out nones and get the value out of the `Option`

To do so there is a need to add 3 additional methods to `Option`
```scala
sealed trait Option[+A] {

  //skipped for brevity
   
  def isEmpty: Boolean
  
  def isNonEmpty: Boolean = !isEmpty
  
  def get : A
}
```

and to corresponding subclasses
```scala
case class Some[A](get: A) extends Option[A] {
  def isEmpty: Boolean = false
}

case object None extends Option[Nothing] {
  def isEmpty: Boolean = true

  def get : Nothing = ???
}
```

Finally the pipeline
```scala
def pipeline2 = data
  .map(x => map3(x)(Option.pure))
  .map(z => (DivModuleWithOption.div _).tupled(z))
  .filter(_.isNonEmpty)
  .map(_.get)
```

generates following stream of numbers
```
List(0.0, 1.5, -1.0)
```

and this is all we need.

## Resources

* [Sources to the post](https://github.com/ssledz/ssledz.github.io-src/tree/master/monad-intro-session)
* [Implement monad from scratch - github sources](https://github.com/ssledz/ssledz.github.io-src/tree/master/monad-gentle-introduction)
* [About Monads - a gentle introduction]({% post_url 2019-01-28-about-monads-a-gentle-introduction %})