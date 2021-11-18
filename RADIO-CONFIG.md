Radio Dongle Configuration
==========================

Once the Sensorgnome operating system is up and running the various radio dongles need
to be plugged in, configured, and their proper operation verified.

To verify that the radios are operating properly a simple web browser that can bring up the
Sensorgnome's UI web page is sufficient.

USB port mapping
----------------

The purpose of USB port mapping is to establish a clean correspondence between (human-readable)
labels on USB ports, port numbers reported to Motus, and the port designations used by the
Sensorgnome software.

While establishing the port mapping may seem like a detail it is actually extremely important
because it is the most critical link in communicating antenna orientation to Motus.
When detection data is evaluated, the antenna information is often used to determine animal
travel direction.
If antennas, radios or ports are misidentified the result is bad science!

### Background

Motus identifies ports using single digit integers from P1 through P9
and P0 (which stands for 10).
It is recommended to label the ports on a Sensorgnome in the same way from 1 through 10
(e.g. using marker pen, sticky labels, etc).

By convention, port 1 is the upper port on the Raspberry PI next to the Ethernet jack,
port 2 is below, 3 is the upper outer port, and 4 is the lower outer port.
Typically a Sensorgnome uses a USB hub plugged into the rPi port 4
and the hub's ports are numbered 4 through 7 or 4 through 10 depending on whether it's a 4-port
or a 7-port hub.

The software uses an entirely different port numbering, which consists of the _path_ through ports
and hubs to reach a device. For example, a radio plugged into port 3 of a hub, itself plugged
into port 4 of an rPi ends up with the path `1.4.3` (the leading 1 refers to the first root
hub).

### Mapping

_The following procedure is intended to be made accessible entirely through the web UI._
_Editing the `usb-port-map.txt` file is a stop-gap measure._

To perform the mapping follow these steps:

- ensure all USB ports are labeled and all devices to be plugged in are also labeled
- bring up the sensorgnome's web UI and locate the "Devices" section
- unplug all USB devices (leaving any hub plugged in)
- plug one device into the desired port, 
- Watch the device appearing in the Web UI's "Devices" section, note the path shown in
  parentheses (ex: 1.3.4)
- Make a note of the mapping from path to desired port, ex: "1.3.4 -> 5" to map that path to port 5
- Plug each remaining USB device in one at a time and take note of the desired mapping
- SSH into the sensorgnome and edit `/data/config/usb-port-map.txt` or move the SDcard to your
  laptop and edit `config/usb-port-map.txt` in the "DATA" drive
- Add the mappings noted down to the file (see instructions therein, but it's the format shown
  above of _path_ `->` _port_)
- Move the SDcard back to the SG, power up, and double-check the port assignments

The port mappings are deterministic when using the same model rPi and the same hub models, so
the `usb-port-map.txt` file can be copied between identical devices.

In the end it is highly recommended to double check the correct port mappings:

- Verify in the Web UI "Devices" that all devices are assigned a port 1 through 10 (no port should
  be shown in red)
- Unplug each device in turn, watch the correct line disappear, plug it back in and watch the
  correct line with the correct port number reappear.

Verifying successful reception
------------------------------

To verify the correct end-to-end operation of radios some test tags are necessary.
For Lotek tags a tag database with the test tags is recommended but not essential.

### Verify the reception of Lotek tags

- Ensure at least one FunCube or RTLSDR radio is plugged in and shows in the Web UI Devices
  section with a port numbered 1 through 10 (i.e. not shown in red)
- Ensure the test tag is activated
- Watch the "Live Pulses" box in the Web UI, when the tag transmits next you should see 3-4
  lines of the form `00:01:14.346 p3 2.812 kHz -39.57 / -53.8 dB` where the `p3` refers to
  USB port 3
- If you loaded a tag database and the tag is in that database then after 2 radio bursts
  (i.e. 8 lines in the "Live Pulses") you should see you tag listed in the "Live Known Tags"
  box, e.g. `01:13:36.199 ant  3 TestTags#1.1@166.38:25.1 + 2.826kHz -43.6/-54.9dB`
- Note that if you have multiple radios plugged in you should see live pulses and live known
  tags from all of them, so you should see more than 4 lines appear at once.

### Verify the reception of CTT tags

- Ensure at least one CTT MOTUS adapter or equivalent is plugged in and shows in the Web UI
  Devices section with a port numbered 1 through 10 (i.e. not shown in red)
- Ensure the test tag is activated, or in the case of a solar LifeTag that it has bright light
  shining on it
- Watch the "Live known tags" box and you should see tag transmissions appear of the form
  `01:16:36.017 port 2 78664C33 @434Mhz -74dB`

### Troubleshooting

- As you plug radios into USB ports they should appear in the Web UI Devices section within
  2-3 seconds. If they don't, reboot the Sensorgnome. If that doesn't make them show up
  there is a software or hardware problem. Compare with what happens as you plug/unplug
  other identical devices if you have any.
- If a FUNcube is shown in the Devices section with a frequency other than the expected one
  (166.376 for north America) press the "Refresh Devices List" button. If that doesn't fix it
  _TBD_
- If the Devices look correct but the Live Pulses do not show anything first ensure your test
  tag is active and remember this box only shows Lotek tags. Some test tag intervals are long,
  e.g. 25 seconds, so have some patience. If nothing happens, reboot the Sensorgnome.
- If you see Live Pulses but no Live Known Tags check the Tag Database section in the Web UI
  and ensure it has your test tag listed. If not, you need to update the tag database on the
  SDcard in `/data/config/SG_tag_database.sqlite` or in `config/SG_tag_database.sqlite` in the
  DATA drive when you plug the SDcard into your laptop.
