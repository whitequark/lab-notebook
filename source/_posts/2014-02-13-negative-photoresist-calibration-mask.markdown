---
layout: post
title: "Negative photoresist calibration mask"
date: 2014-02-13 11:03:58 +0400
comments: true
categories:
  - pcb
---

It is convenient to quickly determine exposure time and highest resolution for a new combination
of photoresist and UV light source. I've drawn a calibration mask just for that purpose.

<!-- more -->

<figure class="code">
  <figcaption>
    <span>(negative-calibration-mask.svg)</span>
    <a href="/files/negative-calibration-mask.svg">download</a>
  </figcaption>
  <img src="/images/photoresist/negative-calibration-mask-demo.svg" width="400">
</figure>

The mask size is 32mm×25mm, and the SVG is made with the expectation that it will be printed
on A4 paper. It is also mirrored, because the mask should be placed with toner side adjacent
to PCB.

The smallest feature present on the mask, 0.5mm, is derived from the most common resolution of
consumer-grade laser printers, 600dpi, which maps to dot size of 0.41mm. I would not expect such
a tiny feature to be properly printed, though.

To use the mask, one should cover more and more of its surface with an opaque object from the right
side (starting at "30" mark), with 30-second intervals. I turn off the UV light source when
re-covering the mask to ensure that intervals stay as close to perfect time as possible.

Here's how my printer, Brother DCP-7010R, reproduces the mask when printing at 600 dpi.
The second picture is taken after applying [Density Toner][]:

[density toner]: http://www.kruseonline.com/eng/prodotti/density-toner

{% fancybox /images/photoresist/calibration-mask-printed.jpeg "Before Density Toner" %}
{% fancybox /images/photoresist/calibration-mask-dense.jpeg "After Density Toner" %}

As it is seen, even the smallest 0.05mm feature is reproduced very well. A defect can be seen
on the right. I suspect the cause of defect is dirty drum on my (used) printer. I have cleaned
the drum in the past to get rid of similar defects, but, apparently, not thoroughly enough.

Additionally, the toner distribution becomes much more uniform after applying Density Toner.
I have applied a tiny amount of the aerosol---two small splashes once just to cover the entire
mask area. If the aerosol drips from the film, its quantity is excessive.
