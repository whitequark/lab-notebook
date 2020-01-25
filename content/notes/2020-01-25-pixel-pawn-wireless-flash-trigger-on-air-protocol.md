---
kind: article
created_at: 2020-01-25 18:43:35 +0000
title: "Pixel Pawn wireless flash trigger on-air protocol"
tags:
  - reverse engineering
  - radio frequency
---

In this note I describe the on-air protocol of Pixel Pawn wireless flash trigger.

<!-- more -->

* table of contents
{:toc}

# Tools and methods

To interact with the flash trigger, I used [Lime Microsystems LimeSDR Mini](https://limemicro.com/products/boards/limesdr-mini/). To determine the center frequency of transmissions, I used [SDRAngel](https://github.com/f4exb/sdrangel) in spectrogram mode, knowing that the device is advertised to work in the 2.4 GHz range. To determine bit rate, modulation, and packet format, I used [Universal Radio Hacker](https://github.com/jopohl/urh) as described in its documentation. To understand commands better, I used the [Glasgow debug tool](https://github.com/GlasgowEmbedded/glasgow)'s `radio-nrf24l` applet in transmit and receive mode as described [below](#communication).

# Framing

Modulation GMSK, data rate 250 kbps, on-air time 356.00 µs, of which settling time 60.75 µs, transmission time 295.25 µs. Packet format:

    1010101010101010101010101010101010101100001101010111111001001110101-1100000
    <                        67 fixed bits                            > < CMD >

Each button press produces a burst of 5-10 packets. However, holding a button or being in an active mode only produces a single packet every few hundred ms.

# Channels

The channel to frequency mapping is as follows:

| Channel | Frequency |
| ------- | --------- |
| `HHHH`  |  2.4020   |
| `HHHL`  |  2.4065   |
| `HHLH`  |  2.4100   |
| `HHLL`  |  2.4185   |
| `HLHH`  |  2.4210   |
| `HLHL`  |  2.4295   |
| `HLLH`  |  2.4355   |
| `HLLL`  |  2.4385   |
| `LHHH`  |  2.4450   |
| `LHHL`  |  2.4465   |
| `LHLH`  |  2.4515   |
| `LHLL`  |  2.4600   |
| `LLHH`  |  2.4620   |
| `LLHL`  |  2.4695   |
| `LLLH`  |  2.4710   |
| `LLLL`  |  2.4770   |
{: style="width: 200px"}

# Commands

Commands are specified in 7 last bits of the packet.

| Command | Encoding | Condition |
| ------- | -------- | --------- |
| wakeup | `1100000` | power on, mode switch, other command prefix |
| autofocus | `0001111` | half press |
| normal release | `0010100` | mode 1 press |
| shutter open | `0010000` | mode 2 first press |
| shutter close | `0011011` | mode 2 second press |
| timer start | `1100100` | mode 3 first press |
| timer cancel | `0011011` | mode 3 second press |

The preamble can be quite short, as few as 2 octets long. However, commands that are not preceded by `1100000` will be often not recognized, regardless of preamble length.

# Communication

Considering the framing, any appropriately encoded octet sequence that includes the following one will trigger a command:

    aa aa aa aa b0 d5 f9 3a (80|CMD)

An elegant way to emulate a transmitter is to use an nRF24L01(+) in nRF2401 compatible mode with 4 address bytes set to `aa aa aa aa` and data bytes set to `b0 d5 f9 3a (80|CMD)`. However, in a pinch, just transmitting this as a kind of in-band signal in any other packet framing also works just fine.

Similarly, an elegant way to emulate a receiver is to use an nRF24L01(+) in nRF2401 compatible mode with 4 address bytes set to `b0 d5 f9 3a`. (It uses the same `aa` preamble, and synchronizes to address bytes.)

nRF24L01(+) only support channel frequencies of integer MHz; this flash trigger uses some channels of half-integer MHz, e.g. 2.4465. The nRF24L01(+) is promiscuous enough that it easily and reliably locks to transmissions on half-integer MHz channels. However, the flash trigger receiver configured to use such a channel ignores any transmissions half MHz apart. This means that an nRF24L01(+) can only transmit on half of the defined channels.

One could notice that nRF24L01(+) transmits with its PLL in open loop, and the frequency of said PLL drifts down. By issuing the `REUSE_TX_PL` command and pulsing CE for a few ms, it will transmit the last command in a loop while drifting down, and eventually hitting the right frequency. This, however, is a rather disgusting workaround.
