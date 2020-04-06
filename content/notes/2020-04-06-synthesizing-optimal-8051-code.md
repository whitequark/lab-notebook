---
kind: article
created_at: 2020-04-06 16:44:20 +0000
title: "Synthesizing optimal 8051 code"
tags:
  - software
---

While working on an application targeting Nordic nRF24LE1, a wireless SoC with a fairly slow 8051 core, I was wondering if I can have fast, or at least not unusably slow, cryptography. Most cryptographic algorithms involve wide rotates, and the 8051 only has instructions for rotating a 8-bit accumulator by one bit at a time. In this note I explore deriving optimal code for rotating values in registers (that may be bigger than 8 bits) by multiple bits.

<!--more-->

* table of contents
{:toc}

# Introduction

My chosen approach (thanks for [John Regehr](https://www.cs.utah.edu/~regehr/) for the [suggestion](https://twitter.com/johnregehr/status/1212563858524499968)) is to implement an interpreter for an abstract 8051 assembly representation in [Racket](https://racket-lang.org) and then use [Rosette](https://emina.github.io/rosette/) to translate assertions about the results of interpreting an arbitrary piece of code into a query for an [SMT solver](https://en.wikipedia.org/wiki/Satisfiability_modulo_theories).

Rosette greatly simplifies this task because it lets me avoid learning anything about SMT solvers, and only requires me to understand the constraints of its symbolic execution approach. (Only a small subset of Racket is safe to use in Rosette, and functions outside of that subset are hard to use correctly without an in-depth understaning of how Rosette works.)

# Code generator

The following code generates all possible optimal (more on that below) 8-bit and 16-bit rotates. It uses a rather hacky and complicated scheme where it runs several solvers in parallel, one per CPU, each aiming for a particular fixed number of instructions, and then picks the smallest result as the solvers finish. This is because at the time of writing it, I did not understand that Rosette allows optimizing exists-forall problems. (It is quite easy to do so, as I'll describe in a future note.)

However, that turned out to be a blessing in disguise; when writing this note, I [rewrote the query as an optimization problem](/files/synth51/synth51-broken.rkt) for the solver, and it doesn't seem like that would work for this use case. First, of the solvers that can be used by Rosette, only Z3 supports quantified formulas, whereas Boolector had the best performance with the simpler queries. Second, even for very small programs (such as 8-bit rotates, which all fit in 4 instructions, and even restricting the usable registers to 2 out of 8), the memory footprint of Z3 grows extremely quickly, and I always ran out of memory before getting a solution.

By "optimal" here I mean "optimal within the limited model being used", of course. The model I'm using specifically omits any memory access (preventing the use of the `XCHD` instruction among other things), and in general has a very limited number of instructions to make solver runtime manageable. It is possible (but unlikely) that some of the instructions missing in the model but present in every 8051 CPU provide a faster way to do rotates. It is possible (and fairly likely) that your specific flavor of 8051 CPU provides a faster way to do rotates that involves memory-mapped I/O; indeed, nRF24LE1 does, but I was interested in more portable code.

<%= highlight_code 'racket', '/files/synth51/synth51.rkt' %>

# Results

Generating the optimal 8-bit and 16-bit rotates took about half a day on a modern laptop (Dell XPS13 9360, using all cores and with mitigations disabled). Because of that I have not attempted generating wider ones so far.

## 8-bit rotates

The following code lists all optimal 8-bit rotates, by 0 to 7 bits.

<%= highlight_code 'text', '/files/synth51/rot8.asm' %>

## 16-bit rotates

The following code lists all optimal 16-bit rotates, by 0 to 15 bits. I find the approach the solver used for the rotate by 10 nothing short of brilliant, and the approach it took for rotate by 3/5/11/13 pretty neat as well.

<%= highlight_code 'text', '/files/synth51/rot16.asm' %>
