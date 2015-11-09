---
layout: post
title: "Virtual Box VDI compaction"
date: 2015-10-13 10:00:43 +0200
comments: true
categories: [virtual box, linux, virtualization]
---

Virtual Disk Image (``VDI``) files grow over time. If You discover that VDI on the host system is much bigger than used space on the guest partition it is time for compaction.

1. Install zerofree tool (``apt-get install zerofree``).
2. Remove unused files (``apt-get autoremove``, ``apt-get autoclean``, ``orphaner --guess-all``).
3. Reboot the guest system in single user mode (Grub menu will appear if you press and hold ``Shift`` during starting, 
then hit ``e`` when Grub boot appear and append ``single`` option to the Grub boot parameters).
4. Remount filesystems as readonly (``mount -n -o remount,ro -t auto /dev/sda1 /``).
5. Fill unused block with zeros (``zerofree /dev/sda1``). It’s time consuming operation. If You have other disk devices (e.g. `/dev/sda5`) then also perform ``zerofree`` on each one.
6. Shutdown the system (``poweroff``).
7. Compact VDI files on the host system (``VBoxManage modifyhd my.vdi compact``). It’s time consuming operation. 

Instead points 1,3-5 to fill free space with zeros You can do following (You don't need to boot in single user mode)

1. ``sudo dd if=/dev/zero of=/bigemptyfile bs=4096k``
2. ``sudo rm -rf /bigemptyfile``
