---
layout: post
title: "An improvised vacuum chamber"
date: 2014-12-01 00:37:33 +0300
comments: true
categories:
  - vacuum
---

In this note I describe an improvised vacuum chamber made out of stuff I had laying around the house, and some fun things I did with it.

<!--more-->

* table of contents
{:toc}

Tools
-----

rotary vane vacuum pump
: generic, single-stage 47 l/min

CNC mill
: [CNC3020T](http://www.freezepage.com/1395478161OWYSYNBZGX)

CNC fixture attachment
: [own work](/notes/2014-08-17/a-fixture-attachment-system-for-cnc-3020t/)

flat endmill
: d=1.6mm two flute endmill

drill
: IKEA cordless drill

d=5mm drill bit for metal
: generic

rf power source
: [own work](/notes/2014-11-30/three-point-oscillator/), ~32 MHz at up to 60 W input

Materials
---------

glass bin
: Nescafe 200ml coffee bin

flat elastomer sheet
: generic latex glove

vacuum hose
: generic freon charging hose

plastic tube with OD equal to ID of vacuum hose
: generic

acrylic sheet
: d=3mm

*[ID]: inner diameter
*[OD]: outer diameter

Fabricating flange adapter
--------------------------

The following is the [LinuxCNC][] parametric G-code that I used for milling this adapter. Being parametric, it can be adjusted for different acrylic thickness, etc.

{% include_code files/coffee-bin-chamber-flange.ngc lang:text %}

{% fancybox /images/coffee-bin-chamber/flange.jpeg %}

In principle, the adapter can be made without the groove. Then, while it is harder to achieve good sealing, it is possible to fabricate it using only simple manual tools.

[linuxcnc]: http://linuxcnc.org

Assembling
----------

The overall assembly looks like this when exploded:

{% fancybox /images/coffee-bin-chamber/exploded.jpeg %}

The hose is fixed inside the central hole of the flange by inserting it into the hole and then anchoring it there by driving the plastic tube inside the hose:

{% fancybox /images/coffee-bin-chamber/flange-on-hose.jpeg %}

The elastomer is then cut into rings--one ring was not enough to achieve good seal, so I used two--and placed between the chamber and the flange:

{% fancybox /images/coffee-bin-chamber/assembled.jpeg %}

Pumping down
------------

Rotary vane pumps exhibit peculiar behavior at different inlet pressures that allow to roughly monitor the pumping process:

  * At the very beginning, the pump will exhaust a lot of oil mist while pumping near atmospheric pressure gas. This should be over in a few seconds.
  * Next, the pump will hum for about a minute (for this 200ml chamber).
  * Next, the pump starts rattling. This is completely normal, and in fact desirable, as it signifies that the pressure is under 100 Pa.

If the process doesn't advance to a next stage, it means there is a leak in the chamber.

Lighting up
-----------

After the pressure is under 100 Pa, a glow discharge can start. Place the chamber near the rf coil and it will start to glow!

{% fancybox /images/coffee-bin-chamber/violet.jpeg %}

I've also heated the chamber to ~60°C while pumped down, which caused it to glow white rather than purple:

{% fancybox /images/coffee-bin-chamber/white.jpeg %}

I'm not sure why this happens exactly.
