---
layout: post
title: "Line art photography cleanup"
date: 2016-04-29 07:41:00 +0000
comments: true
categories:
  - software
  - photography
---

Often, photographs of line art, such as schematics, contain lots of noise:
glare, unwanted reflections, uneven lighting, etc. In this note I present
a simple and reliable cleanup method using [GIMP][].

[gimp]: http://gimp.org

<!--more-->

Here is the source picture and the result:

{% fancybox gal-try-1 /images/line-art-cleanup/source.jpeg %}
{% fancybox gal-try-1 /images/line-art-cleanup/result.jpeg %}

The source picture is a photograph of schematics printed on an adhesive film
and applied to a curved surface of an appliance made from glossy gray
polypropylene. It is illuminated by a single ceiling light. These conditions,
while typical, result in a low-quality picture: for example, due to curvature,
it is all but impossible to capture a picture with entirely even illumination
and no glare.

The picture was processed in GIMP using the standard "Difference of Gaussians"
filter with parameters "Radius 1" set to 20.0px and "Radius 2" set to 1.5px,
and then the "Levels" tool in automatic mode. Unlike the "Threshold" tool,
which cannot process unevenly lit images because it is global,
"Difference of Gaussians" is local and has no such limitation.

I do not have an understanding of how this filter works, and the values were
chosen by trial and error.
