---
layout: post
title: "SMD reflow with a blowtorch"
date: 2016-04-28 02:53:36 +0000
comments: true
categories:
  - insanity
---

I've designed a circuit with, among other things, an integrated buck converter  ([Wurth 171050601][buck]), which has an exposed pad. While the rest of SMT devices on the PCB can be easily soldered with an iron, this IC posed a problem, since the exposed pad is completely inaccessible.

I didn't have an SMD rework station, or a hot air gun, or a hot plate, or a stove and a skillet (just moved ~8000km, come on). But I did have a blowtorch, so I decided to figure out if that can be used for reflow.

[buck]: https://archive.is/Bxj3d

<!--more-->

I'll begin with a word about the torch. It's [Bernzomatic TS8000][ts8000] running on MAP/Pro (propylene), a true monster of handheld combustion that can get a 1/4" pipe to red-hot in a few seconds:

  {% fancybox /images/blowtorch-reflow/torch.jpeg %}
  {% fancybox /images/blowtorch-reflow/flame.jpeg %}

Naturally, I expected that damaging the board would be pretty easy. However, that proved to be not the case.

First, I tried a test board: spare PCB with a piece of leaded solder lying on an exposed copper plane. When holding the tip of the flame ~25cm away from the PCB, it did not reach melting temperature in reasonable time (a few minutes) at all. When holding the tip of the flame ~15cm away from the PCB, it took over a minute to get the solder to melt and wet the plane.

It could be seen that the entire board is heated quite evenly, both by measuring its temperature with a handheld IR thermometer, and visually by looking at the solder mask; the red solder mask on this board ([DirtyPCBs batch circa 2016-04-25][dirtypcbs]) is significantly thermochromic, going from "arterial blood" to "venous blood" when heated from room temperature to 200°C.

Then, I did the same with the actual component I needed, in isolation, in case I overheat it:

  {% fancybox /images/blowtorch-reflow/process.jpeg %}

The result is practically perfect, and certainly there is not even minor delamination:

  {% fancybox /images/blowtorch-reflow/result.jpeg %}

Something to note is that torch exhaust contains a substantial amount of water vapor, which readily condenses on cold areas of the PCB.

[ts8000]: https://archive.is/RSIA9
[dirtypcbs]: http://dirtypcbs.com

Conclusions
-----------

  * Way short of an expectation that a blowtorch would destroy an SMT PCB, reflowing it using one is a perfectly practical method that gives usable results without failures through trial-and-error.
  * The TS8000 torch moves a massive amount of air and generates ~3kW of heat through combustion. Moreover, it does not have an aperture. These properties mean that it is much better than a typical cheap SMD rework station at rapidly and evenly heating an entire PCB, which is especially convenient if you have the attention span of a hamster on meth.
  * Burning organic fuel produces a lot of water vapor, which may interfere with operation of the PCB assembly. Similarly, an especially flammable flux could ignite. Thus, this process is suboptimal for PCBs, even if the properties of heat transfer are more favorable than the typical 'dry' solution.
  * Nevertheless, I should try reflowing complete assemblies, even with plastic components, using this method and record the results.
