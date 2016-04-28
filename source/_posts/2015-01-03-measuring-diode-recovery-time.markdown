---
layout: post
title: "Measuring diode recovery time"
date: 2015-01-03 07:03:23 +0300
comments: true
categories:
  - electronics
  - measurement
---

After assembling a full-wave rectifier out of some [1A7][] 1kV-rated diodes, I noticed that it
does not, in fact, rectify. I speculated that the diodes I used have a recovery time too high.
Since it was not specified in the datasheet, I decided to measure it myself, which I
describe in this note.

[1A7]: http://lib.chipdip.ru/758/DOC000758188.pdf

<!--more-->

Background
----------

Before a diode can conduct current forward, a space charge needs to be established
across the p-n junction. After the external voltage is reversed, the diode will
conduct in reverse for a certain time before the charge carriers recombine.

The following is a typical measurement circuit used in industry:
![industry-standard test circuit](/images/diode-recovery/industry-test.png)

Simulation
----------

The following is the test circuit I use and simulation of its behavior:
![simulation (circuit)](/images/diode-recovery/sim-circuit.png)
![simulation (waveforms)](/images/diode-recovery/sim-graph.png)

Measurement
-----------

The circuit implements a pulse generator using a MOSFET half-bridge with
the fall time of ~15ns and uses regular 0.125W thin film resistors.
It is simple and reuses components I already had.
The blue channel probes _pulse_ and the yellow one probes _common_.

The DUT has a recovery time of about 7.5µs, which of course makes it useless in a rectifier
working at ~350kHz. (The cursors do not highlight the entire recovery interval.)
![1a7 measurement](/images/diode-recovery/1a7.png){:style="max-width:100%"}

For comparison, these are the waveforms corresponding to 1N4148 (4ns recovery time) tested
using the same circuit:
![1n4148 measurement](/images/diode-recovery/1n4148.png){:style="max-width:100%"}

My 150MHz oscilloscope probe is too crude to capture the pulse, not to mention
there is too much parasitic inductance in the circuit anyway.
