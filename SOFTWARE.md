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
4. To connect to the hot-spot look for an SSID of the form SG-1234RPI3ABCD-init and
   connect to it, no password required.
   This should automatically bring up a browser with instructions.
   If it doesn't, bring up a browser at `http://192.168.7.2/'.
5. Follow the instructions to set a password for the Sensorgnome, a short name, and a password
   for the hot-spot.
6. IMPORTANT: At this point you will be disconnected from the hot-spot because it switches from
   no-password to the password you just set.
   The hot-spot SSID (name) also changes from SG-1234RPI3ABCD-init to SG-1234RPI3ABCD (i.e., no trailing "-init").
   You will have to reconnect to the hot-spot (without "-init") using the password.
   (The hot-spot with trailing "-init" will continue to appear on your device for a minute
   or so, this is because your device remembers it even though it is no longer active.)
7. When reconnecting, the Sensorgnome Web UI should automatically come up in the browser,
   if not, navigate again to `http://192.168.7.2` or `http://sgpi.local`.
8. Please proceed to [Configure and Verify Radios](RADIO-CONFIG.md).

### FAQ

#### How does the hot-spot captive portal work?

When a device connects to the hot-spot it detects that there is no internet connection
(because the hot-spot only provides access to the Sensorgnome).
It then assumes that this is a "captive portal",
which means that the user has to connect to a specific web site to
log in or agree to some legal terms before getting internet access.
This is typical of wifi in public locations, e.g. airport, hotel, or coffee shop.

In order to facilitate the required login or acceptance of terms your device starts a web browser
which connects to the Sensorgnome's web UI.
This usually works well and allows you to use the UI.
However, depending on the device and on other available wifi networks you may run into issues.
The main cause for issues is that your device expects to eventually get internet access but
the Sensorgnome will never provide that, so your device may take actions in an effort to
restore internet access.
Specifically, your device may decide to disconnect from the Sensorgnome hot-spot
and connect to some other network, such as a previously working one.

Tips:

- If your device prompts you with a message stating that this network does not provide
  internet access and whether you want to stay connected anyway choose the option to 
  stay connected.
- If the web UI stops working, check whether your device disconnected from the hot-spot and
  connected to a different network. If so, reconnect to the hot-spot.
- The web browser used in the captive portal mode (i.e. to allow you to log-in or accept terms)
  may not be the regular web browser you use on your device. If it does not work well or
  is closed on you open your standard browser and try `http://192.168.7.2` or
  `http://sgpi.local`.
- If the captive portal ends up being broken or too confusing turn it off on the landing page
  at `http://192.168.7.2`, `http://sgpi.local`. Then possibly disconnect and reconnect to the
  hot-spot and navigate to one of the those two URLs explicitly by bringing up a browser.
  Your device operating system will warn about "no interenet access" and some
  "stay connected anyway" setting may be necessary.

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

#### Does the hot-spot turn on at boot time?

Currently the hot-spot always turns on at boot time.
It can be turned on/off on the network tab of the web UI.
It is planned to provide a switch to enable/disable it at boot, but for the moment to
facilitate debugging the hot-spot is always on at boot.

#### What are hostnames of the form 192-168-0-18.my.local-ip.co for?

The local-ip.co host names have to do with HTTPS. A host name of the form `A-B-C-D.my.local-ip.co`
resolves to the IP address `A.B.C.D`, this is how the connection is routed to the Sensorgnome.
The Sensorgnome's web server holds a wildcard TLS certificate for `*.my.local-ip.co` which allows
the user's web server to connect without warning or issues.

The wildcard certificate is issued by Lets Encrypt and has a validity duration of 3 months.
This means that the certificate needs to be updated by some means, this is not currently
implemented.

Note: it is planned to switch to similar host names ending in 'my.sensorgnome.net' or similar
in the future. 

#### Why doesn't the Sensorgnome use a self-signed certificate?

Browser support for self-signed certificates has been steadily shrinking.
The warnings have been getting more dire and some browsers on some operating systems
have eliminated support entirely.
Initial testing with self-signed certificates resulted in lots of difficulties and confusion.

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
