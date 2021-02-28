#!/bin/bash
aurman -Sy --noconfirm --noedit wd719x-firmware aic94xx-firmware upd72020x-fw
sudo mkinitcpio -p linux
