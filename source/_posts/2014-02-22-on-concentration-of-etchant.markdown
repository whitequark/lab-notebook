---
layout: post
title: "On concentration of etchant"
date: 2014-02-22 07:55:59 +0400
comments: true
categories:
  - pcb
---

How much etchant is too much? It appears that there can indeed be too much etchant,
resulting in, essentially, passivation of the copper layer---not with copper oxide, but
with the etching product (CuSO₄ in this case).

Using 15% (NH₄)₂S₂O₈ instead of 30% results in much more robust etching process.

<!-- more -->

* table of contents
{:toc}

Materials
---------

30% etchant
: (NH₄)₂S₂O₈ 30% wt

15% etchant
: (NH₄)₂S₂O₈ 15% wt

Too much etchant
----------------

The manufacturer-recommended ammonia persulphate concentration is 250 g of salt in 500 g of
water, or 30% by weight. This is a very concentrated solution; a drying droplet of it grows
a relatively hard crystallic shell, which can preserve the sludge in the droplet core for a long
time.

This is the solution I've used initially. It produced very strange results: most of copper on
a test board was etched within 10 min, but the rest was not being etched _at all_. I've even tried
to scratch it (which normally would induce a rigorous reaction), however it just continued to sit
in the very concentrated solution for minutes, with that scratch intact:

{% fancybox /images/etching/2014-02-22/failboard-overview.jpeg 400 %}
{% fancybox /images/etching/2014-02-22/failboard-highlights.jpeg 400 %}

While poking that board, I've noticed that it has hard white-ish crystals, soluble in water,
deposited on the surface. I've theorised that these crystals prevented access of etchant to
copper very efficiently. To verify, I took a small piece of PCB without any resist and put
it into the solution, then took it out when the crystals formed, removed most liquid and dried:

{% fancybox /images/etching/2014-02-22/fail-crystals.jpeg 500 %}

The crystals appear to be light blue CuSO₄·H₂O (I've heated them above 110°C while drying).
Apart from easily visible blue crystals, the board is also partially covered with glossy film
of the same substance, in a pattern reminiscent of the failed test board above.

Diluting
--------

I took 204 g of 30% etchant and added 207 g of distilled water, bringing it down to 15% by weight.

I've etched the board for 22 min at 27°C, and the result is nice and uniform, with all areas
being finished at roughly same time. After I took board out of solutions and dried, no big crystals
grew on it, though it was covered by a thin film of those. The film likely originated from the thin
layer of etchant solution remaining on board.

{% fancybox /images/etching/2014-02-22/no-crystals.jpeg 500 %}

The scratch was me testing how fast copper is being etched.

The same test board etched with the new solution, for about 30 min:

{% fancybox /images/etching/2014-02-22/etched.jpeg 700 %}
