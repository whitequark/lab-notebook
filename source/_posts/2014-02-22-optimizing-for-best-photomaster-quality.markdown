---
layout: post
title: "Optimizing for best photomaster quality"
date: 2014-02-22 05:48:15 +0400
comments: true
categories:
  - pcb
  - photoresist
---

Objective:
: find the combination of paper, environment and printer configuration resulting in most faithful
  reproduction of the original image with least amount of defects and highest toner density.

Result:
: use high-quality transparent film ([Lomond 0707415][0707415] works), verify printer output
  very rigorously and check which of the "Paper type" settings results in best imprint. No settings
  appear to affect toner density.

[0707415]: http://online.lomond.sk/en/detail/0707415

<!-- more -->

Tools
-----

Printer
: [Brother DCP-7010R](http://www.brother.ru/g3.cfm/s_page/92250/s_level/39720/s_product/DCP7010R), Brother cartridge/toner

Laminator
: [ROYAL PL-2100](http://www.royalsupplies.com/Laminators/PL-2100-Laminator.html), 120°C roller temperature

Materials
---------

"MGChemicals" film
: [MGChemicals 416-T 100µm PET film](http://www.amazon.com/gp/product/B005T8WR6I)

"Lomond" film
: [Lomond 0707415 125µm PET film][0707415]

Finding correct paper type setting
----------------------------------

The printer driver handily provides a paper type setting, which includes "Transparencies"
as an option. I've tried really hard to figure out what exactly does the setting change,
to no avail. I've read the entire service manual for the printer, but it sadly does not
mention anything about that.

My guesses, as there aren't as much parameters the printer can control:

 * Toner density (i.e. changing Vbias). This does not appear to be the case.
 * Fusor temperature. This has been confirmed (see below).

However, after setting "correct" paper type for printing on PET film, i.e. "Transparencies",
I've noticed some odd distortion. I have decided to repeat the job on plain paper, setting
the paper type to both "Plain" and "Transparencies". The results are horrifying:

{% fancybox gal-paper-type /images/photomaster/2014-02-22/paper-type.jpeg 700 %}

Have you noticed anything? It's not immediately obvious to naked eye.

{% fancybox gal-paper-type /images/photomaster/2014-02-22/paper-transp-highlight.jpeg %}
{% fancybox gal-paper-type /images/photomaster/2014-02-22/paper-transp-highlight-2.jpeg %}

That's right. When I select "Transparencies", the printer (or perhaps its driver)
distorts the image oddly. It appears as if it duplicated some pixel rows and removed
some others. The picture printed with "Plain" setting is reproduced faithfully.

By the way, on actual transparencies the distortion is identical. You may even notice it now
in the [previous note][]:

{% fancybox gal-resist /images/photoresist/2014-02-13/try-8-developed.jpeg 300 %}

Do you see how the 0.3 mm line is wider than 0.35 mm line? That's not how millimeters work.
I initially assumed it was an exposing-related defect (UV reflecting off copper), but no, that
distortion is present in exact same way on the negative I've used.

[previous note]: /notes/2014-02-16/optimizing-for-best-photoresist-adhesion/

Using quality laser printer film
--------------------------------

Make sure the transparent film you're using does not deform while in the laser printer
fusor. For example, this is the imprint on "MGChemicals" film left after a few tries:

{% fancybox gal-mgchem /images/photomaster/2014-02-22/mgchemicals-fail.jpeg 500 %}

  * Picture marked "first" was done on a freshly unpacked sheet.
  * Picture marked "second" was done immediately after on the same sheet. As it can be seen,
    the sheet was deformed after first run, and not all toner was well-attached.
  * Picture marked "sandwich" was done by running the film through the printer together with
    a sheet of plain paper. Likely, the fusor temperature is not enough to reliably
    melt the toner in this case. If I set the paper type to "Thicker paper", the imprint
    is much better, but is still far from perfect.

It is nearly impossible to take a picture of, but if you view the sheet under a sharp angle
to a light source, it can be seen that it's all "wavy", and, additionally, it has four
deep depressions from some internal guiding mechanics of the printer.

Running such a distorted sheet through a laminator with roller temperature of 120°C (which is
less than typical fusor temperature of a laser printer) partially fixes the distortion: the
sheet still shows the "wavy" pattern, but the depressions from rollers are no longer present.

Printing on such fixed sheet results in somewhat higher quality imprint (fourth on the picture
above), but it's not as good as first one.

Another way to verify quality of your film is to print the exact same pattern on film and
on paper:

{% fancybox gal-mgchem /images/photomaster/2014-02-22/mgchemicals-fail-grid.jpeg 500 %}

The film and paper are lying with their toner side adjacent to each other. A highly nonlinear
distortion can be clearly visible. Of course, it's not possible to print a high-quality
photomaster on such film.

Not satisfied with this, I bought "Lomond" film. It is still deformed slightly by the printer
rollers, but that doesn't at all affect the imprint quality. Also, as evident by the grid
test, it has near zero in-plane deformation even after five runs through printer:

{% fancybox gal-lomond /images/photomaster/2014-02-22/lomond-win.jpeg 400 %}
{% fancybox gal-lomond /images/photomaster/2014-02-22/lomond-win-grid.jpeg 400 %}

Toner density
-------------

I have not found toner density to be affected by paper type or DPI settings. Toner conservation
was (obviously) set to "Off" at all times.
