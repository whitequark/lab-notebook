---
kind: article
created_at: 2016-09-17 14:48:58 +0000
title: "Parametric model of a Kawai Tsugite joint"
tags:
  - mechanics
has_solvespace: true
---

I made a model of the [Kawai Tsugite][kt] joint in the [SolveSpace CAD][ss].
The views of a joint half and an assembled joint below are live; if you download
the [design files][design], then you can slide the assembly together and apart,
which is quite fun.

[kt]: http://woodgears.ca/puzzles/3way_joint.html
[ss]: http://solvespace.com
[design]: /files/kawai-tsugite.zip

<script type="text/javascript" src="/images/kawai-tsugite/joint.js"></script>
<script type="text/javascript" id="solvespace_model_joint">
injectSolveSpace('solvespace_model_joint', solvespace_model_joint,
                 {width: 390, height: 300, scale: 3})
</script>

<script type="text/javascript" src="/images/kawai-tsugite/slide.js"></script>
<script type="text/javascript" id="solvespace_model_slide">
injectSolveSpace('solvespace_model_slide', solvespace_model_slide,
                 {width: 390, height: 300, scale: 3,
                  offset: new THREE.Vector3(-65.73/2, -65.73/2, 65.73/2)})
</script>
