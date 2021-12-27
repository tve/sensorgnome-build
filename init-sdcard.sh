#! /bin/bash -e
if [[ ! -d /run/media/$USER/boot ]]; then
    echo "Cannot find SD card at /run/media/$USER/boot"
    echo "Did you perhaps forget to remove and re-insert the SD card after flashing?"
    exit 1
fi

set -x
cp network.txt /run/media/$USER/boot/
cp SG_tag_database.sqlite /run/media/$USER/boot/

PI=/run/media/$USER/rootfs/home/pi
mkdir -p $PI/.ssh
cat ~/.ssh/*.pub >>$PI/.ssh/authorized_keys
chmod 644 $PI/.ssh/* || true
sync
