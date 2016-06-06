---
layout: post
title: "Installing a split type air conditioner"
date: 2016-06-05 16:56:02 +0000
comments: true
categories:
  - air conditioning
---

I've recently bought a Hitachi RAS/RAC-DX10HDK split type air conditioner and decided to install it myself; just for education and expanding my skillset. This took somewhere around 12-16 hours, not including shopping for parts, so economically it doesn't make a lot of sense even if you have all the tools on hand. In this note I describe how I did it.

<!--more-->

* table of contents
{: toc}

Tools
-----

40mm adjustable wrench
: Kraftool

20mm adjustable wrench
: IKEA

scissors
: generic

philips screwdriver
: IKEA

measuring tape
: IKEA

keyhole saw
: generic

mufflers
: 3M Peltor X 27dB

Hammer drill with SDS Plus and three jaw chucks
: IKEA

d=5mm SDS Plus concrete drill bit
: IKEA

d=10mm SDS Plus concrete drill bit
: Thakita

d=3mm wood drill bit
: IKEA

wire stripper
: [RS 262-0151](https://archive.is/Os1yX)

terminal crimper
: generic

ACR rotary vane vacuum pump
: [generic](https://archive.is/VGHMn)

spring-type copper tube bender set, 6mm-16mm
: [generic](https://archive.is/77G3g)

eccentric copper tube flaring tool
: CT-806

imperial units copper tube flaring bar
: CM-196

copper tube cutter
: CT-274

freon leak detector
: WJL-6000

ACR two gauge manifold
: CPS, unknown model

freon charging hose ×3
: generic, 500psi working pressure

5/16" female SAE flare to 1/4" male SAE flare adapter
: generic

4mm (across flats) hex key
: generic

luggage tension scale
: Samsonite

Materials
---------

2.5kW cooling, 3.2kW heating capacity split type air conditioner
: [Hitachi RAS/RAC-DX10HDK](https://archive.is/wMXLv)

1-2HP air conditioner outdoor unit scaffold
: [generic](https://archive.is/uSeyH)

condensate drainage pump
: [Aspen Mini Orange](https://archive.is/8q9Qu)

6.35mm crimp spade terminal ×10
: generic

4×1.0mm²×5m NBR insulated cable
: generic

ID=1/4" PVC tube
: generic

OD=1/4" brass hose barb union
: generic

1/4"×5m ACR copper tube
: [generic](https://archive.is/jqIUa)

3/8"×5m ACR copper tube
: [generic](https://archive.is/jqIUa)

13mm×9mm×2m black PVC foam insulation ×2
: [generic](https://archive.is/H1oiP)

60mm×13m white PVC tape
: [generic](https://archive.is/vlcTM)

20mm PVC adhesive tape
: generic

5.6kg R-410a canister
: generic

100mm×54mm×2m white PVC cable channel
: generic

5mm×31mm plastic dowel ×9
: IKEA

d=3.5mm×30mm self-tapping pan head screw
: IKEA

nylon cable tie ×10
: generic

Introduction
------------

The air conditioner comes with impressively elaborate documentation. There's the installation leaflet that assumes pretty much no prior knowledge of HVAC tech, which was quite surprising to me:

{% fancybox /images/hitachi-ac/leaflet-1.jpeg %}
{% fancybox /images/hitachi-ac/leaflet-2.jpeg %}

There's the 1:1 drawings of indoor and outdoor unit, to be put against a wall:

{% fancybox /images/hitachi-ac/indoor-dim.jpeg %}
{% fancybox /images/hitachi-ac/outdoor-dim.jpeg %}

There's the self-test function and elaborate diagnostics instructions underneath the cover of the outdoor unit:

{% fancybox /images/hitachi-ac/diagnostics.jpeg %}

A peek inside
-------------

Of course, the first thing I did is disassemble the indoor and outdoor units. Who wouldn't? These are quite interesting in construction.

Indoor unit. Look at the cute little pipes--these are less than 1/4", seems like 3/8" and 5/16".

{% fancybox /images/hitachi-ac/indoor-unit-1.jpeg %}
{% fancybox /images/hitachi-ac/indoor-unit-2.jpeg %}
{% fancybox /images/hitachi-ac/indoor-unit-3.jpeg %}
{% fancybox /images/hitachi-ac/indoor-unit-4.jpeg %}
{% fancybox /images/hitachi-ac/indoor-unit-5.jpeg %}

Its blower. It's pretty much a turbine stretched all along the length of the unit.

{% fancybox /images/hitachi-ac/indoor-unit-blower.jpeg %}

Outdoor unit. It's strikingly *empty*. Very unbalanced with the >20kg compressor firmly on one side, too, which makes it a pain to carry around. You can see the valves deep inside, expansion valve and reversing valve.

{% fancybox /images/hitachi-ac/outdoor-unit-empty.jpeg %}
{% fancybox /images/hitachi-ac/outdoor-unit-valves.jpeg %}

Installation
------------

Despite all the fancy things--tubes, vacuum pumps, compressed gases...--the installation of an air conditioner is primarily a) very laborous b) very straightforward. Mostly, it is quite some bending, a lot of drilling and *even more* cutting of cable channels.

Fucking cable channels, man. I swear they are non-euclidean. It is basically impossible to saw one straight, much less at a precise angle. And due to the shape of the wall, I also needed to make it slated both vertically and horizontally. This seemed easy at first, before I realized that cutting a channel at an angle α meant increasing the cross-section width (or height) by sinα, and to avoid ugliness one has to cut both sides at an angle α/2. As if cutting them straight wasn't hard enough. And on top of that? Chirality. The first time I marked everything out, I got exactly half of the pieces mirrored. The second time I mirrored, mostly, the other half. And then some of them didn't have the right dimensions anyway and had to be redone. Not having to deal with cable channels alone is worth paying the tech.

To get the freon lines in shape, I measured the segments of the path they ought to take, then unwrapped two coils in synchronization and bent them along the way; and once I got a part of the shape right, I would tie them together with nylon cable ties. Careful positioning of the coiled tube allows to hold the half-done lines against the wall and check the fit.

After bending the lines, I put half of the insulation onto the line without cutting it across the length, and the other by cutting it. The former is *much* more convenient afterwards, since insulating foam tends to come apart at the seam and produce condensation, but it takes some time to get it across the bends.

The condensate pump is connected between A and B terminals. These supply 220VAC to the outdoor unit; voltage appears on them when the system starts transporting heat, and disappears a few minutes after it stops, which leaves ample time to remove any condensate still flowing after the cooling stops. The SSR in the pump that cuts the power if the condensate line is blocked is not connected anywhere; it is not rated high enough to be put into the outdoor unit power circuit. It could have been made to cut the connection to the C terminal (that carries data to and from the outdoor unit) but I didn't bother.

Anyway, this is what I got. Note the condensate pump hidden in the channel--this is why the PVC channel had to be 100mm wide.

{% fancybox /images/hitachi-ac/installed-outdoor.jpeg %}
{% fancybox /images/hitachi-ac/installed-indoor-1.jpeg %}
{% fancybox /images/hitachi-ac/installed-indoor-2.jpeg %}

Charging
--------

Charging is pretty straightforward: open the service valve, vacuum the freon lines, fill it with 0.78kg of R-410a. However, there are some unexpected things.

1. Vacuuming the freon lines takes a *lot* of time, or at least a lot longer than one would expect based on the volume of the system alone. This is, in retrospect, quite obvious: the lubricating PAG oil in the compressor is freely miscible with R-410a and it was pressurized to ~10 atm at the factory to keep moisture out, so quite a bit of R-410a dissolved into it and then it slowly got back into vapor phase.
2. The 1/4" flare connections can be tightened pretty easily. The 3/8" ones require a *lot* of force, more or less all the force I can exert (not a lot). I thought I tightened them well but they started loudly hissing when I first opened the service valve.
3. The freon cylinder I had did not have an internal tube that would allow to withdraw liquid (R-410a has to be withdrawn as liquid since it is an azeotropic mixture, and withdrawing it in gas phase would mean the lighter component predominantly filling the system, making it much less efficient). So it has to be inverted. However, the only scales with enough range I had were luggage tension scales... with a hook, that can be only used on the cylinder in the upright position. So that was pretty annoying. In the end I overfilled it a bit (to just under 1 kg) but that doesn't matter a lot in a system with TXV.

Problem: blower causes noise
----------------------------

When I finished charging it and confirmed that it worked, I noticed a maddening noise coming from indoor unit, as if something flopped in sync with the blower. Since this was after I assembled the entire thing, it could not be taken off and had to be disassembled in place, which was almost as maddening. The culprit? A small piece of packing cardboard stuck on the blower in the least accessible place, affixed by what looked like moisture and glue:

{% fancybox /images/hitachi-ac/blower-cardboard.jpeg %}

Problem: condensate drainage pump is loud
-----------------------------------------

Initially the condensate drainage pump was placed close to the condensate collector vessel. This caused two problems. First, it was pinned by the freon line to the cable channel, which caused both of them to vibrate. Second, it was connected by a short length of (fairly rigid) hose to the collector vessel, which again caused it to vibrate. That was quite annoying.

I mitigated that somewhat by moving the drainage pump further upstream, pushing the freon line upwards with a cable tie attached to the cable channel, and wrapping it in some foam. This didn't work very well, but it made the noise bearable.
