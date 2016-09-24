#!/bin/bash
#########	Modified version of Terry's mk-save.gtkdlg script made for DebianDog
### 		No warranty of any kind... Use at your own risk!
###20160924 saintless - GNU GPL v3 applies. No warranty of any kind... Use it at your own risk!

if [ "$(whoami)" != "root" ]; then
echo "You have to run this script as Superuser!"
echo "Run the script again using sudo."
fi

rscli() {
echo 
echo -e "\e[0;32m                  *** RESIZE SAVE FILE ***\033[0m"
echo -e "Type full path to save file to resize, e.g. /live/image/live-rw \n      It must be unmounted (not in use) from the system. \n    Make sure when choosing size to increase the file size.  \n               Decreasing is not recommended. \n         Note FAT32 supports up to 3096MB file size."
echo
read -p "Type full path to save file: " SAVE
echo save-file=$SAVE

read -p "Type the new size in Mb: " SIZE
echo new-size=$SIZE

echo y | fsck -y $SAVE
echo y | resize2fs -f $SAVE ${SIZE}m
echo y | fsck -y $SAVE

echo -e "\e[0;32m *** All done. $SAVE file is ${SIZE} Mb now. ***\033[0m"
echo "If there are no errors all should be OK."
}
export -f rscli


rsgui() {
RET=$(export RzSAVE_GUI='
<window title=" Resize Save File.">
 <vbox>
  <text><label>Select the save file you want to resize.</label></text>
  <text><label>It is recommended to use unmounted save file!</label></text> 
  <text><label>Enlarging mounted save file is possible but not recommended!</label></text>
  <text><label>Shrinking mounted save file will damage the structure!</label></text>
  <text><label>Note FAT32 supports up to 3096MB file size.</label></text>
  <hbox>
    <entry accept="savefilename">
      <variable>FILE_SAVEFILENAME</variable>
    </entry>
    <button>
      <input file stock="gtk-open"></input>
      <variable>FILE_BROWSE_SAVEFILENAME</variable>
      <action type="fileselect">FILE_SAVEFILENAME</action>
    </button>
  </hbox>
  <text><label>Type new final size for the save file to make it larger or smaller.</label></text>
  <text><label>Smaller size is not recommended. Backup important data first!</label></text>
  <hbox>
    <text>
      <label>Type New Size x 1MB:  </label>
    </text>
    <entry>
      <variable>Size</variable>
      <default>0</default>
    </entry>
    <button cancel></button>  
    <button ok></button>
  </hbox>

 </vbox>
</window>
'
gtkdialog --program=RzSAVE_GUI)


eval $RET

echo -e "\n$RET\n"

[ "$EXIT" != OK ]&& exit								# exit if not OK button

P=${FILE_SAVEFILENAME%/*}
F=${FILE_SAVEFILENAME##*/}

[ ! -d "$P" ]&& echo " Bad Path. " && exit		# test if is /path
echo y | e2fsck -y $P/$F
echo y | resize2fs -f $P/$F ${Size}m
echo y | e2fsck -y $P/$F
echo "If there are no errors all should be OK."
#xterm -T "resize-save" -si -sb -fg white -bg SkyBlue4 -geometry 75x15 -hold -e "echo y | e2fsck -y $P/$F; echo y | resize2fs -f $P/$F ${Size}m; echo y | e2fsck -y $P/$F; echo If there are no errors all should be OK."
}
export -f rsgui

if [ -z `which gtkdialog` ]; then
rscli
else
rsgui
fi

exit 0
