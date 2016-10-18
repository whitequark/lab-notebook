---
kind: article
created_at: 2016-10-18 19:42:42 +0000
title: "Implementing an UART in Verilog and Migen"
tags:
  - programmable logic
---

* toc
{:toc}

In this note I'll explore the differences between the HDLs Verilog and [Migen][migen].

[migen]: https://m-labs.hk/migen/manual/introduction.html

# Verilog code

A while ago, I wrote a simple UART in Verilog. It consists of three modules.

## Clock divider

The first module defines a reusable clock divider that verifies that, given the input frequency,
the requested frequency makes sense and (if specified) doesn't deviate too much from the target:

<div style="clear:both;"></div>

<%= highlight_code 'verilog', '/files/verilog-vs-migen/ClockDiv.v' %>

It's somewhat too complicated and inflexible due to my desire to have 50% duty cycle on something
that's marked as "clock" going out of a reusable module. The error reporting is also quite
inelegant due to my toolchain, [Icarus Verilog][] and [Yosys][], which did not leave me a better
way to report such errors that worked in both of them, and I did not want to litter code with
<code>`ifdef</code>s.

[icarus verilog]: http://iverilog.wikia.com
[yosys]: http://www.clifford.at/yosys/

## UART

The second one implements the UART itself, as well as its testbench:

<%= highlight_code 'verilog', '/files/verilog-vs-migen/UART.v' %>

It's, again, overcomplicated; my first design sampled the input at the end of every bit period,
which of course made it unreliable. Instead of fixing that properly, i.e. sampling in the middle
of the bit period, I remembered that I read about oversampling somewhere, and implemented that:

![](/images/verilog-vs-migen/bad-sampling.png)

Notwithstanding that it's still silly, it worked. This is what I should have done instead:

![](/images/verilog-vs-migen/good-sampling.png)

## UART testbench

And a simple testbench design that implements a loopback using a single UART instance looks
like this:

<%= highlight_code 'verilog', '/files/verilog-vs-migen/UARTLoopback.v' %>

# Migen code

The Migen implementation has everything in the same file: the UART, the verification code,
and the loopback testbench. (Even so, and even accounting for the fact that the Migen
implementation is simplified compared to the Verilog one, it is remarkably still smaller
than `UART.v` alone!)

<%= highlight_code 'python', '/files/verilog-vs-migen/UART.py' %>

It can be simulated by running `python3 UART.py sim`, and loaded onto an [iCE40-HX8K-B-EVN][evb]
developer board by running `python3 UART.py loopback`.

[evb]: http://www.latticesemi.com/Products/DevelopmentBoardsAndKits/iCE40HX8KBreakoutBoard.aspx

# Migen vs Verilog

My impression of the migration is overwhelmingly positive. There wasn't a single downside to it.
I'll list the benefits roughly in the decreasing order of importance.

## No Verilog processes

In Verilog, any signal may be only driven from a single process, that is, an "always" block.
On the other hand, in Migen there is no such restriction; to drive a signal, a statement should
merely be in the same clock domain. (Statements are placed into a single `always @(*)` block and
an `always @(posedge clk)` block per clock domain during synthesis; Migen reset is synchronous.)

As a result, Migen doesn't have this spurious coupling between syntax and behavior that
Verilog has; for example, instead of having a configurable phase like `ClockDiv`, the Migen
UART code simply resets the divider to the half of its wraparound value from one of
the FSM states, and this does not conflict with the decrement logic, as the later (in code)
action takes precedence.
In this example the counter is not factored out into a submodule, but putting it there would
not change anything as submodules are flattened.

When modeling logic, I try to do it elegantly; in Verilog this means writing an `always`
statement per an elementary component of the system, and factoring out reusable modules.
But the way processes are implemented places a restriction on the usefulness of such fine-grained
approach, and it significantly hinders my ability to model a system efficiently.

## No FPGA initialization fiasco

In Verilog, there are three obvious ways to initialize registers: in an `initial` statement,
inline in the declaration, and using an explicit reset.

When designing FPGA gateware, the first two are preferable, since they use the FPGA's ability
to initialize registers when loading the bitstream, which results in less logic than when
an explicit reset is used, and often the majority of registers will only be reset once.
However, reusable modules ought to be resettable explicitly, and to accomodate that, the reset
values have to be specified twice, which is error-prone, and forgetting it tends to create opaque
bugs.

## No `wire`/`reg` distinction

In Verilog, the distinction is useless since using a `reg` can be used to model both
combinatorial and sequential logic. Migen does away with the distinction; though so does
SystemVerilog, which has `logic`.

## Native finite state machine support

In Verilog, you have to manually implement an FSM using `localparam` and `case` statements;
the compiler performs no next to no checking of validity, and the identifiers clash easily.
SystemVerilog improves on this somewhat with its `typedef enum` construct, but it's still
not very ergonomic---surprising for such a common construct. It is also necessary to keep track
of the state register width manually.

In Migen, the built-in `FSM` module handles all that.

## No instantiation boilerplate

In Verilog, instantiating modules with a large amount of inputs and outputs results in extreme
amounts of boilerplate: for every port, one a `wire` or `reg` declaration, one connection
in the instance, and often one `assign` statement connecting the signal elsewhere.

In Migen, clock and reset signals are connected implicitly, and modules are first-class, so they
can be passed around and have their ports used directly. With less junk code comes less opportunity
for copy-paste and other trivial errors.

## First-class cosimulation

In Verilog, cosimulation requires integration with tool-specific interfaces that are generally
awkward to use.

In Migen, cosimulation is a mere matter of writing a Python generator function, which can
of course call arbitrary code that has a Python interface, such as a CPU simulator or
even a driver for a developer board.

## Platform resource management

In Verilog, toplevel ports are usually bound to specific pads or balls with an external
constraint file, which usually does not provide any meaningful grouping and has to be written
(or copied) per-project.

In Migen, toplevel ports are requested from the "platform", which returns structured signals
or groups of signals in response to a symbolic request; and the definitions can be composed,
i.e. the set of signals can be initially defined by the base board, then extended by a per-project
daughterboard, and so on.

## Built-in build system

In Verilog, running a design on your hardware means awkwardly digging up that Makefile you first
wrote five years ago and used ever since and updating it for your latest project, and maybe
fixing a bug or two in your custom dependency management code.

In Migen, dependency management is provided by Python (which isn't stellar but is far better),
and going from HDL to a bitstream is a single function call.

# Conclusions

Migen's lack of restrictions around process and meaningful handling of resets has substantially
helped me write good HDL. The rest are little increases in productivity that matter,
especially together, but the lack of them is perhaps not a massive hindrance in Verilog.

I haven't used Migen's more advanced features yet, like parameterization of control flow,
and especially arrays of signals indexed by signals; such arrays of signals in particular are
not directly expressible in Verilog (though they seem to be possible in SystemVerilog) and
so are likely to result in very obtuse code when implemented manually.
But they are needed for the more complex logic, like bus arbiters, and I haven't
written one of those (yet).
