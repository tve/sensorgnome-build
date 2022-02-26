# Build Sensorgnome Images and Packages

This repository contains scripts to build a complete Sensorgnome flash image,
currently only for Raspberry Pi.

The whole build process from scratch consists of 3 steps:

- build a dockcross docker image to be able to cross-compile for the target architecture & OS
- use the dockcross image to build all the sensorgnome packages
- use the packages to build a bootable sensorgnome flash image

This repository only deals with the third step. The first step is found in the
sensorgnome-dockcross repo, which results in a docker image on DockerHub
(currently `tvoneicken/sensorgnome-dockcross:armv7-rpi-bullseye-main`).
Unless this image needs to be rebuilt the easiest is to use the DockerHub one.

The second step should be handled within all the respective repositories and ideally each
repo should have a github worflow that automatically produces the packages on push.
Until all repos are converted to this new scheme, some have been built manually and
uploaded to S3.
The outcome of all this is a bunch of packages in some downloadable location, currently
`https://https://motus-builds.s3.us-east-2.amazonaws.com/<owner>/<repo>/<branch>/*.deb`.
See this [crude file listing](https://motus-builds.s3.us-east-2.amazonaws.com/index.html).

The final step is handled in this repo using pimod. Pimod uses a docker container and QEMU
(a processor emulator) to customize an existing rPi or other ARM image.
This is used to load up an official Raspberry Pi OS image, install all the packages
produced in the previous step, apply some final tweaks, and save the result as a
bootable Sensorgnome image.
The output consists of the starting image, an intermediate "base" image, and the final
"sg" image in S3 as
`https://https://motus-builds.s3.us-east-2.amazonaws.com/<owner>/sensorgnome-build/<branch>/sg-*.img`.

Note: the previous version of all this used pi-gen to produce the image and there are a
few other tools available to do the same. Overall the focus should be on installing the
debian packages and they should each do everything necessary for their operation without
requiring additional build steps here. The result ought to be that the specific tool used
for the final image assembly is unimportant as long as a functional clean image pops out.

The switch from pi-gen was motivated by
[these comments](https://github.com/RPi-Distro/pi-gen/issues/486)
where the maintainer states "pi-gen serves its primary purpose of building the official
release images well enough", i.e., it's not designed for customizing.
Pimod's focus is customization.

## Operation

The image build process is organized as follows:

- a `manifest-xxx' file specifies what is to be built, such as the official OS base image,
  the packagaes to install, the dockcross image to use, the name of the final image, etc.
- a `base-xxx.pifile` tells pimod how to construct a "base image" from the official OS image;
  the intent being that only standard packages get installed that are unlikely to change.
- a `sg-xxx.pifile` tells pimod how to construct the final sensorgnome image from the base
  image by adding all the sensorgnome stuff that may often change.
- the `build.sh` script downloads the original OS image, the sensorgnome packages, and
  then runs pimod two times to generate first the base image and then the final image.
- the split into a base image and a final image is motivated by the fact that building the
  base image takes a long time due to the many packages that get downloaded and updated
  and it's nice to be able to iterate more quickly on the sensorgnome stuff that changes.
- the `build.sh` tries to avoid re-downloading or re-building things that are already there,
  to start from a clean slate remove the `images` and `packages` directories.

## Docker

The reason the build process uses docker is that it allows carefully constructed OS images with
all the right tools to be run on almost any platform. Together with QEMU it, in addition,
allows the final image construction to be run on an emulated ARM platform. This way running
a command like `apt install` does exactly what it would do on a real rPi.

The reason two different docker images (dockcross and pimod) are used is that the former
contains cross-compilers while the latter uses QEMU emulation. This means that when compiling
programs using dockcross the compiler/link/etc run at full X64 speed and simply generate code
for ARM. While when running any command in pimod/QEMU there is a whole processor emulation layer
involved.

## Tips

- build the image by running `./build.sh` on a unixy system.
- refer to `.gihub/workflows/build.yml` for the exact process used by the automated build.
- to mount an image on linux using loop-back mounts:

```bash
  sudo losetup -f images/blah.img --show
  sudo kpartx -avs /dev/loopN
  sudo mount /dev/mapper/loopNp1 /mnt
```

## Old version

This repository contains tools to build SensorGnome software packages for the Raspberry Pi
(potentially also BeagleBone) and to build a complete Raspberry Pi OS image with the
SensorGnome software preinstalled.

The build process is designed to run under docker in order to enable building on machines
other than an rPi itself (building on an rPi should work but has not been tested).
There are two main Docker images that are used:
[dockcross](https://github.com/dockcross/dockcross) and [pi-gen](https://github.com/RPi-Distro/pi-gen).
Dockcross contains cross-compilation toolchains that allow ARM executables to be produced on an x64
machine. Pi-gen is a collection of scripts and a docker image that allows a bootable Raspberry
Pi OS image to be pre-loaded with software and a final image file to be produced.

The overall steps in the build process are the following:

- customize dockercross to contain all the library prerequisites for building SensorGnome
- use dockercross to cross-compile all the sensorgnome software packages resulting in a
  collection of `.deb` package files.
- use pi-gen to create a bootable operating system image with the SensorGnome software installed
  and various necessary customizations performed so everything works at boot.

All these steps are orchestrated by the top-level `build.py` script.

## Dockercross customization

A custom version of dockercross is used to generate packages for the Raspberry Pi.
For general use, it should be sufficient to use the published image (see `docker/Dockerfile`)
until Raspberry Pi OS moves to Debian bullseye.
Information on how to generate a new image are in (docker/README.md](docker/README.md).

## Package Building

The `build_packages` directory contains all of the scripts required to build the various packages.
See the README there for more information.
The top-level build script lauches a dockercross container to run `build_packages/build_packages.py`.
In principle, this script should also function without docker on an rPi itself.

Packages currently built are:

- fcd
- find-tags
- _openssh-portable_ -- not built for now due to security and maintainability concerns
- sensorgnome-control
- sensorgnome-librtlsdr
- sensorgnome-support
- vamp-alsa-host
- vamp-plugins

## Image Building

The `build_raspbian` directory contains all of the scripts, customization and config files needed to
build a customized Raspbian image tailored for Sensorgnome.

The image build process proceeds in several stages outlined in the pi-gen repository's readme.
For the sensorgnome a "lite" image is produced, which means no GUI and a minimal set of applications.
The main customizations performed are:

- create a 3-partition layout with an ext4 root partition and a fat32 data partition
- install debian packages used by the SG software
- install SG software packages
- install node.js dependencies
- install systemd units to run SG software automatically

The end result is a `.img` image file, which can be flashed to a SD-card in the same way as a
standard Raspberry Pi OS image is flashed.

## Prerequisites

- Install docker
- pip install -r requirements.txt (preferably in a venv)

## Keys to sign packages and update the debian repo

- TvE has the sensorgnome-repo key in his gpg keyring, it is encrypted using a password found
  in his password store
- The gpg key must be exported as ascii using

``` text
  gpg --list-secret-keys --keyid-format LONG; gpg --export-secret-keys --armor 11162C1D8661F9148480CDD98EFF151A5DDAE8F1
```

- The result must be set as `GPG_PRIVATE_KEY` secret in github, and the passphrase as `GPG_PASSPHRASE`
- To upload the package to S3, an AWS role must be configured to allow the github action to upload

## Docker comments

To understand the role of docker in the build process here are a couple of points:

- For our purposes, docker is not much more than a chroot: it runs processes within a filesystem
  environment that is different from the host system.
- In the case of the dockcross image the filesystem environment contains a full cross-compilation
  toolchain with all its dependencies. This means that within that container it's easy to
  run cross-compilations.
- In the case of pi-gen the container contains everything found on a standard debian system.
  This allows the build process to use programs commonly found on debian to put together the image.
- When a docker image is run (resulting in a running container) the container's filesystem
  is initialized with the image content. On its own this is not very useful to us because we
  need the dockcross container to also have access to the sources we want to cross-compile, and we
  want the pi-gen container to have access to all the files it needs to install. The solution is
  volume mounts: a volume mount mounts a directory of the host onto a directory within the container.
- To build packages we perform the entire build process within a dockcross container.
  The `build_packages` subdirectory is mounted into the dockcross container and the
  the `build_packages/build_packages.py` script is run inside the container. It can then pull
  repositories from github and build the associated debian packages using the cross-compilation
  tools made available by the container image.
- To build the rPi image we use pi-gen and it starts with a debian container and successively
  installs everything to make it be Raspberry Pi OS. This allows standard debian tools to be used
  to install stuff, for example with apt-get.
- The build packages process has one hack, which is that in order to be able to build packages from
  checked-out sources it also mounts the parent directory of the sensorgnome-build dir as a volume.
  The intent is that a developer can clone all the sensorgnome-* repos into one dir, and then the
  build process can use those directories instead of fetching from github.

## Notes

- Applied patch by Evan Jobling: `patch -f -p1 --binary <evanj.patch` -- ignore that one hunk fails
- To build an image using checked-out repositories, check them out (clone) into a sibling dir
  to sensorgnome-build (this repo), then set `SRCDIR` in
  `build_packages/package_sensorgnome_support.py` or
  `build_packages/package_sensorgnome_control.py` and shown in the commented-out statements.
  (TODO: The same `SRCDIR` should be supported for other repos as well.)
  The way this works is that `..` is mounted onto `/mnt` in the docker container
  in `build.py`'s `docker_build_packages`.
