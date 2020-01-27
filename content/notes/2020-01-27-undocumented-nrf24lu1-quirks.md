---
kind: article
created_at: 2020-01-27 23:48:52 +0000
title: "Undocumented nRF24LU1+ quirks"
tags:
  - electronics
  - reverse engineering
---

While working with nRF24LU1+, I discovered that the chip has lots and lots of odd corners that are sparsely or strangely documented, where the silicon doesn't match documentation, etc.

<!--more-->

* table of contents
{:toc}

# Info page size

The datasheet describes the info page as 512 bytes long. However, setting `FSR.INFEN` and reading the entire address space reveals a 1024 byte periodic structure. The second half appears to be a ROM (it cannot be either programmed or erased), and on my chip it starts with `43 46 54 39 32 32 11 41 2c` ("CFT922") and has an additional `00` at offset 0x21.

# Reading info page from MCU

The datasheet describes in detail how to read info page via SPI, and that works just fine. However, it doesn't explain how to read it via MCU, which is strange because the info page contains an unique chip ID and it is avilable for user data. The `FSR.INFEN` bit is documented only to affect SPI accesses, for which a diagram implies the info page replaces the 0th page (0x0000..0x0100).

In practice, it works rather differently. Setting `FSR.INFEN` in firmware replaces all data accesses to flash address space (which is the entire lower half of it) with info page accesses, similar to the previous section. However, code accesses are not affected.

In terms of the 8051 instruction set, `MOVC` always performs a code access, and `MOVX` can perform either a data (0) or a code (1) access depending on the state of `PCON.PMW` bit. `PMW` stands for "program memory write", but, in spite of that name, it affects reads too. Because nRF24LU1+ has non-overlapping code and data spaces (besides the info page quirk) there are no references to it in the documentation for that chip, but the documentation for nRF24LE1, which does have overlapping address spaces, is more suggestive.

This means that the info page may be read via the MCU by setting `PCON.PMW` and `FSR.INFEN` to make compiler-emitted `MOVX` instructions work as expected, and then temporarily clearing `PCON.PMW` each time a byte of the info page is read.

# Bootloader and reset vector

The nRF24LU1+ flash is clearly designed for atomic firmware updates: the population count of the 16 bytes at the top of the flash determines whether the bootloader ("protected area") or application ("unprotected area") is executed at reset. Thus, it is expected that the application and bootloader take turns programming single bits, which will succeed under worst case power failure.

However, it is useful to have a permanent bootloader mode, where the chip can be programmed via USB by using a strap pin, or a delay and a special USB request. To achieve this, a single bit may be programmed at the top of flash, with the bootloader running the application if the firmware update trigger is not present.

Unfortunately, branching to address 0 doesn't work; it just causes the bootloader to be re-entered. The datasheet opaquely alludes to this:

> **Note:** In a program running in a protected flash area, movc may not be used to access addresses 0x00 to 0x03.

By using `MOVC` to access those bytes, it can be seen that, rather than changing the address of the reset vector of the MCU (or for that matter the interrupt vector table; interrupts may not be used in the bootloader), the designers of this chip decided to replace code accesses to the reset vector with a procedurally generated instruction; when `FSR.STP` is enabled, the first four bytes of the code address space are replaced with `02 XX YY 00`, where `XX YY` is the address of the first protected page. This decodes to `LJMP #XXYYh; NOP`.

Most 8051 MCUs use an interrupt vector table with 3 bytes per entry, which in practice means that it is usually densely filled with `LJMP` instructions. (However, there are other possibilities, e.g. sdcc may emit `AJMP`.) That means that it is practical for a bootloader to read out an instruction, recognize an `LJMP` (and perhaps a few others) and interpret it, i.e. jump to the address within.

Unfortunately, there is a problem with this approach, which is that even once the application is running, the `FSR.STP` bit is still set, and this corrupts the first byte of the first interrupt vector (timer 0 overflow). This may be worked around by placing a right-aligned `SJMP` or `AJMP` there. Similarly, if no interrupts are used, the linker may place CRT startup code there, which may be worked around with a dummy interrupt handler. In both cases it is necessary to modify the application firmware; there is nothing the bootloader can do here as `FSR.STP` can not be cleared.
