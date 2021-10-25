#!/bin/sh -e

# Install the previously copied packages in the chroot.
on_chroot << EOF
echo "Setting up nodejs repository."
#curl -fsSL https://deb.nodesource.com/setup_12.x | sudo -E bash -
echo 'deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_12.x buster main' >/etc/apt/sources.list.d/nodesource.list
cp files/nodesource.gpg /usr/share/keyrings/nodesource.gpg

echo "Installing Sensorgnome Packages."
apt install -y /tmp/sg/fcd_0.5-1.deb
apt install -y /tmp/sg/find_tags_0.5-1.deb
apt install -y --reinstall /tmp/sg/sensorgnome-support_0.5-1.deb
#apt install -y --reinstall /tmp/sg/sensorgnome-control_0.5-1.deb
apt install -y /tmp/sg/sensorgnome-librtlsdr_0.5-1.deb
#apt install -y /tmp/sg/sensorgnome-openssh-portable_0.5-1.deb
apt install -y /tmp/sg/vamp-alsa-host_0.5-1.deb
apt install -y /tmp/sg/vamp-plugins_0.5-1.deb
EOF
