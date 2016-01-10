---
layout: post
title: "Write to an HFS+ USB drive from a Synology NAS"
date: 2016-01-10 13:49:39 +0100
comments: true
categories: [linux,nas,mac]
---

It is realy annoying that the newest version of Synolgy DSM (```5.2-5644 Update 1```) can't handle properly ```hfs+``` hard drive device out of the box. Thanks to the fact that many users had the same problems as me before I found realy quickly handy article which shows how to make easy workaround. The trick is to disable journaling on the drive and then try to remount the device in nas with ```ro``` flag switched off. 

So to be able to write to an ```HSF+``` USB drvie you need first

* disable journaling on the drive
* connect your drive to nas
* remount device with ```ro``` flag switched off

###Disabling journaling in the drive
To be able to do this you need to plug in your device to the mac (I couldn't do this from my linux). Then to turn journaling off using ```Disk Utility``` do following:

* open ```Disk Utility``` (located in ```Applications/Utilities```).
* select the disk device to disable journaling on.
* choose ```Disable Journaling``` from the ```File``` menu.

For someone this option could not be visible (Mac OS X 10.4 and later) then before clicking on the ```File``` menu press and hold [Option](http://www.macworld.co.uk/how-to/mac/what-where-option-key-mac-3462401/) key

More you can find [here](https://support.apple.com/en-us/HT204435)

###Remount device with ro flag switched off

First log in as a root to the ds. Then have a look how the drive is mounted

```
ds> mount
/dev/sdq1 on /volumeUSB1/usbshare1-1 type vfat (utf8,umask=000,shortname=mixed,uid=1024,gid=100,quiet)
/dev/sdq2 on /volumeUSB1/usbshare1-2 type hfsplus (ro,force,uid=1024,gid=100,umask=000)
```

You can spot that the drive is mounted with the ```ro```(read only) flag. 


Now unmount the drive.

```
ds> umount -f /dev/sdq2
```

And remount so it is writable using the same info used when it was mounted automatically.

```
ds> mount -t hfsplus /dev/sdq2 /volumeUSB1/usbshare1-2
```

Finally, you can notice that device is no longer mounted as read only.

```
ds> mount
/dev/sdq1 on /volumeUSB1/usbshare1-1 type vfat (utf8,umask=000,shortname=mixed,uid=1024,gid=100,quiet)
/dev/sdq2 on /volumeUSB1/usbshare1-2 type hfsplus (0)
```

To prove this try.

```
ds> ls /volumeUSB1/usbshare1-2/ | grep 'sampleDir'
ds> mkdir /volumeUSB1/usbshare1-2/sampleDir
ds> ls /volumeUSB1/usbshare1-2/ | grep 'sampleDir'
sampleDir
```

###Note

It is very important to switch off journaling in the drive. When you remount the drive with ```ro``` switched off and haven't yet disabled the journaling in the drive you won't be able to write anything to the disk though ```mount``` will print that the drive is mounted as writable.

