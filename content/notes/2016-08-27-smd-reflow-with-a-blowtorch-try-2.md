---
kind: article
created_at: 2016-08-27 15:11:02 +0000
title: "SMD reflow with a blowtorch, try #2"
tags:
  - electronics
  - circuit boards
  - failure
---

Happy with the success of my [previous attempt][reblow] of blowtorch reflow, I've decided to do it
again, this time on a more finicky footprint, TQFN-20, using my [Silego breakout boards][breakout].

[reblow]: /notes/2016-04-28/smd-reflow-with-a-blowtorch/
[breakout]: /notes/2016-08-08/silego-greenpak-4-breakout-boards/

First, an SLG46620V was programmed to output 1780 Hz square wave on all pins except pin 2:

<% highlight_code 'verilog', 'square_wave.v' do %>
module top(output [16:0] o);
  wire clk;
  GP_LFOSC lfosc(.CLKOUT(clk));
  assign o = {17{clk}};
endmodule
<% end %>

Then, it was soldered to the board as follows:

  1. The board (even though it was pre-tinned) was additionally tinned by applying rosin flux
     and then 60/40 solder was dragged across it with a concave tip (Hakko BCM).
  2. More flux was added and the package was put onto the board.
  3. The board was heated from below with a blowtorch, with approx. 10 cm of distance from flame
     tip to the board, for no longer than 10 s. During that, the package has lifted itself upright
     and had to be put down with tweezers.

Observations:

  * The black solder mask was a bad idea. Sure, the boards look cooler, but thermochromism of
    the red mask I've described [earlier][reblow] is a significant help in gauging temperature.
  * Interestingly, when epoxy is heated near its Tg, it visibly changes texture, and this can be
    seen even with black solder mask, since this is a change in shape and not color.
  * The blowtorch was too close, and the rate of heating was too high.
  * Visually, there is nothing wrong with the board; the package is perfectly centered and
    the joints do not have excess solder.

After that, I've captured the output of every pin. Pins 2*, 3, 4, 6, and 12-20 output a nice square
wave (Vdd = 3.4 V):

<small>* Pin 2 is input-only, but I've soldered the package backwards, oops.</small>

![](/images/blowtorch-reflow-2/good-trace.png)

Pins 5, 7, 8, 9, and 10 are something completely different (pin 5 is shown, with the most
significant change):

![](/images/blowtorch-reflow-2/bad-trace.png)

Clearly, the top side of the board was heated unevenly, and solder on half of the package didn't
flow properly.

Conclusion: I should have heeded my own advice and heated the top side of the board (which I didn't
do because I feared that the stream of air would blow away the package), or did it much slower
(which I didn't do because I misremembered how far the torch should be).
More attempts are in order.
