---
layout: post
title: "CNC3020T: fixing power supply"
date: 2014-02-11 07:49:00 +0400
categories:
 - hardware
 - repair
 - cnc3020t
---

[CNC3020T][] is a Chinese CNC mill/router with working area of 300x200x50mm. I've bought
one, intending to use it for PCB prototyping.

[cnc3020t]: http://www.ebay.com/itm170794739687

CNC machine itself is nicely built and has a strong frame. Its control box / power supply, however,
is not. After about a hour of work it emitted a loud crackling noise and shorted the mains. Oops!

<!--more-->

(By the way: the "free worldwide delivery" on eBay means that $300+ EMS charge for hauling a 26kg
beast around is included in the price of the machine. This also means that the actual cost is
around $250.)

Cracking it open:

{% fancybox gal-inside /images/3020t/inside-1.jpeg %}
{% fancybox gal-inside /images/3020t/inside-2.jpeg %}
{% fancybox gal-inside /images/3020t/inside-3.jpeg %}

Evidently, the manufacturer was too cheap to include a switch-mode power supply! Instead, they used
this enormous custom-wound transformer:

{% fancybox gal-trans /images/3020t/trans-1.jpeg %}
{% fancybox gal-trans /images/3020t/trans-2.jpeg %}

This bit me quite hard also because I blindly assumed the machine would use an SMPS and didn't
double-check that they ship me the 220V version. As you can see, it's also 110V-only, and
the autotransformer I had to buy is now useless as well.

Fortunately, some kind soul from [cnczone][pw3024] has traced the spindle control board:

[pw3024]: http://www.cnczone.com/forums/chinese_machines/201446-burnt_resistor_yoc-pw3024.html

{% fancybox gal-spindle /images/3020t/spindle-board-layout.jpeg 700 %}
{% fancybox gal-spindle /images/3020t/spindle-board-top.jpeg %}
{% fancybox gal-spindle /images/3020t/spindle-board-bottom.jpeg %}

Diagnostics revealed that the transformer did not have a short between primary and secondary coils,
but the 18V secondary coil nevertheless produced much higher voltage than it was supposed to.
<del>[This kills the circuit][crab]</del> This resulted in destruction of the L7812, NE555, F2 and,
somehow, the 10kOhm potentiometer connected to Rp1.

[crab]: http://static1.fjcdn.com/comments/4559246+_1694f851eb77646acc2a8ce5ef9d6283.jpg

Anyway, this isn't hard to fix. What's harder is to replace the transformer. One could notice
that the machine is built to consume two supply voltages: 48VDC and 24VDC, rectified from
36VAC and 18VAC correspondingly. It's also possible to deduce peak current from motor rating:

+---------------------------------------------------------|---------+---------+-------|
| Consumers                                               | Voltage | Current | Power |
+---------------------------------------------------------|---------+---------+-------|
| 3x NEMA steppers (2A), NE555, level shifters, fan, etc. | 24VDC   | 2A      | 48W   |
+---------------------------------------------------------|---------+---------+-------|
| Spindle motor (200W)                                    | 48VDC   | 4.2A    | 200W  |
+---------------------------------------------------------|---------+---------+-------|

Now, you may wonder why I've specified 2A for 24V supply despite the fact that there are three
steppers and each is rated at 2A. It is simple; I've measured the current all three steppers
consume while being driven at maximal possible speed and it's just short of 2A.

Anyway, I ordered a [24V][24v-supply] and a [48V][48v-supply] switch-mode supplies on eBay. While
it arrives, I'm using a temporary hack: I use my adjustable power supply to drive both inputs
at 3A@29V:

[24v-supply]: http://www.ebay.com/itm/200914674637
[48v-supply]: http://www.ebay.com/itm/121214164830

{% fancybox gal-hack /images/3020t/adj-supply-1.jpeg %}
{% fancybox gal-hack /images/3020t/adj-supply-2.jpeg %}

You may wonder again: this doesn't match either of the voltages this machine needs. Wouldn't that
damage it? The answer is no:

  * The stepper board has a bunch of logic powered via [AP1501][] buck converter rated
    up to 40V.
  * The stepper board also has [TB6560AHQ][], rated up to 40V as well.
  * The spindle board logic is connected via [L7812][], rated up to 35V.
  * The fan is connected directly to 24V input, but it doesn't seem to mind.

[ap1501]:    http://www.diodes.com/datasheets/AP1501.pdf
[tb6560ahq]: http://www.glyn.de/data/glyn/media/doc/TB6560AHQ_AFG-20080407.pdf
[l7812]:     http://datasheet.octopart.com/L7812CV-STMicroelectronics-datasheet-7271552.pdf

The result is remarkably nice. At 29V, the machine consumes less than 3A (which is the limit
for my power supply) with all three steppers spinning at once and the spindle at maximal speed.
So it is a pretty convenient workaround.
