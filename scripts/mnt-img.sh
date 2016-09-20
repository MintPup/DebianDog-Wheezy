#!/bin/bash
#########	Click image files to mount & unmount."

#####	Terence Becker		SunBurnt		Jan. 3  2014

#####	No warranty of any kind... Use at your own risk!

#20160920 saintless - GNU GPL v3 applies. Changes for DebianDog - gsu line and $FLMAN, removed $FS from "mount -o loop" command.


if [ -z `which gsu` ];then
[ "`whoami`" != "root" ] && x-terminal-emulator -e sudo env LD_LIBRARY_PATH=/usr/local/lib ${0} "$@"
else
[ "`whoami`" != "root" ] && exec gsu ${0} "$@"
fi

[ `which xfe` ] && FLMAN=xfe || FLMAN=rox || FLMAN=thunar FLMAN=default_file-browser

case "$1" in
	''|?|-h|--help)
		echo -e "\n>>>  USAGE:  mnt-img (/Path/ImageFile)\n"
		exit ;;
esac

PF=$1

[ ! -f "$PF" ]&&
	echo -e "\n###  ERROR:  Bad /Path/ImageFile Argument:  $PF\n" && exit

MNT=/media/`echo "$PF" |sed "s#/#+#g"`			# replace: / with: +
   

if [ ! "`mount |grep $MNT`" ];then
	FS=`blkid $PF |sed 's,".$,,;s,^.*",,'`
	[ ! "$FS" ]&&
		echo -e "\n###  ERROR:  Bad File system Type.\n" && exit

	[ -d $MNT ] || mkdir -p $MNT

	mount -o loop $PF $MNT
	[ $? -gt 0 ]&&
		echo -e "\n###  ERROR:  Failed Mounting:  $PF\n" && exit
	echo -e "\n>>>  Mount:  $PF\n"

	L=`readlink $0`

	exec $FLMAN $MNT

exit

else
	umount -d $MNT 2> /dev/null
	[ $? -gt 0 ]&&
		echo -e "\n###  ERROR:  Failed UnMounting:  $PF\n" && exit
	echo -e "\n>>>  UnMount:  $PF\n"
	rmdir $MNT
fi

