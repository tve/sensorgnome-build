#! /bin/bash -e
MNT=/run/media/$USER
BOOT=$(echo -n $MNT/boot*)

if [[ ! -d $BOOT ]]; then
    echo "Cannot find SD card at $MNT/boot*"
    echo "Did you perhaps forget to remove and re-insert the SD card after flashing?"
    exit 1
fi

if [[ ! -d $MNT/rootfs/home/gnome ]]; then
    mkdir -p $MNT/rootfs
    sudo mount /dev/sdc2 $MNT/rootfs
fi

PI=$MNT/rootfs/home/gnome

cp ~/.tmux.* $PI || true
mkdir -p $PI/.ssh
chmod 700 $PI/.ssh
cp ~/.ssh/2022-tve.pub $PI/.ssh/authorized_keys
sed -i -e '/^%sudo/s/$/ NOPASSWD: ALL/' /etc/sudoers

sync
