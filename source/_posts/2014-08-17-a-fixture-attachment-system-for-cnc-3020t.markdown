---
layout: post
title: "A fixture attachment system for CNC3020T"
date: 2014-08-17 19:18:13 +0400
comments: true
categories:
  - cnc
  - cnc3020t
  - fixture
---

I found it convenient to have a table with a grid of nuts for attaching the workpieces, that could double as victim material. In this note I describe how to make such a table out of HDPE.

<!-- more -->

* table of contents
{:toc}

Introduction
------------

My first prototype used a plywood board, however, that doesn't work well with water as coolant; also, plywood tends to deform in unexpected and non-uniform ways. HDPE is cheap, easily machined, works well as victim material, and resists deformation well.

This note describes a table with uniform 8x7 nut array, spaced 30mm between nuts, accepting M4 screws; there is at least 3mm of victim material at any point (5.2mm over nuts, 3mm over mounting screws).

All G-code is parametric (it thus requires LinuxCNC) and can be easily customized if other parameters are needed.

Tools
-----

jig saw
: DEXTER IC400JS

jig saw blade
: [Bosch T301CD](http://www.boschtools.com/Products/Accessories/Pages/BoschAccessoryDetail.aspx?pid=T301CD)

drill press
: PRACTYL 500W with 16mm collet

d=6mm wood drill bit
: generic

CNC mill
: [CNC3020T](http://www.freezepage.com/1395478161OWYSYNBZGX)

d=3.175mm cylindrical endmill
: generic

d=1.5mm l=7.5mm cylindrical endmill
: generic

Materials
---------

HDPE sheet, 300x300x12.7mm
: [generic](https://archive.today/17vTG)

{M6x40 screw, M6 wing-nut, M6 washer} ×4
: generic

{M6x12 bolt, M6 nut} ×6
: generic

M4 nut ×42
: generic

Process
-------

Sheet was cut to fit CNC3020T's table of 300x200mm using a jig saw.

{% fancybox /images/cartesian-fixture/rectangular.jpeg %}

### Mounting holes

Sheet was marked for drilling on a drill press using d=1.5mm endmill. Sheet wasn't drilled on the mill itself to avoid crashing the endmill into the table.

Marking was done using the following G-code script. Origin corresponds to the top of sheet, center of nearest leftmost mounting hole.

{% include_code files/cartesian-fixture/mark.ngc lang:text %}

{% fancybox /images/cartesian-fixture/drilled.jpeg %}

After drilling, pockets for screw heads were milled using d=3.175mm endmill. Initially, commands for milling first and last pocket were commented out and the sheet was attached using a M6x40 bolt in the T-slot, washer and a wingnut. After that, the sheet was reattached properly, i.e. using M6x12 screw and a nut in the T-slot, and the remaining pockets were milled.

{% include_code files/cartesian-fixture/screw-heads.ngc lang:text %}

{% fancybox /images/cartesian-fixture/fixed-1.jpeg %}
{% fancybox /images/cartesian-fixture/fixed-2.jpeg %}

### Nut slots

Sheet was fixed upside-down on the table. To avoid crashing the endmill into the table, a washer was placed between the table and the sheet, offsetting it by 2mm. In other words, a vertical slice through the mounting hole looks like: *bolt head* : *T-slot* : *washer* : *sheet* : *washer* : *wing-nut*.

The middle bolts should be **removed** despite being present on the picture. I discovered they would interfere with the spindle too late. I have replaced them with just a washer between table and sheet.

{% fancybox /images/cartesian-fixture/fixed-3.jpeg %}

Pocketing was done using the following G-code script. The origin is at (13mm,45mm) from near left corner, owing to the asymmetry of the work area.

{% include_code files/cartesian-fixture/nut-pockets.ngc lang:text %}

After pocketing, an M4 nut was driven inside each pocket.

{% fancybox /images/cartesian-fixture/finished-bottom.jpeg %}
{% fancybox /images/cartesian-fixture/finished-top.jpeg %}
{% fancybox /images/cartesian-fixture/mounted.jpeg %}

### Fixing workpieces

I have tried several methods of fixing workpieces in the past. The problem is that the forces inflicted by cutting can be quite great; if the only counteracting force is friction, it *will* get slightly displaced.

So the simple and reliable solution is: just drill some holes in it and screw it down. I drill holes with a d=5mm drill to allow for some inaccuracy in marking the holes and flexibility of material.

{% fancybox /images/cartesian-fixture/fixed-pcb.jpeg %}

Conclusions
-----------

 * HDPE sheet is great for this kind of fixture; it is rigid and does not interact with coolant.
 * Nuts fit tightly inside the pockets and do not get displaced.
 * Offsetting nuts by 7.5mm allows a large margin for attaching materials of different thickness.
 * Placing nuts over the T-slots allows the coolant to escape rather than get stale inside the pockets; nevertheless, nuts can slowly corrode over time.
