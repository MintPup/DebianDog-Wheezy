#!/bin/bash
#########	arcdrop:  Drag-N-Drop Archiver.

#####		Terence Becker		Sunburnt	Nov. 28  2013

#####	No warranty of any kind.	Use at your own risk!	
#20160922 saintless	GNU GPL v3 applies. /mnt changed to /media, added xzm and pfs types, commented the section for iso and Rox Desktop Install. Clicking by mistake the desktop icon breaks the rox pinbd often.
#         Source code and arc-menu: http://smokey01.com/saintless/source-code/arcdrop.zip

appP=`dirname $(realpath "$0")`

pbPF="${HOME}"'/.config/rox.sourceforge.net/ROX-Filer/pinbd'			# DebianDog

[ ! -f "$pbPF" ]&& pbPF="${HOME}"'/Choices/ROX-Filer/PuppyPin'			# Puppy

[ ! -f "$pbPF" ]&& echo -e "\n###  ERROR:  No Rox PinBd file.\n" && exit


#if [ ! "$1" ];then		####################	Rox Desktop Install.
#	mkdir -p /opt/apps
#	ln -s "$appP" /opt/apps/arcdrop
#
#	msg=`echo -e "\n   Install ArcDrop to the Desktop?   \n "`
#	xmessage -center -buttons "Yes:1,No:0" "$msg"
#	[ "$?" -eq 0 ]&& exit
#
#	pb="$(<$pbPF)"														# pinbd
#	if [ ! "`echo \"$pb\" |grep 'arcdrop'`" ];then
#		end='</pinboard>'
#		nl='  <icon x="400" y="300" label="ArcDrop">/opt/apps/arcdrop/arcdrop</icon>'
#		echo "$pb" |grep -v "$end" > "$pbPF"
#		echo -e "$nl\n$end" >> "$pbPF"
#	fi
#	giPF="${HOME}"'/.config/rox.sourceforge.net/ROX-Filer/globicons'
#	gi="$(<$giPF)"														# globicons
#	if [ ! "`echo \"$gi\" |grep 'arcdrop'`" ];then
#		end='</special-files>'
#		nl='	<icon>/opt/apps/arcdrop/arcdrop.png</icon>\n  </rule>'
#		nl='  <rule match="/opt/apps/arcdrop/arcdrop">\n'"$nl"
#		echo "$gi" |grep -v "$end" > "$giPF"
#		echo -e "$nl\n$end" >> "$giPF"
#	fi
#	rox -p "$pbPF"
#	exit
#fi	########################################


cd "${1%/*}"
F="${1##*/}"

ext="zip$|gz$|bz2$|xz$|tar$|tar.gz$|tar.bz2$|tar.xz$|sq$|sfs$|squash$|squashfs$|iso$"
ext="`echo $F |egrep -o \"($ext)\"`"

#xmessage -center "$ext   $F"
#echo -e "\n`pwd`\n$ext\n$F\n"
#exit

if [ "$ext" ];then											### extract files
	case "$ext" in
		zip) unzip "$F" ;;
		gz) gunzip "$F" ;;
		bz2) bzip2 -dk "$F" ;;
		xz) xz -dk "$F" ;;
		tar) tar -xf "$F" ;;
		tar.gz) tar -xzf "$F" ;;
		tar.bz2) tar -xjf "$F" ;;
		tar.xz) tar -xJf "$F" ;;
		sq|sfs|squash|squashfs|xzm|pfs) unsquashfs "$F" ;;
#		iso)
#			[ -d /media/iso ]|| mkdir -p /media/iso iso
#			mount -r -t iso9660 -o loop "$F" /media/iso
#			[ "$?" -gt 0 ]&& echo -e "###  ERROR:  Mounting Failed.\n" && exit
#			cp -a /media/iso iso
#			umount -d /media/iso
#			[ "$?" -gt 0 ]&&
#				echo -e "###  ERROR:  Unmounting Failed.\n" && exit ;;
	esac
	exit
fi


l=`echo "$(<$pbPF)" |grep ArcDrop`							# get menu position
scr=`xrandr 2>/dev/null |sed '/*/!d;s,   ,,;s, .*$,,'`

X=`echo "$l" |sed 's,^.*x=",,;s,".*$,,'`
scrX=`echo "$scr" |cut -dx -f1`
[ "$X" -gt "$((scrX-200))" ]&& X="$((scrX-200))"

Y=`echo "$l" |sed 's,^.*y=",,;s,".*$,,'`
scrY=`echo "$scr" |cut -dx -f2`
[ "$Y" -gt "$((scrY-250))" ]&& Y="$((scrY-250))"

M=0
N="$#"
if [ "$N" -gt 1 ];then
	M=1
	F="NEW_$N-Items_$$"						# > 1 item, make NEW file name
else
	[ -d "$1" ]&& M=1
fi

#xmessage -center "$X x $Y   $M"

Menu="`$appP/arc-menu $X $Y $M`"					# show compression menu

Arc=`echo "${Menu,,}" |sed 's,^.* ,,'`				# get archive format

#xmessage -center "${Menu,,}"
#echo "${Menu,,}   $Arc"
#exit

L=`echo "$@" |sed "s,${1%/*}/,,g"`					# get list of items dropped

#xmessage -center "`echo -e \"$N   $F   $L\n$@\"`"
#echo -e "\n$N\n$F\n$L\n$@\n"
#exit


case "$Arc" in											### compress files
	zip) zip -ry9 "$F.zip" $L ;;
	tar) tar -cf "$F.tar" $L ;;
	tar.gz) tar -czf "$F.tar.gz" $L ;;
	tar.bz2) tar -cjf "$F.tar.bz2" $L ;;
	tar.xz) tar -cJf "$F.tar.xz" $L ;;
	xz) xz -zk "$F".xz "$L" ;;
	bzip2) bzip2 -zk9 "$F.bz2".bz2 "$L" ;;
	gzip) cp "$L" "$L"_BU ; gzip -9 "$F.gz" "$L" ; mv "$L"_BU "$L" ;;
	squashfs) mksquashfs $L "$F.squashfs" ;;
esac

