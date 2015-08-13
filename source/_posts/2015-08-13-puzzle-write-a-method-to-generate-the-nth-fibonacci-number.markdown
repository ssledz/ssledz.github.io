---
layout: post
title: "Puzzle - Write a method to generate the nth Fibonacci number"
date: 2015-08-13 01:18:14 +0200
comments: true
categories: [puzzle,recursion,algorithms,java,dynamic programming]
---

###Preface
Writing a method to generate the nth Fibonacci number is not a rocket science. The recursive formula for that is very simple and can be written following:
```
fibonacci(0) = 0
fibonacci(1) = 1
fibonacci(n) = fibonacci(n-1) + fibonacci(n-2)
```
The n-th Fibonacci number is just the sum of two previous Fibonacci numbers and the first and second formula are our 'base cases'. Based on this we can write a method ``public static long slowFibonacci(int n)``
```java
    public static long slowFibonacci(int n) {

        if (n == 0 || n == 1) {
            return n;
        }

        return slowFibonacci(n - 1) + slowFibonacci(n - 2);

    }
```
You have already noticed that instead of writing fibonacci I have written slowFibonacci. There is a reason for that and You may guessing that probably we can do something with this method to make it much faster and You have right. There is a quite usful programming method which we can use to improve the performance of this method. However before doing this let's try to write a method call stack trace for let's say 5th Fibonacci number.
```
slowFibonacci(5)
-slowFibonacci(4)
--slowFibonacci(3)
---slowFibonacci(2)
----slowFibonacci(1) -> 1
----slowFibonacci(0) -> 0
---slowFibonacci(2) -> 1
---slowFibonacci(1) -> 1
--slowFibonacci(3) -> 2
--slowFibonacci(2)
---slowFibonacci(1) -> 1
---slowFibonacci(0) -> 0
--slowFibonacci(2) -> 1
-slowFibonacci(4) -> 3
-slowFibonacci(3)
--slowFibonacci(2)
---slowFibonacci(1) -> 1
---slowFibonacci(0) -> 1
--slowFibonacci(2) -> 1
--slowFibonacci(1) -> 1
-slowFibonacci(3) -> 2
slowFibonacci(5) -> 5
```
The number of dashes means how many delayed operations is on the stack. Dash followed by the '>' ('->') means that the operation can be computed (return value is provided) and removed from the stack. 

You can notice that the same operations are evaluated many times, for example ``slowFibonacci(2)`` is computed 3 times. It is obvious waste of cpu resources. What can we do to use previously computed value instead of evaluating it again and again ?

###Dynamic programming
'Dynamic programming' method comes to our rescue. According to the wiki, 'dynamic programming' is a method for solving a complex problem by breaking it down into a collection of simpler subproblems. It is applicable to problems exhibiting the properties of overlapping subproblems and optimal substructure. The dynamic programming approach seeks to solve each subproblem only once, thus reducing the number of computations: once the solution to a given subproblem has been computed, it is stored or "memoized": the next time the same solution is needed, it is simply looked up.

What does it mean for us ? Each already solved subproblem (computed i-th Fibonacci number) can be saved in the let's say global array and if the same solution is needed just simply look for it in that table.

###Coding
```java
public class Fibonacci {

    private static long[] FIB = new long[100];

    public static long fibonacci(int n) {

        if (n == 0 || n == 1) {
            return n;
        }

        if (FIB[n] != 0) {
            return FIB[n];
        }

        FIB[n] = fibonacci(n - 1) + fibonacci(n - 2);

        return FIB[n];

    }

    public static long slowFibonacci(int n) {

        if (n == 0 || n == 1) {
            return n;
        }

        return slowFibonacci(n - 1) + slowFibonacci(n - 2);

    }

}
```
Call stack trace for this tuned method is following
```
fibonacci(5)
-fibonacci(4)
--fibonacci(3)
---fibonacci(2)
----fibonacci(1) -> 1
----fibonacci(0) -> 0
---fibonacci(2) -> 1
---fibonacci(1) -> 1
--fibonacci(3) -> 2
--fibonacci(2) -> 2
-fibonacci(4) -> 3
-fibonacci(3) -> 2
fibonacci(5) -> 5
```
You can notice that the number of calls is much smaller then for ``slowFibonacci(5)``. 

At the end I would like to present a simple benchmark
```
fibonacci(45) = 1134903170
Duration: 0,002000s
fibonacci(60) = 1548008755920
Duration: 0,000000s
slowFibonacci(45) = 1134903170
Duration: 7,893000s
```
To compute 45-th Fibonacci number for ``fibonacci`` it takes 2ms and for ``slowFibonacci`` it takes 7.8s so a savings are significant.
