# Docker Details

tl;dr; you can use the tvoneicken/linux-armv7-rpi-buster image that is automatically pulled from
dockerhub, or you can build your own.

Docker is used to build packages for ARM on non-arch machines using the dockercross image.
It is also used to build the rpi image using the pi-gen tool.

The dockercross image used to build packages is somewhat tricky.
Dockercross is a general-purpose docker image to enable cross-compilation for a variety of architectures
and operating system on almost any x64 machine. Unfortunately it is not designed to specifically
support the Raspberry Pi OS and as a result a modified version of dockercross must be used.

As of October 2021 the Raspberry Pi OS uses Debian buster, GCC 8.3, and glibc 2.28.
In order to successfully build packages for the rPi a version of dockercross must be built that
uses (more or less) exactly these software versions. This can be accomplished as follows:
- start with dockercross at commit `12a662e`, which is the last commit that uses buster
- replace `linux-armv7/crosstool-ng.config` with the file of the same name in this directory.
- build the linux-armv7 image (`make linux-armv7`)

The dockercross image thus generated is generic -- to compile anything.
It is further customized for SG by installing specific dependencies.
While it may seem odd to split the customization into two steps it does serve a useful
purpose. The dockercross image customized for rPi should works for as long as rPi OS is based
on buster. The additional SG dependencies may well change as the SG software changes.

## Deprecated

The notes below are old and date from when raspbian used Debian stretch.

### GCC compatibility issue

_Note: this issue is resolved as of October 2021, dockcross uses GCC 8.5.0, which is sufficiently close to the 8.3.0 used by the rPi_

This project uses a patched version of dockcross. While using stock dockcross would be preferable, support for modern versions of GCC doesn't yet exist in the armv7 target. When support for GCC > 8 is added, this part can be easily changed to use a stock container by modifing the Dockerfile.

#### Creating armv7-hf target with GCC 8.3.0 using Dockcross

Work in progress. Essential steps are:
- Clone patched dockcross from GitHub: `git clone https://github.com/dockcross/dockcross.git`
- Switch to the `gcc-8.3.0` branch.
- Run `make linux-armv7-hf` to build dockcross/linux-armv7-hf container.
  - This step can take some serious time.
  - If you get an error about being out of space, increase the size of Docker's volumes by adding `{"storage-opts": ["dm.basesize=64G"]}` to `/etc/docker/daemon.json`. GCC is pretty large and needs more than the default 10GB of space. 64GB is way more than needed. **This may delete any existing containers/images.**
- Run `docker build -t dockcross/linux-arm7-hf .` with the Dockerfile included in this project.
- Run `docker run sensorgnome-armv7-hf > linux-armv7-hf` to create an bash script that sets up and runs dockcross.
- Make the script executable `chmod +x ./linux-armv7-hf`.
- Now cross-compiling should be working.
