Sensorgnome and SixFab HAT support
==================================

**Please do NOT install the SixFab software from their site on your Sensorgnome**
unless you really want to after reading this page first.

Tl;Dr;
------

- The Sixfab 4G/LTE cellular HAT is supported by the SG images, the relevant SixFab
software is already installed and configured in the image.
- You do not need to (and should not) install anything from Sixfab.
- You only need to activate their SIM on their site in the sense of entering your
billing information and choosing a data plan. You do _not_ need to enter any
activation code or anything similar into the SG or its software: once SixFab
can bill you, your SIM works.
- The remote management via the Sixfab site is not officially supported by the SG.
It duplicates functionality from the SG Hub site, results in duplicate management,
and has unknown security implications.
- If you need the Sixfab remote management (i.e. control of your SG and network
through the sixfab web site) please contact the SG developers on github, using
the Sensorgnomads google group, on the Motus slack, or via direct email.

### Activating the SixFab SIM

(The author of this note doesn't have a fresh SIM to test the steps out, so they
may differ from this description. Corrections appreciated.)

- Go to connect.sixfab.com and establish an account
- Establish billing information (and/or enter any coupon you may have received
with the HAT).
- Use the "SIM" section in the left bar to register your SIM (enter the ICCID),
this will activate the SIM, i.e., allow it to connect to a cellular network
and transfer data.
- Do not use the "CORE" section in the left bar: it has to do with the remote management. You do not need to register devices, which is something that has to
do with their remote management of your SG.

### Activating a non SixFab SIM

You can use a non SixFab SIM with the SixFab HAT:
- It must not have a PIN set (a PIN could be handled but currently isn't).
- It may simply work or it may require the "APN" to be set (your carrier should
provide the APN name).
- To set the APN: (needs to be worked out, they obfuscate this stuff)

### SixFab UPS HAT

- The SixFab UPS HAT is sort-of supported by the SG image.
Their firmware has issues making the usefulness of the HAT questionable.
- The Sixfab software for the HAT is already installed in the SG image.
- The SG web UI contains a panel displaying the (often incorrect) information
provided by the HAT firmware.
- You do not need to (and should not) install anything from Sixfab.

Details
-------

The SixFab software consists of three pieces for the two HATs:
- the "core manager" makes the cellular modem work
- the "ups manager" makes the UPS HAT work
- the "core agent" is a remote management agent that allows you to control your
  SG and network through the sixfab web site.

The core manager is already installed and configured in the SG image.
It initializes the modem, baby-sits it (restarting it when there's a problem),
and works with any SIM including the SixFab ones (although some SIMs may require
the "APN" to be configured).

The UPS manager is already installed and configured in the SG image.
It initializes the UPS HAT and enables reporting of information about the
UPS HAT.
This software, in particular the firmware it loads into the HAT, is buggy and
Sixfab has not updated it in over two years (as of early 2023).
In particular, the information about battery voltage and state of charge is
often incorrect, which raises questions about how well it actually
manages and protects the battery.
The HAT also does not seem to resolve rPi under-voltage warnings, which was
the primarily motivation for trying it out.
This being said, it does seem to mostly work.

The core manager is a remote management agent that provides some monitoring
information and provides remote management of the rPi.
It duplicates a lot of functionality of the SG Hub, which provides a more
Sensorgnome-centric view.
The management through the Sixfab site can be handy, however, it is not supported
in the Sensorgnome for the following reasons:
- It hands full access to the Sensorgnome and to the network it is connected to
SixFab without there being any information about the resulting security implications
or SixFab's security practices.
- The network usage implications of the SixFab core agent (which needs to keep a
connection open to SixFab at all times) is unknown and cannot be controlled
(at the end of the day they benefit from extra data usage...).
- While Sixfab makes it look like you have to install their core agent to use
the HAT or their SIM, this is not the case!
- The core agent only works with the SixFab HAT and the SixFab SIM, this means that
it only ever works with a subset of SGs and effort put into supporting it
cannot be spent on supporting something that workes for every SG.

For the reasons above the Sensorgnome image prevents the simple install of the
Sixfab software from the Sixfab site.
The motivation is to avoid the unnecessary installation of the software by
users who do not need it and who are lead to believe they need it by
the Sixfab instructions.
If some users want to use the Sixfab remote management, this can be accomplished.
