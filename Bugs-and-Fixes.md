**Changes for DebianDog-Wheezy-JWM iso version for next iso update:**

**1.** Keep only official Wheezy repoes in sources.list (no more special dd-repository for fixes and new packages by default).
Fixes will be provided different way (maybe as single deb for download and install-reinstall after reading the fixes post).

**2.** Change the main module compression from xz to gzip also in all scripts using mksquashfs command).

**3.** Frisbee will be replaced with Ceni (CLI script using only official Wheezy dependencies).

**4.** Remove some packages like lxlauncher, galculator, gdrive-get, elinks and some menu entries.
(make separate package with sfs-get only like in MintPup).

**5.** Changes in some scripts like pet2sfs, pet2deb (add warning + support for xz compressed pet packages), resize-save (add terminal output), peasyglue (to keep empty /opt/lib), 

**6.** Skip removing /etc/resolv.conf in all remastering scripts (because this breaks the official resolvconf package).
Add CLI versions for both remasterdog and remastercow.

**7.** Use older ffmpeg2sfs version (without backup-restore option for dpkg files).



**List of DebianDog-Wheezy fixes found after 04.09.2015 (will be included in next JWM iso update):**


**1.** Latest debdoginstallscripts from Fred - version 1.0.8:
```
sudo apt-get update
sudo apt-get install debdoginstallscripts
```
Or download and install the package
[debdoginstallscripts_1.0.8_i386.deb](http://www.smokey01.com/saintless/DebianDog/Packages/Included/debdoginstallscripts_1.0.8_i386.deb)

**2.** Some fixes from Fred for fixdepinstall (install deb and dependencies right click option).
[More information read here.](http://murga-linux.com/puppy/viewtopic.php?p=871384#871384)
Install fixed version from the link above or from terminal:
```
sudo apt-get update
sudo apt-get install fixdepinstall
```

**3.** Fix for squashfs module loading scripts from Fred. [More information read here.](http://murga-linux.com/puppy/viewtopic.php?p=878996#878996)
```
sudo apt-get update
sudo apt-get install sfsload portablesfs-loadsfs-fuse
```

**4.** Small fix for apt2sfs. [More information read here.](http://murga-linux.com/puppy/viewtopic.php?p=885536&sid=e09b92e591e85bcc4632168abdb32e5b#885536)
```
sudo apt-get update
sudo apt-get install apt2sfs
```

**5.** Fix for XDM login manager. In case XDM is activated using porteus-boot save on Exit and typing reboot command in terminal (instead using the Reboot-Shutdown menu) does not give option **not to save** changes. [More information read here.](https://github.com/DebianDog/Jessie/issues/2)
To fix this just reisntall XDM (make sure to install debdog-repo-updater first and run apt-get update again - the previous fix):
```
sudo apt-get update
sudo apt-get install --reinstall xdm

```
Or download and install the package [xdm_1.1.11-2_i386.deb](http://smokey01.com/saintless/DebianDog/Packages/Included/xdm_1.1.11-2_i386.deb)

**6.** With porteus-boot and only when using save on exit code upgrading libc6 could create some issues. More information and workarownd read [here](http://murga-linux.com/puppy/viewtopic.php?p=889934&sid=00f59036fe7b1df6f8bc7168fe1df597#889934) and the fix [here.](http://murga-linux.com/puppy/viewtopic.php?p=890342&sid=00f59036fe7b1df6f8bc7168fe1df597#890342)
Install this package to fix the problem (and some improvements for save on exit - I will include porteusbootscripts version 0.0.2:
```
sudo apt-get update
sudo apt-get install porteusbootscripts=0.0.2

```
