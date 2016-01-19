---
layout: post
title: "G38: Probing workpieces in LinuxCNC"
date: 2014-07-06 10:04:16 +0400
comments: true
categories:
  - cnc
  - cnc3020t
  - linuxcnc
---

Touching off to the workpiece by hand is tedious and error-prone. Fortunately, LinuxCNC has the very convenient [G38][] code family, which allows to automate this process. In this note I demonstrate how G38 can be used, using squaring aluminium stock as an example.

[G38]: http://linuxcnc.org/docs/html/gcode/gcode.html#sec:G38-probe

<!-- more -->

* table of contents
{:toc}

Hardware
--------

In our case, the probe itself is very simple--it's just a pair of alligator clips. One of the clips is clamped over the tool, the other is somehow connected to the workpiece. Depending on the CNC controller, the way of connecting the probe can vary, but in case of my CNC3020T machine, it's just a 2.1x5.5 DC barrel jack. The controller outputs bias voltage and reports a short circuit to LinuxCNC.

{% fancybox /images/linuxcnc-probe/probe.jpeg %}

While using the tool you'll be machining the workpiece with can be simpler--less tool changing, no need to use [G43][] tool length compensation--an incorrect probe setup or flaky contact can result in a broken tool. It may make sense to use the butt of a (broken) tool as a probe.

[G43]: http://linuxcnc.org/docs/html/gcode/gcode.html#sec:G43

{% fancybox /images/linuxcnc-probe/probe-attached.jpeg %}

LinuxCNC setup
--------------

In addition to configuring the probe input in the machine settings, I found it helpful to have a HalUI widget indicating the probe status. This way, it's easy to verify if there's a good contact between the probe and the workpiece.

Merge the following with your LinuxCNC config (at `~/linuxcnc/machinename/`):

{% codeblock machinename.ini %}
[DISPLAY]
PYVCP = custompanel.xml

[HAL]
POSTGUI_HALFILE = custom_postgui.hal
{% endcodeblock %}

{% codeblock custom_postgui.hal lang:text %}
net probe-in => pyvcp.probe-in
{% endcodeblock %}

{% codeblock custompanel.xml %}
<pyvcp>
  <vbox>
    <hbox>
      <led>
        <halpin>"probe-in"</halpin>
        <size>15</size>
        <on_color>"red"</on_color>
        <off_color>"green"</off_color>
      </led>
      <label>
        <text>"Probe"</text>
      </label>
    </hbox>
    <label>
      <text>"closed (red)"</text>
    </label>
    <label>
      <text>"open (green)"</text>
    </label>
  </vbox>
</pyvcp>
{% endcodeblock %}

{% fancybox /images/linuxcnc-probe/axis-pyvcp.png %}

Example: probing a cube
-----------------------

The following G-code program probes the dimensions of a cube and sets the coordinate system centered at the face. See the comments in the file for operating instructions.

{% include_code files/linuxcnc-probe/probe-cube.ngc lang:text %}

Example: squaring a cube
------------------------

The following G-code program mills flat the face of a cube. It uses the results of `probe-cube.ngc` to determine the dimensions.

{% include_code files/linuxcnc-probe/square-cube.ngc lang:text %}
