---
kind: article
created_at: 2020-04-06 17:25:03 +0000
title: "Minimizing logic expressions"
tags:
  - software
---

While working on reverse-engineering the Microchip ATF15xx CPLD family, I found myself deriving minimal logic functions from a truth table. This useful because while it is easy to sample all possible states of a black box combinatorial function using e.g. [boundary scan](https://en.wikipedia.org/wiki/Boundary_scan), these truth tables are unwieldy and don't provide much insight into the hardware. While a minimal function with the same truth table would not necessarily be *the* function implemented by the hardware (which may have hidden variables, or simply use a larger equivalent function that is more convenient to implement), deriving one still provides great insight. In this note I explore this process.

<!--more-->

My chosen approach (thanks to [John Regehr](https://www.cs.utah.edu/~regehr/) for the [suggestion](https://twitter.com/johnregehr/status/1212563858524499968)) I got for [an earlier project](/notes/2020-04-06/synthesizing-optimal-8051-code/) is to implement an interpreter for a simple logic expression abstract syntax tree in [Racket](https://racket-lang.org) and then use [Rosette](https://emina.github.io/rosette/) to translate assertions about the results of interpreting an arbitrary logic expression, as well as a cost function, into a query for an [SMT solver](https://en.wikipedia.org/wiki/Satisfiability_modulo_theories).

Although I could use an off-the-shelf logic minimizer here (like [Espresso](https://ptolemy.berkeley.edu/projects/embedded/pubs/downloads/espresso/)), most logic minimizers solve a different problem: quickly translating large designs to simple netlists. However, I would like to have a complex output netlist: the ATF15xx CPLDs have a hardware XOR gate that I would like the minimizer to infer on its own. On the other hand, I don't really care about the runtime of the minimizer as long as it's on the order of minutes to hours. Rosette's flexibility is a perfect match for this task.

The following code demonstrates the approach and its ability to derive a XOR gate from3 the input expression. It can be easily modified for a particular application by extending (or reducing, e.g. for translation to an [and-inverter graph](https://en.wikipedia.org/wiki/And-inverter_graph)) the logic language, or altering the cost function.

<%= highlight_code 'racket', '/files/minlogic.rkt' %>
