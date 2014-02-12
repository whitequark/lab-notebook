---
layout: post
title: "Parametric G-Code for cutting PCBs"
date: 2014-02-12 22:36:23 +0400
comments: true
categories:
  - hardware
  - cnc
  - pcb
---

It's convenient to be able to cut rectangular PCBs with your CNC mill, but
calculating the required coordinates and compensating for tool size by hand
is no fun. Fortunately, G-code is sophisticated enough to describe this
task parametrically.

<!--more-->

{% include_code files/cut-rectangle.ngc lang:text %}
