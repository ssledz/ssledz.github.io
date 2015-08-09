---
layout: post
title: "Puzzle - Write a Method to Reverse a String using recursion"
date: 2015-08-09 20:25:16 +0200
author: slawomir.sledz
comments: true
categories: [puzzle,recursion,algorithms,java]
---

###Problem
I bet that everyone who is reading this know how to write a method to revers the string, but does everyone know how to do it using recursion ? To face such puzzle it it always a good idea to write first some results for given arguments and try to find a pattern. There always must be a 'base case' which can't be divided into subproblems. We also need to discover a procedure which solves bigger problem using its smaller subproblems.

So let's say we need to write a method ``public static String revers(String arg)`` which for a given argument returns a reversed string. Below I have written some examples.
```
revers('a')     = 'a'
revers('ab')    = 'ba'
revers('abc')   = 'cba'
revers('abcd')  = 'dcba'
revers('abcde') = 'edcba'
``` 
Based on that we can already write a recursive procedure.
```
revers('a')     = 'a'
revers('ab')    = 'b'|revers('a')
revers('abc')   = 'c'|revers('ab') 
revers('abcd')  = 'd'|revers('abc')
revers('abcde') = 'e'|revers('abcd')
```
To compute a reversed string for ``'a'`` we need to return that string and it is our 'base case'. In other cases to compute a reversed string we need to get the last char and concatenate it with the reversed string without that last character.

I think we are ready to write some code.
###Coding
```java
    public static String revers(String arg) {

        if (arg.length() == 1) {
            return arg;
        }
        return arg.charAt(arg.length() - 1) + revers(arg.substring(0, arg.length() - 1));

    }
```

```java
    public static void main(String[] args) {
        System.out.println(revers("a"));
        System.out.println(revers("ab"));
        System.out.println(revers("abc"));
        System.out.println(revers("abcd"));
        System.out.println(revers("abcde"));
    }
```

```
a
ba
cba
dcba
edcba

```


