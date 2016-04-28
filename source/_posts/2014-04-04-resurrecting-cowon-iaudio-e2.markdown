---
layout: post
title: "Resurrecting Cowon iAUDIO E2"
date: 2014-04-04 20:15:45 +0400
comments: true
categories:
  - electronics
  - repair
---

Pictured to the right is a Cowon [iAUDIO E2][e2] music player. I have one, but I've lost the
proprietary PC/charging cable long ago. It's a really neat little device, so I decided to figure
out the pinout.

<!-- more -->

The cable is really weird: it's a passive USB A to 3.5mm 4-pin barrel jack cable. Pretty sure that
violates every possible part of the USB specification. The one good thing is that it required
the manufacturer to insert all kinds of protection circuits--just think of what happens when you
plug it in!

Anyway, I made a handy diagram:

{% img bg-white /images/cowon-e2/schematics.svg 500 %}

*This note was originally published on my main blog, [whitequark.org](http://whitequark.org),
but [lab.whitequark.org](http://lab.whitequark.org) is a more appropriate place for it.*

[e2]: http://www.cowonglobal.com/product_wide/iAUDIOE2/product_page_1.php
