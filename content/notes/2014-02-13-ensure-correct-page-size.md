---
kind: article
title: "Ensure correct page size"
created_at: 2014-02-13 12:41:46 +0400
tags:
  - circuit boards
  - failure
---

I have found out in the most painful way possible that a lot of Linux desktop components
(and I mean practically all of them) tend to inexplicably default to the US Legal paper size,
especially on `en_US` locale, insidiously resizing the picture while I'm trying to print it.
US Legal is close enough to A4 that you wouldn't notice the error immediately.

<!-- more -->

For example, pictured on the left is the 32mm wide [calibration mask][], printed from an A4 SVG via
Chromium with paper size set to A4 in the printing dialog. On the right is the same mask, printed
via Inkscape:

[calibration mask]: /notes/2014-02-13/negative-photoresist-calibration-mask/

<%= lightbox '/images/photoresist/calibration-mask-scaled.jpeg' %>

This also gives rise to all kinds of fascinating artifacts, such as 0.15mm line being thinner
than 0.1mm one:

<%= lightbox '/images/photoresist/calibration-mask-scaled-artifacts.jpeg' %>

Watch out!
