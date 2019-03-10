---
layout: post
title: "Option Monad - from scratch"
date: 2019-03-10 11:28:42 +0100
comments: true
categories: [scala, functional-programming, monads]
---

In a [post]({% post_url 2019-01-28-about-monads-a-gentle-introduction %})
I have introduced a concept of `monad`. Since now we should have a good
intuition what `monad` is. We are also aware of the situations where 
they can be used to simplify the code and make it more readable. In this
post we will focus on an `Option` monad which wraps value with a context 
aware of whether or not the value exists. We will start with a problem and solution
not exactly suiting our needs and adapting `Option` monad we will try to fix solution.

## Problem

There are 3 streams of numbers given as a string. 
```scala
val xs = List("0", "9", "9")
val ys = List("3", "3", "1")
val zs = List("2", "3", "2")
```
After merging operation we got a fourth stream `data` containing tuples
of 3 strings 
```scala
val data : List[(String, String, String)] = flatten(xs.zip(ys).zip(zs))
```
Our task is to build a pipeline that generates a stream of `doubles` 
which are the result of division one number by the next one in the 
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

For a given at the beginning streams of numbers we should get
```
0.0, 1.0, 4.5
``` 
And the numbers are correct, but take a look on implementations of `parse`
and `div` functions. Those functions are partial - they don't cover
the whole domain. And for following streams of numbers 

```scala
val xs = List("11", "22", "0" , "9", "9", null)
val ys = List("11", "0" , "33", "3", "3", "1")
val zs = List("0" , "22", "33", "2", "3", "2")
```

after running program we get an `Exception`
```
Exception in thread "main" java.lang.IllegalArgumentException: y or z can't be 0
	at learning.monad.example.DivModule$.div(DivModule.scala:28)
	at learning.monad.example.MonadOption$.$anonfun$pipeline$2(MonadOption.scala:25)
	at learning.monad.example.MonadOption$.$anonfun$pipeline$2$adapted(MonadOption.scala:25)
```

We can easily fix this - lifting partial function to function. Let's add `lift`
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

and modify the pipeline
```scala
def pipeline: List[Double] = data
  .map((DivModule.lift(DivModule.div, -1)).tupled(_))
```

