#!/bin/bash
#set -x
#debiandog
#140930 sfs , moded by Fred (fred181) for DebianDog, with better support for special mountpoints (besides /media/* or /mnt/*) and difference in boot methods.
#Without progressbar 'color fill' otherwise it crashes sometimes, idea from Toni (saintless). 
# Dependency for probepart removed, using disktype instead (much faster).
# 20160925 - saintless - workaround for sh link to dash with special gtkdialog deb installed and changed FLMAN line.

###########################################
 
# Uses thunar as filemanager (for openbox version) but only if both thunar AND openbox are installed, to use xfe instead of rox on Jwm version replace "rox -d" with xfe on the next line.
#[[ `which thunar` && `which openbox` ]] && FLMAN=thunar || FLMAN=rox || FLMAN=defaultfilemanager
[ `which xfe` ] && FLMAN=xfe || FLMAN=rox || FLMAN=thunar || FLMAN=default_file-browser #saintless

#which gsu && gsu=gsu || gsu=sudo
if [ -z `which gsu` ];then
[ "`whoami`" != "root" ] && x-terminal-emulator -e sudo env LD_LIBRARY_PATH=/usr/local/lib ${0} "$@"
else
[ "`whoami`" != "root" ] && exec gsu ${0} "$@"
fi

#saintless - workaround for DebianDog with sh link to dash.
if [ -z `which gtkdialogbin` ];then
gtkdialog="gtkdialog"
else
gtkdialog="gtkdialogbin"
fi

export TEXTDOMAIN=mount-wizard
export OUTPUT_CHARSET=UTF-8

# Moded for DebianDog version of Iguleder's mount-wizard script.


while true
do
_choose_action() {
   i=0
echo '<window title="'$(gettext 'Mounting Wizard')'" icon-name="gtk-harddisk">
<vbox vscrollbar-policy="1">
<text><label>Any grey Unmount button is boot or save partition.</label></text>
'
echo '<hbox space-expand="true">'
   for partition in $1
   do

if [ -f /mnt/live/tmp/modules ]; then
HDRV=`cat /mnt/live/etc/homedrv | cut -d'/' -f3` # mcewanw
BACKDRVEXIT="$(df -h | grep -P '/mnt/live/memory/images/changes-exit' | cut -d'/' -f3 | cut -d' ' -f1)" # mcewanw
# fredx181, test first if /mnt/live/memory/changes is not 'tmpfs' (else it would be /dev/sdx)
TESTBACKDRVCH="$(df -h | grep -P '/mnt/live/memory/changes' | awk '{ print $1}')"
if [ "$TESTBACKDRVCH" != "tmpfs" ]; then
BACKDRVCH="$(df -h | grep -P '/mnt/live/memory/changes' | cut -d'/' -f3 | cut -d' ' -f1)" # mcewanw
fi

# if [ -n "$BACKDRVEXIT" ]; then
if [ $BACKDRVEXIT ]; then # fredx, found that this works more secure as the above commented out, without double quotes and without the '-n' parameter 
BACKDRV="$BACKDRVEXIT"
# elif [ "$BACKDRVCH" ]; then
elif [ $BACKDRVCH ]; then # fredx, found that this works more secure as the above commented out, without double quotes and without the '-n' parameter
BACKDRV="$BACKDRVCH"
fi

    if [ "$BACKDRV" != "$partition" ]; then
    BACKDRV="$(cat /mnt/live/tmp/modules | grep 'changes' | grep -o "$partition")"
	fi

else
if grep -q /lib/live/mount /proc/mounts; then # live-boot v3
if grep -q 'persistence' /proc/cmdline; then
HDRV="$(basename "$(readlink /live/image)")"
else
HDRV="$(df -h | grep -P /lib/live/mount/medium | cut -d'/' -f3)" # mcewanw
fi
if [ "$(losetup -a | grep '/live/persistence')" ];then
BACKDRV="$(losetup -a | grep '/live/persistence' | grep -o "$partition")"
else
BACKDRV="$(basename "$(readlink /live/cow)")"
fi
else # live-boot v2
HDRV="$(df -h | grep -P /live/image | cut -d'/' -f3)" # mcewanw
if [ "$(df -h | grep -P '(?=.*live-rw)(?=.*backing)')" ]; then
BACKDRV="$(df -h | grep -P '(?=.*live-rw)(?=.*backing)' | cut -d'/' -f3 | cut -d' ' -f1)" # mcewanw
else
BACKDRV="$(df -h | grep -P /live/cow | cut -d'/' -f3 | cut -d' ' -f1)" # mcewanw
fi
fi
fi

      fst="`blkid -o value -s TYPE "/dev/$partition"`"
      info=`disktype "/dev/$partition"`
      all=`echo "$info" |sed '/, size /!d;s,^.*size ,,;s, (.*$,,;s, ,,g;s,iB,,g'`
      pr="`df -h | grep -v 'loop\|changes\|live-rw-backing' |awk '/'$partition'/ {print $5}'`"
partition1="$all`df -h | grep -v 'loop\|changes\|live-rw-backing' |awk '/'$partition'/ {print "/"$4" free "$6}' | head -1`"
mntpoint="$(echo "$partition1" |awk '{print $3}' | head -1)"

if [ "$all" = "$partition1" ];then
  mkdir -p /media/$partition
  mount /dev/$partition /media/$partition > /dev/null 2>&1
  if [ $? -eq 0 ];then
      partition1="$all`df -h |awk '/'$partition'/ {print "/"$4" free"}'`"
   umount /dev/$partition && rmdir /media/$partition
  fi
fi
      [ 0 -eq $i ] && echo "   <vbox>"

      case "$partition" in
         *fd*)
            type="floppy24"
            ;;
         *mmc*)
            type="card24"
            ;;
         *sda*)
            type="drive24"
            ;;
         *sr*)
            type="optical24"
            ;;
         *sd*)
            type="card24"
            ;;
         *)
            type="drive24"
            ;;
      esac

      echo "<frame $partition: $fst $partition1>
 <hbox>
"

[ "`df |grep $partition`" ] && echo "
<button tooltip-text=\"$(gettext 'Browse')\">
   <input file stock=\"gtk-open\"></input>
   <action>$FLMAN $mntpoint</action>
   <action>EXIT=ok</action>
</button>
"
echo "
			<progressbar>
				<label>$partition $pr</label>
#				<input>echo "$pr"</input>
#				<action function=\"exit\">Ready</action>
			</progressbar>
" |egrep -v '^#'

      mountpoint -q "$mntpoint" > /dev/null 2>&1
      if [ 0 -eq $? ]
      then
            echo "
   <pixmap><height>32</height><width>32</width><input file>/usr/share/pixmaps/$type.png</input></pixmap>
"

if [ "$partition" = "$HDRV" ] || [ "$partition" = "$BACKDRV" ]; then
echo "
<button sensitive=\"false\">
<label>$(gettext 'Unmount')</label>
   <input file stock=\"gtk-disconnect\"></input>
"
else
echo "
<button>
<label>$(gettext 'Unmount')</label>
   <input file stock=\"gtk-disconnect\"></input>
"
fi
echo "
   <action>mkdir /media/$partition</action>
   <action>umount /dev/$partition /media/$partition</action>
   <action>rmdir /media/$partition</action>
      <action>EXIT:RET1</action>
</button>
"
      else
         echo "
   <pixmap><height>32</height><width>32</width><input file>/usr/share/pixmaps/$type.png</input></pixmap>
<button width-request=\"90\">
   <width>128</width>
   <label>$(gettext 'Mount')</label>
   <input file stock=\"gtk-connect\"></input>
   <action>mkdir /media/$partition</action>
   <action>mount /dev/$partition /media/$partition</action>
      <action>EXIT:RET1</action>
</button>
"
      fi

      echo "
   </hbox>
</frame>"

      i=$((1 + $i))
      if [ 10 -eq $i ]
      then
         echo "</vbox>"
         i=0;
      fi
   done

   [ 0 -ne $i ] && echo "</vbox>"
echo "</hbox>"
echo "</vbox>"
echo "</window>"
}

# list all partitions
partitions=""
         partitions="$(blkid -o list | grep /dev | grep -E -v "loop|swap|crypt|squashfs" | sort | cut -d" " -f1 | sed 's|/dev/||g')"

# let the user choose a partition
eval $(_choose_action "$partitions" | $gtkdialog -sc ) #saintless - workaround for DebianDog with sh link to dash.
case "$EXIT" in
	'RET1')
		exec "$0"
		;;
esac
[ "abort" = "$EXIT" ] && exit 1
done
