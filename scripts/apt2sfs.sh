#!/bin/bash

# april 12 2015 apt2sfs version 1.0.4, Fred: added /tmp and / to the choice of where to create working dir and module.
#
# 20160918 saintless - GNU GPL v3 applies. No warranty of any kind... Use it at your own risk!
#          Changed xz compression to gzip, "xmessage" to "echo", "xterm" to "x-terminal-emulator".
#          xhost +local: runs only in X session now. Workaround for suid-root problem running as user from coonsole.
#          Fix in case remastering with resolvconf package. Information about the author of zerosize idea and function. 
#          Name changed from apt2sfs-cli-fullinst to apt2sfs. Updates from me only here: https://github.com/mintpup
#          My thanks to Daniel Baumann! DebianDog wouldn't exist without his work: https://lists.debian.org/debian-live/2015/11/msg00024.html
#
# Depends: x11-utils, x11-xserver-utils, findutils, unionfs-fuse, coreutils, mount, procps, sed, squashfs-tools, apt, x-terminal-emulator

sudo -K

if [[ `pstree | grep xinit` ]]; then
echo "Active X session."
   if [ -z `which gsu` ]; then
if [ "`whoami`" != "root" ]; then tty -s; if [ $? -ne 0 ]; then exec x-terminal-emulator -e sudo x-terminal-emulator -e "$0" "$@"; exit; else exec sudo x-terminal-emulator -e "$0" "$@"; exit; fi; else tty -s; if [ $? -ne 0 ]; then exec x-terminal-emulator -e "$0" "$@"; exit; fi; fi
   else
if [ "`whoami`" != "root" ]; then tty -s; if [ $? -ne 0 ]; then exec gsu x-terminal-emulator -e "$0" "$@"; exit; else exec sudo x-terminal-emulator -e "$0" "$@"; exit; fi; else tty -s; if [ $? -ne 0 ]; then exec x-terminal-emulator -e "$0" "$@"; exit; fi; fi
   fi 
   
   exe=$(basename $0)

sudopid="$(ps -eo pid,cmd | grep -w "sudo $exe\|sudo $SUDO_COMMAND" | grep -v grep | grep -v "sudo x-terminal-emulator" | grep -v "sudo -S" | awk '{ print $1 }')"
echo $sudopid
[ "$sudopid" ] && echo -e "\e[0;33mPlease run without sudo, e.g. $SUDO_COMMAND,\nExiting now...\033[0m" && exit

else   #20160918 saintless - it doesn't work from console as user without this:
echo "No active X session."
if [ "`whoami`" != "root" ]; then tty -s; if [ $? -ne 0 ]; then exec "$0" "$@"; exit; else exec sudo "$0" "$@"; exit; fi; else tty -s; if [ $? -ne 0 ]; then exec "$0" "$@"; exit; fi; fi 
fi

if [ -z `which unionfs-fuse` ]; then
echo "You don't have unionfs-fuse installed. Please install it first."
exit 0
fi

echo
echo -e "\e[0;32m                         *** apt2sfs ***\033[0m"
echo -e "  Create module from temporary installed package(s) by apt-get. \n Note: These packages will not be registered by dpkg.  \n Depending on the sort of application(s) it may work or not. \n For example an application depending on startup at boot will not work. \n The package(s) will be installed in chroot using 'unionfs-fuse'. \n (but in fact directly into binded write/working directory). \n To make sure there are no traces left behind in the actual running system. "
echo

devs="$(blkid -o list | grep /dev | grep -E -v "swap|ntfs|vfat|crypt" | sort | cut -d" " -f1 | grep -E -v "/loop|sr0|swap" | sed 's|/dev/||g')"
echo -e " Choose where to create the working directory and the new module. \n (must be a linux filesystem, NTFS and FAT filesystems are excluded):"


echo -e "\e[0;33mAvailable options:\033[0m" $devs /tmp /
read -p "Type the name of your choice, e.g. sda1, /tmp or /: " DRV
if [ -z "$(echo "$devs /tmp /" | grep -w "$DRV")" ]; then
read -p "$DRV is not available, try again: " DRV
	if [ -z "$(echo "$devs /tmp /" | grep -w "$DRV")" ]; then
read -p "$DRV is not available, try again: " DRV
   if [ -z "$(echo "$devs /tmp /" | grep -w "$DRV")" ]; then
echo -e "\e[0;31m$DRV is not available, please run again and type a valid name.\033[0m"
read -s -n 1 -p "Press any key to close . . ."
exit 0
   fi
	fi
fi
echo drv=$DRV

read -p "Type package name(s), if multiple, separated by a space: " INSTALL
echo

# Function to cleanly unmount if the script is interrupted
exitfn () {
    trap SIGINT              # Resore signal handling for SIGINT
cmd="apt-get install -y --force-yes $INSTALL"
pdapt="`ps -eo pid,cmd | grep -v grep | grep "$cmd" | awk '{ print $1 }'`"
kill $pdapt 2> /dev/null
echo -e "\e[0;31mRestoring now, script was interrupted.\033[0m"
	if [ "$UNIONCREATED" = "yes" ]; then
# Unmount everything
#umount "$UNION"/tmp 2> /dev/null
umount "$UNION"/proc 2> /dev/null
umount "$UNION"/dev/pts 2> /dev/null
umount "$UNION"/dev 2> /dev/null
umount "$UNION"/sys 2> /dev/null
umount "$UNION" 2> /dev/null
umount "$CHROOTFS"
   if [ "$?" -ne 0 ]; then # Try the -l umount option (lazy) in this case
echo "Try to gently force unmounting of $UNION..."
umount -l "$UNION"/tmp 2> /dev/null
umount -l "$UNION"/proc 2> /dev/null
umount -l "$UNION"/dev/pts 2> /dev/null
umount -l "$UNION"/dev 2> /dev/null
umount -l "$UNION"/sys 2> /dev/null
umount -l "$UNION" 2> /dev/null
umount -l "$CHROOTFS" 2> /dev/null
# As last resort use brute force in this (rare) case
[ "$?" -ne 0 ] && killall unionfs-fuse 2> /dev/null; echo "Forced unmounting of $UNION"
rmdir "$UNION" 2> /dev/null
rmdir "$CHROOTFS" 2> /dev/null 
[ "$?" -eq 0 ] && echo -e "\e[0;32mSuccesfully unmounted and cleaned up!\033[0m"
   else
rmdir "$UNION" 2> /dev/null
rmdir "$CHROOTFS" 2> /dev/null
[ "$?" -eq 0 ] && echo -e "\e[0;32mSuccesfully unmounted and cleaned up!\033[0m"
   fi
rm -rf /.unionfs 2> /dev/null
	fi

# Remove working directory and module
  if [ -f "$SQFS" ]; then
	if [[ -n "$SFS" && -n "$DRV" ]]; then
	rm -rf "$WORK"
	rm -f "$SQFS"
if [ "$?" -eq 0 ]; then 
echo "Script was interrupted. Directory $WORK has been removed. Module $SQFS has been removed. "
fi
	fi
   else
	if [[ -n "$SFS" && -n "$DRV" ]]; then
	rm -rf "$WORK"
if [ "$?" -eq 0 ]; then 
echo "Script was interrupted. Directory $WORK has been removed. Module $SQFS not created. "
fi
	fi
   fi
exit 0
}
export -f exitfn

trap "exitfn" 1 2 15           # Set up SIGINT trap to call function 'exitfn'.

restore() {
# Unmount everything
#umount "$UNION"/tmp
umount "$UNION"/proc
umount "$UNION"/dev/pts
umount "$UNION"/dev
umount "$UNION"/sys
umount "$UNION"
umount "$CHROOTFS"
   if [ "$?" -ne 0 ]; then # Try the -l umount option (lazy) in this case
echo "Try to gently force unmounting of $UNION..."
#umount -l "$UNION"/tmp 2> /dev/null
umount -l "$UNION"/proc 2> /dev/null
umount -l "$UNION"/dev/pts 2> /dev/null
umount -l "$UNION"/dev 2> /dev/null
umount -l "$UNION"/sys 2> /dev/null
umount -l "$UNION" 2> /dev/null
umount -l "$CHROOTFS" 2> /dev/null
# As last resort use brute force in this (rare) case
[ "$?" -ne 0 ] && killall unionfs-fuse && echo "Forced unmounting of $UNION"
rmdir "$UNION"
rmdir "$CHROOTFS"
[ "$?" -eq 0 ] && echo -e "\e[0;32mSuccesfully unmounted and cleaned up!\033[0m"
   else
rmdir "$UNION" 2> /dev/null
rmdir "$CHROOTFS" 2> /dev/null
[ "$?" -eq 0 ] && echo -e "\e[0;32mSuccesfully unmounted and cleaned up!\033[0m"
   fi
rm -rf /.unionfs 2> /dev/null

sleep 2
kill $pd 2> /dev/null

   if [ -f "$WORK/tmp/_exit" ]; then
	if [[ -n "$SFS" && -n "$DRV" ]]; then
	rm -rf "$WORK"
[ "$?" -eq 0 ] && echo -e "\e[0;32mDirectory $WORK has been removed.\033[0m"
	fi
read -s -n 1 -p "Press any key to close . . ."
	exit
   fi
}
export -f restore

check_network() {
echo -e "\e[0;36mChecking network connection...\033[0m"
if ping -c1 google.com 2>&1 | grep unknown; then 
echo -e "\e[0;33mThere is no network connection. Exiting...\033[0m"
sleep 3
touch /tmp/_exit
else
echo -e "\e[0;32mOK\033[0m"
sleep 1
fi
}
export -f check_network

update_repo() {
echo -e "\e[0;36mUpdating package lists...\033[0m"
apt-get update
ret=$?
if [[ $ret -eq 100 ]]; then
[ "$?" -eq 0 ] && echo -e "\e[0;33m There are one or more errors with updating. \n Check your /etc/apt/sources.list.\033[0m"
read -p "Still continue? (Y/n)?" choice

case "$choice" in 
  y|Y|"")
echo -e "\e[0;32mOK, Continue\033[0m"
;;
  n|N)
touch /tmp/_exit
exit 0
;;
*)
echo -e "\e[0;31mNot a valid choice, exiting....\033[0m"
touch /tmp/_exit
exit 0
;;
esac
else
echo -e "\e[0;32mOK\033[0m"
sleep 1
fi
}
export -f update_repo

install_packages() {
echo -e "\e[0;36mInstalling to working directory: $SFS\033[0m"
sleep 1
# Install the packages.
apt-get install -y --force-yes $INSTALL
ret=$?
if [ "$ret" -eq 100 ]; then
touch /tmp/_exit
fi
}
export -f install_packages


export SFS=$(for i in "$INSTALL"; do echo $(echo $i | sed 's| |_|g'); done)
echo $SFS

# Check for choice /tmp, / or drive and set new variable 'WORK' and 'SQFS'
	if [ "$DRV" = "/tmp" ]; then
WORK="/tmp/$SFS"
SQFS="/tmp/$SFS".squashfs
	elif [ "$DRV" = "/" ]; then
WORK="/$SFS"
SQFS="/$SFS".squashfs
	else
WORK="/mnt/$DRV/$SFS"
SQFS="/mnt/$DRV/$SFS".squashfs
mkdir "/mnt/$DRV" 2> /dev/null
mount /dev/$DRV /mnt/$DRV 2> /dev/null
	fi

# Check for existing directory.
if [ -d "$WORK" ]; then
echo -e "Directory "$WORK" already exists, \n Please rename and run again. "
read -s -n 1 -p "Press any key to close . . ."
exit 0
fi

# Check if module already exists.
if [ -f "$SQFS" ]; then
echo -e "Module: "$SQFS" already exists, \n Please rename and run again. "
read -s -n 1 -p "Press any key to close . . ."
exit 0
fi

export INSTALL=$INSTALL

# Setup temp directories for mounting
export UNION=/mnt/unionsfs_$RANDOM; mkdir -p "$UNION"
WRITE="$WORK"; mkdir -p "$WRITE"

echo -e "\e[0;36mMount bind the main module, prepare the chroot.\033[0m"
export CHROOTFS=/mnt/chrootfs_$RANDOM; mkdir "$CHROOTFS" 
mount --bind / "$CHROOTFS"
unionfs-fuse -o nonempty -o allow_other,suid,dev -o cow "$WRITE"=RW:"$CHROOTFS"=RO "$UNION" 2> /dev/null
if [ $? -eq 0 ]; then 
echo -e "\e[0;32mOK\033[0m"
sleep 1
else
echo -e "\e[0;31mSorry, something went wrong, exiting...\033[0m"
rmdir "$UNION"
rmdir "$WRITE"
umount "$CHROOTFS"
rmdir "$CHROOTFS"
exit 0
fi

UNIONCREATED=yes
echo -e "\e[0;36mCopy /etc/resolv.conf to provide network connection.\033[0m"
rm -f $UNION/etc/resolv.conf && touch $UNION/etc/resolv.conf #20160918 saintless - without this the script fails after remaster with official resolvconf package. The touch command could be removed. Should work without it.
echo -en "`cat /etc/resolv.conf`" > $UNION/etc/resolv.conf
#cp -a /etc/resolv.conf $UNION/etc/
[ $? -eq 0 ] && echo -e "\e[0;32mOK\033[0m"
sleep 1
echo -e "\e[0;36mDo the required mount binds for chroot.\033[0m"
# Do the required mount binds for chroot
mount --bind /proc "$UNION"/proc
mount --bind /tmp "$UNION"/tmp
mount --bind /dev "$UNION"/dev
mount --bind /sys "$UNION"/sys
mount -t devpts devpts "$UNION"/dev/pts
[ $? -eq 0 ] && echo -e "\e[0;32mOK\033[0m"
sleep 1
#xhost +local:

if [[ `pstree | grep xinit` ]]; then
echo "Active X session."
xhost +local:                           # 20160918 saintless - dont run this from console
else
echo "No active X session."
fi

chroot "$UNION" /bin/bash -c check_network
[ -f "$UNION"/tmp/_exit ] && echo -e "\e[0;31mRestoring now, there were errors\033[0m" && restore 
chroot "$UNION" /bin/bash -c update_repo
[ -f "$UNION"/tmp/_exit ] && echo -e "\e[0;31mRestoring now, there were errors\033[0m" && restore 
chroot "$UNION" /bin/bash -c install_packages
[ -f "$UNION"/tmp/_exit ] && echo -e "\e[0;31mRestoring now, there were errors\033[0m" && restore 

sleep 2

restore

cd "$WORK"

echo -e "\e[0;36mCleaning... (removing and zerosizing files in working-directory: $SFS)\033[0m"
rm -f "$WORK"/etc/menu.old 
rm -f "$WORK"/var/lib/alsa/asound.state
rm -rf "$WORK"/dev
rm -rf "$WORK"/tmp
rm -rf "$WORK"/var/cache
rm -rf "$WORK"/var/log
rm -rf "$WORK"/.unionfs
#rm -rf "$WORK"/run
find "$WORK"/var/lib/dpkg -maxdepth 1 ! -name info ! -name available ! -name status ! -name dpkg -exec rm -rf {} \;
mv -f "$WORK"/var/lib/dpkg/info "$WORK"/var/lib/dpkg/infonew
mv -f "$WORK"/var/lib/dpkg/available "$WORK"/var/lib/dpkg/availablenew
mv -f "$WORK"/var/lib/dpkg/status "$WORK"/var/lib/dpkg/statusnew
rm -rf "$WORK"/var/lib/apt
rm -f "$WORK"/etc/blkid-cache
rm -f "$WORK"/etc/resolv.conf
rm -rf "$WORK"/etc/udev/rules.d/70-persistent*
rm -rf "$WORK"/var/lib/apt
rm -f "$WORK"/etc/apt/sources.list

# The zerosize man,doc,info idea and function is from Jbv's  FoxyRoxyLinux remastering script (http://foxyroxylinux.com):
zerosize() {
  find $* 2> /dev/null | while read file; do
    echo -n "."
    rm -f $file
    touch $file
  done
}

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

    chown -R man:root usr/share/man

find . -maxdepth 1 -xtype l -delete
echo
echo -e "\e[0;32mOK\033[0m"

#cd "/mnt/$DRV"

# Create module.
echo -e "\e[0;36mCreating $SFS.squashfs....\033[0m"

# Below commented was attempt to make cleanup when interrupted if running 'sudo apt2sfs-cli', it didn't work, ... , still a mystery. 
#trap "killall mksquashfs; exit" 0 1 2 3 15;
#trap "killall mksquashfs; rm -f "$SFS".squashfs; exit" SIGHUP SIGINT SIGTERM

mksquashfs "$WORK" "$SQFS"

# Remove working directory?
read -p "Remove working directory $WORK ? (Y/n)?" choice
case "$choice" in 
  y|Y|"")
if [[ -n "$SFS" && -n "$DRV" ]]; then
rm -rf "$WORK"
[ "$?" -eq 0 ] && echo -e "\e[0;32mDirectory $WORK removed.\033[0m"
read -s -n 1 -p "Press any key to close . . ."
fi
;;
  n|N) 
exit 0
;;
*)
echo -e "\e[0;33mNot a valid choice, not removing directory $SFS\033[0m"
read -s -n 1 -p "Press any key to close . . ."
exit 0
;;
esac

exit 0
