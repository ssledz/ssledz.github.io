---
layout: post
title: "Puzzle - Write a method to compute all permutations of a string"
date: 2015-08-08 21:06:54 +0200
author: slawomir.sledz
comments: true
categories: [puzzle,recursion,algorithms,java]
---

### How to Approche
When we hear a problem beginning with: 'Write a method to compute all...', it is often a good candidate for recursion. By definition recursive solutions are built of solving subproblems. Simply speaking when we need to compute ``f(n)``, we need first to solve a problem for ``f(n-1)``, to solve the problem for ``f(n-1)`` we need to do the same for ``f(n-2)`` and so on. Always at the end we need to face so called 'base case' - ``f(0)`` or ``f(1)``, which is the most easiest subproblem. Good news is that for this problem we know a solution and  many times it is just a hard coded value.

#### Problem
Our task is to write a function ``List<String>perm(String str)`` which will return all permutations of a string given in the argument. To proceed let's think how this problem can be splitted into smaller subproblems and how to connect those problems in the recursive way.


To find a pattern we will write all permutations of following strings ``'a'``, ``'b'``, ``'c'``, ``'ab'``, ``'ac'``, ``'bc'``, ``'abc'`` 
```
perm('a')   = 'a'
perm('b')   = 'b'
perm('c')   = 'c'
perm('ab')  = 'ab', 'ba'
perm('ac')  = 'ac', 'ca'
perm('bc')  = 'bc', 'cb'
perm('abc') = 'abc', 'acb', 'bac', 'bca', 'cab', 'cba' 
```

If You have some experience in solving such puzzles You probably noticed a following pattern

```
perm('a')   = 'a'
perm('b')   = 'b'
perm('c')   = 'c'
perm('ab')  = 'a'|perm('b')  + 'b'|perm('a')
perm('ac')  = 'a'|perm('c')  + 'c'|perm('a')
perm('bc')  = 'b'|perm('c')  + 'c'|perm('b')
perm('abc') = 'a'|perm('bc') + 'b'|perm('ac') + 'c'|perm('ab')
```

where ``|`` means a concatenation of two strings.


First three cases are called 'base cases' and as I mentioned before they can be easily solved. A permutation of a string containing one character is just the same string. At this point of analysis we can now try to write a small program which will solve our problem.

### Coding

```java
    public static List<String> permute(String str) {

        if (str.length() == 1) {
            List<String> ret = new LinkedList<>();
            ret.add(str);
            return ret;
        }

        List<String> permutations = new LinkedList<>();

        for (int i = 0; i < str.length(); i++) {
            String left = "" + str.charAt(i);
            StringBuilder subStr = new StringBuilder(str);
            subStr.deleteCharAt(i);

            List<String> subPermutations = permute(subStr.toString());

            for (String perm : subPermutations) {
                permutations.add(left + perm);
            }

        }

        return permutations;
        
    }
```


```java
    public static void main(String[] args) {

        List<String> permutations = permute("abc");
        System.out.println(String.format("permutations size: %d", permutations.size()));
        for (String perm : permutations) {
            System.out.println(perm);
        }
    }

```

```
permutations size: 6
abc
acb
bac
bca
cab
cba
```
