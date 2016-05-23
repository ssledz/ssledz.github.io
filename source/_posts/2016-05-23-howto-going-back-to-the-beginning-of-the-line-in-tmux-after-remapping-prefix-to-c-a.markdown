---
layout: post
title: "Howto going back to the beginning of the line in tmux after remapping prefix to C-a"
date: 2016-05-23 02:05:54 +0200
comments: true
categories: [tmux, linux]
---

``tmux`` is a great tool. I have been using it since I think half year. 
Before I used to use ``screen``, but only to manage my remote shells. Now I am using ``tmux`` for
local and remote shell management. 

In order to make a switch from ``screen`` to ``tmux`` smooth 
I decided to remap default binding for _prefix_ from *C-b* to *C-a* (like in screen). This caused
that one of my favorite shortcuts - ``C-a`` for going back to the beginning of the line, 
stopped working. 

Recently I have discovered that making:

```
bind C-a send-prefix
```

binds the shortcut to this sequence `C-a C-a` !
