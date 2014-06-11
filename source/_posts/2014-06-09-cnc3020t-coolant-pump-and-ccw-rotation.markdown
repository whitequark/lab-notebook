---
layout: post
title: "CNC3020T: coolant pump and CCW rotation"
date: 2014-06-09 21:34:07 +0400
comments: true
categories:
  - hardware
  - cnc
  - cnc3020t
published: false
---

In this note I explain the way to extend the 3020T CNC mill with a coolant pump (especially useful for milling plastic) and also, as a side effect, a spindle direction switch.

I have used a lot of locally-sourced components which will probably be unobtainable in other parts of the world. However, it should be trivial to find equivalent ones and adapt the instructions.

<!-- more -->

* table of contents
{:toc}

Tools
-----

CNC machine
: [CNC3020T](http://www.freezepage.com/1395478161OWYSYNBZGX)

d=1mm l=10mm D=3.175mm diamond-cut flat carbide endmill
: [generic](https://archive.today/1958C)

electric drill
: generic

Ø 3mm drill bit
: generic

L=200mm diamond file set
: generic

See also ["Producing PCBs using photolitography"](/notes/2014-06-11/producing-pcbs-using-photolitography/#tools).

Materials (water sink)
----------------------

3mm thick clear cast acrylic sheet ×~1000cm²
: generic

d=6mm HDPE plastic tube ×2cm
: generic

Two-component epoxy
: [BISON](http://www.bison.net/en/products/647-2-components-adhesives/product/2266-epoxy-5-minutes/)

Transparent polymethylsiloxane-based sealant
: QUILOSA Orbasil

25x4.5mm nylon cable tie ×5
: generic

flux container
: [CT-006](http://www.chipdip.ru/product/ct-006/)

d=4mm D=6mm silicone hose ×2m
: generic

Materials (pump and piping)
---------------------------

windshield washer pump
: [for LADA-2110](http://www.gasgoo.com/auto-products/wiper-washer-318/1111988.html)

d=4mm D=6mm windshield washer hose ×3m
: for LADA-2110

windshield washer tank
: for GAZ-24

6.3mm spade push on terminal (0.25-1.65mm wire) ×2
: [SG57744](http://www.mantech.co.za/ProductInfo.aspx?Item=72M1648)

M4x0.7x10 stainless steel hex cap screw
: [generic](https://archive.today/pB61A)

Materials (control board)
-------------------------

adjustable 0~37V / 0~40V 3A buck converter
: [MasterKit BM037M](http://www.masterkit.ru/main/set.php?code_id=850630)

flyback diode
: [1N4944](www.semtech.com/images/datasheet/1n49xx.pdf)

24V 10A 1-closure relay
: [834-1A-B-C](www.songchuan.eu/en/attachments/030_834.pdf), Song Chuan

24V 5A 2-switch relay
: [TR99-24VDC-SB-CD](http://us.100y.com.tw/pdf_file/TR99.pdf), Tai-shing Electronics Components

2-pin screw terminal, l=5mm
: [301-021-12](http://lib.chipdip.ru/064/DOC000064100.pdf), Xinya

0.5mm² multistranded hookup wire ×2m
: generic

Materials (mechanical)
----------------------

M3x5 screw ×8
: generic

M3x10 copper PCB stand ×8
: generic

M3 nut ×8
: generic

Materials (PCB manufacturing)
-----------------------------

See ["Producing PCBs using photolitography"](/notes/2014-06-11/producing-pcbs-using-photolitography/#materials).

G-code for container
--------------------

As usual, the G-code I publish is parametric; it can be easily customized for different material thickness, dimensions, etc, without the need for a proprietary CAM processor. Modify the "parameters" sections in the G-code and validate the result using [OpenSCAM][]. The G-code will only work with [LinuxCNC][].

[linuxcnc]: http://linuxcnc.org/

In this case, the G-code defines a tabbed plastic container to be glued, milled out of a material sheet `#<_thickness>` mm thick, using horizontal step `#<_eps>`.

[openscam]: http://openscam.com/

{% include_code files/3020t-coolant-pump/mill-container.ngc lang:text %}

Visualization:

{% fancybox /images/3020t-coolant-pump/container-gcode-viz.png 500 %}

Assembling container
--------------------

After milling, the concave corners have to be filed down in order for the sides to fit together. After that, the container can be glued together with epoxy. In my experience it is very hard to make it fully waterproof using just epoxy, so afterwards I have sealed it with silicone.

{% fancybox gal-assembly /images/3020t-coolant-pump/container-unfolded.jpeg %}
{% fancybox gal-assembly /images/3020t-coolant-pump/container-glued-1.jpeg %}
{% fancybox gal-assembly /images/3020t-coolant-pump/container-glued-2.jpeg %}
{% fancybox gal-assembly /images/3020t-coolant-pump/container-glued-3.jpeg %}

Attaching container
-------------------

The CNC mill has a very conveniently located hole that allows to insert a chain of three nylon cable ties inside to fix the container under the table. I had to cut down the cable ties' latches, as they were somewhat too wide to pass through the hole.

The silicon hose can be easily attached to the pipe

{% fancybox gal-att-cont /images/3020t-coolant-pump/cnc-mill-hole.jpeg %}
{% fancybox gal-att-cont /images/3020t-coolant-pump/cable-tie-cut.jpeg %}
{% fancybox gal-att-cont /images/3020t-coolant-pump/container-attached-1.jpeg %}
{% fancybox gal-att-cont /images/3020t-coolant-pump/container-attached-2.jpeg %}

Adding water pump
-----------------

In order to make a nozzle, I have cut the outside part of the CT-006 flux container, heated it up with a hot air gun at ~200°C, and straightened it until it was bent at about 120°. Then, I have heated the hose in the similar way and attached it to the straightened nozzle.

In order to fix the hose to the CNC mill frame, I used the cable ties. However, the spindle has some convenient grooves, into which you can squeeze the hose; this has the advantage that it is fixed very securely and does not move when the mill traverses, yet it can be easily adjusted for pointing the flow in the desired direction.

Note that the pump leaks like crazy. I have never seen such a shitty piece of engineering. However, disassembling it (it's made of three snap-on injection molded parts) and liberally applying silicone mostly stops leakage. The connection between the pump and the water tank may also need sealing.

{% fancybox gal-att-pump /images/3020t-coolant-pump/piping-1.jpeg %}
{% fancybox gal-att-pump /images/3020t-coolant-pump/piping-2.jpeg %}
{% fancybox gal-att-pump /images/3020t-coolant-pump/piping-3.jpeg %}
{% fancybox gal-att-pump /images/3020t-coolant-pump/piping-4.jpeg %}

Table and water flow
--------------------

The table has an interesting property that any liquid that you pour on it will pour out from the front (or back) slot openings, depending on the direction in which you tilt the machine, but practically no liquid will go elsewhere. This is the ground for the entire modification.

However, and this is **important**, the screws which attach the table of the mill to the rest of the frame rust very easily. You need to replace it with the same M4x10 hex cap screw, but made out of stainless steel. (While the contact of aluminium and stainless steel can produce galvanic corrosion in some circumstances, in this case it shouldn't happen over any interesting timeframe.)

{% fancybox gal-rust /images/3020t-coolant-pump/rust-1.jpeg %}
{% fancybox gal-rust /images/3020t-coolant-pump/rust-2.jpeg %}

{% video /videos/3020t-coolant-pump.webm 500 /videos/3020t-coolant-pump.png %}

Designing control board
-----------------------

I have designed the modification around adding two PCBs to the control block; one with the factory-made buck converter for the pump, and another to integrate it with the LPT interface board. I decided that it is easiest to use relays for switching powerful inductive loads.

The integration board ([EAGLE source](/files/3020t-coolant-pump/intf-board.tbz2); [G-code and photonegatives](/files/3020t-coolant-pump/intf-board-fab.tbz2)) is a very simple board with two relays and two bipolar transistors. The transistors are required, as the optocouplers on the LPT interface board can output no more than 30mA@5V, and driving relays requires higher current.

{% fancybox gal-intf /images/3020t-coolant-pump/intf-board-schematics.png %}
{% fancybox gal-intf /images/3020t-coolant-pump/intf-board-layout.png %}
