---
kind: article
created_at: 2018-01-01 00:22:52 +0000
title: "Synthesizing phosphorus(III) chloride"
tags:
  - chemistry
  - failure
has_mathjax: true
---

In this note I'll describe my failed attempt at synthesis of phosphorus(III) chloride from elements with an emphasis of simplicity. For example, concentrated sulfuric acid or potassium permanaganate may not be easily available in certain locales, and I am trying to avoid using them in this synthesis.

<!--more-->

* toc
{: toc}

## Glassware

  * 14/23-14/23 addition funnel
  * 14/23-14/23-29/32 distillation head
  * 29/32 250 mL flat-bottom flask
  * 14/23-29/32 105° bend
  * 29/32-14/23 two-necked 250 mL round-bottom flask
  * 14/23-14/23 45° bend
  * 14/23-14/23 30cm Liebig condenser
  * 14/23-14/23 still receiver
  * 14/23 100 mL flat-bottom flask
  * gas washing bottle

## Chemicals

  * manganese(IV) oxide
  * 38% hydrochloric acid
  * red phosphorus
  * sodium hydrocarbonate

## Apparatus

<object type="image/svg+xml" data="/images/phosphorus-chloride-synth/pcl3-attempt/apparatus.svg">
</object>

## Overview

The reaction setup is simple. An addition funnel is used to make a controllable chlorine generator, which provides chlorine for the spontaneous reaction with phosphorus. The reaction is extremely exothermic, so controlling its rate is important.

The overall set of reactions is as follows:

$$\ce{
12HCl + 3MnO2 -> 3Cl2 + 3MnCl2 + 6H2O \\
3Cl2 + 2P -> 2PCl3
}$$

That is, in ideal conditions, to produce 1 mole (137 g) of $\ce{PCl3}$, it is necessary to spend 1 mole of $\ce{P}$ (31 g), 1.5 moles of $\ce{MnO_2}$ (87 g) and 6 moles of $\ce{HCl}$ (484 mL at 38%).

## Results

No distillate comes over. Instead, the flask is being very slowly covered with greenish-white solid:

<%= lightbox '/images/phosphorus-chloride-synth/pcl3-attempt/product.jpeg', gallery: 'product' %>
<%= lightbox '/images/phosphorus-chloride-synth/pcl3-attempt/product-closeup.jpeg', gallery: 'product' %>
<%= lightbox '/images/phosphorus-chloride-synth/pcl3-attempt/product-closeup-2.jpeg', gallery: 'product' %>

This is consistent with the product being PCl₅, since it is a greenish-white crystalline solid, it would sublime (and then recrystallize) upon forming because of its high enthalpy of formation, it violently reacts with water producing large amounts of fumes of hydrochloric acid, and indeed, there can be no other crystalline product at STP.

Apparatus improvement and purification is left to further work.

## Observations

  * The $\ce{MnO_2 + HCl}$ chlorine generator is very mild and does not even really need to be controlled using an addition funnel; it's enough to change the speed with which it is stirred.
  * At high chlorine generation rates, one can observe the fumes of $\ce{PCl5}$ in the 105° bend.
  * It is widely believed ([sciencemadness](http://www.sciencemadness.org/talk/viewthread.php?tid=63363), [prepchem.com](http://www.prepchem.com/synthesis-of-phosphorus-pentachloride/)) that preparation of $\ce{PCl5}$ is a complicated affair requiring drying of $\ce{Cl2}$, starting with white phosphorus (lol no), reflux distillation... Turns out all of that is untrue, and a very simple setup works just as well.
