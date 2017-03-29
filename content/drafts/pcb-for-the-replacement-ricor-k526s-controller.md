---
kind: draft
title: "PCB for the replacement Ricor K526S controller"
tags:
  - electronics
  - cryogenics
  - repair
---

In a [previous note](/notes/2016-08-07/replacement-for-the-ricor-k526s-controller/) I've designed a replacement controller for the Ricor K526S cryocooler. In this note I describe a PCB I designed that fits into the original case.

The schematics is simple:

![](/images/ricor-k526s-controller/schematics.png)

I've used 10A MOSFETs, and high-side MOSFET drivers on every channel to make sure the low-side FETs conduct as well as the high-side ones. It's actually overkill in both cases: the motor shouldn't consume more than 3 A and Vgs of 5 V should be sufficient to supply exactly 3A, but I remember the original driver heating up a lot when the rotor wasn't spinning well, and so I decided to add this safety factor.

The board turned out quite elaborate:

![](/images/ricor-k526s-controller/board.png)

The BOM is as follows:

TBD

The design files are TBD.

The gateware differs from [the previously developed one](/notes/2016-08-07/replacement-for-the-ricor-k526s-controller/#controller-logic) as it supports self-test (when TP1 is pulled high):

TBD
