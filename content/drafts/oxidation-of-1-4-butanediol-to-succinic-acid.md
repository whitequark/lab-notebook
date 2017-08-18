---
kind: draft
title: "Oxidation of 1,4-butanediol to succinic acid"
tags:
  - chemistry
  - failure
---

In this note I describe oxidation of 1,4-butanediol to succinic acid according to
[Svetlakov2001].

[Svetlakov2001]: http://dx.doi.org/10.1023/A:1019550005170

<!--more-->

* table of contents
{: toc}

# Reaction plan

Use easily available 68% azeotropic nitric acid to oxidize 1,4-butanediol to succinic acid.

The indicator of progress is evolution of heat and nitrogen oxides, the indicator of completion is cessation of heat evolution and change of solution color from brown to yellow.

# First attempt (2017-08-18)

In a 250ml round-bottom three-neck flask, with a 300 mm Liebig condenser connected in
reflux position, I've mixed with heavy stirring:

  * approx. 198 ml (3 mol) of 68% nitric acid,
  * approx. 44 ml (0.5 mol) of 1,4-butanediol.

Despite the fact that 1,4-butanediol was added quickly, no evolution of fumes was observed, and only a subtle change in color to light yellow. It eventually heated up to 45 °C and started cooling down from that point. The mixture was completely clear.

According to [Svetlakov2001], succinic acid should have started to precipitate 30-40 min after starting the reaction. However, that number was given for 80% nitric acid, not 68%.

The reaction mixture was stirred for 6 hours with no evident evolution of fumes or change in color, although it stayed at about 30 °C. After 6 hours, the stirrer was stopped, and the mixture quickly separated into two layers: top clear layer, taking little volume (likely unreacted butanediol) and bottom cloudy white layer, taking most of the flask (likely a mixture of nitric acid, water, and succinic acid).

No apparent change has happened for a while, until the mixture rapidly started boiling and evolving large amounts of brown fumes; the temperature was over 100 °C. Meanwhile, the condenser coolant pump has failed sometime during the previous six hours. The reaction was quickly brought under control by putting a large bath filled with room temperature water under the reaction flask.

TODO: write about the resulting compound, if any

## Conclusions

  * Never stop stirring a mixture you suspect may contain an interface between a strong oxidizer and an organic compound. (Once stopped, never abruptly start, or you'll make it runaway *more efficiently*.)
  * Yes, it *can* thermal runaway even after seemingly doing nothing for six hours.
  * Yes, a difference in concentration of 10% can matter a *lot*.
  * Scaling it up quite little was a right thing to do. Scaling it up *at all* was not.
  * You can never rehearse getting into PPE and quenching the reaction too much.
  * I need a better ventilation system.
  * And a coolant pump.
