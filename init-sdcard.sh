#! /bin/bash -e
MNT=/run/media/$USER
BOOT=$(echo -n $MNT/boot*)

if [[ ! -d $BOOT ]]; then
    echo "Cannot find SD card at $MNT/boot*"
    echo "Did you perhaps forget to remove and re-insert the SD card after flashing?"
    exit 1
fi

PI=$MNT/rootfs/home/gnome

cp ~/.tmux.* $PI || true
cp ~/.ssh/*.pub $BOOT
#cp SG_tag_database.sqlite /$MNT/bootfs

sync
