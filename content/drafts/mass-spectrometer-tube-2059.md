---
kind: draft
title: "Mass spectrometer tube \"2059\""
tags:
  - vacuum
---

I've bought a quadrupole mass spectrometer tube on eBay. It does not have a vendor, a
part number, documentation or any identifying markings except "2059" stamped on the CF flange, so
I am calling it "2059".

The key is a small protrusion on the air side; it does not match anything on the vacuum side.
The pinout is as follows, looking axially at the air side:

| Pin # | Function |
|-------|----------|
| 1     | Quadrupole mass filter rods 1/3 |
| 2     | Accelerating plate 1 and filament grid |
| 3     | Filament A |
| (Key) | (Key) |
| 4     | Filament B |
| 5     | Accelerating plate 2 |
| 6     | Accelerating plate 3 |
| 7     | Quadrupole mass filter rods 2/4 |
| 8     | N/C |

Based on generic knowledge of quadrupole mass spectrometers, here are the potentials it should
be driven with:

| Pin function | Potential |
|--------------|-----------|
| Accelerating plate 1 and filament grid | 0V |
| Accelerating plate 2 | -150V |
| Accelerating plate 3 | -300V |
| Filament A and B | +70V |

The filament design voltage is unknown.
