#!/bin/bash

# Moded for DebianDog version of Iguleder's mount-wizard script.
# GNU GPL v3 applies. No warranty of any kind... Use it at your own risk!
# 20160924 - saintless - workaround for sh link to dash with special gtkdialog deb installed.

if [ -z `which gsu` ];then
[ "`whoami`" != "root" ] && x-terminal-emulator -e sudo env LD_LIBRARY_PATH=/usr/local/lib ${0} "$@"
else
[ "`whoami`" != "root" ] && exec gsu ${0} "$@"
fi

#saintless - workaround for DebianDog with sh link to dash.
if [ -z `which gtkdialogbin` ];then
gtkdialog="/opt/bin/gtkdialog"
else
gtkdialog="/opt/bin/gtkdialogbin"
fi


[ `which xfe` ] && FLMAN=xfe || FLMAN=rox || FLMAN=thunar || FLMAN=default_file-browser

while true
do
_choose_action() {
   i=0
echo '<window title="Mounting Wizard">'
echo "<hbox>"
   for partition in $1
   do
      [ 0 -eq $i ] && echo "   <vbox>"

      case "$partition" in
         *fd*)
            type="fd2"
            ;;
         *mmc*)
            type="sd2"
            ;;
         *sda*)
            type="drive2"
            ;;
         *sr*)
            type="disc2"
            ;;
         *)
            type="sd2"
            ;;
      esac

      echo "<frame>
<hbox>
   <pixmap>
      <input file>/usr/share/pixmaps/$type.png</input>
   </pixmap>
   <vbox>
      <text>
         <label>$partition</label>
      </text>"

      mountpoint -q "/media/$partition" > /dev/null 2>&1
      if [ 0 -eq $? ]
      then
            echo "<button>
   <label>Browse</label>
   <action>$FLMAN /media/$partition</action>
   <action>EXIT=ok</action>
</button>
<button>
   <label>Unmount</label>
   <action>mkdir /media/$partition  > /dev/null 2>&1</action>
   <action>umount /dev/$partition /media/$partition</action>
   <action>rmdir /media/$partition  > /dev/null 2>&1</action>
      <action>EXIT:RET1</action>
</button>"
      else
         echo "<button>
   <label>Mount</label>
   <action>mkdir /media/$partition</action>
   <action>mount /dev/$partition /media/$partition</action>
      <action>EXIT:RET1</action>
</button>"
      fi

      echo "</vbox>
   </hbox>
</frame>"

      i=$((1 + $i))
      if [ 5 -eq $i ]
      then
         echo "</vbox>"
         i=0;
      fi
   done

   [ 0 -ne $i ] && echo "</vbox>"
echo "</hbox>"
echo "</window>"
}

# list all partitions
partitions=""
         partitions="$(blkid -o list | grep /dev | grep -E -v "loop|swap|crypt" | sort | cut -d" " -f1 | sed 's|/dev/||g')"

# let the user choose a partition
eval $(_choose_action "$partitions" | $gtkdialog -s) #saintless - workaround for DebianDog with sh link to dash.
case "$EXIT" in
	'RET1')
		exec "$0"
		;;
esac
[ "abort" = "$EXIT" ] && exit 1
done
