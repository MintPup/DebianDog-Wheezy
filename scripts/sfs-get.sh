#!/bin/bash

# By fredx181 for DebianDog.
# 20160917 - saintless, remove gsu dependency, add cli version message in case yad is not installed,
#            check for internet connection and small mods to download from github. Search for #github mod.
#            Remove /tmp/sfs.txt on exit. Users can't delete it without sudo (The CLI version runs without sudo).
#            GNU GPL v3 applies. No warranty of any kind... Use it at your own risk!


if [ -z `which yad` ];then
xmessage "Yad is missing. For CLI version type in terminal:
sfs-get-cli"
exit 0
else
echo "Starting GUI version."
fi

if [ -z `which gsu` ];then
[ "`whoami`" != "root" ] && x-terminal-emulator -e sudo env LD_LIBRARY_PATH=/usr/local/lib ${0} "$@"
else
[ "`whoami`" != "root" ] && exec gsu ${0} "$@"
fi

if ping -c1 duckduckgo.com 2>&1 | grep unknown; then
xmessage "You dont have working internet connection. Exiting now."
exit 1
else
echo "Working internet connection found."
fi

# Variables for host directory and contents file:
#HOSTDIR="https://googledrive.com/host/0B8P7qC27sushWHg2VFB6QTRJLW8/DebianDog-Wheezy/Extra-Modules"
#HOSTDIR="http://kazzascorner.com.au/saintless/DebianDog/DebianDog-Jessie/Extra-modules"
HOSTDIR="https://github.com/DebianDog/Wheezy/releases/download/v0.1/"
CONTENTFILE="sfs.txt"

# Set GUI variables up
TITLE="YAD wget downloader"                 # dialog title
TEXT="             <b>Downloads</b> in progress:"        # dialog text
ICON="browser-dload"                     # window icon (appears in launcher)
IMAGE="browser-dload"                    # window image (appears in dialog)

# Remove possible existing contents file:
[ -f /tmp/$CONTENTFILE ] && rm -f /tmp/$CONTENTFILE

# Download sfs.txt to /tmp to read list of available modules further by the script.
# It assumes "sfs.txt" is in DebianDog/Extra-Modules/
cd /tmp
wget --no-check-certificate "$HOSTDIR"/$CONTENTFILE -O $CONTENTFILE #github mod.
ALL=`cat /tmp/$CONTENTFILE`
LIST=$(yad --separator=" " --image="application-x-squashfs" --image-on-top --center --height 500 --width="500" --list --title="Download SFS module" --multiple --text=" Download SFS modules (.squashfs or .sfs). \n Select (multiple) items to download." --column " Available Modules" $ALL --button="gtk-cancel:1" --button="gtk-ok:0")
ret=$?
[[ $ret -ne 0 ]] && exit 1
echo $LIST

# Usage check
 if [[ -z "$LIST" ]]
  then
      echo "Error: No arguments provided"
      yad  --center --title="Download SFS modules" --image="application-x-squashfs" --text "  Nothing selected! \n  Please try again. "
      [[ $ret -ne 0 ]] && exit 1
      exec ${0}
fi

# Add the $HOSTDIR address in front of the sfs name
#URILIST="`echo "$LIST" | sed "s,^,$HOSTDIR/," | sed ':a;N;$!ba;s/\n/ /g'`"
URILIST="`echo "$LIST" | sed "s,^,$HOSTDIR/," | tr '\n' ' '`"

# Select folder to download to:
SAVEFOLDER=$(yad  --center --image="application-x-squashfs" --image-on-top --title="Select folder to download SFS modules" --file --filename /media/ --directory --height=600 --width=800 --text=" Select folder to download SFS modules to" )
ret=$?
[[ $ret -ne 0 ]] && exit 1

MAXDLS="5" # set maximum number of simultaneous downloads

# download file and extract progress, speed and ETA from wget
# we use sed regex for this
# source: http://ubuntuforums.org/showthread.php?t=306515&page=2&p=7455412#post7455412
# modified to work with different locales and decimal point conventions
download(){
echo save="$SAVEFOLDER" 
    cd "$SAVEFOLDER"
    #github mod below:
    wget --no-check-certificate "$1" -O $FILENAME 2>&1 | sed -u \
    "s/.* \([0-9]\+%\)\ \+\([0-9,.]\+.\) \(.*\)/$2:\1\n$2:# Downloading at \2\/s, ETA \3/"
    RET_WGET="${PIPESTATUS[0]}"             # get return code of wget
    if [[ "$RET_WGET" = 0 ]]                # check return code for errors
      then
          echo "$2:100%"
          echo "$2:#Download completed."
      else
          echo "$2:#Download error."
    fi
}


# compose list of bars for yad
for URI in $URILIST; do                     # iterate through all URIs
    FILENAME="${URI##*/}"                   # extract last field of URI as filename
    YADBARS="$YADBARS --bar=$FILENAME:NORM" # add filename to the list of URIs
done

IFS=" "
COUNTER="1"
DYNAMIC_COUNTER="1"

# main
# iterate through all URIs, download them in the background and 
# pipe all output simultaneously to yad
# source: http://pastebin.com/yBL2wjaY

for URI in $URILIST; do
    if [[ "$DYNAMIC_COUNTER" = "$MAXDLS" ]] # only download n files at a time
      then
          download "$URI" "$COUNTER"        # if limit reached wait until wget complete
          DYNAMIC_COUNTER="1"               # before proceeding (by not sending download() to bg)
      else
          download "$URI" "$COUNTER" &      # pass URI and URI number to download()
          DYNAMIC_COUNTER="$[$DYNAMIC_COUNTER+1]"
    fi
    
    [ -f /tmp/$CONTENTFILE ] && rm -f /tmp/$CONTENTFILE #saintless - remove /tmp.sfs.txt on exit. Users can't delete this file without sudo.
    
    COUNTER="$[$COUNTER+1]"                 # increment counter
done | yad --multi-progress --auto-kill $YADBARS --title "$TITLE" \
--text "$TEXT" --window-icon "$ICON" --image "$IMAGE"

# ↑ launch yad multi progress-bar window