---
kind: article
created_at: 2023-07-22 03:37:00 +0000
title: "Blinking a LED using STM32 DMA"
tags:
  - electronics
---

Every embedded developer has blinked a LED---this is both a rite of passage and a smoke test for bring-up of new hardware. Most often you do it in software. Sometimes you do it by connecting the LED directly to a peripheral.

Have you ever blinked a LED using DMA? No loops. No use of the CPU after the initial configuration. No use of the timer PWM output, either. Just the DMA peripheral, unbothered, moisturized, happy, in its lane, focused, flourishing, reconfiguring itself by writing to its own registers every time the timer ticks.

<%= highlight_code 'rust', '/files/dmablink/main.rs' %>

The timer is only used here to make the blinking observable to the human eye. You could remove it entirely and have the DMA peripheral generate high frequency waveforms, though not as quickly as the CPU could do it with the bit banding areas.

Actually, the project I designed this technique for would be using the DMA peripheral to generate composite video waveforms without any involvement of the CPU---by writing the analog level to the pins with a resistor ladder (the DAC isn't fast enough), configuring the timer for the next interval, all while retriggering itself to advance its state.

The [complete project](/files/dmablink/dmablink.zip) can be downloaded. It targets STM32F302R8, but will work on any STM32 chip with the "BDMA" type of the DMA peripheral. (There are several, and this one is the most basic.) If you have a checkout of [stm32-data](https://github.com/embassy-rs/stm32-data/), searching for `"kind": "bdma"` under `build/data/chips/` will show the devices that are compatible.
