# Arch Linux Setup Scripts

Given the decision was made to not support a GUI installer for a long time, Arch Linux has required expert installation knowledge in recent times.  This is a collection of scripts based off [the official installation guide](https://wiki.archlinux.org/title/installation_guide) that help with automating the install of Arch Linux for my particular needs, which are:

* Using a modern and simple desktop environment
* Developing in C#
* Using general image, video, document, and messaging productivity tools
* Using programs that support a security orientation
* Using a discrete NVIDIA GPU to have
  * Excellent gaming performance to replace a console
  * Excellent video encoding performance to back up optical media
* Using an ASUS motherboard
* Using ZFS to mirror critical data with redundancy

The file and folder structure of the repository is a template of sorts that others may be able to reuse for their needs.  Start with modifying common.sh and then modify other files from there.

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

If the USB automation drive contains a LUKS partition that needs to be unlocked, it may be done so by doing:

```
cryptsetup open /dev/sdX cryptusb
```

Then, instead of using /dev/sdX, use /dev/mapper/cryptusb to mount the device.

```
cd ~
mkdir files
mount /dev/sdX files
cd files/boot
./install.sh <block device>
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

## Post Installation

This is the section containing instructions for doing that after a system has been fully restored with most configurations, most data, and is mostly functional.

### Configure ZFS Storage

ZFS storage is configured for mirroring with a ZFS-on-LUKS approach.  LUKS underpins all drives, and systemd-boot unlocks the drives during startup.  From there, regular system operations take over with no special configurations--the encryption is transparent to most everything else.

The LTS branches of the Kernel and associated modules are used to prioritize stability and "it just works".  After confirming that the ZFS module is available for the LTS Kernel in use, run the following to set up ZFS storage:

```
sudo ./storage.sh /dev/sdA /dev/sdB
```

This will create a generic mount point at `/data` that can be used for anything.

### Install GNOME Shell Extensions

Browse to the [GNOME Shell Extensions](https://extensions.gnome.org) website, install the GNOME Shell integration browser extension from the banner, and then install the following GNOME Shell extensions:

* ArcMenu
* Dash to Panel
* Night Theme Switcher

### Enable UEFI Secure Boot

The script installs `/usr/local/sbin/secure-boot-sign` and `/etc/pacman.d/hooks/99-secure-boot-sign.hook` so kernel and systemd updates automatically trigger signing.  Hook `99` is intentionally ordered after the existing `95-systemd-boot.hook`, so `systemd-boot` is copied first and then signed.

#### First-Time Key Enrollment

1. Reboot into UEFI firmware and open `Boot > Secure Boot`.
1. Set `OS Type` to `Windows UEFI Mode`.
1. Set `Secure Boot Mode` to `Custom`.
1. Open `Key Management` and do `Clear Secure Boot keys`.
1. Exit saving changes and reboot into Linux.
1. Create keys, sign bootloader, and enroll keys:

   ```
   sudo ./chroot/secure-boot.sh -e
   ```

1. Back up private signing keys and store them securely:

   ```
   sudo tar -C /var/lib/sbctl -czf ~/sbctl-keys.tar.gz keys
   ```

1. Reboot into Linux.
1. Verify Secure Boot and signing status (see `Verify Secure Boot` below).

#### Reuse Existing Enrolled Keys on Reinstalls

1. Reboot into UEFI firmware and open `Boot > Secure Boot`.
1. Set `OS Type` to `Other OS`.
1. Exit saving changes and reboot into Linux.
1. Start and finish Linux install process.
1. Import keys and sign bootloader:

   ```
   tar -xzf ~/sbctl-keys.tar.gz -C /tmp
   sudo ./chroot/secure-boot.sh -k /tmp/keys
   ```

1. Reboot into UEFI firmware and open `Boot > Secure Boot`.
1. Set `OS Type` to `Windows UEFI Mode`.
1. Exit saving changes and reboot into Linux.
1. Verify Secure Boot and signing status (see `Verify Secure Boot` below).

If firmware keys were reset or cleared, use the first-time enrollment flow again.

#### Verify Secure Boot

```
sudo bootctl status
sudo sbctl status
sudo sbctl verify
```
