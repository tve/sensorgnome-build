#! /bin/bash -e
if [[ -z $1 ]]; then echo "usage: $0 <url>"; exit 1; fi
dev=$(lsblk -d -o NAME,VENDOR,SIZE | egrep 'RPi-MSD.*[2356][0-9]\.[0-9]G' | cut -d" " -f1)
if [[ -z $dev ]]; then echo "No device found"; exit 1; fi
dev=/dev/$dev
echo "Flashing $dev: $(lsblk -dn -o VENDOR,MODEL,SIZE $dev)"

url=$1
zip=$(basename $1)
img=$(basename $1 zip)img
cd /tmp
if ! [[ -f $zip ]]; then
    echo Downloading $url
    wget -nv -O $zip $url
fi
echo Unmounting
umount /run/media/$USER/* 2>/dev/null || true
sudo rpiusbboot
echo Flashing $dev
7z e -so $zip $img | sudo dd of=$dev bs=10M
