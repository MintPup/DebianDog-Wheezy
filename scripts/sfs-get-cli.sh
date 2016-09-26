#!/bin/bash

# CLI script based on the yad version sfs-get from fredx181.
# 20160925 - saintless - sfs-get-cli console version - GNU GPL v3 applies.
# No warranty of any kind... Use it at your own risk!

# Ping your default gateway. Source: http://stackoverflow.com/a/14939373
if ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null; then
echo "Working internet connection found."
else
echo "You dont have working internet connection. Exiting now."
exit 0
fi

SAVEDIR=$(pwd)
echo -e "\e[0;32m         sfs-get-cli for DebianDog-Wheezy\033[0m"
echo 
echo -e "\e[0;32mThe module will be downloaded in:\033[0m"
echo -e "\e[0;32m$SAVEDIR\033[0m"
echo -e "\e[0;32mYou can cd to new directory and run the script again from there.\033[0m"
echo -e "\e[0;32mMake sure you have read-write permissions for this directory\033[0m"
echo -e "\e[0;32mor run the script again using sudo.\033[0m"

read -p "Do you want to continue? (y/n)?" choose
case "$choose" in
  y|Y ) echo "Continue...";;
  n|N ) exit 0;;
  * ) exit 0;;
esac

HOSTDIR="https://github.com/DebianDog/Wheezy/releases/download/v0.1/"
CONTENTFILE="sfs.txt"

[ -f /tmp/$CONTENTFILE ] && rm -f /tmp/$CONTENTFILE
wget --no-check-certificate "$HOSTDIR"/$CONTENTFILE -O /tmp/$CONTENTFILE #github mod.
ALL=`cat /tmp/$CONTENTFILE`
LIST=$ALL
ret=$?
[[ $ret -ne 0 ]] && exit 1

 if [[ -z "$LIST" ]]
  then
      echo "Error: No arguments provided"
      echo "  Nothing selected! Please try again."
      [[ $ret -ne 0 ]] && exit 1
      exec ${0}
fi

URILIST="`echo "$LIST" | sed "s,^,$HOSTDIR/," | tr '\n' ' '`"
ret=$?
[[ $ret -ne 0 ]] && exit 1

echo -e "\e[0;32mAvailable modules:\033[0m" $LIST
###
read -p "Type module name for download:" FILENAME
if [ -z "$(echo "$LIST" | grep -wox "$FILENAME")" ]; then
read -p "$FILENAME is not available, try again: " FILENAME
	if [ -z "$(echo "$LIST" | grep -wox "$FILENAME")" ]; then
read -p "$FILENAME is not available, try again: " FILENAME
   if [ -z "$(echo "$LIST" | grep -wox "$FILENAME")" ]; then
echo -e "\e[0;31m$FILENAME is not available, please run again and type a valid name.\033[0m"
read -s -n 1 -p "Press any key to close . . ."
exit 0
   fi
	fi
fi
echo "Downloading $FILENAME..."

wget --no-check-certificate $HOSTDIR/$FILENAME -O $FILENAME

[ -f /tmp/$CONTENTFILE ] && rm -f /tmp/$CONTENTFILE

exit 0
