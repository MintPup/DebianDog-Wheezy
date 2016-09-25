#!/bin/bash

# jwm-theme-change renamed to theme-change for jwm-obmenu. Source code: http://www.smokey01.com/saintless/DebianDog/Packages/Included/change-jwm-theme.tar.gz
# GNU GPL v3 applies. No warranty of any kind... Use it at your own risk!
# 2016 - for DebianDog by saintless. Updates from me only here: https://github.com/mintpup
# The code contains moded parts from different scripts written for DebianDog and Puppy linux and examples in linux forums and man pages.
# My thanks to Daniel Baumann! DebianDog wouldn't exist without his work: https://lists.debian.org/debian-live/2015/11/msg00024.html

cliversion() {
cd /opt/docs/jwm-themes
theme=$(ls /opt/docs/jwm-themes)
echo
echo -e "\e[0;32m    *** Type your choice from the theme list names and press Enter. ***\033[0m"
echo -e "\e[0;32m    ***       Your new JWM theme will appear in few seconds ***\033[0m"
echo -e "\e[0;32m    ***        To restore the default theme select default. ***\033[0m"
echo
echo -e "\e[0;32mAvailable themes list:\033[0m" $theme
echo
read -p "Type theme of your choice, e.g. blue: " P
if [ -z "$(echo "$theme" | grep -w "$P")" ]; then
read -p "$P is not available, try again: " P
if [ -z "$(echo "$theme" | grep -w "$P")" ]; then
read -p "$P is not available, try again: " P
if [ -z "$(echo "$theme" | grep -w "$P")" ]; then
echo -e "\e[0;32m$P is not available, please run again and type a valid theme.\033[0m"
read -s -n 1 -p "Press any key to close . . ."
exit 0
   fi
	fi
fi
echo "$P theme selected."

rm -f $HOME/.jwm/jwm.theme
cp $P $HOME/.jwm/jwm.theme
/bin/update-menus
jwm -restart
}


guiversion() {
RET=$(export Change_JWM_Theme='
<window title=" Change JWM Theme.">
 <vbox>
  <text><label>Select theme and click OK.</label></text>
  <text><label>It will appear in few seconds.</label></text>
  <text><label>To restore the default theme select default.</label></text>
  <hbox>
    <entry accept="Choose theme." fs-folder="/opt/docs/jwm-themes">
      <variable>FILE_SAVEFILENAME</variable>
    </entry>
    <button>
        <label>" Select "</label>
      <input file stock="gtk-open"></input>
      <action type="fileselect">FILE_SAVEFILENAME</action>
    </button>
    <button ok></button>
  </hbox>

 </vbox>
</window>
'
gtkdialog --program=Change_JWM_Theme)


eval $RET

echo -e "\n$RET\n"

[ "$EXIT" != OK ]&& exit  # exit if not OK button

P=${FILE_SAVEFILENAME}

if [ ! -f "$P" ]; then
echo "Theme $P is not available, please run again and type a valid theme."
exit 0
else
rm -f $HOME/.jwm/jwm.theme
cp $P $HOME/.jwm/jwm.theme
/bin/update-menus
jwm -restart
fi
}

if [ -x "`which gtkdialog 2>/dev/null`" ]; then
echo "gtkdialog found. Starting GUI version..."
guiversion
else
echo "gtkdialog not available. Starting CLI version..."
export -f cliversion
x-terminal-emulator -e cliversion
fi

exit
