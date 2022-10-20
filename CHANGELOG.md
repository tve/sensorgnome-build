# Changelog

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).


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
