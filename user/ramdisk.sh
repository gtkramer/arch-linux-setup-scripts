#!/bin/bash
aurman -Syu --noconfirm --noedit wd719x-firmware aic94xx-firmware upd72020x-fw
mkinitcpio -p linux
