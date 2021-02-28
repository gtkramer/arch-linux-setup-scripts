#!/bin/bash
gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8FD3D9A8D3800305A9FFF259D1742AD60D811D58
aurman -Sy --noconfirm --noedit spotify
