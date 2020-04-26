---
layout: post
title: "Static linking with ghc"
date: 2020-04-26 21:21:12 +0200
comments: true
categories: [haskell, ghc]
---

In order to compile a given source code using static linking

```haskell
-- Main.hs
main = putStrLn "Hello World!"
```

there is a need to pass two additional flags to `ghc` like

* `-optl-static`
* `-optl-pthread`

```bash
$ ghc -optl-static -optl-pthread --make Main
```

then

```bash
$ file Main
Main: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked,
for GNU/Linux 3.2.0, BuildID[sha1]=62d1682f378af2f994758e737ba9dc0b24fc06aa,
with debug_info, not stripped
```