---
kind: article
title: "Producing PCBs using photolithography"
created_at: 2014-06-11 08:16:00 +0400
tags:
  - numerical control
  - circuit boards
  - photolithography
---

In this note I describe a simple and quick photolithographic process with excellent repeatability that I use for producing high-quality PCB prototypes.

<!-- more -->

* table of contents
{:toc}

Tools
-----

CNC machine
: [CNC3020T](http://www.freezepage.com/1395478161OWYSYNBZGX)

laminator
: [ROYAL PL-2100](https://web.archive.org/web/20150407055114/http://www.royalsupplies.com/Laminators/PL-2100-Laminator.html), 120°C roller temperature

printer
: [Brother DCP-7010R](http://www.brother.ru/g3.cfm/s_page/92250/s_level/39720/s_product/DCP7010R), Brother cartridge/toner

magnetic stirrer
: MM-5M

UV light source
: [395nm 3W LED flashlight](http://amazon.com/gp/product/B001RJQR3M)

latex gloves
: [diamond-grip powder-free latex gloves](https://archive.today/Qbyx2)

exposure press
: d=3.175mm clear acrylic sheet

soft brush
: generic soft acrylic brush

Magnetic stirrers may be expensive; I recommend building an open hardware one by [Tekla Labs](http://guides.teklalabs.org/Guide/Magnetic+Stirrer/6).

Materials
---------

toner density enhancer
: [Density Toner by Kruse](http://www.kruseonline.com/eng/prodotti/density-toner)

copper-clad laminate PCB
: any

negative dry film photoresist
: [generic](https://archive.today/6g18h)

negative dry film solder mask
: [Dynamask 5000](https://archive.today/68oyH)

PCB cleaning fluid
: isopropanol 99.7% waterless

preparation etchant
: (NH₄)₂S₂O₈ 15%wt

developer solution
: K₂CO₃ 2%wt

trace etchant
: FeCl₃ 50%wt

resist removal solution
: NaOH 5%wt

tinning solution
: "liquid tin" (locally sourced); [composition & preparation](http://books.google.co.uk/books?id=m8sJBIMtETgC&pg=PA318&lpg=PA318)

Milling and drilling
--------------------

I use [pcb-gcode](http://www.pcbgcode.org/) ([settings](/files/pcb-photolithography/pcb-gcode-settings.tbz2)) for EAGLE to produce G-code for drilling and milling. I draw a contour on the "Milling" layer to cut out the PCB.

Note that if your tools have different lengths, you should set the Z offset in the LinuxCNC tool table; the configuration includes the `G43` code after tool changing sequence.

<%= lightbox '/images/pcb-photolithography/board-layout.png', gallery: 'eagle' %>
<%= lightbox '/images/pcb-photolithography/drill-mill-gcode.png', gallery: 'eagle' %>
<%= lightbox '/images/pcb-photolithography/board-milled.jpeg', gallery: 'photo', title: 'Milled' %>

Photonegatives
--------------

I use Eagle's CAM processor ([configuration](/files/pcb-photolithography/eagle.cam)) to output photonegatives (copper and solder mask) as PostScript, process them with the [ps2svg](/files/pcb-photolithography/ps2svg) script, and then use [Inkscape](http://inkscape.org) to combine them on a single A4 page. It is very important to **not** import PostScript directly to Inkscape; it is unable to import PostScript without spurious, hard-to-notice scaling.

After printing, I apply the "Density Toner" aerosol to the photonegatives to make the distribution of toner more uniform.

<%= lightbox '/images/pcb-photolithography/photonegative.png', gallery: 'eagle' %>

<%= lightbox '/images/pcb-photolithography/photonegative-fresh.jpeg', gallery: 'photo', title: 'Fresh photonegative' %>
<%= lightbox '/images/pcb-photolithography/photonegative-dense.jpeg', gallery: 'photo', title: 'Dense photonegative' %>

Preparation
-----------

Every step of handling PCB must be performed in gloves to avoid leaving grease. Grease on PCB surface generally results in a complete failure.

Earlier, I used a dilute NaOH solution for cleaning the copper surface and achieving better photoresist adhesion ([note 1](/notes/2014-02-16/optimizing-for-best-photoresist-adhesion/), [note 2](/notes/2014-02-24/on-water-break-test/)). However, it was a mistake. It turns out that a much better method exists:

 1. Clean the PCB surface from grease with isopropanol.
 2. Put the PCB into the persulphate etchant for 5-10 seconds. Note that other etchants may not have the same effect.
 3. Rinse PCB under warm tap water.
 4. Remove matte (polyolefin) protective film from photoresist.
 5. Attach photoresist to PCB and put pressure on its front edge (any single edge) with fingers.
 6. Run PCB through laminator and let it cool down.

This method results in excellent attachment (and a truly beautiful color). No matter how hard I scrub the PCB while developing, even the smallest traces of photoresist do not detach.

As far as I'm aware, the reason is that (specifically) persulphate etchant leaves the surface microporous, similar to the aluminium anodizing process.

<%= lightbox '/images/pcb-photolithography/board-in-persulphate.jpeg', gallery: 'photo', title: 'In persulphate etchant' %>
<%= lightbox '/images/pcb-photolithography/board-microporous.jpeg', gallery: 'photo', title: 'After persulphate bath' %>
<%= lightbox '/images/pcb-photolithography/board-with-photoresist.jpeg', gallery: 'photo', title: 'With attached photoresist' %>

Exposure and development
------------------------

The exposure time may be affected by a lot of factors. It is best to determine optimal exposure time using a [calibration pattern](/notes/2014-02-13/negative-photoresist-calibration-mask/).

 1. Expose photoresist for calibrated time.
 2. Remove glossy (PET) protective film from photoresist.
 3. Immerse PCB in developer solution for 1-2 minutes. Immediately after immersing, scrub with a soft acrylic brush until all unexposed areas are free from photoresist.
 4. Rinse PCB under warm tap water.

<%= lightbox '/images/pcb-photolithography/board-with-negative.jpeg', gallery: 'photo', title: 'With overlaid photonegative' %>
<%= lightbox '/images/pcb-photolithography/board-exposed.jpeg', gallery: 'photo', title: 'Exposed' %>
<%= lightbox '/images/pcb-photolithography/board-developed.jpeg', gallery: 'photo', title: 'Developed' %>

Etching
-------

I have found that persulphate-based etchant is very slow and tends to undercut traces. As such, I only use it for preparation, and etch the traces using ferric chloride.

It is very important for the etching liquid to be stirred. This significantly reduces etching time and, as a side effect, reduces trace undercutting.

<%= lightbox '/images/pcb-photolithography/board-etching.jpeg', gallery: 'photo', title: 'Etching' %>
<%= lightbox '/images/pcb-photolithography/board-etching-2.jpeg', gallery: 'photo', title: 'On magnetic stirrer' %>

<%= lightbox '/images/pcb-photolithography/board-etched.jpeg', gallery: 'photo', title: 'Etched' %>
<%= lightbox '/images/pcb-photolithography/board-stripped.jpeg', gallery: 'photo', title: 'Resist stripped' %>

Adding solder mask
------------------

Solder mask is very convenient to have on the PCB surface and isn't complex to add once you already have a working photolithography process. The process for adding solder mask, as well as exposure time, are also very similar to the ones for photoresist:

1. Remove matte (polyolefin) protective film from solder mask.
2. Attach solder mask to PCB and put pressure on its front edge (any single edge) with fingers.
3. Run PCB through laminator (if the solder mask is old and adheres poorly, do it 4-5 times) and let it cool down.
4. Expose solder mask for calibrated time.
5. Remove glossy (PET) protective film from solder mask.
6. Immerse PCB in developer solution for 1-2 minutes. Immediately after immersing, scrub with a soft acrylic brush until all unexposed areas are free from solder mask.
7. Cure solder mask; that is, expose it for ~10-30x longer than the first time.

<%= lightbox '/images/pcb-photolithography/board-with-mask.jpeg', gallery: 'photo', title: 'With solder mask' %>
<%= lightbox '/images/pcb-photolithography/board-mask-developed.jpeg', gallery: 'photo', title: 'Developed' %>

Tinning
-------

Chemical tinning is an excellent last step in the fabrication process that would make soldering much easier (even more so for SMD components). To perform it, simply put the board into the tinning solution for the time specified in the manual. In my case, it's 15-30 min for 1µm thick tin layer.

<%= lightbox '/images/pcb-photolithography/board-tinned.jpeg', gallery: 'photo', title: 'Tinned' %>
