#!/bin/bash
# This script includes code from fredx181's redeb
# saintless - for DebianDog.
# 20160926 - included xz extract option, error checking, warning messages. Works now without sudo.
# GNU GPL v3 applies. No warranty of any kind... Use it at your own risk!

FILE=$1
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$1" ]; then
echo "usage: pet2deb <package>.pet to create deb from pet package."
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

echo -e "\e[0;32m            pet2deb for DebianDog\033[0m"
echo 
echo -e "\e[0;32mUsing converted pet packages could break your system.\033[0m"
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

mkdir ./opt
mkdir ./opt/bin
mv -f ./usr/bin/* ./opt/bin
rm -fr ./usr/bin

mv -f ./usr/sbin/* ./opt/bin
rm -fr ./usr/sbin

mv -f ./bin/* ./opt/bin
rm -fr ./bin

mv -f ./sbin/* ./opt/bin
rm -fr ./sbin

mv -f ./usr/local/bin/* ./opt/bin
rm -fr ./usr/local/bin

mv -f ./usr/local/sbin/* ./opt/bin
rm -fr ./usr/local/sbin

mkdir ./opt/lib
mv -f ./usr/local/lib/lib* ./opt/lib
mv -f ./usr/lib/lib* ./opt/lib
mv -f ./lib/lib* ./opt/lib

mv -f ./lib/i386/lib* ./opt/lib
mv -f ./usr/lib/i386/lib* ./opt/lib
mv -f ./lib/i386-linux-gnu/lib* ./opt/lib
mv -f ./usr/lib/i386-linux-gnu/lib* ./opt/lib

mv -f ./lib/i486/lib* ./opt/lib
mv -f ./usr/lib/i486/lib* ./opt/lib
mv -f ./lib/i486-linux-gnu/lib* ./opt/lib
mv -f ./usr/lib/i486-linux-gnu/lib* ./opt/lib

mv -f ./lib/i586/lib* ./opt/lib
mv -f ./usr/lib/i586/lib* ./opt/lib
mv -f ./lib/i586-linux-gnu/lib* ./opt/lib
mv -f ./usr/lib/i586-linux-gnu/lib* ./opt/lib

mv -f ./lib/i686/lib* ./opt/lib
mv -f ./usr/lib/i686/lib* ./opt/lib
mv -f ./lib/i686-linux-gnu/lib* ./opt/lib
mv -f ./usr/lib/i686-linux-gnu/lib* ./opt/lib

mkdir ./DEBIAN

echo 'Package: PACK_NAME
Priority: optional
Section: utilities
Installed-Size: PACK_SIZE
Maintainer: root
Architecture: i386
Version: 1.0.1
Depends: libc6
Description: PACK_NAME-converted-pet-to-deb' > ./DEBIAN/control

PACKAGENAME=`basename "$FILE" | cut -d'.' -f1 | sed -e 's/[^A-Za-z]*//g'`
sed -i 's|PACK_NAME|'"$PACKAGENAME"'|' ./DEBIAN/control
SIZE=`du -s ./ | sed -e 's/[^0-9]*//g'`
sed -i 's|PACK_SIZE|'"$SIZE"'|' ./DEBIAN/control

echo '#!/bin/sh

if [ -x "`which update-menus 2>/dev/null`" ]; then
	update-menus
fi

exit 0' > ./DEBIAN/postinst
chmod a+r+x ./DEBIAN/postinst

cp ./DEBIAN/postinst ./DEBIAN/postrm

if [ -f $DIR/"$FILE"-convert-to.deb ]; then
mv $DIR/"$FILE"-convert-to.deb $DIR/"$FILE"-convert-to.deb.old
fi

dpkg-deb -b ./ $DIR/"$FILE"-convert-to.deb

cd $DIR

mv $FILE.tar.gz $FILE

rm -fr $EXTRACT

echo "Done creating $FILE-convert-to.deb package." 

exit 0
