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

I found it convenient to have a table with a grid of nuts for screwing down the workpieces that could double as victim material. In this note I describe how to simply make such a table out of HDPE.

<!-- more -->

Introduction
------------

My first prototype used a plywood board, however, that doesn't work well with water as coolant; also, plywood tends to deform in unexpected and non-uniform ways. HDPE is cheap, easily machined, works well as victim material, and resists deformation well.

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

d={1, 3.175}mm flat endmill
: generic

Materials
---------

HDPE sheet, 300x300x12.7mm
: [generic](https://archive.today/17vTG)

{M6x12 screw, M6x40 bolt, M6 nut, M6 wing-nut, M6 washer} ×6
: generic

Process
-------

Sheet was cut to fit CNC3020T's table of 300x200mm using a jig saw.

{% fancybox /images/cartesian-fixture/rectangular.jpeg %}

### Mounting holes

Sheet was marked for drilling on a drill press using d=1mm endmill. Sheet wasn't drilled on the mill itself to avoid crashing the endmill into the table.

Marking was done using the following G-code script. Origin corresponds to the top of sheet, center of nearest leftmost mounting hole.

{% include_code files/cartesian-fixture/mark.ngc lang:text %}

{% fancybox /images/cartesian-fixture/drilled.jpeg %}

After drilling, pockets for screw heads were made. Initially, commands for milling first and last pocket were commented out and the sheet was attached using a M6x40 bolt in the T-slot, washer and a wingnut. After that, the sheet was reattached properly, i.e. using M6x12 screw and a nut in the T-slot, and the remaining pockets were milled.

{% include_code files/cartesian-fixture/screw-heads.ngc lang:text %}

{% fancybox /images/cartesian-fixture/fixed-1.jpeg %}
{% fancybox /images/cartesian-fixture/fixed-2.jpeg %}
