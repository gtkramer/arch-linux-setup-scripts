# Arch Linux Setup Scripts

Given the decision was made to not support a GUI installer for a long time, Arch Linux has required expert installation knowledge in recent times.  This is a collection of scripts based off [the official installation guide](https://wiki.archlinux.org/title/installation_guide) that help with automating the install of Arch Linux for my particular needs, which are:

* Using Linux on a Lenovo ThinkPad
* Using a modern desktop environment
* Developing in C#
* Using general image, video, document, and messaging productivity tools
* Using programs that support a security orientation

The file and folder structure of the repository is a template of sorts that others may be able to reuse for their needs.  Start with modifying parameters.sh and then modify other files from there.

## Assumptions

* A wired internet connection is available and used for the entire process
* An OPAL self-encrypting drive is being used to support hardware-level encryption

## Preparation

1. Back up files
1. Configure BIOS/UEFI
    * Give USB devices boot priority
    * UEFI only mode with no CMS support
1. Update BIOS/UEFI firmware
    * Check if microcode is updated by BIOS/UEFI vendor
1. Prepare USB automation drive
1. Prepare USB installer drive

### Update BIOS/UEFI Firmware

Download and uncompress a bootable update CD image and then use the following commands.

```
aurman -Syu --noconfirm --noedit geteltorito
sudo usermod -a -G optical "$USER"
geteltorito.pl -o bios.img gjuj28us.iso
sudo sgdisk -Z /dev/sdX
sudo dd if=bios.img of=/dev/sdX bs=1M
```

Reboot and follow the on-screen instructions.

### Prepare USB Automation Drive

```
sudo sgdisk -Z /dev/sdX
sgdisk -n 1:0:0 -t 1:8302 -c 1:files /dev/sdX
mkfs.ext4 -F /dev/sdX
cp -r arch-linux-setup-scripts <mounted /dev/sdX>
```

### Prepare USB Installer Drive

Download the Arch Linux installer ISO image and then use the following commands.

```
sudo sgdisk -Z /dev/sdX
sudo dd if=archlinux-2016.10.01-dual.iso of=/dev/sdX bs=1M
```

Reboot and follow the instructions for installation and post installation.

## Installation

Boot into the live environment and then use the following commands.

```
mount /dev/sdX /root/files
cd /root/files/boot
./install.sh
cd ~
umount /root/files
arch-chroot /mnt
mount /dev/sdX /mnt
cd /mnt/boot
./bootstrap.sh
cd ../chroot
./install.sh
```

Exit out of the chroot environment and reboot the machine.  Upon logging into the desktop, execute the desired scripts from the user folder.

## Post Installation

Verify boot order.  Have external devices first with the Arch Linux entry just above the HDD entry.
