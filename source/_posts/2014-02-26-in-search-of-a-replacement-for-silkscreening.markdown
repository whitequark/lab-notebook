---
layout: post
title: "In search of a replacement for silkscreening"
date: 2014-02-26 20:07:52 +0400
comments: true
categories:
  - pcb
published: false
---

Names and placement markers on PCB aren't essential, but sure they are convenient. I'm
trying to figure out a nice way to mimic the silkscreen-based process used in industry
to print on PCBs.

<!-- more -->

* table of contents
{:toc}

Tools
-----

Laminator
: [ROYAL PL-2100](http://www.royalsupplies.com/Laminators/PL-2100-Laminator.html), 120°C roller temperature

Printer
: [Brother DCP-7010R](http://www.brother.ru/g3.cfm/s_page/92250/s_level/39720/s_product/DCP7010R), Brother cartridge/toner

UV Light
: [395nm 3W LED flashlight](http://amazon.com/gp/product/B001RJQR3M)

Exposure press
: 3.175mm clear acrylic sheet

Materials
---------

Acrylic paint
: TiO₂-based acrylic paint

Solder mask (substrate)
: [Dynamask 5000 dry film solder mask](http://www.ebay.com/itm/161140135802)

Photoresist
: [negative dry film photoresist](http://amazon.com/gp/product/B00B0Z8AZ6)

Photoresist removal solution
: NaOH 5%wt

Stencil film
: [Lomond 0707415 125µm PET film](http://online.lomond.sk/en/detail/0707415)

Try #1
------

I tried to use a stencil made out of PET film to press acrylic paint through with a spatula.
However, paint tends to get squished under the board, leading to very disappointing results:

{% fancybox gal-pet /images/silkscreen/2014-02-26/pet-film-failed.jpeg "Failed" %}

I used a solder paste stencil instead of silkscreen stencil, because I can't yet generate
g-code for the latter, but this should not affect results in such a significant way.

Try #2
------

I had an idea: what if I mimic the silkscreening process, except remove the mesh (screen)?
In other words, laminate a layer of dry film resist over solder mask, then expose the solder
mask everywhere except where I want paint to appear, then push paint into grooves with a spatula.

It almost worked, except for two things:

 * NaOH would strip solder mask as well, though quite a bit slower.
 * Paint adheres much better to resist than to underlying solder mask. That makes sense in
   retrospect, because the mask is explicitly designed to repel substances such as solder
   or flux.

{% fancybox gal-resist /images/silkscreen/2014-02-26/resist-initial.jpeg "Initial" %}
{% fancybox gal-resist /images/silkscreen/2014-02-26/resist-attached.jpeg "Attached" %}
{% fancybox gal-resist /images/silkscreen/2014-02-26/resist-exposed.jpeg "Exposed" %}
{% fancybox gal-resist /images/silkscreen/2014-02-26/resist-developed.jpeg "Developed" %}
{% fancybox gal-resist /images/silkscreen/2014-02-26/resist-painted.jpeg "Painted" %}
{% fancybox gal-resist /images/silkscreen/2014-02-26/resist-failed.jpeg "Failed" %}

Try #3
------

I tried to use a stencil made out of PET film with engraved grooves. I would push the ink
into grooves, then push stencil with ink against PCB (mimicking offset printing).

Unfortunately, it turns out, the ink dries very quickly in the process and doesn't transfer
to PCB at all.

{% fancybox gal-groove /images/silkscreen/2014-02-26/groove-initial.jpeg "Initial" %}
{% fancybox gal-groove /images/silkscreen/2014-02-26/groove-filled.jpeg "Filled with ink" %}
