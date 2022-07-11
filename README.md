# Arch Linux Setup Scripts

Given the decision was made to not support a GUI installer for a long time, Arch Linux has required expert installation knowledge in recent times.  This is a collection of scripts based off [the official installation guide](https://wiki.archlinux.org/title/installation_guide) that help with automating the install of Arch Linux for my particular needs, which are:

* Using a modern and simple desktop environment
* Developing in C#
* Using general image, video, document, and messaging productivity tools
* Using programs that support a security orientation
* Using a discrete NVIDIA GPU to support graphically-intense workflows
* Using an ASUS motherboard

The file and folder structure of the repository is a template of sorts that others may be able to reuse for their needs.  Start with modifying parameters.sh and then modify other files from there.

## Assumptions

* A wired internet connection is available and used for the entire process

## Process Overview

1. Back up files
1. Prepare USB automation drive and UEFI firmware
1. Prepare USB installer drive
1. Reboot
1. Update UEFI firmware
1. Installation
1. Post installation

Two separate USB drives are needed to support the installation process.

### Prepare USB Automation Drive and UEFI firmware

Run the following commands on one USB drive.

```
sudo sgdisk -Z /dev/sdX
sudo sgdisk -n 1:1M:+4G -t 1:8302 -c 1:files /dev/sdX
mkfs.fat -F32 /dev/sdXN
cp -rf arch-linux-setup-scripts <mounted /dev/sdXN>
cp -f *.CAP <mounted /dev/sdXN>
```

### Prepare USB Installer Drive

Download the Arch Linux installer ISO image and then use the following commands on the other USB drive.

```
sudo sgdisk -Z /dev/sdY
sudo dd if=archlinux-2016.10.01-dual.iso of=/dev/sdY bs=1M
```

### Update UEFI Firmware

Within the ASUS UEFI menus, browse to the USB automation drive with the new firmware file to perform the update.  This may only be done from a FAT32 filesystem.

## Installation

Boot into the live environment with the two USB drives plugged in and then use the following commands to create a bootable system.

```
cd ~
mkdir files
mount /dev/sdX files
cd files/boot
./install.sh
cd ~
umount files
arch-chroot /mnt
mount /dev/sdX /mnt
cd /mnt/boot
./bootstrap.sh
exit
reboot
```

Log in as root.  Use the following commands to minimally configure the system and add a GUI desktop.

```
mount /dev/sdX /mnt
cd /mnt/chroot
./install.sh
reboot
```

Upon logging into the desktop, execute the desired scripts from the user folder.

## Post Installation

Verify boot order.  Have external devices first with the Arch Linux entry just above the HDD entry.
