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
Jan  7 23:01:19 localhost sg-control[7631]:       throw er; // Unhandled 'error
' event
Jan  7 23:01:19 localhost sg-control[7631]:       ^
Jan  7 23:01:19 localhost sg-control[7631]: Error: EIO: i/o error, open '/dev/s
ensorgnome/CornellTagXCVR.port=7.port_path=1_1_4'
Jan  7 23:01:19 localhost sg-control[7631]: Emitted 'error' event on ReadStream
 instance at:
Jan  7 23:01:19 localhost sg-control[7631]:     at internal/fs/streams.js:126:1
4
Jan  7 23:01:19 localhost sg-control[7631]:     at FSReqCallback.oncomplete (fs
.js:180:23) {
Jan  7 23:01:19 localhost sg-control[7631]:   errno: -5,
Jan  7 23:01:19 localhost sg-control[7631]:   code: 'EIO',
Jan  7 23:01:19 localhost sg-control[7631]:   syscall: 'open',
Jan  7 23:01:19 localhost sg-control[7631]:   path: '/dev/sensorgnome/CornellTa
gXCVR.port=7.port_path=1_1_4'
Jan  7 23:01:19 localhost sg-control[7631]: }
```
Solution: reseat USB connectors and power cycle :-(

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

