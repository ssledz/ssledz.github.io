---
layout: post
title: "Monad transformers - a quick recap"
date: 2018-12-18 23:19:06 +0100
comments: true
categories: [scala, functional-programming, monads]
---

Someone have said that monads are like burrito, if you ever taste one than
you can't imagine live without it, and it is really, really true :)

Monads are a powerful tool. Thanks to them we can abstract over computation.
We can make one computation depended on another and if needed fail fast.

But one day the time will come when we have two different monads and we will find
out that they don't compose !

Let's make some code to visualize the problem. I am going to show two use
cases and I will start with the simplest one.

We have two entities : User and Address and two functions retrieving data
with the respect of a given predicate

```scala
case class User(id: Long, login: String)
case class Address(userId: Long, street: String)

def findUserByLogin(login: String): Future[User] = ???
def findAddressByUserId(userId: Long): Future[Address] = ???

```

Our goal is to write a function which for a given login returns user's street name

```scala
def findStreetByLogin(login : String) : Function[String] =
  for {
    user <- findUserByLogin(login)
    address <- findAddressByUserId(user.id)
  } yield address.street
```

So far so good - quite simple and classic enterprise task :)

However there are two caveats to this solution worth noting. What happened
if there is no such user or the user exists but it has no address ?

If so we will see Null Pointer Exception in logs - sick !

Of course we can filter out those nulls and rewrite functions to be aware of
nulls but as you already know this also is not a good solution. Can we
do better ? Of course we can, let's introduce a context aware
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

It turns out that `Future` and `Option` monads do not compose in such a way.
For a first look, composition looks very natural in `for` comprehension,
but if we transform it into series of `flatMap` and 'map' at the end, we
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
def findStreetByLogin(login: String): Future[Option[String]] =
  for {
    user <- ???(findUserByLogin(login))
    address <- ???(findAddressByUserId(user.id))
  } yield address.street
```

We already know that `for` comprehension deals with `flatMap`, `map`,
`withFilter` and `foreach`. In our case compiler needs only `flaMap` and `map`
to de sugar `for`. So let's introduce a new data type `OptionT`,
which wraps `Function[Option[A]]` and in a proper way handles
flatMap in order to compose `Future` with `Option`.

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

In fact `OptionT[F[_], A]` abstracts over `F` and `A` and it only requires that `F`
is a monad. A minimal api for monad can be described by following trait

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

The last thing is to implement `Monad` instance for `Future`.

```scala
object MonadInstances {
  implicit val futureInstance: Monad[Future] = new Monad[Future] {

    import scala.concurrent.ExecutionContext.Implicits.global

    override def pure[A](x: A): Future[A] = Future.successful(x)

    override def flatMap[A, B](xs: Future[A])(f: A => Future[B]): Future[B] =
        xs.flatMap(f)
  }
}
```

And thanks to that we can finally write

```scala
import MonadInstances._

def findStreetByLogin(login: String): Future[Option[String]] =
  for {
    user <- OptionT(findUserByLogin(login))
    address <- OptionT(findAddressByUserId(user.id))
  } yield address.street
```