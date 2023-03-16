Sensorgnome security and networking
=================================

Note: this document is intended for security/network admins to provide an overview
of the security and communication methods employed by a Sensorgnome device.

The Sensorgnome (SG) software is open source and available for audit at:
- https://github.com/tve/sensorgnome-control (web interface and uploader)
- https://github.com/tve/sensorgnome-support (system services)
- https://github.com/tve/sensorgnome-build (system image build)

The overall strategy employed can be summarized as follows:
- leverage as standard an OS image as possible
- limit protocols to SSH and HTTPS
- use outbound-only connections across the internet
- enforce the selection of a reasonably strong password at configuration time
- use a single password for the system to avoid "password fatigue"

Operating system image and updates
----------------------------------

- The SG base image is a standard Raspberry Pi OS image, i.e. Debian Bullseye as of
  early 2022.
- The image uses the standard repositories, plus an additional repository for the
  Sensorgnome software.
- The Raspberry Pi foundation does not publish security updates like Ubuntu does, for
  example. Thus it is not possible to auto-install just security updates. However,
  security fixes are promptly made available in the general repo. It is thus possible to
  enable automatic "full" updates, but the system stability of doing so is unknown.

Passwords
---------

- Sensorgnomes use a non-standerd standard 'gnome' linux user and users are forced to provide a password
  when first deploying a Sensorgnome (the software does not work unless a password is set).
- The password is checked against a "top 100k passwords" list.
- It is possible to use SSH keys and disable password login using standard linux procedures.
- The same password is used to log in as user 'gnome' and to access the web interface (the web
  interface uses a PAM plugin to auth)

Network interfaces
------------------

- The Sensorgnome supports four network interfaces: ethernet, wifi client, wifi
  hotspot (access point), and if installed, cellular.
- The SG never forwards (routes) packets between the interfaces.
- The ethernet interface uses DHCP and is the preferred interface for internet access.
- The wifi client interface can be configured through the web interface and supports
  WPA2 PSK. It should be possible to configure WPA2 EAP or WPA3, but not through the web interface.
  The interface expects a DHCP server for configuration.
- The wifi hotspot can be enabled/disabled through the web interface or by pressing a button on
  the Sensorgnome. The hotspot uses WPA2 PSK.
- The cellular interface supports a variety of 4G LTE modems that are typically USB-attached.

Data upload
-----------

- The Sensorgnome uploads new data automatically approximately every hour via HTTPS to a Motus server
  (port 443).
  This assumes internet connectivity via one of the ethernet, wifi client, or cellular interfaces.
- The upload data volume is typ. under 5MB/day.
- Network connectivity (when a default route is provided via DHCP) is probed by connecting to
  http://connectivitycheck.gstatic.com/generate_204, which is one of the standard Android
  connectivity check addresses.
- Users can manually trigger an upload using the web interface.
- Users can also manually download data to their laptop/phone via the web interface.
- The Sensorgnome also connects to a Motus server using HTTPS to send status and monitoring data.

Open ports
----------

- port 22 (SSH): SSH access, root login disabled, only user 'gnome' access
- port 80 (HTTP): redirect to port 443 (HTTPS)
- port 443 (HTTPS): web interface to monitor Sensorgnome status and perform configuration changes

HTTPS certificates
-----------------

- due to the fact that a Sensorgnome needs to operate without having a public DNS name it cannot
  use regular HTTPS certificates (e.g. from Let's Encrypt), instead a certificate from local-ip.co
  is used.
