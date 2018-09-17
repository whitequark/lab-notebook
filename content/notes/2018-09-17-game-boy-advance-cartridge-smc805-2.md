---
kind: article
created_at: 2018-09-17 11:02:33 +0000
title: 'Game Boy Advance cartridge "SMC805-2 VER:1.5"'
tags:
  - electronics
  - reverse engineering
---

I have been asked to determine if a (pirate) Game Boy Advance cartridge with the PCB marked "SMC805-2 VER:1.5 2006.11.16" can be reflashed. The cartridge contains a battery, an ASIC in a chip-on-board package (epoxy blob), an unidentified Intel chip marked "RL0ZAA00" (possibly "RLOZAA00" or "RLOZAAOO") "A5367952" "Z37LA59B" in a VFBGA-56 package, an ISSI (neé ICSI) static RAM [IS62LV1024LL-55H](/files/gba-cartridge/IS62LV1024.pdf) in a TSOP-32 package, and miscellaneous passives.

Front side of the board with the cartridge pins annotated ([zoomable version](/images/gba-cartridge/labelled.svg)):

<object type="image/svg+xml" data="/images/gba-cartridge/labelled.svg"></object>

It was immediately clear that the Intel chip has to be a Flash, it has a parallel interface, and by looking at it at a shallow angle to the PCB, it could be seen that the balls are laid out in a 7x8 grid. It was then a matter of a search query to discover that an Intel parallel flash in a BGA-56 package belongs to the 28F series, similar to [28F128Kxx](/files/gba-cartridge/28F128.pdf).

After desoldering the chip, I have traced the test points to the balls they are connected to, and the pinout matched the 28F series perfectly. Test point assignment ([zoomable version](/images/gba-cartridge/labelled-mag.svg)):

<object type="image/svg+xml" data="/images/gba-cartridge/labelled-mag.svg"></object>

Note that the Flash interface is completely independent from the cartridge interface; every Flash interface data signal goes through the ASIC.

It is not clear if the Flash interface is tristated by the ASIC when not in use, or by some other method, such as the J1-J2 switch.
