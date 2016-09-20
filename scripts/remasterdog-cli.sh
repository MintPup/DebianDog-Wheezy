#!/bin/bash

# GNU GPL v3 applies. No warranty of any kind... Use it at your own risk!
# 20160611 - saintless for DebianDog. Updates from me only here: https://github.com/mintpup
# CLI script moded from RemasterDog by fredx181. Added some extra functions from apt2sfs-cli.
# The zerosize idea and function is from Jbv's FoxyRoxyLinux remastering script: http://foxyroxylinux.com
# The code contains moded parts from different scripts written for DebianDog and Puppy linux and examples in linux forums and man pages.
# My thanks to Daniel Baumann! DebianDog wouldn't exist without his work: https://lists.debian.org/debian-live/2015/11/msg00024.html


if [ -z `which bash` ]; then
echo "bash missing. Install bash and run the script again."
exit 0
fi

if [ -z `which rsync` ]; then
echo "rsync missing. Install rsync and run the script again."
exit 0
fi

if [ "$(whoami)" != "root" ]; then
echo "You have to run this script as Superuser!"
echo "Run the script again using sudo."
fi

echo "Removing configuration files left from uninstalled packages."
dpkg --purge `dpkg --get-selections | grep deinstall | cut -f1` 2> /dev/null

echo -e "\e[0;32m                    *** System Remaster ***\033[0m"
echo
echo -e " Remaster the system in new 01-filesystem.squashfs module.  "
echo

devs="$(blkid | grep /dev | grep -E -v "swap|ntfs|vfat|crypt" | sort | cut -d" " -f1 | grep -E -v "/loop|sr0|swap" | sed 's|/dev/||g' | sed 's/.$//')"
echo -e " Choose where to create the working directory and the new module. \n (must be a linux filesystem, NTFS and FAT filesystems are excluded):"
echo
echo -e "\e[0;32m    *** Unload any extra squashfs modules or they will be included! ***\033[0m"
echo -e "\e[0;32m    *** Check for enough free space first by running df -h command! ***\033[0m"
echo -e "\e[0;32m    ***       This script will not do the check for you!            ***\033[0m"
echo

echo -e "\e[0;32mAvailable options:\033[0m" $devs /tmp
###
read -p "Type the name of your choice, e.g. sda1 or /tmp: " DRV
if [ -z "$(echo "$devs /tmp" | grep -w "$DRV")" ]; then
read -p "$DRV is not available, try again: " DRV
	if [ -z "$(echo "$devs /tmp" | grep -w "$DRV")" ]; then
read -p "$DRV is not available, try again: " DRV
   if [ -z "$(echo "$devs /tmp" | grep -w "$DRV")" ]; then
echo -e "\e[0;31m$DRV is not available, please run again and type a valid name.\033[0m"
read -s -n 1 -p "Press any key to close . . ."
exit 0
   fi
	fi
fi
echo drv=$DRV

# Check for choice /tmp or drive and set new variable 'DEST' and 'SFS'
	if [ "$DRV" = "/tmp" ]; then
DEST="/tmp/work-dir"
SFS=/tmp/01-filesystem.squashfs
	else
DEST="/media/$DRV/work-dir"
SFS=/media/$DRV/01-filesystem.squashfs
mkdir "/media/$DRV" 2> /dev/null
mount /dev/$DRV /media/$DRV 2> /dev/null
	fi

# Check for existing directory.
if [ -d "$DEST" ]; then
echo -e "Directory "$DEST" already exists, \n Please rename and run again. "
read -s -n 1 -p "Press any key to close . . ."
exit 0
fi

# Check if module already exists.
if [ -f "$SFS" ]; then
echo -e "Module: "$SFS" already exists, \n Please rename and run again. "
read -s -n 1 -p "Press any key to close . . ."
exit 0
fi

mkdir $DEST/
echo -n "Copying files in $DEST/... Please, wait..."
rsync -avh --progress / $DEST --exclude=/{dev,live,lib/live/mount,cdrom,mnt,proc,sys,media,run,tmp,initrd,lost+found,persistence.conf}

mkdir -p $DEST/{dev,live,lib/live/mount,proc,run,mnt,media,sys,tmp}
cp -a /dev/console $DEST/dev
chmod a=rwx,o+t $DEST/tmp
echo ""

echo -n "Cleaning..."
rm -f $DEST/var/lib/alsa/asound.state
rm -f $DEST/root/.bash_history
rm -f $DEST/root/.xsession-errors
rm -rf $DEST/root/.cache
rm -rf $DEST/root/.thumbnails
rm -f $DEST/etc/blkid-cache
#rm -f $DEST/etc/resolv.conf #removing breaks the official resolvconf package functions.
rm -rf $DEST/etc/udev/rules.d/70-persistent*
rm -f $DEST/var/lib/dhcp/dhclient.eth0.leases
rm -f $DEST/var/lib/dhcpcd/*.lease
rm -fr $DEST/var/lib/aptitude/*
rm -fr $DEST/var/lib/dpkg/updates/tmp.i
rm -fr $DEST/var/cache/debconf/*.dat-old
rm -f $DEST/etc/blkid-cache
rm -f $DEST/etc/blkid-cache.old
rm -f $DEST/etc/blkid.tab
rm -f $DEST/etc/blkid.tab.old
rm -f $DEST/etc/machine-id
touch $DEST/etc/machine-id
rm -rf $DEST/var/cache/apt-show-versions/*
echo ""

ls $DEST/var/lib/apt/lists | grep -v "lock" | grep -v "partial" | xargs -i rm $DEST/var/lib/apt/lists/{} ;

ls $DEST/var/cache/apt/archives | grep -v "lock" | grep -v "partial" | xargs -i rm $DEST/var/cache/apt/archives/{} ;

ls $DEST/var/cache/apt | grep -v "archives" | xargs -i rm $DEST/var/cache/apt/{} ;
rm -f $DEST/var/log/* 2> /dev/null

cd $DEST

# The zerosize function is from Jbv's  FoxyRoxyLinux remastering script (http://foxyroxylinux.com):
zerosize() {
  find $* | while read file; do
    echo -n "."
    rm -f $file
    touch $file
  done
}

echo -n "Zerosizing man, doc, info..."
    zerosize usr/share/doc -type f -size +1c
    zerosize usr/share/doc -type l

    zerosize usr/share/man -type f -size +1c
    zerosize usr/share/man -type l


    zerosize usr/share/info -type f -size +1c
    zerosize usr/share/info -type l

    zerosize usr/share/gnome/help -type f -size +1c
    zerosize usr/share/gnome/help -type l

    zerosize usr/share/gtk-doc -type f -size +1c
    zerosize usr/share/gtk-doc -type l
echo ""

    chown -R man:root usr/share/man
    
  
cd ..

rm -fr $DEST/usr/share/doc/elinks
ln -sf /usr/share/doc/elinks-data $DEST/usr/share/doc/elinks

echo ###
echo "Now you can clean manually $DEST if you like."
echo "After that type 1 and press Enter to continue."
echo "Other key will skip mksquashfs command."
echo ###
echo "1)Type 1 and press Enter to continue."
echo ###

read n
case $n in
    1) mksquashfs $DEST $SFS ;;
esac


echo ###
echo "Do you want to delete $DEST ?"
echo ###
echo "1)Type 1 YES - delete $DEST"
echo "2)Type 2 NO and exit."
echo ###
echo "Type the number and press Enter."
echo ###

read n
case $n in
    1) rm -rf $DEST;;
    2) exit;;
esac
