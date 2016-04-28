---
layout: post
title: "Parametric G-Code for cutting PCBs"
date: 2014-02-12 22:36:23 +0400
comments: true
categories:
  - cnc
  - pcb
---

It's convenient to be able to cut rectangular PCBs with your CNC mill, but
calculating the required coordinates and compensating for tool size by hand
is no fun. Fortunately, G-code is sophisticated enough to describe this
task parametrically.

<!--more-->

{% include_code files/cut-rectangle.ngc lang:text %}

Of course, before you launch this script, you need to set up the coordinate system.
Jogging the tool to `(0, 0, 0)` and executing `G10 L20 P0 X0 Y0 Z0` would do the job.

You can even simulate the toolpath in [OpenSCAM][], as it can perform calculations
in g-code:

[openscam]: http://openscam.com/

{% fancybox /images/cnc-pcb/cut-rectangle.png 400 %}
