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

I will use ``Main`` and ``Main2`` classes to play with hot swapping:  

```java
public class Main {

    static class Foo {
        int counter;

        void foo() {
            System.out.printf("foo - %08d", counter);
            counter++;
        }
    }

    static Foo foo = new Foo();

    static int counter = 0;

    static void mainLoop() {
        System.out.printf("tick - %08d\t", counter++);
        foo.foo();
        System.out.println();
    }

    public static void main(String[] args) throws InterruptedException {
        while (true) {
            mainLoop();
            Thread.sleep(2000);
        }
    }
}
```

And the second one:

```java
public class Main2 {

    static class Foo {

    }

    static void mainLoop() {

        String fields = Stream.of(Foo.class.getFields())
                .map(f -> f.getName())
                .collect(Collectors.joining(",", "[", "]"));
        String methods = Stream.of(Foo.class.getDeclaredMethods())
                .map(m -> m.getName())
                .collect(Collectors.joining(",", "[", "]"));

        System.out.printf("fields=%s\t methods=%s\n", fields, methods);

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

|---------|------------------|------------|----------|
|         | case             | works ?    |Test class|
|:--------|:-----------------|:----------:|:---------|
|**1.**   |change body method| YES        |Main      |
|**2.**   |add method        | YES        |Main      |
|**3.**   |add field         | YES        |Main      |
|**4.**   |remove field      | YES        |Main2     |
|**5.**   |remove method     | YES        |Main2     |
|---------|------------------|------------|----------|

### Intellij IDEA settings

All tests will be performed using Intellij IDEA. Ensure that following options are set

* enable [classes reloading](https://www.jetbrains.com/help/idea/2016.1/reloading-classes.html?origin=old_help)

{% img center /images/custom/idea/dcevm-hotswap-settings.png %}

* pass ``-XXaltjvm=dcevm`` vm option to run/debug configuration

{% img center /images/custom/idea/dcevm-run-dbg-conf.png %}

### Case 1 : change body method

Run debug. In the console you should see following output:

```
tick - 00000000	foo - 00000000
tick - 00000001	foo - 00000001
tick - 00000002	foo - 00000002
tick - 00000003	foo - 00000003
```

Then change ``counter++;`` to ``counter+=2;`` in ``Foo`` class.
 
```java
static class Foo {
    int counter;

    void foo() {
        System.out.printf("foo - %08d", counter);
        counter+=2;
    }
}
```

Hit `<ctr>+<shift>+<F9>` to compile and after few seconds you should spot that the classes were reloaded successfully

```
tick - 00000004	foo - 00000004
tick - 00000005	foo - 00000006
tick - 00000006	foo - 00000008
```

### Case 2 : add method

Revert all changes in ``Main`` class and run debug. Add method

```java
void bar() {
    System.out.printf("\tbar - %08d", counter);
}
```

to the ``Foo`` class and call it from the ``mainLoop``
 
```java
static void mainLoop() {
    System.out.printf("tick - %08d\t", counter++);
    foo.foo();
    foo.bar();
    System.out.println();
}
```


Hit `<ctr>+<shift>+<F9>` to compile.

```
tick - 00000003	foo - 00000003
tick - 00000004	foo - 00000004
tick - 00000005	foo - 00000005	bar - 00000006
tick - 00000006	foo - 00000006	bar - 00000007
tick - 00000007	foo - 00000007	bar - 00000008
```

Classes were reloaded successfully.

### Case 3 : add field

Revert all changes in ``Main`` class and run debug. Add field ``int counter2`` to ``Foo`` class and append following
two statements to the end of ``foo`` method.

```java
System.out.printf("\tcounter2 - %08d", counter2);
counter2++;
```

``Foo`` class should look following

```java
static class Foo {
    int counter;

    int counter2;

    void foo() {
        System.out.printf("foo - %08d", counter);
        counter++;
        System.out.printf("\tcounter2 - %08d", counter2);
        counter2++;
    }
}
```

Hit `<ctr>+<shift>+<F9>` to compile. And appears

```
tick - 00000002	foo - 00000002
tick - 00000003	foo - 00000003
tick - 00000004	foo - 00000004	counter2 - 00000000
tick - 00000005	foo - 00000005	counter2 - 00000001
tick - 00000006	foo - 00000006	counter2 - 00000002
```

that this kind of change was also reloaded successfully.

### Case 4 : remove field

Run debug. In the console you should see following output:

```
fields=[]	 methods=[]
fields=[]	 methods=[]
fields=[]	 methods=[]
```

Then add two public fields ``int number`` and ``String name`` to the ``Foo`` class.

```java
static class Foo {
    public int number;
    public String name;
}
```

Hit `<ctr>+<shift>+<F9>` to compile, and after few seconds...

```
fields=[]	 methods=[]
fields=[number,name]	 methods=[]
fields=[number,name]	 methods=[]
```

Then remove ``number`` field and hit again `<ctr>+<shift>+<F9>`.

```
fields=[number,name]	 methods=[]
fields=[name]	 methods=[]
fields=[name]	 methods=[]
```

The change was reloaded.

### Case 5 : remove method

Revert all changes in ``Main2`` class and run debug. Add
 
* public field ``String name`` 
* public method ``String getName()``
 
to the ``Foo`` class. Then hit `<ctr>+<shift>+<F9>` to compile, and after few seconds...

```
fields=[]	 methods=[]
fields=[name]	 methods=[getName]
fields=[name]	 methods=[getName]
```
 
Then remove ``getName()`` method and hit again `<ctr>+<shift>+<F9>`.

```
fields=[name]	 methods=[getName]
fields=[name]	 methods=[]
fields=[name]	 methods=[]
```
 
Seems that this change was also reloaded successfully. 

## Notes
 
During the play with hot swapping in Intellij IDEA you could notice that for some circumstances code would not be 
reloaded. Intellij IDEA has a following limitation about which you need to be aware:

> the old code is still used until the VM exits the obsolete stack frame

About that you can read [here](http://stackoverflow
.com/questions/32507900/hotswap-dcevm-doesnt-work-in-intellij-idea-community-version)
 
## Resources

* [DCEVM](https://dcevm.github.io/)
* [HotswapAgent Quick start](http://www.hotswapagent.org/quick-start)
* [HotswapProjects](https://github.com/HotswapProjects)
* [Hotswap/DCEVM doesn't work in Intellij IDEA (Community Version)](http://stackoverflow.com/questions/32507900/hotswap-dcevm-doesnt-work-in-intellij-idea-community-version)
* [Using DCEVM and Hotswap for rapid turnaround](https://wiki.wocommunity.org/display/WOL/Using+DCEVM+and+Hotswap+for+rapid+turnaround)