Sensorgnome Deployment Issues and Bugs
======================================

## SG-7F5ERPI46977 spews syslog with fw-clk-arm frequency 2022-12-21

Many log lines every few seconds like:
```
Dec 19 17:25:50 localhost kernel: [323962.337870] raspberrypi-clk soc:firmware:clocks: Failed to change fw-clk-arm frequency: -12
Dec 19 17:25:50 localhost kernel: [323962.537892] raspberrypi-clk soc:firmware:clocks: Failed to change fw-clk-arm frequency: -12
Dec 19 17:25:51 localhost kernel: [323962.737924] raspberrypi-clk soc:firmware:clocks: Failed to change fw-clk-arm frequency: -12
```
This spontaneously started with:
```
Dec 19 17:18:48 localhost kernel: [323540.389093] xhci_hcd 0000:01:00.0: Ring expansion failed
Dec 19 17:18:48 localhost kernel: [323540.389154] option1 ttyUSB4: usb_wwan_open: submit read urb 0 failed: -12
Dec 19 17:18:48 localhost kernel: [323540.389721] xhci_hcd 0000:01:00.0: Ring expansion failed
Dec 19 17:18:48 localhost kernel: [323540.389731] option1 ttyUSB4: usb_wwan_open: submit read urb 1 failed: -12
Dec 19 17:18:48 localhost kernel: [323540.390175] xhci_hcd 0000:01:00.0: Ring expansion failed
Dec 19 17:18:48 localhost kernel: [323540.390181] option1 ttyUSB4: usb_wwan_open: submit read urb 2 failed: -12
Dec 19 17:18:48 localhost kernel: [323540.390603] xhci_hcd 0000:01:00.0: Ring expansion failed
Dec 19 17:18:48 localhost kernel: [323540.390608] option1 ttyUSB4: usb_wwan_open: submit read urb 3 failed: -12
Dec 19 17:18:49 localhost kernel: [323540.708406] hwmon hwmon1: Failed to get throttled (-12)
Dec 19 17:18:49 localhost kernel: [323541.048417] raspberrypi-clk soc:firmware:clocks: Failed to change fw-clk-arm frequency: -12
Dec 19 17:18:55 localhost kernel: [323546.818075] raspberrypi-clk soc:firmware:clocks: Failed to change fw-clk-arm frequency: -12
```
Conclusion:
- This SG had previous issues seemingly related to the hub, nees to look into that again.

## SG-5B7DRPI44315 stops uploading to Motus 2022-12-20

It looks like the upload task got stuck in the post-upload status check phase.
Logs:
```
Dec 20 10:19:50 localhost sg-control[636]: Motus upload starting for SG-5B7DRPI44315-20221220-889d0e47.zip with 1 files
Dec 20 10:19:51 localhost sg-control[636]: Motus upload filePartName: 30751_889d0e47d5b9598e13e7e33f6223adb3b13db129.zip.part
Dec 20 10:19:53 localhost sg-control[636]: Motus upload completed in 2077 ms
```
Next expected line, which is missing would have been like:
```
Dec 20 09:46:02 localhost sg-control[636]: *** Motus upload SG-5B7DRPI44315-20221220-a5fdd67a.zip complete, JobID: 21824279, files:
```
Conclusions:
- most likely some request doesn't have a timeout or the timeout logic has an issue
- need to look into watchdog-like feature, although a restart of sg-control is perhaps
  the safest & cleanest option overall

## SG-8D21RPZ2778A telegraf does not run 2022-12-20

Telegraf never ran:
```
syslog-20221115:Nov 15 09:58:56 localhost systemd[1]: telegraf.service: Scheduled rest
art job, restart counter is at 3.                                                     
syslog-20221115:Nov 15 09:58:56 localhost telegraf[1097]: 2022-11-15T09:58:56Z E! [tel
egraf] Error running agent: error loading config file /etc/telegraf/telegraf.conf: plu
gin inputs.socketstat: line 123: configuration specified the fields ["socket_types"], 
but they weren't used                                                                 
syslog-20221115:Nov 15 09:58:56 localhost systemd[1]: telegraf.service: Main process e
xited, code=exited, status=1/FAILURE                                                  
syslog-20221115:Nov 15 09:58:56 localhost systemd[1]: telegraf.service: Failed with re
sult 'exit-code'.                                                                     
```
This started when the SG was updated. Most likely telegraf was updated and the std config file
was reinstalled.
Conclusions:
- need to test telegraf update
- need to figure out how to deal with the config file & upgrades
- the upgrade.log files are empty, needs to be fixed
- would be handy to have a way to drop a file onto the SG...

### Resolution

An upgrade of the telegraf service caused an incorrect config item to prevent the service from
starting. The config has been fixed.

## SG-7F5ERPI46977 fails radio init due to USB issue

Issues at the USB level seemingly due to the hub. Went down a rabbit hole around USB Full Speed
Isochronous bandwidth limitation in the rPi VIA USB chip, but not at all clear that that's the
issue. Suspecting the hub. But then after a reboot all went away, so...
USB problems recurred 2022-12-21...

SG-WCC sg-control crashed after plugging two FCDs in, one being on a hub.
Most significant error in syslog:
usb 1-1.1.2: Not enough bandwidth for altsetting 1

sg-control log:
```
Jan  7 23:01:19 localhost sg-control[7631]: events.js:377
Jan  7 23:01:19 localhost sg-control[7631]:       throw er; // Unhandled 'error' event
Jan  7 23:01:19 localhost sg-control[7631]:       ^
Jan  7 23:01:19 localhost sg-control[7631]: Error: EIO: i/o error, open '/dev/sensorgnome/CornellTagXCVR.port=7.port_path=1_1_4'
Jan  7 23:01:19 localhost sg-control[7631]: Emitted 'error' event on ReadStream instance at:
Jan  7 23:01:19 localhost sg-control[7631]:     at internal/fs/streams.js:126:14
Jan  7 23:01:19 localhost sg-control[7631]:     at FSReqCallback.oncomplete (fs.js:180:23) {
Jan  7 23:01:19 localhost sg-control[7631]:   errno: -5,
Jan  7 23:01:19 localhost sg-control[7631]:   code: 'EIO',
Jan  7 23:01:19 localhost sg-control[7631]:   syscall: 'open',
Jan  7 23:01:19 localhost sg-control[7631]:   path: '/dev/sensorgnome/CornellTagXCVR.port=7.port_path=1_1_4'
Jan  7 23:01:19 localhost sg-control[7631]: }
```
Solution: reseat USB connectors and power cycle :-(

Update: this is a persistent problem. So far two Sabrent hubs have exibited the issue. From syslog:

```
Mar 16 22:33:33 localhost kernel: [ 1157.281725] usb 1-1.1.3: 1:0: usb_set_interface failed (-110)
Mar 16 22:33:33 localhost kernel: [ 1157.281879] cma: cma_alloc: linux,cma: alloc failed, req-size: 1 pages, ret: -4
Mar 16 22:33:33 localhost kernel: [ 1157.281892] usb 1-1.1.3: Not enough bandwidth for altsetting 1
```

From lsusb:
- Bad: ID 05e3:0608 Genesys Logic, Inc. Hub
- Bad: ID 05e3:0610 Genesys Logic, Inc. Hub
- Good: ID 214b:7250 Huasheng Electronics USB2.0 HUB


## SG-68B4RPI33F06 fails to start due to chrony glitch

Sg-control process doesn't start due to temporary issue with chrony.

```
Jan 22 09:17:07 localhost chronyd[484]: Could not open /dev/pps0 : No such file or directory
Jan 22 09:17:07 localhost systemd[1]: chrony.service: Control process exited, code=exited, s
tatus=1/FAILURE
Jan 22 09:17:07 localhost udisksd[405]: failed to load module mdraid: libbd_mdraid.so.2: can
not open shared object file: No such file or directory
Jan 22 09:17:07 localhost systemd[1]: chrony.service: Failed with result 'exit-code'.
Jan 22 09:17:07 localhost systemd[1]: Failed to start chrony, an NTP client/server.
Jan 22 09:17:07 localhost systemd[1]: Dependency failed for Sensorgnome main control process
Jan 22 09:17:07 localhost systemd[1]: sg-control.service: Job sg-control.service/start faile
d with result 'dependency'.
...
Jan 22 09:17:07 localhost systemd[1]: Starting chrony, an NTP client/server...
Jan 22 09:17:07 localhost chronyd[600]: chronyd version 4.0 starting (+CMDMON +NTP +REFCLOCK
 +RTC +PRIVDROP +SCFILTER +SIGND +ASYNCDNS +NTS +SECHASH +IPV6 -DEBUG)
Jan 22 09:17:07 localhost chronyd[600]: Frequency 12.464 +/- 0.008 ppm read from /var/lib/chrony/chrony.drift
Jan 22 09:17:07 localhost chronyd[600]: Loaded seccomp filter
```

## Notes about uptime / boot time

The `uptime` command and sg-control read `/proc/uptime` which has the time elapsed since boot, as
accumulated by the timer interrupt.

The SG dashboard displays the boot time by subtracting the uptime from the current time. This
is pretty good, but may not coincide with the time at boot because at boot the time may not have
been accurate, especially if the rPi had been powered off. The time at boot is captured in
`/proc/stat` as `btime` in case that's of interest.

## SG-A3F8RPI42548 has Quected EG25 LTE modem identified as sixfab HAT

```
Feb 28 00:00:09 localhost init-sixfab-gps.sh[2539]: 0 lrwxrwxrwx 1 root root 13 Feb 23 13:17 usb-Quectel_EG25-G-if00-port0 -> ../../ttyUSB0
Feb 28 00:00:09 localhost init-sixfab-gps.sh[2539]: 0 lrwxrwxrwx 1 root root 13 Feb 23 13:17 usb-Quectel_EG25-G-if01-port0 -> ../../ttyUSB1
Feb 28 00:00:09 localhost init-sixfab-gps.sh[2539]: 0 lrwxrwxrwx 1 root root 13 Feb 23 13:17 usb-Quectel_EG25-G-if02-port0 -> ../../ttyUSB2
Feb 28 00:00:09 localhost init-sixfab-gps.sh[2539]: 0 lrwxrwxrwx 1 root root 13 Feb 23 13:17 usb-Quectel_EG25-G-if03-port0 -> ../../ttyUSB3
```

This causes init-sixfab-gps.sh to fail 'cause it expects LE91 in the filenames.

## Gestures fails to start because it doesn't detect the Sixfab HAT

When the gestures service started udev hadn't discovered the Sixfab HAT yet, so gestures concluded that there's no button.

## SG-68B4RPI33F06 has 9 FCDs and 1 CTT but only shows 7 of the 9 FCDs

Error in sg-control about one of the FCDs:
```
Mar 22 19:35:00 localhost sg-control[1088]: USBAudio 1:11: setting frequency to 166.376
Mar 22 19:35:00 localhost sg-control[1088]: USBAudio 1:11: setting lna_gain to 1
Mar 22 19:35:00 localhost sg-control[1088]: USBAudio 1:11: setting rf_filter to 6
Mar 22 19:35:00 localhost sg-control[1088]: USBAudio 1:11: setting mixer_gain to 1
Mar 22 19:35:00 localhost sg-control[1088]: USBAudio 1:11: setting if_filter to 0
Mar 22 19:35:00 localhost sg-control[1088]: USBAudio 1:11: setting if_gain to 0
Mar 22 19:35:01 localhost sg-control[1088]: VAH command:  ["start 6"]
Mar 22 19:35:01 localhost sg-control[1088]: Error: Error: invalid command
Mar 22 19:35:01 localhost sg-control[1088]:  so I'm unable to attach plugin lotek-plugins.so:findpulsefdbatch:pulses to {"path":"/dev/sensorgnome/funcubeProPlus.port=6.alsaDev=6.usbPath=1:11.port_path=1_5_3","attr":{"type":"funcubeProPlus","port":"6","alsaDev":"6","usbPath":"1:11","port_path":"1_5_3","radio":"VAH"},"stat":{"dev":5,"mode":8630,"nlink":1,"uid":0,"gid":29,"rdev":29888,"blksize":4096,"ino":328,"size":0,"blocks":0,"atimeMs":1679513561988.2646,"mtimeMs":1679513561988.2646,"ctimeMs":1679513561988.2646,"birthtimeMs":0,"atime":"2023-03-22T19:32:41.988Z","mtime":"2023-03-22T19:32:41.988Z","ctime":"2023-03-22T19:32:41.988Z","birthtime":"1970-01-01T00:00:00.000Z"}}
```

Also, the SG only shows 7 of the 9 FCDs in sg-control.

Resolution: there is a limit of 8 sound "cards" in the alsa driver. This results in 7 FCDs 'cause one sound card is used by the rpi hardware. There does not seem to be an easy way to increase this limit. Since 7 seems plenty for now this is not being pursued further.

## SG-5B16RPI4106B dhcpcd runs out of buffer space

Error in syslog every second:
```
Jun  5 06:33:47 localhost dhcpcd[933]: ipv6nd_sendadvertisement: No buffer space available
```

## SG-5B16RPI4106B pulses but no tags

Job ID 24077502:
- /data/SGdata/2023-05-28/Davy_5-5B16RPI4106B-006-2023-05-28T14-53-51.4370Z-all.txt.gz
- /data/SGdata/2023-05-28/Davy_5-5B16RPI4106B-006-2023-05-28T14-53-51.4410Z-ctt.txt.gz
- Got 0 (unfiltered) detections between 2023-05-28 14:53:51.437 and 2023-05-28 15:50:08.505.

Job ID 24077696:
- /data/SGdata/2023-05-28/Davy_5-5B16RPI4106B-006-2023-05-28T15-53-51.4410Z-all.txt.gz
- /data/SGdata/2023-05-28/Davy_5-5B16RPI4106B-006-2023-05-28T15-53-51.4450Z-ctt.txt.gz
- Got 0 (unfiltered) detections between 2023-05-28 15:53:51.441 and 2023-05-28 16:53:34.509.

Job ID 24080427:
- /data/SGdata/2023-05-28/Davy_5-5B16RPI4106B-006-2023-05-28T22-53-51.4590Z-all.txt.gz
- /data/SGdata/2023-05-28/Davy_5-5B16RPI4106B-006-2023-05-28T22-53-51.4620Z-ctt.txt.gz
- Got 0 (unfiltered) detections between 2023-05-28 22:53:51.459 and 2023-05-28 23:49:33.260.

Job ID 24080794:
- /data/SGdata/2023-05-28/Davy_5-5B16RPI4106B-006-2023-05-28T23-53-51.4650Z-ctt.txt.gz
- /data/SGdata/2023-05-28/Davy_5-5B16RPI4106B-006-2023-05-28T23-53-51.4620Z-all.txt.gz
- Got 0 (unfiltered) detections between 2023-05-28 23:53:51.462 and 2023-05-29 00:48:55.000.

## SG-E0E7RPI44165 modem disconnects from USB and doesn't reappear

Initial detection:
```
Aug 31 18:17:06 localhost kernel: [   10.493680] usb 1-1.3: New USB device found, idVendor=2c7c, idProduct=0125, bcdDevice= 3.18
Aug 31 18:17:06 localhost kernel: [   10.493721] usb 1-1.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
Aug 31 18:17:06 localhost kernel: [   10.493739] usb 1-1.3: Product: EG25-G
Aug 31 18:17:06 localhost kernel: [   10.493755] usb 1-1.3: Manufacturer: Quectel
```

But later when ModemManager starts:
```
Aug 31 18:17:10 localhost ModemManager[563]: <info>  [base-manager] couldn't check support for device '/sys/devices/platform/scb/fd580000.ethernet': not supported by any plugin
Aug 31 18:17:10 localhost ModemManager[563]: <info>  [base-manager] couldn't check support for device '/sys/devices/platform/soc/fe300000.mmcnr/mmc_host/mmc1/mmc1:0001/mmc1:0001:1': not supported by any plugin
```

On SG-BBDBRPI40313:

```
Feb 21 01:23:36 raspberrypi ModemManager[482]: <warn>  [ttyUSB0/probe] failed to parse QCDM version info command result: -7
Feb 21 01:23:37 raspberrypi ModemManager[482]: <info>  [base-manager] couldn't check support for device '/sys/devices/platform/scb/fd580000.ethernet': not supported by any plugin
Feb 21 01:23:37 raspberrypi ModemManager[482]: <info>  [device /sys/devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb1/1-1/1-1.3] creating modem with plugin 'quectel' and '5' ports
Feb 21 01:23:37 raspberrypi sg-boot[654]: mkfs.fat 4.2 (2021-01-31)
Feb 21 01:23:37 raspberrypi ModemManager[482]: <info>  [base-manager] modem for device '/sys/devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb1/1-1/1-1.3' successfully created
Feb 21 01:23:37 raspberrypi ModemManager[482]: <info>  [base-manager] couldn't check support for device '/sys/devices/platform/soc/fe300000.mmcnr/mmc_host/mmc1/mmc1:0001/mmc1:0001:1': not supported by any plugin
```

## Some CTT json tags are not recognized and serial port hangs

CTT seems to have two different JSON formats (really?) and one is not recognized, plus the tags
must do something funny with the serial port because reading & writing it ends up hanging.

The format looks like:
```
{"protocol":"1.0.0","meta":{"data_type":"coded_id","rssi":0},"data":{"id":"78664C3304"}}
```

The hanging is fixed by using the serialport module instead of just opening the port as a file.
It's not clear why I switched to opening the port as a file in the first place.

## GPSd doesn't detect or work with Adafruit GPS HAT

Typically it is shown as no-dev in the Web UI. Most likely this is due to baud rate mismatch
or perhaps due to the probing of GPSd putting the GPS into a weird state.

GPSd is supposed to "autobaud" but in reality this was broken and is fixed in 3.23 or 3.24 (not
sure). Debian sits on 3.22 and only provides 3.25 in unstable at the moment.
Installing 3.25 from sources shows that it does autobaud but ends up being unreliable and
frequently finds a checksum error in the stanzas coming from the GPS and then starts detection
essentially from scratch. It is unclear whether the GPS sends garbage or something else happens
(this was at 38400 baud). It seems that rather than having gpsd use the GPS' baud rate that the
baud rate should be changed to 9600.

Gist with a script that detects and changes the baud rate:
https://gist.github.com/tve/19ab477ba43b685103c107d1cbb1dc34

## Sensorgnome debian repo key expiry

Fix: sudo curl -L -o /etc/apt/trusted.gpg.d/sensorgnome.gpg https://sensorgnome.s3.amazonaws.com/sensorgnome.gpg

## Old Microchip CTT receivers not working due to incorrect baud rate

Issue noticed 8/5/2024, issue introduced 11/26/2023, affects RC builds rc13 through rc15, dev builds 2023-333 through 2024-157.
Cause: code change to support CTT v3 dongles changed baud rate from 115200 to 9600 for unknown reasons, commit ee78c67
Sensorgnomes known to have these receivers (all belong to Birds of Canada):
- SG-1BC7RPI3C2C5: runs 2023-115, i.e. not affected
- SG-AEA7RPI320AE: runs 2023-126, i.e. not affected
- SG-4C33RPI3CD7A: runs 2023-115, i.e. not affected

## SG-11A9RPI340AA and SG-847CRPI37DF3 cell modem issues

- Both use a Quectel EG25-G modem, two different(?) SIM cards
- One connects, the other doesn't, problem moves with SIM card

### Connecting one

```
Nov 19 18:17:21 localhost ModemManager[548]: <info>  [modem0] simple connect started...
Nov 19 18:17:21 localhost ModemManager[548]: <info>  [modem0] simple connect state (3/10): enable
Nov 19 18:17:21 localhost ModemManager[548]: <info>  [modem0] state changed (disabled -> enabling)
Nov 19 18:17:21 localhost ModemManager[548]: <info>  [modem0] power state updated: on
Nov 19 18:17:22 localhost ModemManager[548]: <info>  [modem0] simple connect state (4/10): wait to get fully enabled
Nov 19 18:17:22 localhost ModemManager[548]: <info>  [modem0] state changed (enabling -> enabled)
Nov 19 18:17:22 localhost ModemManager[548]: <info>  [modem0] simple connect state (5/10): wait after enabled
Nov 19 18:17:22 localhost ModemManager[548]: <info>  [modem0] 3GPP registration state changed (unknown -> registering)
Nov 19 18:17:22 localhost ModemManager[548]: <info>  [modem0] 3GPP registration state changed (registering -> roaming)
Nov 19 18:17:22 localhost ModemManager[548]: <info>  [modem0] state changed (enabled -> registered)
Nov 19 18:17:22 localhost ModemManager[548]: <info>  [modem0] simple connect state (6/10): register
Nov 19 18:17:22 localhost ModemManager[548]: <info>  [modem0] simple connect state (7/10): wait to get packet service state attached
Nov 19 18:17:22 localhost ModemManager[548]: <info>  [modem0] simple connect state (8/10): bearer
Nov 19 18:17:22 localhost ModemManager[548]: <info>  [modem0] simple connect state (9/10): connect
Nov 19 18:17:22 localhost ModemManager[548]: <info>  [modem0] state changed (registered -> connecting)
Nov 19 18:17:22 localhost ModemManager[548]: <info>  [modem0/bearer1] QMI IPv4 Settings:
Nov 19 18:17:22 localhost ModemManager[548]: <info>  [modem0/bearer1]     address: 100.72.76.94/30
Nov 19 18:17:22 localhost ModemManager[548]: <info>  [modem0/bearer1]     gateway: 100.72.76.93
Nov 19 18:17:22 localhost ModemManager[548]: <info>  [modem0/bearer1]     DNS #1: 8.8.4.4
Nov 19 18:17:22 localhost ModemManager[548]: <info>  [modem0/bearer1]     DNS #2: 8.8.8.8
Nov 19 18:17:22 localhost ModemManager[548]: <info>  [modem0/bearer1]        MTU: 1360
Nov 19 18:17:23 localhost ModemManager[548]: <info>  [modem0/bearer1] couldn't start network: QMI protocol error (14): 'CallFailed'
Nov 19 18:17:23 localhost ModemManager[548]: <info>  [modem0/bearer1] verbose call end reason (2,210): [internal] pdn-ipv6-call-disallowed
Nov 19 18:17:23 localhost ModemManager[548]: <info>  [modem0/bearer1] reloading stats is supported by the device
Nov 19 18:17:23 localhost ModemManager[548]: <info>  [modem0] state changed (connecting -> connected)
Nov 19 18:17:23 localhost ModemManager[548]: <info>  [modem0] simple connect state (10/10): all done
Nov 19 18:17:23 localhost init-modem[961]: successfully connected the modem
Nov 19 18:17:23 localhost dhcpcd[451]: wwan0: carrier acquired
Nov 19 18:17:23 localhost modemmanager: if-up for modem 0 interface wwan0
Nov 19 18:17:23 localhost dhcpcd[451]: wwan0: IAID 00:00:00:03
Nov 19 18:17:24 localhost dhcpcd[451]: wwan0: soliciting an IPv6 router
Nov 19 18:17:24 localhost dhcpcd[451]: ap0: no IPv6 Routers available
Nov 19 18:17:24 localhost dhcpcd[451]: wwan0: soliciting a DHCP lease
Nov 19 18:17:24 localhost dhcpcd[451]: wwan0: offered 100.72.76.94 from 100.72.76.93
Nov 19 18:17:24 localhost dhcpcd[451]: wwan0: leased 100.72.76.94 for 7200 seconds
Nov 19 18:17:24 localhost dhcpcd[451]: wwan0: adding route to 100.72.76.92/30
Nov 19 18:17:24 localhost dhcpcd[451]: wwan0: adding default route via 100.72.76.93
```

### Failing one

```
Nov 19 19:17:21 localhost ModemManager[563]: <info>  [modem0] simple connect started...
Nov 19 19:17:21 localhost ModemManager[563]: <info>  [modem0] simple connect state (3/10): enable
Nov 19 19:17:21 localhost ModemManager[563]: <info>  [modem0] state changed (disabled -> enabling)
Nov 19 19:17:21 localhost ModemManager[563]: <info>  [modem0] power state updated: on
Nov 19 19:17:21 localhost ModemManager[563]: <info>  [modem0] 3GPP registration state changed (unknown -> unknown)
Nov 19 19:17:22 localhost ModemManager[563]: <info>  [modem0] simple connect state (4/10): wait to get fully enabled
Nov 19 19:17:22 localhost ModemManager[563]: <info>  [modem0] state changed (enabling -> enabled)
Nov 19 19:17:22 localhost ModemManager[563]: <info>  [modem0] simple connect state (5/10): wait after enabled
Nov 19 19:17:22 localhost ModemManager[563]: <info>  [modem0] simple connect state (6/10): register
Nov 19 19:17:51 localhost init-modem[969]: error: couldn't connect the modem: 'Timeout was reached'
```
