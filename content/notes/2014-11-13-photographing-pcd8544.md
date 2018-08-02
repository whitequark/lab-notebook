---
kind: article
title: "Photographing PCD8544"
created_at: 2014-11-13 20:48:51 +0300
tags:
  - microscopy
  - semiconductors
  - pretty pictures
---

I had a broken Nokia 3310 LCD on my hands, so I decided to take a photomicrograph of the display controller, [PCD8544](https://www.sparkfun.com/datasheets/LCD/Monochrome/Nokia5110.pdf). As far as I'm aware this is the first publicly accessible die shot.

<!-- more -->

The 3310 LCD uses the chip on glass technique for integrating the display controller. In short, the chip is bonded to the glass using an [ACF epoxy][acf] infused with tiny conductive spheres. As long as the layer of epoxy is no thicker than the sphere diameter, and the distance between adjacent pads is, conversely, larger, it will serve as a good bonding mechanism. This is in fact similar to [anisotropic conductive adhesive tape][3m].

[acf]: http://flipchips.com/tutorial/assembly/anisotropic-conductive-film-for-flipchip-applications-introduction/
[3m]: http://solutions.3m.com/wps/portal/3M/en_US/Electronics_NA/Electronics/Products/Product_Catalog/~/3M-Electrically-Conductive-Adhesive-Transfer-Tape-9703?N=4294406280+5153906&&Nr=AND%28hrcy_id%3A5CP6S9HG9Rgs_H1RGD426ZK_N2RL3FHWVK_GPD0K8BC31gv%29&rt=d

The glass substrate is in fact transparent by itself, but the glass and especially the epoxy obscure the chip surface far too much for it to be interesting:

<%= lightbox '/images/pcd8544/on-glass.jpeg' %>

Separating the chip from glass is a challenge in itself. I've tried the following using the supplies and tools I had at the moment:

  * Heating the assembly to 150°C on a hot plate and shearing the chip along the bonding plane, as recommended in [ACF-X reworking manual](http://multimedia.3m.com/mws/media/501881O/3mtm-anisotropic-conductive-film-adhesive-5363-rework-process.pdf?&fn=5363_ACF_6002969.pdf).
  * Heating the assembly to 480°C using a hot air gun and doing the same.
  * Soaking the assembly for ~12 hours in 30% H₂SO₄.
  * Soaking the assembly for ~12 hours in 5% NaOH.

The epoxy was not noticeably affected.

At last, I decided to simply burn it. I heated it up in blue MAPP flame (somewhere under 1995°C) and after a few minutes of heating, all visible epoxy residue on the glass burned away, leaving the glass clear, and the chip could be easily separated. After separating the chip, I kept it in flame for a bit longer to remove any remains of the epoxy.

After separating, I scrubbed the surface of the chip, first **gently** using the edge of the tweezers, then using a Q-tip soaked in isopropanol. This left the surface quite clean.

The following picture were taken using the [Sony α3000](http://store.sony.com/a3000-interchangeable-lens-digital-camera-zid27-ILCE3000K/B/cat-27-catid-All-Alpha-a3000) camera and [Sony E 30mm F3.5](http://store.sony.com/e-30mm-f3.5-macro-e-mount-macro-lens-zid27-SEL30M35/cat-27-catid-All-E-Mount-Lenses) macro lens. The chip was illuminated using a noname white LED lamp from IKEA; exposure was set to ISO100 and shutter to 1/20. The camera was mounted on a tripod and shutter was set to a 10-second delay in order to eliminate any vibration. The pictures were taken in RAW mode and further processed in [darktable](http://www.darktable.org/).

<%= lightbox '/images/pcd8544/bare-photo.png' %>

Different incident angle of light, pre-Q-tip, slightly less sharp:

<%= lightbox '/images/pcd8544/bare-photo-2.png' %>

Note the chip name in the upper left corner; seems to be "SA2081"?

In the future I plan to take an even closer look using a proper microscope in tandem with the camera.
