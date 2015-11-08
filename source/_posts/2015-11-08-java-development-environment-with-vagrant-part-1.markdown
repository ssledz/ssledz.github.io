---
layout: post
title: "Java Development Environment with Vagrant - part 1"
date: 2015-11-08 16:06:35 +0100
comments: true
categories: [virtual box, linux, vagrant, dev env]
---

###Preface

This post describes my development environment driven by Vagrant. You can ask why Vagrant ? To be honest this is my first adventure with this tool. I am suprised how easy can be the process of setting brand new development environment. This tool can really save plenty of hours. 

###What is [Vagrant](https://docs.vagrantup.com/v2/why-vagrant/index.html) (based on documentation)

Vagrant provides easy to configure, reproducible, and portable work environments built on top of industry-standard technology and controlled by a single consistent workflow to help maximize the productivity and flexibility of you and your team. Sounds cool, isn't it. One can configure the whole development environment with all the tools, needed libraries and various dependencies and other can just based on that create his own brand new development environment. The Process of introducing new team members into the project can be shortened by the time of setting new development environment.

###Vagrant Providers

Vagrant has an ability to manage dozen of machine types like

* ```VirtualBox```
* ```VMware```
* ```Docker```
* ```Hyper-V```

In my setting I am using ```Virtualbox``` which is a free cross-platform consumer virtualization product supported by Oracle. To use this provider ```VirtualBox``` must be installed on its own. VirtualBox can be installed by [downloading](https://www.virtualbox.org/wiki/Downloads) a package or installer for your operating system and using standard procedures to install that package.

###Vagrant Installation

Visit the [downloads page](http://www.vagrantup.com/downloads) and get the appropriate installer or package for your platform. Then install it using standard procedures for your operating system. The installer will automatically add ```vagrant``` to your system path so that it is available in terminals. 

###Setting development environment

To set up java development environment You need just type the following bunch of commands
```
git clone git@github.com:ssledz/vagrant-boxes.git
cd vagrant-boxes/java-dev-environment
vagrant up
```

To loggin to the machine do
```
vagrant ssh
```

To check what can You find in this environment please visit this [page](https://github.com/ssledz/vagrant-boxes/tree/master/java-dev-environment).

More about how to use this setting to develop in the next post.
