#!/bin/bash

# 2014, by fredx181 for DebianDog.
# 20160926 - saintless, remove gsu dependency, add cli version message in case yad is not installed,
#            GNU GPL v3 applies. No warranty of any kind... Use it at your own risk!


if [ -z `which yad` ];then
xmessage "Yad is missing. For CLI version type in terminal:
addnewuser-cli"
exit 0
else
echo "Starting GUI version."
fi

if [ -z `which gsu` ];then
[ "`whoami`" != "root" ] && x-terminal-emulator -e sudo env LD_LIBRARY_PATH=/usr/local/lib ${0} "$@"
else
[ "`whoami`" != "root" ] && exec gsu ${0} "$@"
fi

       
function new_user(){
    add_user=$(yad --title "Add a new user" --text "  <b>Add a new user</b> \n The new user will also be added to the most important groups:  \n sudo, audio, cdrom, video, fuse and more." --form --field "Username (use lowercase only):       : "  --field "Password:       :H" --field "Retype Password:       :H")
ret=$?
[[ $ret -ne 0 ]] && exit 1
    if [ -z "$(echo $add_user | cut -d "|" -f 1)" ] || [ -z "$(echo $add_user | cut -d "|" -f 2)" ] || [ -z "$(echo $add_user | cut -d "|" -f 3)" ]; then
        yad --title "Error" --text " You probably didn't fill in all fields, click 'OK' to try again. "
ret=$?
[[ $ret -ne 0 ]] && exit
        new_user
    elif [ "$(echo $add_user | cut -d "|" -f 2)" != "$(echo $add_user | cut -d "|" -f 3)" ]; then
        yad --title "Error" --text " Passwords do not match, please try again"
ret=$?
[[ $ret -ne 0 ]] && exit
        new_user
    fi
}
    
new_user
    
user="`echo $add_user | cut -d "|" -f 1`"
pass="`echo $add_user | cut -d "|" -f 3`"

adduser $user --gecos ",,," --disabled-password
echo "$user:$pass" | chpasswd
usermod -a -G cdrom,floppy,sudo,audio,dip,video,plugdev,scanner,lpadmin,netdev,bluetooth,fuse $user
exit 0
