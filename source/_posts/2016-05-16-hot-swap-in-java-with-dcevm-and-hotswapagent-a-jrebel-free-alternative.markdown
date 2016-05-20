---
layout: post
title: "Hot Swap in Java with DCEVM and HotSwapAgent - A JRebel free alternative"
date: 2016-05-16 22:38:40 +0200
comments: true
published: true
categories: [jvm, java, hotswap]
---

Reloading a bytecode in a virtual machine when application is running is very limited. In fact 
HotSpot(TM) VM allows only changing method bodies. To address this problem some commercial and open source tools were 
created. Among them is _Dynamic Code Evolution Virtual Machine_ (**DCEVM**) and 
**HotSwapAgent** - very promising open source tool.

I have already some experience in using **DCEVM**. Some times ago I have been working for an insurance company where 
I was using this modified vm to develop a code in a gosu language. [Gosu](https://gosu-lang.github.io/) is another 
JVM language. I remember that then hot swapping worked very well.
  
Let's try this tool. First we need to patch our current jvm.

### Installing Dynamic Code Evolution VM

In order to enhance current Java (JRE/JDK) installations with **DCEVM**
you need to download the latest [release](https://dcevm.github.io/) 
of **DCEVM** installer for a given major java version,

> ``java 7`` and ``java 8`` are supported
 
run the installer
  
```
java -jar DCEVM-light-8u74-installer.jar
```

then select a proper java installation directory on your disc and press _Install DCEVM as altjvm_
 
{% img center /images/custom/dcevm-installer.png %}

That's all really. Very simple isn't it ? 

To validate the installation run:

```
java -version
```

and if everything went alright you should see something similar to below
output:

```
java version "1.8.0_91"
Java(TM) SE Runtime Environment (build 1.8.0_91-b14)
Dynamic Code Evolution 64-Bit Server VM (build 25.71-b01-dcevmlight-10, mixed mode)
```

Note that in the third line instead of ``Java HotSpot(TM)`` we have 
now ``Dynamic Code Evolution``. 

#### Kind of installers
Worth noting is the fact that there are two kind of installers

 * _light_
 * and _full_
  
The latter one supports more features (for example, it supports removal of superclasses),
but because of the maintenance issues the _full_ edition is available 
for a fewer versions of jdk.

### Downloading HotswapAgent

HotswapAgent does the work of reloading resources and framework configuration. 
So in order to have a support for reloading a spring bean definitions just 
after a change occurs, we need to perform one more step - 
download latest release of [hotswap-agent.jar](https://github.com/HotswapProjects/HotswapAgent/releases)
and put it anywhere. For example here: ``~/bin/hotswap/hotswap-agent.jar``.

## Running application in order to test hot swapping

I will use following piece of code to play with hot swapping:  

```java
public class Main {
    
    static class Foo {
        int counter;

        void foo() {
            System.out.println("foo - " + counter);
            counter++;
        }
    }

    static Foo foo = new Foo();

    static int counter = 0;

    static void mainLoop() {
        System.out.printf("tick - %d\n", counter++);
        foo.foo();
    }

    public static void main(String[] args) throws InterruptedException {
        while (true) {
            mainLoop();
            Thread.sleep(2000);
        }
    }
}
```

I will test following use cases:

|---------|------------------|------------|
|         | case             | supports ? |
|:--------|:-----------------|:----------:|
|**1.**   |change body method| YES        |
|**2.**   |add method        | YES        |
|**3.**   |remove method     | YES        |
|**4.**   |add field         | YES        |
|**5.**   |remove field      | YES        |
|---------|------------------|------------|

### Intellij IDEA settings

All tests will be performed using Intellij IDEA. Ensure that following options are set

* enable [classes reloading](https://www.jetbrains.com/help/idea/2016.1/reloading-classes.html?origin=old_help)

{% img center /images/custom/idea/dcevm-hotswap-settings.png %}

* pass ``-XXaltjvm=dcevm`` vm option to run/debug configuration

{% img center /images/custom/idea/dcevm-run-dbg-conf.png %}

### Case 1 : change body method

### Case 2 : add method

### Case 3 : remove method

### Case 4 : add field

### Case 5 : remove field

## Resources

* [DCEVM](https://dcevm.github.io/)
* [HotswapAgent Quick start](http://www.hotswapagent.org/quick-start)
* [HotswapProjects](https://github.com/HotswapProjects)
* [Hotswap/DCEVM doesn't work in Intellij IDEA (Community Version)](http://stackoverflow.com/questions/32507900/hotswap-dcevm-doesnt-work-in-intellij-idea-community-version)
* [Using DCEVM and Hotswap for rapid turnaround](https://wiki.wocommunity.org/display/WOL/Using+DCEVM+and+Hotswap+for+rapid+turnaround)