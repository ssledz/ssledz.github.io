---
layout: post
title: "Hot Swap in Java with DCEVM and HotSwapAgent - A JRebel free alternative"
date: 2016-05-16 22:38:40 +0200
comments: true
published: true
categories: [jvm, java, hotswap]
---

### Installing Dynamic Code Evolution VM

In order to enhance current Java (JRE/JDK) installations with **DCEVM**
you need to download the latest [release](https://dcevm.github.io/) 
of **DCEVM** installer for a given major java version 
(``java 7`` and ``java 8`` are supported),
 
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

### Hotswap Agent

Hotswap agent does the work of reloading resources and framework configuration. 
So in order to have a support for reloading a spring bean definitions just 
after a change occurs, we need to perform one more step - 
download latest release of [hotswap-agent.jar](https://github.com/HotswapProjects/HotswapAgent/releases)
and put it anywhere. For example here: ``~/bin/hotswap/hotswap-agent.jar``.

## Running application to test hot swapping

