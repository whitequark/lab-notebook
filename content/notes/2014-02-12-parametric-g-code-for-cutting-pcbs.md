---
kind: article
title: "Parametric G-Code for cutting PCBs"
created_at: 2014-02-12 22:36:23 +0400
tags:
  - numerical control
  - g-code
  - circuit boards
---

It's convenient to be able to cut rectangular PCBs with your CNC mill, but
calculating the required coordinates and compensating for tool size by hand
is no fun. Fortunately, G-code is sophisticated enough to describe this
task parametrically.

<!--more-->

<%= highlight_code 'gcode', '/files/cut-rectangle.ngc' %>

Of course, before you launch this script, you need to set up the coordinate system.
Jogging the tool to `(0, 0, 0)` and executing `G10 L20 P0 X0 Y0 Z0` would do the job.

You can even simulate the toolpath in [OpenSCAM][], as it can perform calculations
in g-code:

[openscam]: http://openscam.com/

<%= lightbox '/images/cnc-pcb/cut-rectangle.png' %>
