---
kind: article
created_at: 2018-01-02 04:16:30 +0000
title: "Synthesizing sulfur(II) dichloride"
tags:
  - chemistry
  - failure
has_mathjax: true
---

In this note I'll describe my failed attempt the synthesis of sulfur dichloride, which is a precursor for thionyl chloride.

<!--more-->

* toc
{: toc}

## Glassware and equipment

### Chlorine generator

  * 29/32 250 mL flat bottom flask
  * 19/26-29/32 hose adapter
  * magnetic stirrer

### Reactor and still

  * 14/19 silicone stopper with 25 cm glass tube
  * 29/32 250 mL round bottom flask
  * 14/23-14/23-29/32 distillation head
  * 14/23-14/23 30 cm Liebig condenser
  * 14/23-19/26 still receiver
  * 19/26 100 mL flat bottom flask
  * gas washing bottle
  * 250 mL heating mantle

## Chemicals

  * manganese(IV) oxide
  * 38% hydrochloric acid
  * sulfur
  * sodium hydrocarbonate

## Apparatus

<object type="image/svg+xml" data="/images/sulfur-chloride-synth/try-1/apparatus.svg">
</object>

## Overview

Excess chlorine is reacted with elemental sulfur to form $\ce{S2Cl2}$ and eventually $\ce{SCl2}$, which are then distilled to remove any residual sulfur (sulfur is very soluble in sulfur chlorides).

The overall set of reactions is as follows:

$$\ce{
4HCl + MnO2 -> Cl2 + MnCl2 + 2H2O \\
\frac{1}{2}S + \frac{1}{2}Cl2 -> \frac{1}{2}S2Cl2 \\
\frac{1}{2}S2Cl2 + Cl2 -> SCl2
}$$

That is, in ideal conditions, to produce 1 mole (135 g, 78 mL) of $\ce{SCl2}$, it is necessary to use 1 mole of $\ce{S}$ (32 g), 1 mole (87 g) of $\ce{MnO_2}$ and 4 moles of $\ce{HCl}$ (315 mL at 38%).

## Results

I have not appreciated the degree to which chlorine can escape the apparatus. It easily escapes through ground glass joints, even clamped. It cracks the joint clamps in as little as ten minutes, making them release with a snap. It permeates right through silicone with speed that is impressive and severely concerning:

<img src="/images/sulfur-chloride-synth/try-1/chlorine-escaping.jpeg">

Additionally, the apparatus is dynamically nonfunctional: the surface area of interaction between chlorine and sulfur is quite small, and instead of being sunk into sulfur, most chlorine ends up in the chlorine trap, as can be seen by the deep green color of the hose connecting to the trap.

In spite of that, I appear to have successfully synthesized a small amount of $\ce{S2Cl2}$, a golden-yellow liquid that produces white fumes on contact with air with a suffocating odor resembling the mixture of those of $\ce{HCl}$ and $\ce{SO_2}$. It has condensed all over the apparatus after I've melted and resolidified the sulfur out of curiosity:

<img src="/images/sulfur-chloride-synth/try-1/product.jpeg">

## Improvements

  * Use PVC hoses where exposed to chlorine. [Tygon][] is a kind and a brand of PVC hosing, and it makes sense that PVC would be resistant to chlorine, being a chlorinated polymer. Using regular PVC hosing would result in plasticizer leaching and, eventually, cracking, but is much cheaper and more accessible.
  * Use chlorine-resistant grease on every glass joint exposed to it.
  * Use a magnetic stirrer to agitate the solid sulfur (and eventually, the sulfur-sulfur chlorides mix) to significantly increase contact surface area between sulfur and chlorine. Ideally, all incoming chlorine will be sunk into sulfur.
  * Use Kipp's apparatus to precisely control the amount of chlorine being evolved (see the previous item) and avoid losing any. This is not strictly necessary but it makes the synthesis more predictable and avoids waste of hydrochloric acid.

[tygon]: http://www.tygon.saint-gobain.co.jp/pdf/FT-Tygon-2375Ultra.pdf

## Observations

  * Note the easily visible longitude gradient in the hose connecting the still receiver to the trap. It means the permeability of silicone is so high that over the mere ~30 cm length of the hose, so much chlorine escapes that the transverse gradient becomes low enough to stop forcing quite as much chlorine into the hose.
  * The white silicone stopper turned itself into gooey mush.
  * Contrary to what happened to the silicone stopper (perhaps because of the filler that gives it the yellow color), the silicone hoses significantly hardened, at places cracked, and **welded themselves to glass** at hose barbs.
  * Cleaning condensed $\ce{S2Cl2}$ from the apparatus is easy: just add water, and it turns into $\ce{SO_2}$ and $\ce{HCl}$. However, it dissolves sulfur, which is now deposited as an extremely fine, hard to clean powder *everywhere*. It might be a better idea to rinse it away with a chlorinated solvent first.
