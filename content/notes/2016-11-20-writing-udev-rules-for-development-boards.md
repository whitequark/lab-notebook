---
kind: article
created_at: 2016-11-20 09:01:51 +0000
title: "Writing udev rules for development boards"
tags:
  - software
---

When developing hardware, one encounters two problems:

  1. The JTAG adapter (or the like) isn't visible to the JTAG programmer running as a process
     under an unprivileged user.
  2. There are approximately eleven USB-Serial adapters plugged in and they arrange themselves
     through a fair dice roll on every reboot.

Sometimes <em>\*cough\*FTDI\*cough\*</em> you could even encounter both with the same device!
Exciting!

This note is Linux-specific.

# Matching a device series

A device series is usually uniquely identified by a VID/PID pair (unless the vendor decided
to cheap out on a [license][usbpid] from the USB consortium and didn't bother open-sourcing
their design and applying via [Openmoko][ompid], which happens more often than you'd expect).

[usbpid]: http://www.usb.org/developers/vendor/
[ompid]: http://wiki.openmoko.org/wiki/USB_Product_IDs

A VID/PID pair can be identified using `lsusb`:

<pre>
Bus 001 Device 005: ID <b>0403:6010</b> Future Technology Devices International, Ltd FT2232C Dual USB-UART/FIFO IC
</pre>

Then, create a file such as `/etc/udev/rules.d/99-ftdi.rules` using the VID/PID pair:

<pre>
ACTION=="add", ATTR{idVendor}=="<b>0403</b>", ATTR{idProduct}=="<b>6010</b>", MODE:="666"
</pre>

Some other attributes that can be used are `ATTR{manufacturer}`, `ATTR{product}` and
`ATTR{serial}`, which are listed when calling <code>lsusb -d <b>0403:6010</b></code> at
the end of the rows `iManufacturer`, `iProduct` and `iSerial`. These are especially useful
if the vendor was in fact too cheap for an unique VID/PID pair.

# Matching a specific device (endpoint)

A device endpoint is usually uniquely identified by the combination of manufacturer string,
product string, serial string, and endpoint number. (In case there's only one endpoint,
like in most simple USB-serial ICs, that can be dropped.) If you know the device file,
udev can tell everything you need:

<pre>
$ udevadm info -q all /dev/ttyUSB3
P: /devices/pci0000:00/0000:00:1c.4/0000:04:00.0/usb3/3-2/3-2:1.1/ttyUSB3/tty/ttyUSB3
N: ttyUSB3
S: serial/by-id/usb-Silicon_Labs_CP2105_Dual_USB_to_UART_Bridge_Controller_XXXXXXXX-if01-port0
S: serial/by-path/pci-0000:04:00.0-usb-0:2:1.1-port0
E: DEVLINKS=/dev/serial/by-id/usb-Silicon_Labs_CP2105_Dual_USB_to_UART_Bridge_Controller_XXXXXXXX-if01-port0 /dev/serial/by-path/pci-0000:04:00.0-usb-0:2:1.1-port0
E: DEVNAME=/dev/ttyUSB3
E: DEVPATH=/devices/pci0000:00/0000:00:1c.4/0000:04:00.0/usb3/3-2/3-2:1.1/ttyUSB3/tty/ttyUSB3
E: ID_BUS=usb
<b>E: ID_MODEL=CP2105_Dual_USB_to_UART_Bridge_Controller</b>
E: ID_MODEL_ENC=CP2105\x20Dual\x20USB\x20to\x20UART\x20Bridge\x20Controller
E: ID_MODEL_FROM_DATABASE=CP210x UART Bridge
E: ID_MODEL_ID=ea70
E: ID_PATH=pci-0000:04:00.0-usb-0:2:1.1
<b>E: ID_PATH_TAG=pci-0000_04_00_0-usb-0_2_1_1</b>
E: ID_PCI_CLASS_FROM_DATABASE=Serial bus controller
E: ID_PCI_INTERFACE_FROM_DATABASE=XHCI
E: ID_PCI_SUBCLASS_FROM_DATABASE=USB controller
E: ID_REVISION=0100
<b>E: ID_SERIAL=Silicon_Labs_CP2105_Dual_USB_to_UART_Bridge_Controller_XXXXXXXX</b>
E: ID_SERIAL_SHORT=XXXXXXXX
E: ID_TYPE=generic
E: ID_USB_DRIVER=cp210x
E: ID_USB_INTERFACES=:ff0000:
<b>E: ID_USB_INTERFACE_NUM=01</b>
E: ID_VENDOR=Silicon_Labs
E: ID_VENDOR_ENC=Silicon\x20Labs
E: ID_VENDOR_FROM_DATABASE=Cygnal Integrated Products, Inc.
E: ID_VENDOR_ID=10c4
E: MAJOR=188
E: MINOR=3
E: SUBSYSTEM=tty
E: TAGS=:systemd:
E: USEC_INITIALIZED=14656077412643
</pre>

Then, create a file such as /etc/udev/rules.d/99-cp2105.rules using the full identifier
and interface number:

<pre>
ACTION=="add", SUBSYSTEM=="tty", \
  ENV{ID_SERIAL}=="<b>Silicon_Labs_CP2105_Dual_USB_to_UART_Bridge_Controller_XXXXXXXX</b>",
  ENV{ID_USB_INTERFACE_NUM}="<b>01</b>", \
  SYMLINK+="cp2105_i1"
</pre>

This will create a file `/dev/cp2105_i1` when this specific IC is connected to USB, no matter
where. Or, use the path:

<pre>
ACTION=="add", SUBSYSTEM=="tty", \
  ENV{ID_MODEL}=="<b>CP2105_Dual_USB_to_UART_Bridge_Controller</b>", \
  ENV{ID_PATH_TAG}=="<b>pci-0000_04_00_0-usb-0_2_1_1</b>",
  ENV{ID_USB_INTERFACE_NUM}="<b>01</b>", \
  SYMLINK+="cp2105_i1"
</pre>

This will create the device file when any IC from this series is connected to this specific USB
port. This is of course more fragile, but works with devices that don't have unique serial numbers.
