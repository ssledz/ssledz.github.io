---
layout: post
title: "Java Development Environment with Vagrant - part 1"
date: 2015-11-08 16:06:35 +0100
comments: true
categories: [virtual box, linux, vagrant, virtualization, productivity]
---

###Preface

This post describes my development environment driven by Vagrant (Full description what can be found there is [here](https://github.com/ssledz/vagrant-boxes/tree/master/java-dev-environment)). You can ask why Vagrant ? To be honest this is my first adventure with this tool. I am suprised how easy can be the process of setting brand new development environment. This tool can really save plenty of hours. 

###What is [Vagrant](https://docs.vagrantup.com/v2/why-vagrant/index.html) (based on documentation)

Vagrant provides easy to configure, reproducible, and portable work environments built on top of industry-standard technology and controlled by a single consistent workflow to help maximize the productivity and flexibility of you and your team. Sounds cool, isn't it? One can configure the whole development environment with all the tools, needed libraries and various dependencies and other can just based on that create his own brand new development environment. The Process of introducing new team members into the project can be shortened by the time of setting new development environment.

###Vagrant Providers

Vagrant has an ability to manage some of machine types like

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

Now vagrant box image is downloading from the box repository and then installation script ```provision.sh``` will be called. 

The ```provision.sh``` trace can look following
```
==> default: Creating directories
==> default:     Creating bin directory
==> default:     Creating public_html directory
==> default:     Creating servers directory
==> default: Installing packages
==> default:     apt-get update
==> default:     Installing vim
==> default:     Installing git
==> default: Installing mc
==> default:     Installing libssl-dev libreadline-dev zlib1g-dev
==> default:     Installing make g++
==> default:     Installing apg
==> default:     Installing mysql-server
==> default:         Creating /etc/mysql/conf.d/utf8_charset.cnf
==> default:         Restarting mysql
==> default:     Installing nginx-core ssl-cert
==> default:         Creating /etc/nginx/sites-available/public_html
==> default:         Enabling /etc/nginx/sites-available/public_html
==> default:         Restarting nginx
==> default: Downloading jdks
==> default:     jdk-5u22-linux-x64.tar.gz is available
==> default:     jdk-6u45-linux-x64.tar.gz is available
==> default:     jdk-7u80-linux-x64.tar.gz is available
==> default:     jdk-8u65-linux-x64.tar.gz is available
==> default: Installing jdks
==> default:     Extracting jdk-5u22-linux-x64.tar.gz
==> default:     Extracting jdk-6u45-linux-x64.tar.gz
==> default: Extracting jdk-7u80-linux-x64.tar.gz
==> default:     Extracting jdk-8u65-linux-x64.tar.gz
==> default:     Cleaning
==> default: Installing apache-maven
==> default:     Downloading apache-maven-3.3.3-bin.tar.gz
==> default:     Extracting apache-maven-3.3.3-bin.tar.gz using tar
==> default:     Cleaning
==> default:     Creating symbolic link apache-maven
==> default: Installing apache-ant
==> default:     Downloading apache-ant-1.9.6-bin.tar.gz
==> default:     Extracting apache-ant-1.9.6-bin.tar.gz using tar
==> default:     Cleaning
==> default:     Creating symbolic link apache-ant
==> default: Installing gradle
==> default:     Downloading gradle-2.8-bin.zip
==> default:     Extracting gradle-2.8-bin.zip using unzip
==> default:     Cleaning
==> default:     Creating symbolic link gradle
==> default: Installing sbt
==> default:     Downloading sbt-0.13.9.tgz
==> default:     Extracting sbt-0.13.9.tgz using tar
==> default:     Cleaning
==> default:     Creating symbolic link sbt
==> default: Installing environment managers (for Java, Ruby, node.js and Python) 
==> default:     Installing jenv
==> default:         Clonning from github to ~/.jenv
==> default:         Setting environment variables
==> default:         Make build tools jenv aware
==> default:             ant plugin activated
==> default:             maven plugin activated
==> default:             gradle plugin activated
==> default:             sbt plugin activated
==> default:     Installing rbenv
==> default:         Clonning from github to ~/.rbenv
==> default:         Installing plugins that provide rbenv install
==> default:     Installing nodenv
==> default:         Clonning from github to ~/.nodenv
==> default:         Installing plugins that provide nodenv install
==> default:     Installing pyenv
==> default:         Clonning from github to ~/.pyenv
==> default: Updating .bashrc
==> default: Install runtimes using environment managers
==> default:     Install java
==> default:     Set jdk 1.8 globally
==> default:     Install ruby
==> default:     Install node.js
==> default:     install python
==> default: Installing apache-tomcat
==> default:     Downloading apache-tomcat-8.0.28.tar.gz
==> default:     Extracting apache-tomcat-8.0.28.tar.gz using tar
==> default:     Cleaning
==> default:     Creating symbolic link apache-tomcat
==> default:     Creating apache-tomcat /bin/setenv.sh
==> default:     Copying tomcat-users.xml to apache-tomcat/conf
==> default:     Creating /etc/init.d/tomcat script
==> default:     Starting tomcat
```


To loggin to the machine do
```
vagrant ssh
```

To check what can You find in this environment please visit this [page](https://github.com/ssledz/vagrant-boxes/tree/master/java-dev-environment).

More about how to use this setting to develop in the next post.
