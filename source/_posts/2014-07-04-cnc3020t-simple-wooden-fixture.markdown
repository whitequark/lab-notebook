---
layout: post
title: "CNC3020T: simple wooden fixture"
date: 2014-07-04 05:01:16 +0400
comments: true
categories:
  - cnc
  - cnc3020t
  - fixture
---

The CNC3020T CNC mill doesn't come with anything particularly useful for fixing the workpiece to the table. In this note I describe a simple wooden fixture that is suitable for securely attaching rectangular pieces of material to the table.

<!-- more -->

* table of contents
{:toc}

Tools
-----

drill press
: PRACTYL 500W with 16mm collet

d={5,6}mm drill bit for wood
: generic

jig saw
: DEXTER IC400JS

wood jig saw blade for clean cuts
: [Bosch T301CD](http://www.boschtools.com/Products/Accessories/Pages/BoschAccessoryDetail.aspx?pid=T301CD)

Materials
---------

20x40x2000 pine wood bar
: generic

M6 nut ×2
: generic

M6x90 bolt ×2
: generic

M6 washer ×4
: generic

M5 wing nut ×4
: generic

M5x40 bolt ×4
: generic

Overview
--------

The fixture consists of two wooden parts held together with M6 bolts and clamping the workpiece, each of which is pressed to the table with M5 bolts.

<figure class="code">
  <figcaption>
    <span>(drawing.svg)</span>
    <a href="/images/simple-fixture/drawing.svg">download</a>
  </figcaption>
  <img src="/images/simple-fixture/drawing.svg" width="500">
</figure>

Fabrication
-----------

Mark the holes and sawing lines. Drill the holes before sawing--this helps to keep the mating surfaces perfectly parallel. Saw the fixture parts; if using a jig saw, a blade specifically designed for clean cuts helps a lot.

{% fancybox /images/simple-fixture/fixture-marked-h.jpeg %}
{% fancybox /images/simple-fixture/fixture-marked-v.jpeg %}
{% fancybox /images/simple-fixture/fixture-drilled-h.jpeg %}
{% fancybox /images/simple-fixture/fixture-drilled-v.jpeg %}
{% fancybox /images/simple-fixture/fixture-sawed.jpeg %}

Note that the mating surfaces are supposed to be the *outer* ones, as they are much flatter than the ones produced by hand-sawing.

{% fancybox /images/simple-fixture/fixture-attached.jpeg %}

Conclusions
-----------

 * Pine wood yields and especially fractures easily. It is imperative to use washers. Not the best material to use for this.
 * With wood, it makes sense to use a drill 0.5-1mm wider than the M-rating of the fastener.
 * The CNC3020T table is designed for M6 bolts; sliding the proper bolts into the table would make screwing the nut much easier. However, I wasn't able to find the bolts of proper length and M6 wing nuts.
