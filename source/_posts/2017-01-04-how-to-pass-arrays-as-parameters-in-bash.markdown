---
layout: post
title: "How To Pass Arrays As Parameters in Bash"
date: 2017-01-04 15:34:05 +0100
comments: true
categories: [bash]
---

Let's say we have a function in bash which simply iterates through all elements from array and prints them on 
the standard output. 
   
```
printElems() {
  for e in ${arr[@]}; do 
    echo $e
  done
}
```

We can call this function in the following way

```
arr=(el1 el2 el3 el4)
printElems
```

If we want to call function with other parameters we need to update arr variable accordingly

```
arr=(el1 el2 el3 el4)
printElems
arr=(el5 el6 el7 el8)
```

So far so good. But what if we want to make our printElems function generic and put it to the separate file. Is it wise 
enough to stay with our solution to maintain arr variable in global scope ? The answer is - it depends on the size of 
the project. It is obvious that maintaining global variables is cumbersome in projects which are getting bigger and 
bigger during their lifetime. So that is there any smart way to improve our function to not pollute the global scope ?

The answer is yes, and in this task will help us bash feature called 'indirect variable reference'.

Below is an improved version of ```printElem``` function. A new function~(```printElems2```) is not dealing with global 
variable at
 all. In fact the function receives a variable name and thx to the indirect reference operator ```$(!variable_name)```
 the value of the function parameter is set to local variable called ```my_arr```.
  
```
printElems2() {
  local my_arr=${!1}
  for e in ${my_arr[@]}; do 
    echo $e
  done
}
```


```
arr1=(el1 el2 el3 el4)
arr2=(el5 el6 el7 el8)

printElems2 arr1[@]
printElems2 arr2[@]

```

More information about 'indirect variable reference' feature you 
can find [here](http://www.tldp.org/LDP/abs/html/ivr.html#IVRREF)