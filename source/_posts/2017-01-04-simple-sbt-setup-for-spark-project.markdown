---
layout: post
title: "Simple Sbt Setup For Spark Project"
date: 2017-01-04 18:03:14 +0100
comments: true
categories: [scala, spark]
---

Below can be found a simple sbt setup for a spark application in scala.

Directory layout
```
find .
.
./build.sbt
./src/main
./src/main/scala
./src/main/scala/pl
./src/main/scala/pl/softech
./src/main/scala/pl/softech/WordCountExample.scala
./src/main/resources
./src/main/resources/log4j.properties
./src/main/resources/words.txt

```

build.sbt
```
name := "spark-simple-app"

version := "1.0"

scalaVersion := "2.11.8"

val sparkVersion = "2.1.0"

libraryDependencies += "org.apache.spark" %% "spark-core" % sparkVersion
```
log4j.properties
```
log4j.rootCategory=ERROR, console
log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.target=System.err
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%d{yy/MM/dd HH:mm:ss} %p %c{1}: %m%n
```
WordCountExample.scala
```scala
package pl.softech

import org.apache.spark.{SparkConf, SparkContext}


object WordCountExample {

  def main(args: Array[String]) {

    val conf = new SparkConf().setAppName("spark-simple-app").setMaster("local[*]")

    val sc = new SparkContext(conf)

    val textFile = sc.textFile("src/main/resources/words.txt")

    val counts = textFile.flatMap(line => line.split(" "))
      .map(word => (word, 1))
      .reduceByKey(_ + _)
      .sortBy(-_._2)

    printf(counts.collect().mkString("\n"))

    sc.stop()
  }

}
```

Sources can be found [here](https://github.com/ssledz/ssledz.github.io-src/tree/master/spark-simple-template) 