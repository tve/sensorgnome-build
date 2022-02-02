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

After booting the Sensorgnome a network connection and a web browser are required in order to
verify its operation. There are several options:

- Connect to the Sensorgnome's hot-spot with a laptop or phone.
- Use an Ethernet cable to connect the rPi to a laptop or to the local LAN.
- After step 2 below, create a `wpa_supplicant.conf` file in the boot partition with a local WiFi
  access point SSID/passphrase so it joins that network (this is std Raspberry Pi functionality,
  more info in the next section).

Note that all three forms of network can be used at the same time!
In particular, if WiFi or Ethernet are giving trouble don't disconnect/power off:
try to connect to the hot-spot and go from there!

### Steps

1. Plug the SDcard into a laptop/computer.
2. Launch Etcher, select "flash from URL", enter the image URL (e.g. like above),
   select the SDcard as destination, start the flashing process.
3. Remove the SDcard and plug it into the rPi, power on the rPi. It will take up to a minute
   for the rPi to initialize, start its hot-spot and connect to ethernet/wifi if appropriate.
4. To connect to the hot-spot (recommended) look for an SSID of the form SG-1234RPI3ABCD and
   connect to it. This should automatically bring up a browser with instructions. If it doesn't,
   bring up a browser at `https://192.168.7.2/' and click through the security warnings (due to
   using a self-signed certificate).
5. If you are using ethernet or WiFi client, verify connectivity to the rPi using ping sgpi.local
   or ping 192.168.7.2: see more below (or trust your luck and proceed to the next step).
6. Open your browser to `http://<sgname>/` where `sgname` is the hostname or IP address of your
   new Sensorgnome as discovered in the previous step (or guessed).
7. Once the web page appears navigate to the settings tab (on mobile use landscape orientation or
   the hamburger menu in the top-left) and modify the basic settings.
8. Please proceed to [Configure and Verify Radios](RADIO-CONFIG.md).

If you have prepared configuration files (e.g. to configure the WiFi client or when setting up
a batch of Sensorgnomes):

- After flashing in step 2 remove the SDcard, wait a couple of seconds, plug it back in:
  this will now mount the filesystems so the files on the boot partition can be accessed.
  - On Linux the mount point is typically `/run/media/<user>/boot`.
  - On Windows you will see a "boot" disk and a "USB drive" or similar disk. Do not let
    Windows "Verify and fix" a partition. (The "USB drive" corresponds to the Linux root
    partition, which Windows cannot mount.) After the rPi's first boot there will be a third
    "DATA" drive showing up.
  - On MacOS ...
- Copy configuration files to the boot partition: `deployment.json`, `aquisition.json`,
  `wpa_supplicant.conf`, `SG_tag_database.sqlite`, etc. See below for more info.

### Configuration files

It is recommended to edit the configuration using the Web UI. However, when setting up a
batch of Sensorgnomes it can be handy to copy prepared config files instead.
The config files can be placed in the boot partition (top level directory) and on
first boot the rPi moves the
config files to their proper location, which is in `/etc/sensorgnome` on the linux partition.

- `wpa_supplicant.conf`: configure SSID/passphrase for your local WiFi network so the sensorgnome
  can join, as opposed to performing this config using the Web UI.
- `deployment.json`: configure the sensorgnome deployment information, such as project ID, 
  location, etc.
- `SG_tag_database.sqlite`: tag database with your tags so the SG web UI can display tag names.
- `acquisition.json`: configure low-level radio acquisition details.
- `usb-port-map.txt`: configure how the USB ports on the rPi and attached hubs get mapped to
  "port 0" through "port 9" when tag detections are sent to Motus (this is now more flexible
  but a bit less automagic than in earlier Sensorgnome releases).

Information on creating a `wpa_supplicant.conf` file can be found in the Raspberry Pi
Computer Configuration documentation in the Setting up a Headless Raspberry Pi
[Configuring Networking](https://www.raspberrypi.com/documentation/computers/configuration.html#configuring-networking31)
section

### Verifying connectivity

Pointing a web browser at the Sensorgnome on first boot is efficient if it works, but it does
not provide any information when it doesn't work. Note that sometimes it takes a while for
your laptop/phone to find `sgpi.local` so have some patience, most browsers auto-reload but
hitting the reload button a few times can't hurt.

The following steps are suggested for troubleshooting whether the problem has to do with
booting the rPi, connecting to the network, finding the Sensorgnome on the network, or the
web server not starting on the Sensorgnome.

#### Ping the Sensorgnome

Bring up a command-line/`cmd`/terminal window and enter the command `ping <sgname>`,
where `sgname` is the hostname or IP address of the new Sensorgnome.
In all three types of connectivity (WiFi, Ethernet, hot-spot) `sgpi.local` _should_ work.
In the hot-spot case `192.168.7.2` also works, this IP address does _not_ work for the other
two cases.

When using WiFi the network's access point user interface may be able to show that the
Sensorgnome connected and what it's IP address is.
On a LAN the DHCP service will also have a list of recently issued leases, but that may
be difficult to locate.

Note that on Windows `ping <sgname> /t` prevents the ping from stopping after 4 tries.

#### Use the hot-spot

If pinging with WiFi or Ethernet connectivity is not working the easiest next step
is to try the hot-spot (an completely unconfigured Sensorgnome starts the hot-spot automatically).
Double-press "the button" on the Sensorgnome to start the hot-spot,
the LED should blink every second when it's enabled.

If the hot-spot cannot be started (i.e., the LED doesn't start to blink) most likely there
is a software/flashing issue and the SDcard was not prepared correctly or some modification
of the config files caused havoc. Alternatively, the button/LED are not connected correctly.
Suggestions:

1. verify the button and LED hardware
2. reflash the SDcard and without making any config file modification, plug it into the 
   rPi, boot, and try to enable the hot-spot.

If the hot-spot starts, connect to it. The SSID is the ID of the Sensorgnome, which
is of the form `SG-XXXXRPI0XXXX`. The passphrase is the same as the SSID.

Note that it may be handy to use the phone to connect to the hot-spot in order to
avoid reconfiguring the laptop. If you use a phone:

- Turn off mobile/cellular data, especially on Android. Android will show you a warning that
  the Sensorgnome's hot-spot doesn't have internet, that is correct, but as a result, if you
  have mobile/cellular data on, Android will use that to route data and your web browser will
  not be able to reach the Sensorgnome's web site.
- Be sure you use `http://192/168.7.2` (or `http://sgpi.local`) as URL, emphasis on `http`,
  so your browser doesn't automagically try https.
- If one device shows the hot-spot and another doesn't it is possible that the hot-spot
  is on 5Ghz, this happens if the rPi tries to connect to a 5Ghz access point at the same
  time as it's running the hot-spot. (So far a way to prevent this hasn't been found.)

#### Network scan

If you just cannot locate the Sensorgnome's IP address the last resort is to perform
a network scan.

- The typical tool is `nmap`.
  Your best bet is to search for `using nmap to scan the local network`.
- You can also scan for devices that have mDNS enabled (this is what makes `.local`
  hostnames work)
  - Mac/Linux command-line: `avahi-browse -alt` _should_ show the SG as `sg ... Workstation`,
    `avahi-browse -altr` will also show IP addresses.
  - Mac command-line: `dns-sd -B _ssh._tcp` (untested)
  - Windows command-line: supposedly `dns-sd` works, but it doesn't on my machine...
- Windows 10 has built-in support for mDNS/Bonjour/`.local` hostnames.
  On older versions install iTunes or the
  [Bonjour Print Services for Windows](http://support.apple.com/kb/DL999).

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
