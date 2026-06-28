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
* Using btrfs to mirror critical data with redundancy

The file and folder structure of the repository is a template of sorts that others may be able to reuse for their needs.  Start with modifying common.sh and then modify other files from there.

## Assumptions

* A wired internet connection is available and used for the entire process

## Process Overview

1. Back up files
1. Prepare USB automation drive and UEFI firmware
1. Prepare USB installer drive
1. Reboot
1. Update UEFI firmware
1. Configure BIOS and motherboard
1. Installation
1. Post installation

Two separate USB drives are needed to support the installation process.

## Prepare USB Automation Drive and UEFI Firmware

Run the following commands on one USB drive.

```
sudo sgdisk -Z /dev/sdX
sudo sgdisk -n 1:1M:+4G -t 1:8302 -c 1:files /dev/sdX
mkfs.fat -F32 /dev/sdXN
cp -rf arch-linux-setup-scripts <mounted /dev/sdXN>
cp -f *.CAP <mounted /dev/sdXN>
```

## Prepare USB Installer Drive

Download the Arch Linux installer ISO image and then use the following commands on the other USB drive.

```
sudo sgdisk -Z /dev/sdY
sudo dd if=archlinux-x86_64.iso of=/dev/sdY bs=1M status=progress
```

## Update UEFI Firmware

Within the ASUS UEFI menus, browse to the USB automation drive with the new firmware file to perform the update.  This may only be done from a FAT32 filesystem.

## BIOS and Motherboard Configuration

A few one-time firmware settings and physical switch changes are needed on the ASUS Pro WS W880-ACE SE.

Change the following from their defaults in the UEFI firmware menus:

* **Advanced > CPU Configuration > Total Memory Encryption → Enabled.**  Turns on Intel Total Memory Encryption.  GNOME's built-in Device Security assessment expects this for a hardened system.
* **Advanced > APM Configuration > ErP Ready → Enabled (S4+S5).**  Cuts standby power in the hibernate (S4) and soft-off (S5) states.  Without it, the board's firmware wakes the machine moments after it powers down for hibernation, interrupting the cycle and preventing a clean resume.

The following ship enabled by default, but the encrypted, hardware-backed setup depends on them, so confirm they remain enabled:

* **Advanced > System Agent (SA) Configuration > VT-d → Enabled.**  Exposes the Intel IOMMU so the kernel can confine each device's direct memory access.  The `intel_iommu=on iommu.strict=1 iommu.passthrough=0` parameters on the systemd-boot entries depend on it; together they block DMA attacks that could otherwise read LUKS keys out of RAM while the machine is suspended.  This also backs the firmware's pre-boot DMA protection, which guards the window before the kernel's IOMMU takes over (GNOME's Device Security report lists it separately as *Pre-boot DMA Protection*).  After booting, confirm it is active with `cat /sys/kernel/iommu_groups/*/type` — every group should read `DMA`, not `identity`.
* **Advanced > PCH-FW Configuration > PTT → Enabled.**  Turns on Intel Platform Trust Technology, the CPU's built-in firmware TPM 2.0.  This presents `/dev/tpmrm0`, which `systemd-cryptenroll` can use to seal a LUKS key to the Secure Boot state for password-less unlock.

Set the following physical switches on the motherboard while the system is powered off.  This board is a server/desktop hybrid, and disabling the unused components shortens boot time:

* **Switch 13 (BMC) → off.**  Disables the onboard baseboard management controller.
* **Switch 29 (VGA) → off.**  Disables the onboard VGA output.

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

This sections contains instructions to follow after a system has been fully restored with most of its configurations and data and is mostly functional.

### Configure Storage

Bulk data is stored on a btrfs RAID1 mirror layered on LUKS.  LUKS underpins both drives and systemd-boot unlocks them during startup; btrfs then mirrors the data with end-to-end checksums, so bit rot is detected and self-healed from the good copy.  Because btrfs is in the mainline kernel, it never holds back a kernel update the way an out-of-tree module like ZFS can.

Run the following to set up storage.  This destroys all data on both devices:

```
sudo ./storage.sh /dev/sdA /dev/sdB
```

This creates a generic mount point at `/data` (a dedicated btrfs subvolume) that can be used for anything, scrubbed monthly by `btrfs-scrub@data.timer` to verify and repair the mirror.

### Install GNOME Shell Extensions

Browse to the [GNOME Shell Extensions](https://extensions.gnome.org) website, install the GNOME Shell integration browser extension from the banner, and then install the following GNOME Shell extensions:

* ArcMenu
* Dash to Panel
* Night Theme Switcher
* Power Off Options

### Configure the Steam Client

By default Steam disables GPU accelerated rendering in its web views on NVIDIA.  Since the entire client UI--including Big Picture mode--is rendered by the CEF (Chromium) web helper, this forces it to composite in software.  On a 4K display that makes the client and Big Picture mode painfully slow.  To fix it:

1. Open **Steam > Settings > Interface**.
1. Enable **Enable GPU accelerated rendering in web views**.
1. Restart Steam.

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
