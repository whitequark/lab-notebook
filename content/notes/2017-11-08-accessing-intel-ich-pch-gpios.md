---
kind: article
created_at: 2017-11-08 08:37:49 +0000
title: "Accessing Intel ICH/PCH GPIOs"
tags:
  - software
  - electronics
---

In this note I describe the method required for accessing GPIOs on (in theory) every Intel chipset from ICH0 to (at least) Series 100 PCH.

<!--more-->

* table of contents
{: toc}

# Overview

Historically (going as far back as ICH0), Intel used a special PCI function to implement a multitude of legacy functions (such as `A20#`, the [LPC bus], etc). The Intel lingo for this is "D31:F0", as in "device 31, function 0", but it shows up in `lspci` as `00:1f.0 ISA bridge`. In this note, I will use the Intel terminology for PCI devices.

[LPC bus]: https://en.wikipedia.org/wiki/Low_Pin_Count

## GPIOs on ICH0..9 and Series 5..9 PCH

On these platforms, D31:F0 has an I/O BAR. The size of the I/O space was increased for ICH6, but otherwise the GPIO interface is identical. It is comprised of a set of I/O ports. To access them, it is enough to place the I/O space of the function in the global I/O space, and enable decoding.

The implementation is as follows:

  * The vendor and device IDs are checked to make sure we're not crashing the system.
  * The I/O BAR is configured via libpci.
  * The I/O permissions are requested via ioperm.
  * Finally, GPIO registers can be used.

## GPIOs on Series 100 PCH

On these platforms, D31:F0 is solely dedicated to being an LPC bridge. The GPIOs are located in what Intel calls "private configuration space", accessible through a "primary to sideband bridge" through "target port IDs". All this seems extremely opaque, but in reality very little has changed.

The "primary to sideband bridge" is simply a PCI function (located at D31:F1) that has BAR0, a memory BAR, "private configuration space", initialized by platform firmware to point to some location it finds convenient. To prevent the OS from reassigning the BAR, the firmware "hides" the device, namely sets a bit in the configuration space that causes all reads to return all-ones. (Writes still go through.) The "target port ID" is the bits [23:16] of the D31:F1 BAR0.

The implementation is as follows:

  * The vendor and device IDs are checked to make sure we're not crashing the system.
  * The D31:F1 function is blindly enabled bypassing the operating system as to avoid changing the BAR, and verified to have been enabled correctly.
  * The memory BAR is read from D31:F1.
  * The D31:F1 function is quickly disabled again.
  * The address read from BAR is mapped into the process' address space.
  * Finally, GPIO registers can be used.

# Intel documentation

 * Intel® 82801EB I/O Controller Hub 5 (ICH5) / Intel® 82801ER I/O Controller Hub 5 R (ICH5R) Datasheet (Document [252516-001])
 * Intel® 9 Series Chipset Family Platform Controller Hub (PCH) Datasheet (Document [330550-002])
 * Intel® 100 Series and Intel® C230 Series Chipset Family Platform Controller Hub (PCH) Datasheet – Volume 1 of 2 (Document [332690-004EN])
 * Intel® 100 Series and Intel® C230 Series Chipset Family Platform Controller Hub (PCH) Datasheet - Volume 2 of 2 (Document [332691-002EN])

[252516-001]: /files/gpioke/Intel-252516-001.pdf
[330550-002]: /files/gpioke/Intel-330550-002.pdf
[332690-004EN]: /files/gpioke/Intel-332690-004EN.pdf
[332691-002EN]: /files/gpioke/Intel-332691-002EN.pdf

# Code

Run `make && sudo ./gpioke` and enjoy a printout of GPIO status live from your chipset. This demo was written very carefully and is not supposed to ever crash your machine. However, it has not undergone a lot of live testing.

<% highlight_code 'make', 'Makefile' do %>
CFLAGS = -std=c11 -lpci -Wall -g

gpioke: gpioke.c
  $(CC) $(CFLAGS) -o $@ $^
<% end %>

<%= highlight_code 'c', '/files/gpioke/gpioke.c' %>
