#!/bin/bash

# 20160926 saintless: ffmpeg2sfs CLI version for DebianDog-Wheezy.
# GNU GPL v3 applies. No warranty of any kind... Use it at your own risk!
# The code contains moded parts from different scripts written for DebianDog and Puppy linux and examples in linux forums and man pages.
# My thanks to Daniel Baumann! DebianDog wouldn't exist without his work: https://lists.debian.org/debian-live/2015/11/msg00024.html                     


if [ "$(whoami)" != "root" ]; then
echo "You have to run this script as Superuser!"
echo "Run the script again using sudo."
fi

echo
echo -e "\e[0;32m      *** ffmpeg2sfs CLI version for DebianDog-Wheezy ***\033[0m"
echo
echo -e "\e[0;32m Make ffmpeg-wheezy.squashfs module from downloaded deb packages. \033[0m"
echo -e "\e[0;32m Packages installed in save file will be excluded from the module. \033[0m"
echo -e "\e[0;32m So it is recommended to start the script without persistence.\033[0m"
echo -e "\e[0;32m To start fresh - apt-get clean - will run before downloading.\033[0m"
echo -e "\e[0;32m This module will not be registered by dpkg. \033[0m"
read -p "Do you want to continue? (y/n)?" choose
case "$choose" in
  y|Y ) echo "Continue...";;
  n|N ) exit 0;;
  * ) exit 0;;
esac

# Ping your default gateway. Source: http://stackoverflow.com/a/14939373
if ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null; then
echo "Working internet connection found."
echo
else
echo "You dont have working internet connection. Exiting now."
exit 0
fi

devs="$(blkid | grep /dev | grep -E -v "swap|ntfs|vfat" | sort | cut -d" " -f1 | grep -E -v "/loop|sr0|swap" | sed 's|/dev/||g' | sed 's/.$//')"
echo -e " Choose where to create the working directory for ffmpeg2sfs module \n (must be a linux filesystem, NTFS and FAT are excluded):"
echo

echo -e "\e[0;32mAvailable options:\033[0m" $devs
###
read -p "Type the name of your choice, e.g. sda1 or /tmp: " DRV
if [ -z "$(echo "$devs" | grep -w "$DRV")" ]; then
read -p "$DRV is not available, try again: " DRV
	if [ -z "$(echo "$devs" | grep -w "$DRV")" ]; then
read -p "$DRV is not available, try again: " DRV
   if [ -z "$(echo "$devs" | grep -w "$DRV")" ]; then
echo -e "\e[0;31m$DRV is not available, please run again and type a valid name.\033[0m"
read -s -n 1 -p "Press any key to close . . ."
exit 0
   fi
	fi
fi

echo drv=$DRV
SFS="ffmpeg-wheezy"

mkdir /media/$DRV 2> /dev/null
mount /dev/$DRV /media/$DRV 2> /dev/null
if [ -d "/media/$DRV/$SFS" ]; then
echo "/media/$DRV/$SFS already exists. Rename it and run the script again."
exit 0
fi

if [ -f "/media/$DRV/$SFS.squashfs" ]; then
echo "/media/$DRV/$SFS.squashfs already exists. Rename it and run the script again."
exit 0
fi

read -p "Do you want to run apt-get update first? (y/n)?" choose
case "$choose" in
  y|Y ) apt-get update;;
  n|N ) echo "Continue...";;
  * ) echo "Continue...";;
esac

apt-get clean
apt-get -d install -y ffmpeg

mkdir -p "/media/$DRV/$SFS"
cd /var/cache/apt/archives/ 
for arg in *.deb ; do
dpkg -x "$arg" "/media/$DRV/$SFS"
done
apt-get clean

cd "/media/$DRV/$SFS"

echo "Cleaning..."
rm -fr "/media/$DRV/$SFS"/etc
rm -fr "/media/$DRV/$SFS"/opt
rm -fr "/media/$DRV/$SFS"/root
rm -fr "/media/$DRV/$SFS"/var
rm -fr "/media/$DRV/$SFS"/usr/share/doc
rm -fr "/media/$DRV/$SFS"/usr/share/man
rm -fr "/media/$DRV/$SFS"/usr/lib/i386-linux-gnu/i686/cmov/libavcodec.so.54.59.100
rm -fr "/media/$DRV/$SFS"/usr/lib/i386-linux-gnu/i686/cmov/libavformat.so.54.29.104
ln -s /usr/lib/i386-linux-gnu/libavcodec.so.54.59.100 "/media/$DRV/$SFS"/usr/lib/i386-linux-gnu/i686/cmov/libavcodec.so.54.59.100
ln -s /usr/lib/i386-linux-gnu/libavformat.so.54.29.104 "/media/$DRV/$SFS"/usr/lib/i386-linux-gnu/i686/cmov/libavformat.so.54.29.104

cd "/media/$DRV"

mksquashfs $SFS $SFS.squashfs

echo "Done creating '/media/$DRV/$SFS.squashfs."
read -p " Do you want to remove '/media/$DRV/$SFS'? (y/n)?" choose
case "$choose" in
  y|Y ) rm -rf /media/$DRV/$SFS;;
  n|N ) exit 0;;
  * ) exit 0;;
esac

exit 0
