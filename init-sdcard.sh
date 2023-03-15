#! /bin/bash -e
if [[ ! -d /run/media/$USER/bootfs ]]; then
    echo "Cannot find SD card at /run/media/$USER/bootfs"
    echo "Did you perhaps forget to remove and re-insert the SD card after flashing?"
    exit 1
fi

MNT=/run/media/$USER
PI=$MNT/rootfs/home/gnome

cp ~/.tmux.* $PI || true
cp ~/.ssh/*.pub $MNT/bootfs
#cp SG_tag_database.sqlite /$MNT/bootfs

sync
