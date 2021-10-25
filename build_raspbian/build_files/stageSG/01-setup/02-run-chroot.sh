#!/bin/sh -e

# Set up data and config directories.
on_chroot << EOF
    echo "Creating data directory"
    mkdir -p /data
    mkdir -p /data/config
    mkdir -p /data/SGdata
    
    echo "Creating symlinks for deprecated /boot mount points."
    ln -s /data/config /boot/uboot
    ln -s /data/SGdata /boot/SGdata
EOF
