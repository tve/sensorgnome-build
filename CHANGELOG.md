# Changelog

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## Unreleased (included in latest dev build)

- add sample rate check for funcubes/rtlsdr and restart dongle if there's an issue
- improve radio error reporting in UI
- support RTLSDR.com ("blog") V4 dongle
- support turning on bias-tee for RTL-SDR (was already supported for FCD)
- fix for Pi3 for Adafruit/MTK GPS
- display SNR for Lotek pulses and tags (text view and new chart)
- changed pulse detection for rtlsdr to 6dB to match FCD
- added experimental AGC for rtlsdr, disabled by default, display current gain
- make timeseries on radio page more robust to time jumps
- add IF (intermediate frequency) gains for RTL-SDR E4000 tuner to acquisition.json
- for RTL-SDR E4000 tuner pick the next higher tuner_gain if an invalid value is set in acquisition.json
- display cell IMEI
- add serial output feed capability

## [v2.0-rc14](https://sensorgnome.s3.amazonaws.com/images/sg-armv7-rpi-2.0-rc14.zip)

### Fixed/improved

- revert boot count "epoch"

### Added/removed

- add ability to alter boot count (software tab, danger zone)
- add 1-page view (instead of tabbed) for screen shots/saves
- add UTC time in top-right corner of web UI for screen shots/saves
- log change of release train to syslog
- preliminary support for SensorStation V3

## [v2.0-rc13](https://sensorgnome.s3.amazonaws.com/images/sg-armv7-rpi-2.0-rc13.zip)

### Fixed/improved

- update to latest version of Raspberry Pi OS 'bullseye' (2023-05-03) and updated packages
- fixed support for latest "V3" CTT dongles producing JSON output
- switched interface to CTT dongles to use serialport module instead of std file access
- fix to charts not showing in UI
- extend sg-log to 120 days and syslog to 60 days, increase root partition to accommodate
- report cellular info into sg-hub-agent so it can be monitored on sghub
- periodically query FCD/RTLSDR sample rate, display in web ui, and report via sg-hub-agent
- start boot count at random "epoch" offset

## [v2.0-rc12](https://sensorgnome.s3.amazonaws.com/images/sg-armv7-rpi-2.0-rc12.zip)

### Added/removed

- add USB port mapping for 3B+

### Fixed/improved

- fix radio charts
- fix saving of config and time-series (charts) race condition

Equivalent dev image: 2023-126

## [v2.0-rc11](https://sensorgnome.s3.amazonaws.com/images/sg-armv7-rpi-2.0-rc11.zip)

### Added/removed

- display wifi state using rPi green LED
- removed use of short-name (use station name on SGhub where applicable)
- implement remote commands via SGhub
- new hotspot-less install flow through SGhub
- charts on radio tab for noise/performance measurements

### Fixed/improved

- reworked a lot of GPS support
- fixed uninitialized clock issues
- avoid native code install for sg-control
- upgrade to node.js v18

Equivalent dev image: 2023-115

## [v2.0-rc10](https://sensorgnome.s3.amazonaws.com/images/sg-armv7-rpi-2.0-rc10.zip)

### Added

- support WaveShare SIM7600 series modems (USB dongle, HAT "should" work too)
- added cellular info panel to network tab
- support remote commands to reboot & enable/disable hotspot
- installed vnstat to keep track of network usage, display info on network tab
- added ability to switch release train (stable vs. testing)
- start to support image customization using the rpi-imager
- very basic support for SensorStation V1

### Fixed/improved

- rewrite cellular modem management using ModemManager, disabling SixFab's software
- support SixFab cellular HAT with EC25/EG25 modem
- moved dangerous system operations to a "danger zone" panel
- misc improvements to the upgrade process
- attempt to handle device open error due to USB issues for CTT receivers
- use one password for web UI, ssh, _and_ hot-spot
- changing the password in the web ui also changes hot-spot password
- rework GPS detection to handle modems and to reduce time taken at boot
- force system to use UTC time-zone

Equivalent dev image: 2023-089

## [v2.0-rc9](https://sensorgnome.s3.amazonaws.com/images/sg-armv7-rpi-2.0-rc9.zip)

### Fixed/improved

- reduce internet bandwidth by reducing connectivity check frequency (wasn't backing off)
- fix display of 5-minute CTT detections

Equivalent dev image: 2023-053

## [v2.0-rc8](https://sensorgnome.s3.amazonaws.com/images/sg-armv7-rpi-2.0-rc8.zip)

### Fixed/improved

- automatic renewal of the HTTPS key/cert
- fix hotspot password (always set to same as SG pw)
- run everything in UTC (currently EST which becomes crazy when the SG is in CET and the troubleshooter is in PST and server logs are in UTC)
- reduce bandwidth used by shipping uncompressed logs
- ensure all http requests to SG hub are compressed
- print clear start message in sg-control log to help troubleshooting
- improve sg-control logging of updates/upgrades (the logging to upgrade.log seems to break)
- add safeguards to upload dying (see ISSUES.md "SG-5B7DRPI44315 stops uploading")
- fix telegraf not starting after system upgrade
- fix sg-control not starting due to chrony start-up delay
- remove session token in "refreshing motus session" (security issue)
- enable fsck for /data
- implement systemd watchdog for sg-hub-agent to avoid hung agent
- reduce telegraf monitoring interval to 10 minutes (was 1m)
- direction finder detections widget needs timestamps
- add system shutdown button

Equivalent dev image: 2023-047

## [v2.0-rc7](https://sensorgnome.s3.amazonaws.com/images/sg-armv7-rpi-2.0-rc7.zip)

### Fixed/improved

- **short label**: fixed initial setting and editing of receiver "short label"/"label"
- **upload**: force refresh of auth token on upload error to avoid odd corner cases
- **rtlsdr**: fix detection of rtlsdr at boot time on rpi4

## [v2.0-rc5](https://sensorgnome.s3.amazonaws.com/images/sg-armv7-rpi-2.0-rc5.zip)

### Fixed/improved

- **lotek radios**: the web UI now allows switching radio frequency (166.38/150.1/150.5Mhz)
- **rtlsdr radios**: the plugging and unplugging of rtlsdr radios now functions correctly

### Added

- **monitoring**: added reporting of sg-control information
- **monitoring**: fixed upload of log files

## [v2.0-rc4](https://sensorgnome.s3.amazonaws.com/images/sg-armv7-rpi-bullseye-2.0-rc4.zip)

### Summary

No functional change from 2022-292 except for switch to "V2.x" release numbers instead of YYYY-DDD

Note that v2.0-rc1 through rc3 were failed attempts at creating a release candidate (had to iron out the release process somehow).

## [2022-292](https://sensorgnome.s3.amazonaws.com/images/pimod/sg-armv7-rpi-bullseye-testing-2022-292.zip)

### Summary

This is the first release candidate intended for broader testing. It is also the first release to use this changelog. The software build process, the Sensorgnome configuration and its web UI have all changed dramatically since the previous public Sensorgnome release ca. 2019. Except for the software that processes radio pulses and tag detections everything has changed...

### Added

- **landing pages**: now have a color background to make it a little easier to describe steps
- **headless set-up**: documented how to set-up SG without using the hot-spot
- **time sync**: documented timestamps used for detections while time is not synchronized

### Changed

- **release**: created a "stable" OS package repository as well as a "testing" repo and produce "testing" images distinct from release ones
- **documentation**: started [GitBook documentation](https://docs.motus.org/sensorgnome-2022)
- **web ui**: added help info to a number of widgets (see (i) buttons)
- **web ui**: moved UPS hat to config tab, support for this HAT is sketchy due to issues with its firmware

### Deprecated

- Support for the SixFab UPS HAT has been side-lined due to issues with its firmware.

### Removed

- **web ui**: removed count of "pre 2010" and "other SG" files: the former no longer exist and there's nothing really actionable about the latter

### Fixed

- **sg-control**: the main process logs to syslog resulting in per-line timestamps
- **caddy**: the Caddy webserver logs have been quieted down

### Security

- There are no security-related changes in this release.
