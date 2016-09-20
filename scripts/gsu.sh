#!/bin/bash

# gsu-notimeout - yad script for DebianDog by fredx181 (2014).
# 20160918 saintless - Included x-terminal-emulator alternative version to make it work without yad and renamed to gsu.
#                      GNU GPL v3 applies. No warranty of any kind... Use it at your own risk!


if [ -z `which yad` ]; then
x-terminal-emulator -e sudo env LD_LIBRARY_PATH=/usr/local/lib "$@"
exit 0
else
echo "Starting yad version."
fi

cmd=$*

sudo_check_if_passwd_needed=$(sudo -H -S -- $cmd 2>&1 &)
if [[ "$(echo "$sudo_check_if_passwd_needed" | grep -o "\[sudo\] password for $USER")" != "[sudo] password for $USER" ]]; then
sudo -K
exit 1
fi

pass=$(yad --class="GSu" \
    --title="Password" \
    --text=" Enter password for <b>$USER</b> " \
    --image="dialog-password" \
    --entry --hide-text)
ret=$?
[[ $ret -ne 0 ]] && exit 1
if [[ -z "$pass" ]]; then
yad --text="  Sorry, incorrect password.  \n    Please try again. " --button="gtk-close:0"
exec ${0} $cmd
fi

echo "$pass" | sudo  -k -S -p "" -E true
ret=$?
if [ $ret -ne 0 ]; then
yad --text="  Sorry, incorrect password.  \n    Please try again. " --button="gtk-close:0"
exec ${0} $cmd
fi

echo "$pass" | sudo -S env LD_LIBRARY_PATH=/usr/local/lib sh -c "$cmd"
ret=$?
echo $ret
if [ $ret = 127 ]; then
yad --text="    Sorry, could not find:     \n   '$cmd' .  \n     Please try again. " --button="gtk-close:0"
fi
sudo -K
exit $?
