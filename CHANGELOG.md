# Changelog

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [v2.0-rc6](https://sensorgnome.s3.amazonaws.com/images/sg-armv7-rpi-2.0-rc6.zip)

### Fixed/improved

- **short label**: fixed initial setting and editing of receiver "short label"/"label"
- **upload**: force refresh of auth token on upload error to avoid odd corner cases

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
