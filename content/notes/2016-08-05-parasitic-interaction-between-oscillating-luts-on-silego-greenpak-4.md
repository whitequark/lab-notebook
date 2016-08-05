---
kind: article
created_at: 2016-08-05 20:49:10 +0000
title: "Parasitic interaction between oscillating LUTs on Silego GreenPAK 4"
tags:
  - semiconductors
  - electronics
---

In a [previous note](/notes/2016-08-05/ring-oscillators-on-silego-greenpak4/) I've discovered that a ring oscillator made from three nearby `GP_LUT2` configured as inverters oscillates faster than a single `GP_LUT2`, whereas the expected behavior is that it would three times slower. In this note I describe how that happens.

This is the logic that exhibits anomalous behavior:

<% highlight_code 'verilog', 'gp_2lut_x3.v' do %>
module top(
        (*LOC="P4"*) output q0,
        (*LOC="P5"*) output q1,
        (*LOC="P6"*) output q2
    );
    (* LOC="LUT2_0" *)
    GP_2LUT #(.INIT(4'b0001)) lut1(.IN0(q0), .OUT(q1));
    (* LOC="LUT2_1" *)
    GP_2LUT #(.INIT(4'b0001)) lut2(.IN0(q1), .OUT(q2));
    (* LOC="LUT2_2" *)
    GP_2LUT #(.INIT(4'b0001)) lut3(.IN0(q2), .OUT(q0));
endmodule
<% end %>

The first thing I tried was to hook up the scope to the output of all three LUTs. Sure enough, they're phase-matched perfectly:

![](/images/gp4-ringosc-2/locked.png)

In contrast, this is how it should look (and how it looks if I move `lut3` to `LUT2_4`, which is in another matrix):

![](/images/gp4-ringosc-2/unlocked.png)

Now, why does that happen? Let's permute the logic to find out:

  * [Swap the LUTs](#){: data-show-hide="swap-luts"}: phase-matched.

    <% highlight_code 'verilog' do %>
    module top(
        (*LOC="P4"*) output q0,
        (*LOC="P5"*) output q1,
        (*LOC="P6"*) output q2
    );
        (* LOC="LUT2_2" *)
        GP_2LUT #(.INIT(4'b0001)) lut1(.IN0(q0), .OUT(q1));
        (* LOC="LUT2_1" *)
        GP_2LUT #(.INIT(4'b0001)) lut2(.IN0(q1), .OUT(q2));
        (* LOC="LUT2_0" *)
        GP_2LUT #(.INIT(4'b0001)) lut3(.IN0(q2), .OUT(q0));
    endmodule
    <% end %>
    {: id="swap-luts"}

  * [Introduce a gap instead of using consecutive LUTs](#){: data-show-hide="gapped-luts"}: phase-matched.

    <% highlight_code 'verilog' do %>
    module top(
        (*LOC="P4"*) output q0,
        (*LOC="P5"*) output q1,
        (*LOC="P6"*) output q2
    );
        (* LOC="LUT2_0" *)
        GP_2LUT #(.INIT(4'b0001)) lut1(.IN0(q0), .OUT(q1));
        (* LOC="LUT2_1" *)
        GP_2LUT #(.INIT(4'b0001)) lut2(.IN0(q1), .OUT(q2));
        (* LOC="LUT2_3" *)
        GP_2LUT #(.INIT(4'b0001)) lut3(.IN0(q2), .OUT(q0));
    endmodule
    <% end %>
    {: id="gapped-luts"}

  * [Use three LUTs from another matrix](#){: data-show-hide="other-matrix"}: phase-matched.

    <% highlight_code 'verilog' do %>
    module top(
        (*LOC="P4"*) output q0,
        (*LOC="P5"*) output q1,
        (*LOC="P6"*) output q2
    );
        (* LOC="LUT2_4" *)
        GP_2LUT #(.INIT(4'b0001)) lut1(.IN0(q0), .OUT(q1));
        (* LOC="LUT2_5" *)
        GP_2LUT #(.INIT(4'b0001)) lut2(.IN0(q1), .OUT(q2));
        (* LOC="LUT2_6" *)
        GP_2LUT #(.INIT(4'b0001)) lut3(.IN0(q2), .OUT(q0));
    endmodule
    <% end %>
    {: id="other-matrix"}

  * [Use only two LUTs in a ring](#){: data-show-hide="two-luts"}: phase-matched---nevermind this circuit shouldn't oscillate at all!

    <% highlight_code 'verilog' do %>
    module top(
        (*LOC="P4"*) output q0,
        (*LOC="P5"*) output q1
    );
        (* LOC="LUT2_0" *)
        GP_2LUT #(.INIT(4'b0001)) lut1(.IN0(q0), .OUT(q1));
        (* LOC="LUT2_1" *)
        GP_2LUT #(.INIT(4'b0001)) lut2(.IN0(q1), .OUT(q2));
    endmodule
    <% end %>
    {: id="two-luts"}

  * [Use three completely independent oscillators](#){: data-show-hide="independent-oscs"}: still phase-matched.

    <% highlight_code 'verilog' do %>
    module top(
        (*LOC="P4"*) output q0,
        (*LOC="P5"*) output q1,
        (*LOC="P6"*) output q2
    );
        (* LOC="LUT2_0" *)
        GP_2LUT #(.INIT(4'b0001)) lut1(.IN0(q0), .OUT(q0));
        (* LOC="LUT2_1" *)
        GP_2LUT #(.INIT(4'b0001)) lut2(.IN0(q1), .OUT(q1));
        (* LOC="LUT2_2" *)
        GP_2LUT #(.INIT(4'b0001)) lut3(.IN0(q2), .OUT(q2));
    endmodule
    <% end %>
    {: id="independent-oscs"}

  * [Move the third independent oscillator to the other matrix](#){: data-show-hide="cross"}: `lut3` loses the phase relationship to `lut1` and `lut2`.

    <% highlight_code 'verilog' do %>
    module top(
        (*LOC="P4"*) output q0,
        (*LOC="P5"*) output q1,
        (*LOC="P6"*) output q2
    );
        (* LOC="LUT2_0" *)
        GP_2LUT #(.INIT(4'b0001)) lut1(.IN0(q0), .OUT(q0));
        (* LOC="LUT2_1" *)
        GP_2LUT #(.INIT(4'b0001)) lut2(.IN0(q1), .OUT(q1));
        (* LOC="LUT2_4" *)
        GP_2LUT #(.INIT(4'b0001)) lut3(.IN0(q2), .OUT(q2));
    endmodule
    <% end %>
    {: id="cross"}

It seems that the parasitic interactions between the LUTs that are physically adjacent to each other are very strong---in fact favored more than the actual function they're supposed to implement.

Interestingly, in the case of three completely independent oscillators---but not any of the previous ones---there is even a second-order effect, with the output signals appearing modulated by another signal that is phase-shifted across the three oscillators:

![](/images/gp4-ringosc-2/independent.png)
