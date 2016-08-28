---
kind: article
created_at: 2016-08-28 21:16:22 +0000
title: "SMD reflow with a blowtorch, try #3"
tags:
  - electronics
  - circuit boards
  - failure
---

See [try #1][try1] and [try #2][try2].

[try1]: /notes/2016-04-28/smd-reflow-with-a-blowtorch/
[try2]: /notes/2016-08-27/smd-reflow-with-a-blowtorch-try-2/

First, I have tried to fix the board from [try #2][try2] by pointing the torch vertically down,
with the board ~20 cm from the tip of the flame, for ~90 s. There was no difference. It will
become clear why after considering my second attempt.

Second, I have tried to solder another SLG46620V onto an identical breakout board, using the same
procedure as described above. It was immediately clear that this won't work---the package hasn't
even centered itself over the footprint, which meant that most of the solder definitely didn't
liquefy. Despite the success in [try #1][try1], it seems that ultimately pointing the torch
down at the board is at best very unreliable.

I suspect that the primary reason is that the rather hot air is drawn upwards by its buoyance much
faster than I expected, and most of it does not actually reach the board.

Third, I have heated the board again, but from underside, keeping the tip of the flame
~15 cm under the board, and soldering for ~90 s as well. This makes it much easier to observe
the package, and it centered itself over the footprint along with the solder becoming reflective
at ~60 s into the cycle.

This second SLG46620V was programmed to output a 25 kHz square wave on every pin instead of 1780 Hz
to make any soldering failures even more visible:

<% highlight_code 'verilog', 'square_wave.v' do %>
module top(output [16:0] o);
  wire clk;
  GP_RCOSC #(.OSC_FREQ("25k")) rcosc(.CLKOUT_FABRIC(clk));
  assign o = {17{clk}};
endmodule
<% end %>

In a way this has worked even worse; all board pins except 16 and 17 have a perfect square wave
but board pins 16 and 17 are not connected to the package pads whatsoever. (The signal appears
as it supposed to on the exposed sides of the QFN pads, which can be carefully probed.)

In conclusion, I will shelve this method as unreliable unless I discover that something else
in my process is at fault.
