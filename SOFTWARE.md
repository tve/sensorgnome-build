SensorGnome Software Installation
=================================

The initial installation consists of flashing an SDcard with a Sensorgnome release image,
booting the rPi, connecting to it, configuring it via the web UI, and verifying the
correct operation.

Flashing the SDcard
-------------------

For reliable long term operation in a Raspberry Pi a quality SDcard is highly recommended.
The "endurance" series from Samsung or Sandisk are good examples,
the Samsung EVO series is OK too.
In 2021 a Samsung PRO Endurance 32GB card costs $9 on Amazon US, 
but be sure to buy a "sold by Amazon" and not from some shady outfit...

A complete disk image needs to be flashed to the SDcard, which is most reliably done using
a specialized application.
The recommended app on Windows and Linux is [Balena Etcher](https://www.balena.io/etcher/)
(there is a MacOS version too, untested),
but any other application that works to flash Raspberry Pi OS images will work.
The Sensorgnome image is just an enhanced rPi image.

Etcher can directly download the Sensorgnome image given a URL, when using a different
application it may be necessary to first download the image manually.
Also, when preparing multiple SDcards it may be faster to download manually only once.
As of this writing there is no official download location for Sensorgnome images,
the provisional location is (`XXX` is a placeholder):
[https://sensorgnome.s3.amazonaws.com/images/pimod/sg-armv7-rpi-bullseye-2022-XXX.zip](https://sensorgnome.s3.amazonaws.com/images/pimod/sg-armv7-rpi-bullseye-2022-XXX.zip).

After booting the Sensorgnome a laptop or phone with a web browser are required in order to
configure it using the Sensorgnome's hot-spot (Wifi access point).

### Steps

1. Plug the SDcard into a laptop/computer.
2. Launch Etcher, select "flash from URL", enter the image URL (e.g. like above),
   select the SDcard as destination, start the flashing process.
3. Remove the SDcard and plug it into the rPi, power on the rPi. It will take up to a minute
   for the rPi to initialize and start its hot-spot.
4. To connect to the hot-spot look for an SSID of the form SG-1234RPI3ABCD and
   connect to it. This should automatically bring up a browser with instructions. If it doesn't,
   bring up a browser at `http://192.168.7.2/'.
5. Follow the instructions to set a password for the Sensorgnome, a short name, and a password
   for the hot-spot. You will have to reconnect to the hot-spot using the password after
   setting it.
6. When reconnecting the Sensorgnome Web UI should automatically come up in the browser,
   if not, navigate again to `http://192.168.7.2`.
7. Please proceed to [Configure and Verify Radios](RADIO-CONFIG.md).

### FAQ

#### Why a disk image?

The reason the Sensorgnome release is distributed as disk images is that the system requires
2 disk partitions (two filesystems).
One small FAT32 partition which the boot loader understands and can load the initial program from.
And then one large partition that has a proper Linux filesystem that is way too complex for a
bootloader and that the entire system runs from (and that "gets started" by that "initial program").
The image packs everything together (and is the standard way of doing these things).

Previous versions of Sensorgnome had only one large FAT32 partition occupying the entire SDcard
and instead of having a second partition for the linux filesystem they put that
inside one big file within the FAT32 partition.
So it was a bit like nested dolls.
Technically that works, but the performance suffers because every filesystem access
requires two levels of mapping and access, and it's very unconventional though creative.

#### Why does flashing require root/admin/superuser permissions?

In order to write an image to a disk one has to read/write to the raw disk, which inherently
provides access to all the data that may be on the disk.
That's a security issue in that it circumvents all the access controls that the operating
system normally imposes on disk access.
For this reason the operating system only allows the super-user/root/admin to access raw disk.
And that's why Etcher (and any program that writes an image) has to ask for this permission.

#### Is there any alternative to using the hot-spot for initial configuration?

No & yes. The hot-spot method was chosen because it functions pretty much automatically
on almost any laptop or phone. There are two alternatives that are not currently supported,
but could be tested & documented if there is significant demand:

- The Sensorgnome Web UI can be reached over Ethernet (if plugged in) or over WiFi (if there
  is an open network), this is not promoted because of security issues. The sticking point
  is that the Web UI uses HTTPS but there is no simple solution for providing the required
  certificate resulting in obscure browser warnings (that are being eliminated
  in favor of outright blocking) and DNS issues.
- Appropriate configuration files could be preinstalled on the SDcard at the time of flashing
  and before the first boot. Until the config files are stable this is a bit premature and
  the exact use-case is not obvious when considering that each Sensorgnome does need some
  interactive configuration and verification that all the radios and connectivity work as
  intended.

#### What are all the partitions on the SDcard for?

When the SDcard is initially flashed from the image there are two partitions/filesystems:

- a 256MB `boot` partition holding a FAT32 filesystem that is used in the initial boot stage.
- an approx 3GB `rootfs` partition holding an EXT4 Linux filesystem with the operating system,
  this partition cannot (easily) be mounted on a Windows system and may show up as empty or
  unused, but it certainly isn't!
- the rest of the SDcard is empty/unpartitioned.

When the SDcard is first booted a third partition is created:

- a large `data` partition filling the rest of the SDcard (e.g. about 26GB on a 32GB card) holding
  a FAT32 filesystem that is used to store the Sensorgnome's config and data.
