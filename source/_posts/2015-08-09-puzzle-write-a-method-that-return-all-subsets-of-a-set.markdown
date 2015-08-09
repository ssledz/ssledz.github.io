---
layout: post
title: "Puzzle - Write a method that return all subsets of a set"
date: 2015-08-09 21:52:26 +0200
comments: true
categories: [puzzle,recursion,algorithms,java] 
---
###Problem
Write a method ``public static Set<Set<String>> subsets(Set<String> set)`` which returns all subsets of a given set. From mathematics point of view we need to compute the power set of the given set. The number of such subsets can be easily computed because it just 2 to the power of 'number of element in a set'. So for a set consisting of ``3`` elements it is 8.  To proceed let's write some examples.
```
subsets({'a'}) = {} + {'a'}
subsets({'b'}) = {} + {'b'}
subsets({'c'}) = {} + {'c'}

subsets({'b','c'}) = {} + {'b'} + {'c'} + {'b','c'}
subsets({'a','c'}) = {} + {'a'} + {'c'} + {'a','c'}
subsets({'a','b'}) = {} + {'a'} + {'b'} + {'a','b'}

subsets({'a', 'b', 'c'}) = {} + {'a'} + {'a','b'} + {'a','c'} + {'a','b','c'} + {'b'} + {'b','c'} + {'c'}
```

Based on that we can notice a following pattern
```
subset('a')            = {}, {'a'}
subset('b')            = {}, {'b'}
subset('c')            = {}, {'c'}
subsets({'b','c'})     = subset({'b'}) + subset({'c'}) + {'b','c'}
subsets({'a','c'})     = subset({'a'}) + subset({'c'}) + {'a','c'}
subsets({'a','b'})     = subset({'a'}) + subset({'b'}) + {'a','b'}
subsets({'a','b','c'}) = subsets({'b','c'}) + subsets({'a','c'}) + subsets({'a','b'}) + {'a','b','c'}
```
###Coding
```java
    public static Set<Set<String>> subsets(Set<String> set) {

        if (set.size() == 1) {
            Set<Set<String>> ret = new HashSet<>();
            ret.add(new HashSet<>());
            ret.add(new HashSet<>(set));
            return ret;
        }

        Set<Set<String>> ret = new HashSet<>();
        ret.add(set);

        for (String e : set) {

            Set<String> newSet = new HashSet<>(set);
            newSet.remove(e);
            Set<Set<String>> subsets = subsets(newSet);
            ret.addAll(subsets);

        }
        return ret;

    }
```

```
    public static void main(String[] args) {
        Set<String> set  = new HashSet<>(Arrays.asList("a", "b", "c", "d"));

        Set<Set<String>> subs = subsets(set);
        System.out.println("size: " + subs.size());
        for(Set<String> sub : subs) {
            System.out.println(sub.toString());
        }
    }
```

```
size: 16
[]
[a]
[b]
[c]
[a, b]
[d]
[a, c]
[b, c]
[a, d]
[b, d]
[a, b, c]
[c, d]
[a, b, d]
[a, c, d]
[b, c, d]
[a, b, c, d]
```
