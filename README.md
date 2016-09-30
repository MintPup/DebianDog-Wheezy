[**My thanks to Daniel Baumann! DebianDog wouldn't exist without his work.**](https://lists.debian.org/debian-live/2015/11/msg00024.html)

DebianDog-Wheezy Jwm version development continues here.


My fellows linux developers complained [**here**](http://murga-linux.com/puppy/viewtopic.php?p=926113#926113), [**here**](http://murga-linux.com/puppy/viewtopic.php?p=926177#926177) and [**here**](http://murga-linux.com/puppy/viewtopic.php?p=926168#926168) about apt2sfs.sh script and I had to remove it. Probabaly I will remove few more today to make them happy. Seems I have to wait for their permissions unknown period of time. Or move forward writing my own version for some DebianDog scripts. I choose the second option.

It will include more and more CLI scripts in the future and less not official Wheezy packages. If you don't like command line typing better try [the OpenBox version from Fred.](https://github.com/DebianDog/Wheezy)

I plan to make some changes to make the system more responsive on very old computers and I will try to change the endless bugs fixing method used to the moment with bugs prevention method in next iso update. Starting with Wheezy first if it works well the same changes will be made also in MintPup and in all DebianDog versions maintained by me in the future.

[List of changes for next iso update you can read here.](https://github.com/MintPup/DebianDog-Wheezy/blob/master/Bugs-and-Fixes.md)

Till then you can download the latest available DebianDog-Wheezy Jwm iso version here:

https://github.com/DebianDog/Wheezy

I will get back to the starting point first building base version with only live-boot-2 (without yad, without gtkdialog, without porteus-boot scripts, without /opt directory and sh restored to dash). From this point I will try to make command line scripts for frugal and full install, sfs-load, remaster and some more working with dash. The result from this base will tell how DebianDog-Jwm and MintPup development will continue here for me.


