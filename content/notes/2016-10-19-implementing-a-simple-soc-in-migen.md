---
kind: article
created_at: 2016-10-19 18:35:29 +0000
title: "Implementing a simple SoC in Migen"
tags:
  - programmable logic
---

* toc
{:toc}

In this note I'll write about implementing a simple microcontroller based on an
[OpenRISC 1000][or1k] CPU core using [Migen][].

[or1k]: https://opencores.org/or1k/Main_Page
[migen]: https://m-labs.hk/migen/manual/introduction.html

# Prerequisites

To write this note, I was using:

  * [migen][migengit] commit `3cc73b9f4298a0a375b4bbd1bfc8807dfdb38ffd`;
  * [misoc][misocgit] commit `b53b60c3f9aaa24388cccc96f9be367b92019533`;
  * [mor1kx][mor1kxgit] commit `fb519d011ae2524e3681f07b206df0a6c03f82a8`;
  * [Yosys][yosysgit] version `0.6+205git42a9712`;
  * [IceStorm][icestormgit] version `0~20160913git266e758-2`;
  * [arachne-pnr][arachnegit] version `0.1+20151224git1a4fdf9`;
  * [uart.py][uart] from the [earlier note][uartnote];
  * [binutils][binutils] version `2.26.51.20160313` built with `--target=or1k-none`;
  * the [iCE40-HX8K-B-EVN][evb] development board.

Newer versions will probably still work fine.

[migengit]:    https://github.com/m-labs/migen
[misocgit]:    https://github.com/m-labs/misoc
[mor1kxgit]:   https://github.com/openrisc/mor1kx
[yosysgit]:    https://github.com/cliffordwolf/yosys
[icestormgit]: https://github.com/cliffordwolf/icestorm
[arachnegit]:  https://github.com/cseed/arachne-pnr
[uart]:        /files/verilog-vs-migen/UART.py
[uartnote]:    /notes/2016-10-18/implementing-an-uart-in-verilog-and-migen/#migen-code
[binutils]:    https://www.gnu.org/software/binutils/
[evb]:         http://www.latticesemi.com/Products/DevelopmentBoardsAndKits/iCE40HX8KBreakoutBoard.aspx

# Implementation

The SoC consists of the three main parts: the mor1kx wrapper, the SoC gateware, and the ROM code.

## mor1kx wrapper

The mor1kx wrapper simply instantiates the CPU core from an adjacent checkout of the `mor1kx`
git repository, and configures it to remove as many features as realistically possible,
with the exception of narrowing the register file.
(There is an option `OPTION_RF_ADDR_WIDTH`, but enabling it broke stores with
the address in `r2` while stores with address in `r1`, `r3`, `r4` and `r5` worked,
for a reason I am unable to comprehend. There is also an option `OPTION_RF_WORDS`, which
does nothing.)

There is a version of this wrapper in MiSoC, but it's not configurable and enables too
many features, e.g. caches, such that the resulting core won't fit into iCE40-HX8K.

<%= highlight_code 'python', '/files/migen-simple-soc/mor1kx.py' %>

## SoC gateware

The overall architecture of the SoC can be seen on this wonderful diagram:

<figure>
<figcaption>Simple SoC</figcaption>
<pre>
 +----------+   +-----------------+
 |          |   |     Wishbone    |
 | CPU core +---+    arbiter &    |
 |          |   |     decoder     |
 +----------+   +-+------+------+-+
                  |      |      |
         +--------+-+ +--+---+ ++-----+ +-----+
         | 256B RAM | | LEDs | | UART +-+ PHY |
         +----------+ +------+ +------+ +-----+
</pre>
</figure>

The full code can be [downloaded][simplesoc.py]; I will describe it part-by-part here.

[simplesoc.py]: /files/migen-simple-soc/simplesoc.py

### Digression: the Wishbone bus

All of the components in this SoC are connected using the [Wishbone] bus, which is actually
fairly simple as far as buses go, but it has a number of signals that are dazzling at first,
and the specification is very obtuse and probably creates more confusion than it solves.

When implementing a typical I/O peripheral (without any wait states and without support
for any but word granularity access) in Migen, the following list can be used as a reference:

  * The `rst` and `clk` inputs are implicit as a part of the clock domain
    and not part of the Wishbone interface in Migen;
  * The `cyc` and `stb` inputs, when asserted together, indicate that there is a valid bus
    cycle and this peripheral is selected;
  * The `adr` input is the address of the access; it has the granularity of bus width and
    includes every bit even if it's already partially decoded by the arbiter.
    For example, if a CPU is accessing the address `0x10001000` and a peripheral is mapped
    with a base address `0x10000000` on a 32-bit Wishbone bus, the peripheral will observe
    `adr == 0x04000400`.
  * The `dat_r` output is the word being read from the peripheral; since its value does not
    affect anything when the peripheral is not selected, it can (and should, for simplicity)
    be updated regardless of whether there is a bus cycle.
  * The `dat_w` input is the word being written into the peripheral, and `we` is the write
    enable strobe; `dat_w` is only valid when all of `cyc`, `stb` and `we` are asserted.
  * The `ack` output should be asserted once a transaction successfully completes, i.e.
    in response to `cyc` and `stb` being asserted.
  * The `err` output can be asserted to abort the transaction; this will raise a bus error
    exception or the like.
  * The `cti` and `bte` signals are related to burst transfers and can be ignored.

The peripheral should also use registered feedback, i.e. the `dat_r`, `ack` and (if any) `err`
outputs should be asserted through combinatorial logic. This improves timing closure, since
in this case accesses take two cycles instead of one, but the critical path for the Wishbone
bus includes only signals in that bus, and not the rest of your design also.

[wishbone]: https://en.wikipedia.org/wiki/Wishbone_(computer_bus)

### GPIO peripheral

The GPIO peripheral maps consecutive 32-bit write-only registers (with one bit used) to
the output array, of no more than 8 outputs:

<% highlight_code 'python' do %>
class SimpleGPIO(Module):
    def __init__(self, outputs):
        self.bus = bus = wishbone.Interface()

        ###

        self.sync += [
            bus.ack.eq(0),
            If(bus.cyc & bus.stb & ~bus.ack,
                bus.ack.eq(1),
                If(bus.we,
                    Array(outputs)[bus.adr & 0x3].eq(bus.dat_w[0])
                )
            )
        ]
<% end %>

Note this basic pattern:

<% highlight_code 'python' do %>
self.sync += [
    bus.ack.eq(0),
    If(bus.cyc & bus.stb & ~bus.ack,
        bus.ack.eq(1),
        If(bus.we,
            ...)
    )
]
<% end %>

This makes sure that the code replaced by `...` will execute only during a valid bus transaction
(the `bus.cyc & bus.stb` part), execute exactly once per bus cycle (the "negative ack feedback"),
and execute only during write transactions (the `bus.we` part).

### UART peripheral

The UART peripheral has two 32-bit registers with the following layout:

<small>(speaking of layout, do you have *any idea* how *ridiculously hard* it is to lay this
out in HTML?)</small>

<style>
.uartreg td { text-align: center; }
.uartreg tr:first-child th:first-child { width: 100px; }
#uartreg0 tr:first-child td:nth-child(2) { width: 300px; }
#uartreg0 tr:first-child td:nth-child(3) { width: 80px; }
#uartreg0 tr:first-child td:nth-child(4) { width: 80px; }
#uartreg4 tr:first-child td:nth-child(2) { width: 300px; }
#uartreg4 tr:first-child td:nth-child(3) { width: 80px; }
#uartreg4 tr:first-child td:nth-child(4) { width: 80px; }
</style>
<figure id="uartreg0" class="uartreg">
<figcaption>Address 0 (RX Status/Data Register)</figcaption>
<table>
  <tr><th>Bit</th>     <td>31:10</td><td>9</td>       <td>8</td>      <td>7:0</td></tr>
  <tr><th>Type</th>    <td>N/A</td>  <td>R</td>       <td>R/C1</td>   <td>R</td></tr>
  <tr><th>Function</th><td>N/A</td>  <td>RX Error</td><td>RX Full</td><td>RX Data</td></tr>
</table>
</figure>
<figure id="uartreg4" class="uartreg">
<figcaption>Address 4 (TX Command/Data Register)</figcaption>
<table>
  <tr><th>Bit</th>     <td>31:10</td><td>9</td>       <td>8</td>       <td>7:0</td></tr>
  <tr><th>Type</th>    <td>N/A</td>  <td>R</td>       <td>W</td>       <td>W</td></tr>
  <tr><th>Function</th><td>N/A</td>  <td>TX Empty</td><td>TX Start</td><td>TX Data</td></tr>
</table>
</figure>

The bit types that are reasonable to use in peripheral registers are:

  * R means read-only (writes do nothing);
  * W means write-only (reads return zeroes);
  * R/W means read-write (reads return what was written, and any written value is valid);
  * R/C1 means read-only, cleared by writing one (writing zero does nothing, writing one
    clears the bit if it was set, or does nothing);
  * N/A means reserved and should be written as zero (reads return garbage, zero
    writes do nothing, non-zero writes result in unpredictable behavior); if software observes
    these restrictions, the bit can gain new functionality later.

The R/C1 bit type is particularly useful for event flags. The reason it's specifically cleared
by writing one is that this allows updating unrelated bits in the same register without
accidentally clearing some interesting flags, even if the set of flags is not known beforehand
and thus they cannot be explicitly masked; in general, it is otherwise impossible to safely
update a part of the register using a read-modify-write cycle without introducing a race condition.

Of course, when implementing a peripheral you have complete freedom over its behavior; and you
could implement odd things, like registers that self-clear on reads, or bits that have completely
different meaning when reading and writing, or somesuch. But this is error-prone and also annoys
software developers, so maybe don't do that.

The implementation of the peripheral is essentially the same as for the GPIO one, though it also
has readable registers:

<% highlight_code 'python' do %>
class SimpleUART(Module):
    def __init__(self, serial, clk_freq, baud_rate):
        self.bus = bus = wishbone.Interface()
        self.submodules.phy = phy = UART(serial, clk_freq, baud_rate)

        ###

        self.sync += [
            If((bus.adr & 1) == 0,
                bus.dat_r.eq(Cat(phy.rx_data, phy.rx_ready, phy.rx_error))
            ).Elif((bus.adr & 1) == 1,
                bus.dat_r.eq(Cat(Replicate(0, 9), phy.tx_ack))
            ),

            phy.rx_ack.eq(0),
            phy.tx_ready.eq(0),

            bus.ack.eq(0),
            If(bus.cyc & bus.stb & ~bus.ack,
                bus.ack.eq(1),
                If(bus.we,
                    If((bus.adr & 1) == 0,
                        phy.rx_ack.eq(bus.dat_w[8])
                    ).Elif((bus.adr & 1) == 1,
                        phy.tx_data.eq(bus.dat_w[:8]),
                        phy.tx_ready.eq(bus.dat_w[8])
                    )
                )
            )
        ]
<% end %>

Note how the strobe bits of the PHY (`rx_ack` and `tx_ready`) are assigned zero by default;
this ensures that they are asserted for exactly one cycle after a write transaction that
has the corresponding bits set.

### SoC interconnect

The last part of the SoC is the one that brings it all together and in the darkness binds them.
It consists of the system reset generator and the Wishbone interconnect:

<% highlight_code 'python' do %>
def mem_decoder(address):
    return lambda a: (a << 2) & 0xf0000000 == address


class SimpleSoC(Module):
    def __init__(self, platform, code):
        clk12  = platform.request("clk12")
        serial = platform.request("serial")

        self.clock_domains.cd_por = ClockDomain(reset_less=True)
        self.clock_domains.cd_sys = ClockDomain()
        reset_delay = Signal(10, reset=1023)
        self.comb += [
            self.cd_por.clk.eq(clk12),
            self.cd_sys.clk.eq(clk12),
            self.cd_sys.rst.eq(reset_delay != 0)
        ]
        self.sync.por += \
            If(reset_delay != 0,
                reset_delay.eq(reset_delay - 1)
            )

        self.submodules.cpu = MOR1KX(platform, 0x00000000)
        self.submodules.ram = wishbone.SRAM(0x100, init=code)
        self.submodules.leds = SimpleGPIO([
            platform.request("user_led") for _ in range(8)
        ])
        self.submodules.uart = SimpleUART(serial, 12000000, 9600)
        self.submodules.wishbonecon = wishbone.InterconnectShared(
            masters=[
                self.cpu.ibus,
                self.cpu.dbus
            ],
            slaves=[
                (mem_decoder(0x00000000), self.ram.bus),
                (mem_decoder(0x10000000), self.leds.bus),
                (mem_decoder(0x20000000), self.uart.bus),
            ],
            register=True)
<% end %>

The reset generator is necessary because, while uploading a bitstream into the FPGA performs
the basic functions of a reset---it initializes the registers to the known values and then
ungates the clock among all other I/O pins---it does not do the latter deterministically, and
in practice, while it would still work for simple designs, large one such as this SoC will
break.

The Wishbone interconnect in this case includes an arbiter and a decoder, connected back-to-back
inside of the MiSoC built-in `wishbone.InterconnectShared` module.
The arbiter is necessary because the CPU has separate instruction and data buses; since we have
only one SRAM block used for both instructions and data, if we want to be able to perform any
loads and stores to RAM, it should be shared.
The decoder allows us to simplify peripherals, as they can be ignorant of the exact address
they are mapped at.

## Software

The software I wrote as an example is very straightforward, and perhaps representative of
the inner desires of us all: you can say anything to it through UART, and it will scream
in response. It is implemented in OR1K assembly:

<% highlight_code 'text' do %>
    l.xor   r0, r0, r0
    l.movhi r1, 0x1000
    l.movhi r2, 0x2000
    l.ori   r10, r0, 1
0:  l.lwz   r3, 0(r2)
    l.andi  r4, r3, 0x100
    l.sfeqi r4, 0
    l.bf    0b
    l.sw    0(r1), r10
    l.ori   r11, r0, 0x100
    l.sw    0(r2), r11
    l.ori   r12, r0, 16
1:  l.ori   r11, r0, 0x141
    l.sw    4(r2), r11
2:  l.lwz   r11, 4(r2)
    l.andi  r11, r11, 0x200
    l.sfeqi r11, 0
    l.bf    2b
    l.addi  r12, r12, -1
    l.sfnei r12, 0
    l.bf    1b
    l.sw    0(r1), r0
    l.j     0b
<% end %>

Note the absence of delay slots; the `PRONTO_ESPRESSO` pipeline used in our mor1kx instantiation
does not include those, unlike the two other ones.

An interesting exercise would be to implement an UART bootloader, such that compiled programs
would no longer require rebuilding the bitstream, which takes about a minute.

# Demonstration

<iframe src="https://vine.co/v/5wuvL3EXjha/embed/simple" width="600" height="600" frameborder="0"></iframe><script src="https://platform.vine.co/static/scripts/embed.js"></script>
