Support for persistence save file on NTFS partition needs replacing mount and umount with links to busybox v.1.21.1
and removing /lib/modules/3.2.0-4-486/kernel/fs/ntfs/ntfs.ko
And some changes in /bin/boot/9990-misc-helpers.sh functions. Copy the changed script also in /lib/live/boot/
I don't know why all boot scripts exist in both /bin/boot and /lib/live/boot but this is the way update-initramfs 
command generates the initrd.img
