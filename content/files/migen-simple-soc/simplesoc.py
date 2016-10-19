from migen import *
from migen.build.generic_platform import *
from migen.build.platforms import ice40_hx8k_b_evn

from misoc.interconnect import wishbone

from mor1kx import MOR1KX
from uart import UART


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


if __name__ == "__main__":
    import subprocess, struct

    subprocess.call(["or1k-none-as",
                     "program.s", "-o", "build/program.o"])
    subprocess.call(["or1k-none-objcopy", "-O", "binary",
                     "build/program.o", "build/program.bin"])
    with open("build/program.bin", "rb") as f:
        code = [v for t in struct.iter_unpack('>L', f.read()) for v in t]

    plat = ice40_hx8k_b_evn.Platform()
    plat.build(SimpleSoC(plat, code))
    plat.create_programmer().load_bitstream("build/top.bin")
