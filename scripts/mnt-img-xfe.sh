#!/bin/bash

# 2013: mnt-img-xfe - saintless for DebianDog.
# GNU GPL v3 applies. No warranty of any kind... Use it at your own risk!
# Special xfe file manager mnt-img version. Based on mnt-img script from Terry (sunburnt). Doesn't work well with Rox.
# Click on image opens the content in xfe window. Closing the window unmounts the image and removes the mount directory.
# Using it as right click "open with mnt-img-xfe" opens the save file content (live-rw, persistence, changes.dat, debdogsave.2fs).


if [ -z `which xfe` ];then
xmessage "Xfe is missing. Install it and run the script again."
exit 0
fi

if [ -z `which gsu` ];then
[ "`whoami`" != "root" ] && x-terminal-emulator -e sudo env LD_LIBRARY_PATH=/usr/local/lib ${0} "$@"
else
[ "`whoami`" != "root" ] && exec gsu ${0} "$@"
fi

if [ -z "$1" ]; then
xmessage "usage: mnt-img-xfe path-to-file."
exit 0
fi

set -x

 imgFile="$1"
 if [ -z "$imgFile" ] ;then exit 1 ;fi
 if [ "`dirname $imgFile`" = '\.' ] ;then
  imgFile="`pwd``echo $imgFile |sed 's/^\.//'`"
 fi
 Mnt='/media/'`echo "$imgFile" |sed "s#^\.##g" |sed "s#/#+#g"`
 
  if [ ! -f $imgFile ]; then
  xmessage "The file does not exist."
  exit 1
  fi
   
 Ext=`echo "$imgFile" |sed 's/^.*\.//'`	# get file type from extention
  if [ "$Ext" = '2fs' ] ;then
   Type='ext2'
  elif [ "$Ext" = '3fs' ] ;then
   Type='ext3'
  elif [ "$Ext" = '4fs' ] ;then
   Type='ext4'
  elif [ "$Ext" = 'sfs' ] ;then
   Type='squashfs'
  elif [ "$Ext" = 'squashfs' ] ;then
   Type='squashfs'
  elif [ "$Ext" = 'dat' ] ;then
   Type='squashfs'
  elif [ "$Ext" = 'pfs' ] ;then
   Type='squashfs'  
   elif [ "$Ext" = 'iso' ] ;then
   Type='iso9660'
  fi

  mkdir -p $Mnt
  mount -o loop $imgFile $Mnt
  xfe -p n=1 $Mnt

  umount $Mnt
  Err=$?
  rmdir $Mnt

exit 0
