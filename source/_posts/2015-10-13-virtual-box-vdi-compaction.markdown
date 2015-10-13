---
layout: post
title: "Virtual Box VDI compaction"
date: 2015-10-13 10:00:43 +0200
comments: true
categories: [virtual box, linux]
---

Virtual Disk Image (``VDI``) files grow over time. If You discover that VDI on the host system is much bigger than used space on the guest partition it is time for compaction.

1. Install zerofree tool (``apt-get install zerofree``).
2. Remove unused files (``apt-get autoremove``, ``apt-get autoclean``, ``orphaner --guess-all``).
3. Reboot the guest system in single user mode (hit e during Grub boot and append single option to the Grub boot parameters).
4. Remount filesystems as readonly (``mount -n -o remount,ro /``).
5. Fill unused block with zeros (``zerofree /``). It’s time consuming operation.
6. Shutdown the system (``poweroff``).
7. Compact VDI files on the host system (``VBoxManage modifyhd my.vdi compact``). It’s time consuming operation. 
