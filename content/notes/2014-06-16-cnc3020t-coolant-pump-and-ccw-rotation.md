---
kind: article
title: "CNC3020T: coolant pump and CCW rotation"
created_at: 2014-06-16 00:27:35 +0400
tags:
  - electronics
  - g-code
  - numerical control
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

d=0.6..1.5mm diamond-cut flat carbide endmill set
: [generic](https://archive.today/cIJDL)

electric drill
: generic

d=3mm drill bit
: generic

L=200mm diamond file set
: generic

clamper/cutter
: generic

See also ["Producing PCBs using photolithography"](/notes/2014-06-11/producing-pcbs-using-photolithography/#tools).

Materials (water sink)
----------------------

d=3mm thick clear cast acrylic sheet ×~1000cm²
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

834-1A-B-C, 24V 10A 1-closure relay
: [Song Chuan](http://songchuan.eu/attachments/ds/834.pdf)

TR99-24VDC-SB-CD, 24V 5A 2-switch relay
: [Tai-shing Electronics Components](http://getec.cl/oldweb/pdf/reles/tr99.pdf)

l=5mm 2-pin screw terminal ×4
: [301-021-12](http://lib.chipdip.ru/064/DOC000064100.pdf), Xinya

1N4944 diode
: [generic](http://www.semtech.com/images/datasheet/1n49xx.pdf)

1N4148 diode ×2
: [generic](http://www.nxp.com/documents/data_sheet/1N4148_1N4448.pdf)

PC827
: [generic](http://lib.chipdip.ru/224/DOC000224974.pdf)

390Ω 1/4W resistor ×2
: generic

4-pin pinhead
: generic

4-pin pinhead socket ×2
: generic

3.7mm U-type terminal (0.25-1.65mm wire) ×2
: generic

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

See ["Producing PCBs using photolithography"](/notes/2014-06-11/producing-pcbs-using-photolithography/#materials).

G-code for container
--------------------

As usual, the G-code I publish is parametric; it can be easily customized for different material thickness, dimensions, etc, without the need for a proprietary CAM processor. Modify the "parameters" sections in the G-code and validate the result using [OpenSCAM][]. The G-code will only work with [LinuxCNC][].

[linuxcnc]: http://linuxcnc.org/

In this case, the G-code defines a tabbed plastic container to be glued, milled out of a material sheet `#<_thickness>` mm thick, using horizontal step `#<_eps>`.

[openscam]: http://openscam.com/

<%= highlight_code 'gcode', '/files/3020t-coolant-pump/mill-container.ngc' %>

Visualization:

<%= lightbox '/images/3020t-coolant-pump/container-gcode-viz.png' %>

Assembling container
--------------------

After milling, the concave corners have to be filed down in order for the sides to fit together. After that, the container can be glued together with epoxy. In my experience it is very hard to make it fully waterproof using just epoxy, so afterwards I have sealed it with silicone.

<%= lightbox '/images/3020t-coolant-pump/container-unfolded.jpeg', gallery: 'assembly' %>
<%= lightbox '/images/3020t-coolant-pump/container-glued-1.jpeg', gallery: 'assembly' %>
<%= lightbox '/images/3020t-coolant-pump/container-glued-2.jpeg', gallery: 'assembly' %>
<%= lightbox '/images/3020t-coolant-pump/container-glued-3.jpeg', gallery: 'assembly' %>

Attaching container
-------------------

The CNC mill has a very conveniently located hole that allows to insert a chain of three nylon cable ties inside to fix the container under the table. I had to cut down the cable ties' latches, as they were somewhat too wide to pass through the hole.

The silicon hose can be easily attached to the pipe

<%= lightbox '/images/3020t-coolant-pump/cnc-mill-hole.jpeg', gallery: 'att-cont' %>
<%= lightbox '/images/3020t-coolant-pump/cable-tie-cut.jpeg', gallery: 'att-cont' %>
<%= lightbox '/images/3020t-coolant-pump/container-attached-1.jpeg', gallery: 'att-cont' %>
<%= lightbox '/images/3020t-coolant-pump/container-attached-2.jpeg', gallery: 'att-cont' %>

Adding water pump
-----------------

In order to make a nozzle, I have cut the outside part of the CT-006 flux container, heated it up with a hot air gun at ~200°C, and straightened it until it was bent at about 120°. Then, I have heated the hose in the similar way and attached it to the straightened nozzle.

In order to fix the hose to the CNC mill frame, I used the cable ties. However, the spindle has some convenient grooves, into which you can squeeze the hose; this has the advantage that it is fixed very securely and does not move when the mill traverses, yet it can be easily adjusted for pointing the flow in the desired direction.

Note that the pump leaks like crazy. I have never seen such a shitty piece of engineering. However, disassembling it (it's made of three snap-on injection molded parts) and liberally applying silicone mostly stops leakage. The connection between the pump and the water tank may also need sealing.

<%= lightbox '/images/3020t-coolant-pump/piping-1.jpeg', gallery: 'att-pump' %>
<%= lightbox '/images/3020t-coolant-pump/piping-2.jpeg', gallery: 'att-pump' %>
<%= lightbox '/images/3020t-coolant-pump/piping-3.jpeg', gallery: 'att-pump' %>
<%= lightbox '/images/3020t-coolant-pump/piping-4.jpeg', gallery: 'att-pump' %>

Table and water flow
--------------------

The table has an interesting property that any liquid that you pour on it will pour out from the front (or back) slot openings, depending on the direction in which you tilt the machine, but practically no liquid will go elsewhere. This is the ground for the entire modification.

However, and this is **important**, the screws which attach the table of the mill to the rest of the frame rust very easily. You need to replace it with the same M4x10 hex cap screw, but made out of stainless steel. (While the contact of aluminium and stainless steel can produce galvanic corrosion in some circumstances, in this case it shouldn't happen over any interesting timeframe.)

<%= lightbox '/images/3020t-coolant-pump/rust-1.jpeg', gallery: 'rust' %>
<%= lightbox '/images/3020t-coolant-pump/rust-2.jpeg', gallery: 'rust' %>

<video controls poster="/videos/3020t-coolant-pump.png" width="500">
  <source src="/videos/3020t-coolant-pump.webm" type="video/webm">
</video>

Designing control board
-----------------------

I have designed the modification around adding two PCBs to the control block; one with the factory-made buck converter for the pump, and another to integrate it with the LPT interface board. I decided that it is easiest to use relays for switching powerful inductive loads.

The integration board ([EAGLE source](/files/3020t-coolant-pump/intf-board.tbz2)) is a very simple board with two relays that is designed to be used with the LPT interface board.

Note that the board misses a connection between two parts of a ground polygon. You would probably want to fix that, so I don't include production artifacts.

The board is manufactured as described in ["Producing PCBs using photolithography"](/notes/2014-06-11/producing-pcbs-using-photolithography/).

The board is connected as follows:

|-----------|----------------------------------------------------|
| Connector | Designation                                        |
|-----------|----------------------------------------------------|
| X1        | buck converter IN                                  |
|-----------|----------------------------------------------------|
| X2, X3    | splice into the spindle supply                     |
|-----------|----------------------------------------------------|
| X4        | 24V tap                                            |
|-----------|----------------------------------------------------|
| JP1       | the `CP-`..`DIR+` connector on LPT interface board |
|-----------|----------------------------------------------------|
{: style="max-width: 550px"}

<%= lightbox '/images/3020t-coolant-pump/intf-board-schematics.png', gallery: 'intf' %>
<%= lightbox '/images/3020t-coolant-pump/intf-board-layout.png', gallery: 'intf' %>

<%= lightbox '/images/3020t-coolant-pump/intf-board-bottom.jpeg', gallery: 'intf' %>
<%= lightbox '/images/3020t-coolant-pump/intf-board-top.jpeg', gallery: 'intf' %>

Installing control board
------------------------

The control board and the buck converter board are attached to the case using the screws and PCB stands. The case is drilled using a template, as described in the [SMPS conversion note](/notes/2014-05-29/cnc3020t-switch-mode-power-supply-conversion/#assembly). The cord connected to the coolant pump is simply passed through a spare hole in the case, knotted inside to prevent an external force from pulling it out of the screw terminal on the PCB.

The EMC2 configuration described in [earlier note](/notes/2014-02-12/cnc3020t-emc2-configuration-and-hidden-features/) already supports the newly added features.

<%= lightbox '/images/3020t-coolant-pump/boards-template.jpeg', gallery: 'intf-install', title: 'Template' %>
<%= lightbox '/images/3020t-coolant-pump/boards-drilled.jpeg', gallery: 'intf-install', title: 'Drilled' %>
<%= lightbox '/images/3020t-coolant-pump/intf-connections.jpeg', gallery: 'intf-install', title: 'Connections overview (early board revision)' %>
<%= lightbox '/images/3020t-coolant-pump/intf-board-installed.jpeg', gallery: 'intf-install', title: 'Installed board' %>
