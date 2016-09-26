#!/bin/bash

# 20160926 - saintless - for DebianDog. Alternative console version to addnewuser yad version from fredx181.
#            GNU GPL v3 applies. No warranty of any kind... Use it at your own risk!



if [ "$(whoami)" != "root" ]; then
echo "You have to run this script as Superuser!"
echo "Run the script again using sudo."
exit 1
fi

echo -e "\e[0;32m        This script will help you to create new user easier.\033[0m"
echo -e "\e[0;32m        The user will be added to the groups listed below:\033[0m"
echo -e "\e[0;32mcdrom floppy sudo audio dip video plugdev scanner lpadmin netdev bluetooth fuse\033[0m"

read -p "Do you want to continue? (y/n)?" choose
case "$choose" in
  y|Y ) echo "Continue...";;
  n|N ) exit 0;;
  * ) exit 0;;
esac

read -p "Type the new user name: " user
echo $user

adduser $user --gecos ",,,"
usermod -a -G cdrom,floppy,sudo,audio,dip,video,plugdev,scanner,lpadmin,netdev,bluetooth,fuse $user
#usermod -a -G cdrom,floppy,sudo,audio,dip,video,plugdev,netdev $user #for Debian Etch and Lenny.
echo "$user ALL=(ALL) ALL" >> /etc/sudoers
exit 0
