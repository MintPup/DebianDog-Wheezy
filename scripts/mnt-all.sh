#!/bin/bash
#########	Get all partitions, make dirs., mount all partitions. And unmount.

#####	Terence Becker		SunBurnt			Jan. 3  2014

#####	No warranty of any kind... Use at your own risk!

### 2015 saintless - Mod for Debian-Lenny "|hd" and commented "ln -s" commands.
#                    GNU GPL v3 applies. No warranty of any kind... Use it at your own risk!


if [ "$(whoami)" != "root" ]; then
echo "You have to run this script as Superuser!"
echo "Run the script again using sudo."
fi

INFO=`blkid |egrep '(ext|fat|ntfs)' |sed '/sd\|mmc\|hd/!d;s,^.*/,,;s," $,,;s,:.*", ,'` # mcewanw added

Flag=0

if [ "$1" = '-h' ];then									# unmount cli argument
	echo -e '\n>>>  USAGE:  mnt-all [-u = unmount, -h = help]\n
Links to this file named "unmnt-all" or "unmount-all", unmount all partitions.\n
"mnt-all" and any other links pointing to this file, mount all partitions.\n'
elif [ "$1" = '-u' ];then Flag=1						# unmount cli argument
elif [ "${0##*/}" = 'unmnt-all' ];then Flag=1			# unmount by link name
elif [ "${0##*/}" = 'unmount-all' ];then Flag=1			# unmount by link name
fi


if [ $Flag -eq 1 ];then
	parts=`echo "$INFO" |sed 's, .*$,,;s,^,/dev/,'`
	umount $parts 2> /dev/null							# unmount all parts
#	echo -e '\n >>>  Umount '$parts'\n'
#	rm -f /0_*											# delete links in /
	exit
fi


#find /mnt -maxdepth 1 -xtype l -delete								# delete dead links
#rm -f /0_*
BOOT=`mount |sed '/\/live\/image/!d;s, .*$,,;s,^.*/,,'`

#ln -s /live/image /0_$BOOT								# make boot part. links
#ln -s /live/image /media/$BOOT

echo "$INFO" |while read P
do
	PART=${P% *}
#	[ "`mount |grep $PART`" ]&& continue
	[ -d /media/$PART ]|| mkdir -p /media/$PART
	mount -w -t ${P#* } /dev/$PART /media/$PART				# mount part.
	[ $? -eq 0 ]&& echo -e '\n >>>  Mount:  '$PART'\n' ||
		echo -e '\n###  ERROR:  Failed Mount:  '$PART'\n'
#	ln -sf /media/$PART /0_$PART
done
