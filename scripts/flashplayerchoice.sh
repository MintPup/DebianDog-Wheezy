#!/bin/bash

# 20160927 saintless - flashplayerchoice for DebianDog.
# Options to install or download pet package versions from: http://www.smokey01.com/OscarTalks/
# GNU GPL v3 applies. No warranty of any kind... Use it at your own risk!
# My thanks to Daniel Baumann! DebianDog wouldn't exist without his work: https://lists.debian.org/debian-live/2015/11/msg00024.html                     


# Ping your default gateway. Source: http://stackoverflow.com/a/14939373
if ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null; then
echo "Working internet connection found."
else
echo "You dont have working internet connection. Exiting now."
exit 0
fi

if [ "$(whoami)" != "root" ]; then
echo "You have to run this script as Superuser!"
echo "Run the script again using sudo."
exit 0
fi

URL="http://www.smokey01.com/OscarTalks/"
fp10="flashplayer10-10.3.183.90"
fp11="flashplayer11-11.2.202.635-i386"
fp23="flashplayer-23.0.0.162-i386"
DIR="/usr/lib/mozilla/plugins"


flashplugin() {
rm -f $DIR/libflashplayer.so
apt-get install -q -y flashplugin-nonfree
rm -f /var/cache/flashplugin-nonfree/*.tar.gz
apt-get clean
}

purgeflashplugin() {
apt-get purge -q -y flashplugin-nonfree
apt-get autoremove -q -y
dpkg --purge `dpkg --get-selections | grep deinstall | cut -f1` 2> /dev/null
}

flashplayer10() {
mkdir -p $DIR && cd $DIR
wget $URL/$fp10.pet
mv $fp10.pet $fp10.pet.tar.gz
tar -zxvf $fp10.pet.tar.gz
rm -f $fp10.pet.tar.gz
mv -f ./$fp10/$DIR/libflashplayer.so ./libflashplayer.so
rm -fr $fp10
}

flashplayer11() {
mkdir -p $DIR && cd $DIR
wget $URL/$fp11.pet
mv $fp11.pet $fp11.pet.tar.gz
tar -zxvf $fp11.pet.tar.gz
rm -f $fp11.pet.tar.gz
mv -f ./$fp11/$DIR/libflashplayer.so ./libflashplayer.so
rm -fr $fp11
}

flashplayer23() {
mkdir -p $DIR && cd $DIR
wget $URL/$fp23.pet
mv $fp23.pet $fp23.pet.tar.gz
tar -zxvf $fp23.pet.tar.gz
rm -f $fp23.pet.tar.gz
mv -f ./$fp23/$DIR/libflashplayer.so ./libflashplayer.so
rm -fr $fp23
}

rmflashplayer() {
rm -f $DIR/libflashplayer.so
}

echo
echo -e "\e[0;32m    *** Flash Player Choice for DebianDog ***\033[0m"
echo

read -p "Do you want to run apt-get update first? (y/n)?" choose
case "$choose" in
  y|Y ) apt-get update;;
  * ) echo "Continue...";;
esac

echo 
echo -e "\e[0;32m    *** Available install/remove flashplayer options. ***\033[0m"
echo
echo "1) Install flashplugin-nonfree with apt-get (= 34 Mb uncompressed)."
echo "2) Flash-Player-10 - download and extract (= 12 Mb uncompressed)."
echo "3) Flash-Player-11 - download and extract (= 17 Mb uncompressed)."
echo "4) Flash-Player-23 - download and extract (= 16 Mb uncompressed)."
echo
echo "5) Remove flushplugin-nonfree (if installed)."
echo
echo "6) Remove Flash-Player- 10, 11 or 23 (if exists)."
echo
echo " Any other key for exit."
echo
echo -e "\e[0;32m    *** Type the number and press Enter. ***\033[0m"
echo

read n
case $n in
    1) flashplugin;;
    2) flashplayer10;;
    3) flashplayer11;;
    4) flashplayer23;;  
    5) purgeflashplugin;;
    6) rmflashplayer;;
    *) exit;;
esac

exit 0
