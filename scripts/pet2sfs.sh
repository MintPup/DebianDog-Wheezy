#!/bin/bash
# This script includes code from fredx181's redeb
# saintless - for DebianDog.
# 20160926 - included xz extract option, error checking, warning messages. Works now without sudo.
# GNU GPL v3 applies. No warranty of any kind... Use it at your own risk!

FILE=$1
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$1" ]; then
echo "usage: pet2sfs <package>.pet to create sfs from pet package."
exit 0
fi

if [ ! -f $FILE ]; then
echo "The file does not exist."
exit 1
fi

if [ "`echo "${FILE##*.}"`" != "pet" ]; then
echo "This is not a .pet file."
exit 1
fi

echo -e "\e[0;32m            pet2sfs for DebianDog\033[0m"
echo 
echo -e "\e[0;32mUsing converted pet to sfs modules could break your system.\033[0m"
echo -e "\e[0;32mIt is advanced user option for testing without persistence.\033[0m"
echo -e "\e[0;32mMake sure you have read-write permissions for the pet file\033[0m"
echo -e "\e[0;32mand location or run the script again using sudo.\033[0m"

read -p "Do you want to continue? (y/n)?" choose
case "$choose" in
  y|Y ) echo "Continue...";;
  n|N ) exit 0;;
  * ) exit 0;;
esac

cd $DIR

mv $FILE $FILE.tar.gz

if file $FILE.tar.gz | grep -q  "gzip"
then
echo "OK, gzip compression detected."
EXTRACT=$(tar -zxvf $FILE.tar.gz)
else
echo "Not in  gzip format. Trying XZ instead."
EXTRACT=$(tar --xz -xvf $FILE.tar.gz)
fi

cd $EXTRACT
rm -f *.specs

if [ -f $DIR/$FILE.sfs ]; then
mv $DIR/$FILE.sfs $DIR/$FILE.sfs.old
fi

mksquashfs ./ $DIR/$FILE.sfs

cd $DIR

mv $FILE.tar.gz $FILE

rm -fr $EXTRACT

echo "Done creating $FILE.sfs package." 

exit 0
