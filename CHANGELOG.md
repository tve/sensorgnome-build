# Changelog

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [v2.0-rc10](https://sensorgnome.s3.amazonaws.com/images/sg-armv7-rpi-2.0-rc10.zip)

### Fixed/improved

- rewrite cellular modem management using ModemManager, disabling SixFab's software
- support WaveShare SIM7600 series modems (USB dongle, HAT "should" work too)
- support SixFab cellular HAT with EC25/EG25 modem
- added cellular info panel to network tab
- installed vnstat to keep track of network usage, display info on network tab
- moved dangerous system operations to a "danger zone" panel, added ability to switch
  release train (stable vs. testing)
- misc improvements to the upgrade process
- attempt to handle device open error due to USB issues for CTT receivers
- use one password for web UI, ssh, _and_ hot-spot
- changing the password in the web ui also changes hot-spot password
- start to support image customization using the rpi-imager
- rework GPS detection to handle modems and to reduce time taken at boot
- support remote commands to reboot & enable/disable hotspot
- force system to use UTC time-zone
- very basic support for SensorStation V1

## [v2.0-rc9](https://sensorgnome.s3.amazonaws.com/images/sg-armv7-rpi-2.0-rc9.zip)

### Fixed/improved

- reduce internet bandwidth by reducing connectivity check frequency (wasn't backing off)
- fix display of 5-minute CTT detections

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
