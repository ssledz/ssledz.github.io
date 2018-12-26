---
layout: post
title: "Monad transformers - a quick recap"
date: 2018-12-18 23:19:06 +0100
comments: true
categories: [scala, functional-programming, monads]
---

Someone have said that **monads** are like burrito, if you ever taste one than
you can't imagine live without it.

**Monads** are a powerful tool. Thanks to them we can abstract over computation.
We can make one computation depended on another and if needed fail fast.

But one day the time will come when we have two different **monads** and we will find
out that they don't compose !

Let's make some code to visualize the problem. I am going to show two use
cases and I will start with the simplest one.

### Case 1
We have two entities : `User` and `Address` and two functions retrieving data
with the respect of a given predicate
```scala
case class User(id: Long, login: String)
case class Address(userId: Long, street: String)

def findUserByLogin(login: String): Future[User] = ???
def findAddressByUserId(userId: Long): Future[Address] = ???

```
Our goal is to write a function which for a given login returns user's street name
```scala
def findStreetByLogin(login : String) : Future[String] =
  for {
    user <- findUserByLogin(login)
    address <- findAddressByUserId(user.id)
  } yield address.street
```

So far so good - quite simple and classic enterprise task :)

However there are two caveats to this solution worth noting. What happened
if there is no such user or the user exists but it has no address ?
It is obvious that we will see `Null Pointer Exception` - sick !

Of course we can filter out those nulls and rewrite functions to be aware of
them but as you already know this is also not a good solution. Can we
do better ? Yes we can, let's introduce a context~(`Option`) aware
of whether value exists or not.
```scala
def findUserByLogin(login: String): Future[Option[User]] = ???
def findAddressByUserId(userId: Long): Future[Option[Address]] = ???
```
But wait below function is not compiling...
```scala
def findStreetByLogin(login: String): Future[Option[String]] =
  for {
    maybeUser <- findUserByLogin(login)
    user <- maybeUser
    address <- findAddressByUserId(user.id)
  } yield address.map(_.street)
```
It turns out that `Future` and `Option` **monads** do not compose in such a way.
For a first look, composition looks very natural in `for` comprehension,
but if we transform it into series of `flatMap` and `map` at the end, we
will notice that the puzzles don't feet. If we start with `Future` than the
function passed to `flatMap` must return a `Future`. In our case we want
to return `Option` in the middle and based on it return a next `Future`
being a container fo an user's possible address.

Equipped with this knowledge we can rewrite our function in the following
way
```scala
def findStreetByLogin(login: String): Future[Option[String]] =
  findUserByLogin(login).flatMap {
    case Some(user) => findAddressByUserId(user.id).map(_.map(_.street))
    case None => Future.successful(None)
  }
```
Now it compiles and return correct results. But it is not as readable as
our first naive attempt. Can we do better ? Ideally we would want to have
something like
```scala
def findStreetByLogin(login: String): ??? =
  for {
    user <- ???(findUserByLogin(login))
    address <- ???(findAddressByUserId(user.id))
  } yield address.street
```
We need somehow to fuse `Future` with `Option` in a smart way to make
the composition possible.

#### Fusing `Future` with `Option`
We already know that `for` comprehension deals with `flatMap`, `map`,
`withFilter` and `foreach`. In our case compiler needs only `flaMap` and `map`
to de sugar `for`. So let's introduce a new data type `OptionFuture`,
which wraps `Future[Option[A]]` and in a proper way handles
flatMap in order to compose `Future` with `Option`.
```scala
case class OptionFuture[A](value: Future[Option[A]]) {

  def flatMap[B](f: A => OptionFuture[B])(implicit ex: ExecutionContext): OptionFuture[B] =
    flatMapF(a => f(a).value)

  def flatMapF[B](f: A => Future[Option[B]])
                 (implicit ex: ExecutionContext): OptionFuture[B] = OptionFuture(
    value.flatMap { as =>
      as match {
        case Some(a) => f(a)
        case _ => Future.successful(None)
      }
    }
  )

  def map[B](f: A => B)(implicit ex: ExecutionContext): OptionFuture[B] =
    OptionFuture(value.map { x => x.map(f) })
}
```
Let's take a little time to better look at `OptionFuture` data type.
First question coming to my mind is - can we make it more abstract ?
It turns out that we can abstract over `Future` very easly. In terms
of `Future` we are calling only two kinds of functions:

* `flatMap`
* `Future.successful`

It means that `Future` can be swapped with `Monad`.

What about the `Option` ? Over the `Option` we are performing **pattern matching**
- so it means that we need to know something about it structure.

And because of that we can't to abstract over it.

This leads us to the definition of **monad transformer** for `Option` and
we call it `OptionT`

#### Monad transformer for `Option`
```scala
case class OptionT[F[_], A](value: F[Option[A]]) {

  def flatMap[B](f: A => OptionT[F, B])(implicit m: Monad[F]): OptionT[F, B] =
    flatMapF(a => f(a).value)

  def flatMapF[B](f: A => F[Option[B]])(implicit F: Monad[F]): OptionT[F, B] = OptionT(
    F.flatMap(value) { as =>
      as match {
        case Some(a) => f(a)
        case _ => F.pure(None)
      }
    }
  )

  def map[B](f: A => B)(implicit F: Monad[F]): OptionT[F, B] =
    OptionT(F.map(value) { x => x.map(f) })
}
```
`OptionT[F[_], A]` abstracts over `F` and `A` and it only requires that `F`
is a monad.

#### Monad quick recap
A minimal api for monad can be described by following trait
```scala
trait Monad[M[_]] {

  def pure[A](x: A): M[A]

  def flatMap[A, B](xs: M[A])(f: A => M[B]): M[B]

  def map[A, B](xs: M[A])(f: A => B): M[B] = flatMap(xs)(x => pure(f(x)))

}

object Monad {

  def apply[M[_]](implicit m: Monad[M]): Monad[M] = m

}
```
And its instance for `Future` you can find below.
```scala
object MonadInstances {
  implicit def futureInstance(implicit ex: ExecutionContext): Monad[Future] =
    new Monad[Future] {

      override def pure[A](x: A): Future[A] = Future.successful(x)

      override def flatMap[A, B](xs: Future[A])(f: A => Future[B]): Future[B] = xs.flatMap(f)
    }
}
```

#### Final solution
Putting all pieces together we can finally write
```scala
import scala.concurrent.ExecutionContext.Implicits.global
import MonadInstances._

def findStreetByLogin(login: String): OptionT[Future, String] =
  for {
    user <- OptionT(findUserByLogin(login))
    address <- OptionT(findAddressByUserId(user.id))
  } yield address.street
```
of course we can return directly `Future[Option[String]]` just by calling
`value` function on the result like
```scala
def findStreetByLogin(login: String): Future[Option[String]] =
  (for {
    user <- OptionT(findUserByLogin(login))
    address <- OptionT(findAddressByUserId(user.id))
  } yield address.street).value
```

At the beginning I said that I have two cases to show, but because the
post could be to long to go through without a brake I decided to break it
into two pieces. The whole code base used in this post can be found in
the following [link](https://github.com/ssledz/ssledz.github.io-src/tree/master/monad-transformer)

More soon...