---
layout: post
title: "On water break test"
date: 2014-02-24 10:07:49 +0400
comments: true
categories:
  - pcb
---

**Update:** [superseded](/notes/2014-06-11/producing-pcbs-using-photolitography/#preparation).

I have used the water break test (checking whether copper surface is clean of contaminants
based on the fact that really clean copper is hydrophilic) [in the past][photoresist], however
I misunderstood how the test results must look.

[photoresist]: /notes/2014-02-16/optimizing-for-best-photoresist-adhesion/#interlude-water-break-test

<!-- more -->

The PCB on left was immersed in NaOH 5%wt for 10 minutes, as in the note above.
The PCB on right was left in same solution for about 11 hours.

{% fancybox /images/pcb-cleaning/2014-02-24/water-break-test.jpeg 700 %}

Only the right PCB truly passes the test. The amorphous blob on the picture is a really
thin film of water uniformly (unlike a drop) spread over that area.

I have thought that if water film spreads and remains on PCB for a few seconds, it means
the surface is clean. Evidently, this is not the case. In fact, it is very easy to remove
water from PCB on left by tilting it, whereas for the PCB on right it is only possible to
wipe it or wait until it dries on its own.

There are no immediately visible differences between resist attachment to two boards, but
it seems that with properly cleaned board, resist sticks to it better in extreme circumstances:
when it's placed over drilled holes or after it was contained in aggressive etching solution
for >40 min:

{% fancybox /images/pcb-cleaning/2014-02-24/good-attachment.jpeg 700 %}

