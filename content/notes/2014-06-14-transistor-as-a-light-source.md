---
kind: article
title: "Transistor as a light source"
created_at: 2014-06-14 21:49:14 +0400
tags:
  - semiconductors
  - pretty pictures
---

In this note I demonstrate that a bipolar transistor can be made to emit light.

<!-- more -->

Demonstration
-------------

For observing this effect, it's best to use a big, easy to decap transistor with massive body that would function as a heatsink. КТ805БМ in TO-3 package (known in the West as [BDW21A](http://products.semelab-tt.com/pdf/bipolar/shortform/SF_BDW21A.pdf)) is perfectly fit for the task.

First, we need to decap it. This is somewhat problematic, as TO-3 features a solid 1mm of aluminium. I broke a diamond disc and two endmills while trying to decap it by hand and using my CNC mill, and eventually pried the half-detached cap out using diagonal cutters. It was not an enjoyable process, but it worked.

Then, it is necessary to apply reverse voltage across the base-emitter junction. The junction starts (reversibly) break down at about 10.9V. The die will start to emit a significant amount of light (as well as heat like crazy) at 2A and higher.

<%= lightbox '/images/transistor-light/capped.jpeg', title: 'Capped' %>
<%= lightbox '/images/transistor-light/decapped.jpeg', title: 'Decapped' %>

<%= lightbox '/images/transistor-light/power-off.jpeg', title: 'Power off' %>
<%= lightbox '/images/transistor-light/power-on.jpeg', title: 'Power on' %>
<%= lightbox '/images/transistor-light/va-measure.jpeg', title: 'A lot of power' %>

Explanation
-----------

The breakdown of the p-n transition happens due to the [avalanche effect](http://en.wikipedia.org/wiki/Avalanche_breakdown). The [recombination](http://en.wikipedia.org/wiki/Carrier_generation_and_recombination) of the holes and electrons necessarily converts excess energy into some other form; in this case, photons are emitted.

The transistor is not damaged, unless allowed to overheat.
