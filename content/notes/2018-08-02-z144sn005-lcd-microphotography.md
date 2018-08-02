---
kind: article
created_at: 2018-08-02 05:50:10 +0000
title: "Z144SN005 LCD microphotography"
tags:
  - microscopy
  - pretty pictures
---

I've been provided a Z144SN005 LCD that has split in halves as a result of excess mechanical force. Z144SN005 is a ST7735S-based LCD organized as 128RGB×128; it has 384 sources and 128 gates. I took some microphotographs of it using an Amscope ME300TZ-2L-3M metallurgical microscope.

The following microphotographs of the front glass plate that contains color filters demonstrate the pixels lighting up:

<%= lightbox '/images/z144sn005-display/filters-trans-4x.png', gallery: 'front', title: '4x magnification, transmitted light' %>
<%= lightbox '/images/z144sn005-display/filters-refl-4x.png', gallery: 'front', title: '4x magnification, reflected light' %>
<%= lightbox '/images/z144sn005-display/filters-trans-refl-4x.png', gallery: 'front', title: '4x magnification, reflected and transmitted light' %>
<%= lightbox '/images/z144sn005-display/filters-refl-10x.png', gallery: 'front', title: '10x magnification, reflected light' %>
<%= lightbox '/images/z144sn005-display/filters-trans-refl-10x.png', gallery: 'front', title: '10x magnification, reflected and transmitted light' %>

The following microphotographs (all taken in combined transmitted and reflected light for extra contrast) of the back glass plate show the circuitry driving the liquid crystals confined between the two glass plates.

First, row (gate) drivers. There's 128 in total. Note the numbered LCD rows.

<%= lightbox '/images/z144sn005-display/drivers-row-4x.png', gallery: 'back-rows', title: '4x magnification, row drivers' %>
<%= lightbox '/images/z144sn005-display/drivers-row-10x.png', gallery: 'back-rows', title: '10x magnification, row drivers' %>

Second, column (source) drivers. There's 384 in total, so the routing is far more dense. Note that the column drivers are located at the side of the display *far* from the controller, likely because of lack of space. Note the thick power distribution traces.

<%= lightbox '/images/z144sn005-display/drivers-col-1-4x.png', gallery: 'back-columns', title: '4x magnification, column structures in bottom right corner' %>
<%= lightbox '/images/z144sn005-display/drivers-col-1-10x.png', gallery: 'back-columns', title: '10x magnification, column structures in bottom right corner' %>
<%= lightbox '/images/z144sn005-display/drivers-col-2-10x.png', gallery: 'back-columns', title: '10x magnification, column structures in bottom center-right' %>
<%= lightbox '/images/z144sn005-display/drivers-col-3-10x.png', gallery: 'back-columns', title: '10x magnification, column structures in bottom center' %>
<%= lightbox '/images/z144sn005-display/drivers-col-4-10x.png', gallery: 'back-columns', title: '10x magnification, column structures in bottom left corner' %>
<%= lightbox '/images/z144sn005-display/drivers-col-5-10x.png', gallery: 'back-columns', title: '10x magnification, column structures in top left corner' %>
<%= lightbox '/images/z144sn005-display/drivers-col-6-4x.png', gallery: 'back-columns', title: '4x magnification, column structures in top right corner' %>

At last, here's a magnified shot of one of the cracks in the glass that killed the LCD:

<%= lightbox '/images/z144sn005-display/crack-10x.png', title: '10x magnification, glass crack' %>

The cleanest pictures were taken by wetting a cotton bud with IPA, then swabbing the glass with the cotton bud such as to leave a thin film but also remove all junk somewhere out of the visual field, and photographing while the field has not evaporated. IPA appears to be nearly index-matched with the glass used in this LCD, and so it hides most if not all imperfections in the glass, apart from any cleaning that may happen as a result of this procedure.
