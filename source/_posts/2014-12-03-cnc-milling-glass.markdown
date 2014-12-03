---
layout: post
title: "CNC-milling glass"
date: 2014-12-03 05:24:13 +0300
comments: true
categories:
  - cnc
  - cnc3020t
  - glass
  - vacuum
---

In an earlier note I described an [improvised vacuum chamber][chamber]. I wanted to perform [sputtering][] in it, but an acrylic flange would melt if the feedthroughs got hot enough (and they will get hot), and that would be pretty gross.

[chamber]: /notes/2014-12-01/coffee-bin-chamber/
[sputtering]: https://en.wikipedia.org/wiki/Sputtering

In this note I describe how I CNC-milled a glass flange.

<!--more-->

* table of contents
{:toc}

Tools
-----

CNC mill
: [CNC3020T](http://www.freezepage.com/1395478161OWYSYNBZGX)

CNC3020T fixture attachment
: [own work](/notes/2014-08-17/a-fixture-attachment-system-for-cnc-3020t/)

CNC3020T coolant mod
: [own work](/notes/2014-06-16/cnc3020t-coolant-pump-and-ccw-rotation/)

flat endmill
: d=1.6mm two flute endmill

diamond crown drill
: [Dremel glass drilling bit 662](http://www.dremeleurope.com/general/en/dremel%C2%AEglassdrillingbit-464-ocs-p/)

diamond file set
: generic

Materials
---------

glass sheet
: bathroom mirror shelf, 12.5mm × 12.5mm × 3.9mm non-tempered soda glass panel

acrylic sheet
: d=3mm

Milling fixture
---------------

The first step is to fabricate a fixture that would hold the glass. Other people have been using rather [complicated fixtures](https://www.youtube.com/watch?v=HyI111Tn0Cs#t=61), also made out of acrylic, but I decided to make a fixture that would only compensate for lateral load for simplicity. This has proved to be a good idea.

The following [LinuxCNC][] G-code mills one half of the fixture suitable for my fixture attachment system, which uses a grid of M4 nuts spaced by 30mm:

[linuxcnc]: http://linuxcnc.org

{% include_code files/cnc-milling-glass/fixture.ngc lang:text %}

Unfortunately the G-code is not parametric and will have to be manually adjusted for particular application.

The G-code also contains correction for a positioning error, the reason for which I do not yet know: all distances were uniformly expanded at about 0.2mm per 30mm. The only edge that requires such precision was manually adjusted to compensate.

{% fancybox /images/cnc-milling-glass/fixture.jpeg %}

Note how the left part of the fixture has a gap to workpiece. This is because I in fact used it to determine the positioning error. The right part grips the glass tightly, so it is not a problem.

Milling glass
-------------

All parts of the flange are made using helical milling. This departs from the technique used for the [acrylic flange][acrylic], which plunged into the groove. The following is the adjusted parametric G-code:

{% include_code files/cnc-milling-glass/flange.ngc lang:text %}

Cooling the tool with water is absolutely crucial. The Dremel bit comes with some proprietary mixture containing ethyleneglycol, but I have found that water also works. It might be worth investigating using antifreeze as coolant, though of course it is much more expensive than tap water.

[acrylic]: /notes/2014-12-01/coffee-bin-chamber/#fabricating-flange-adapter

{% fancybox /images/cnc-milling-glass/milling.jpeg %}

I have tried a set of feeds, speeds and helical milling steps (which are just as essential as feeds/speeds for milling glass), and found that a wide range of settings work. In particular:

  * Feed rate does not noticeably affect finish quality. (There will always be chipped edges; more on that later.) I have used feedrates from 10 to 600 mm/min at 4000 rpm with little difference.
  * Spindle speed does not noticeably affect quality, but with a mill that uses PWM and a DC motor, low spindle speed will result in the tool seizing inside deep pockets. This does not seem to be due to direct friction, but rather, seemingly, due to water acting to prevent rotation instead of lubricating it. 4000 rpm was not enough, 15000 rpm was.
  * Milling step does not noticeably affect quality, again. I did most of my testing with 50µm step to reduce the load on the tool and workpiece. With 600 mm/min feedrate, it is moderately quick.

Unfortunately the workpiece seems to crack away when the pocket reaches the final ~0.4mm of glass, no matter how slow I go or how thin a step I use. I decided to just use a diamond file to dull the edge; the cracks don't touch the bulk of material, so they don't matter for my usage.

{% fancybox /images/cnc-milling-glass/bottom-edge.jpeg %}

The top edges and inner edges (which are milled even after the non-fixed part of the workpiece breaks away) are chipped as well, though the defects are even smaller and duller.

{% fancybox /images/cnc-milling-glass/top-edge.jpeg %}
{% fancybox /images/cnc-milling-glass/inner-edge.jpeg %}

The straight path across the flange was a G-code bug, which is fixed in the G-code I publish.

Results
-------

Working with glass is much easier than I expected. If minor chipping is not a problem for you, then it's even easier than acrylic and aluminium.

It would be interested to mill an aspherical [lens](/notes/2014-05-27/making-a-lens-using-a-cnc-mill/) using this technique and a diamond burr.

The new flange keeps the vacuum well. (Seal not pictured.)

{% fancybox /images/cnc-milling-glass/on-chamber.jpeg %}

The bathroom mirror shelves are a very good source of small, cheap glass panels. I can purchase them for about $0.40 each.
