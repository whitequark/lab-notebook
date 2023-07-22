#![no_std]
#![no_main]

use core::{ptr, sync};

use defmt::{*, unreachable};
use {defmt_rtt as _, panic_probe as _};

use stm32_metapac as pac;

// -8<-8<- configuration
const GPIO_REGS: pac::gpio::Gpio = pac::GPIOC;
const GPIO_LED: usize = 5;
// -8<-8<- end of config

// The DMA registers are laid out in memory like this:
// - CH(n+0)_CR   <- control register (R/O when EN=1, except for EN)
// - CH(n+0)_NDTR <- length register  (R/O when EN=1)
// - CH(n+0)_PAR  <- peripheral addr  (R/W when EN=1!)
// - CH(n+0)_MAR  <- memory addr      (R/W when EN=1!)
// - CH(n+1)_CR
// - CH(n+1)_...
//
// This means that a single DMA transfer to the DMA registers themselves can set
// up the transfer (without setting EN=1) for CH(n+0)..CH(n+k-1) and then trigger
// CH(n+k), but it cannot trigger the transfers it just set up; these should be
// triggered by a previously configured CH(n+k) channel that writes the same data
// over except now with EN=1.
//
// To work around this limitation it helps to see the DMA channel as having three
// distinct phases it is circularly traversing:
//  1. Setup phase:    EN=0; configuration is being written to the channel
//  2. Transfer phase: EN=1, NDTR>0; data is being transferred
//  3. Dormant phase:  EN=1, NDTR=0; transfer has finished but the channel is locked
// Two of the three phases (with EN=1) make it impossible to reconfigure the channel
// directly, instead requiring EN bit to be reset. For a system made out of DMA
// channels to return to its initial state, it needs at least three channels,
// so that the one channel in the transfer phase can advance the state of the system.

const DMA1_CHX_BASE: *mut u32 = 0x4002_0008 as *mut u32;

macro_rules! dma_control {
    ( en  $(| $ctrl:tt)* ) => { (1<<0) | dma_control!($($ctrl)*) };
    ( m2m $(| $ctrl:tt)* ) => { (1<<4) | (1<<14) | dma_control!($($ctrl)*) };
    ( m2p $(| $ctrl:tt)* ) => { (1<<4) | dma_control!($($ctrl)*) };
    ( p2m $(| $ctrl:tt)* ) => { dma_control!($($ctrl)*) };
    // CCRx: MEM2MEM=0 PL=00 MSIZE=PSIZE=10 MINC=1 PINC=1 CIRC=0 DIR=0 *IE=000 EN=0
    () => { 0b0_00_10_10_1_1_0_0_000_0u32 }
}

macro_rules! dma_configs {
    [
        $( $n:literal: ($($ctrl:tt)|+, len: $len:expr, dst: $dst:expr, src: $src:expr) ),*
        $( , )?
    ] => {
        [
            $(
                // CCRx
                dma_control!($($ctrl)|+),
                // CNDTRx
                $len as *const u32 as u32,
                // CPARx
                $dst as *mut   u32 as u32,
                // CMARx
                $src as *const u32 as u32,
                // reserved
                0u32
            ),*
        ]
    }
}

const fn dma1_chx(number: usize) -> *mut u32 {
    DMA1_CHX_BASE.wrapping_add(5 * (number - 1))
}

unsafe fn dma1_setup_ch(first: usize, config: &[u32]) {
    sync::atomic::fence(sync::atomic::Ordering::SeqCst);
    for offset in 0..config.len() {
        ptr::write_volatile(dma1_chx(first).offset(offset as isize), config[offset]);
    }
}

#[cortex_m_rt::entry]
fn main() -> ! {
    info!("running!");

    // Configure SYSCFG to make TIM6 trigger DMA1_CH3. This is STM32F302R8Tx specific.
    pac::RCC.apb2enr().modify(|r| r.set_syscfgen(true));
    pac::SYSCFG.cfgr1().modify(|r|
        r.set_tim6_dac1_ch1_dma_rmp(pac::syscfg::vals::Tim6Dac1Ch1DmaRmp(1)));

    pac::RCC.ahbenr().modify(|r| r.set_gpiocen(true));
    GPIO_REGS.moder().modify(|r| r.set_moder(GPIO_LED, pac::gpio::vals::Moder::OUTPUT));
    let gpio_bsrr = GPIO_REGS.bsrr().as_ptr() as *mut u32;
    let gpio_setb = 1u32 << GPIO_LED;
    let gpio_clrb = gpio_setb << 16;

    let mut dma1_config_0 = [0u32; 5 * 1];

    let mut dma1_config_a0 = [0u32; 5 * 5];
    let mut dma1_config_a1 = [0u32; 5 * 5];
    let mut dma1_config_a2 = [0u32; 5 * 2];

    let mut dma1_config_b0 = [0u32; 5 * 5];
    let mut dma1_config_b1 = [0u32; 5 * 5];
    let mut dma1_config_b2 = [0u32; 5 * 2];

    dma1_config_0 = dma_configs![
        3: (m2p,    len:                    1, dst: dma1_chx(4), src: &dma_control!(m2m|en)),
    ];

    dma1_config_a0 = dma_configs![
        2: (m2m,    len:                    1, dst: gpio_bsrr,   src: &gpio_setb),
        3: (m2p|en, len:                    1, dst: dma1_chx(4), src: &dma_control!(m2m|en)),
        4: (m2m,    len: dma1_config_a1.len(), dst: dma1_chx(2), src: &dma1_config_a1),
        5: (m2m,    len: dma1_config_a2.len(), dst: dma1_chx(5), src: &dma1_config_a2),
        6: (m2m,    len: dma1_config_b0.len(), dst: dma1_chx(2), src: &dma1_config_b0),
    ];
    dma1_config_a1 = dma_configs![
        2: (m2m|en, len:                    1, dst: gpio_bsrr,   src: &gpio_setb),
        3: (m2p,    len:                    1, dst: dma1_chx(4), src: &dma_control!(m2m|en)),
        4: (m2m|en, len: dma1_config_a1.len(), dst: dma1_chx(2), src: &dma1_config_a1),
        5: (m2m|en, len: dma1_config_a2.len(), dst: dma1_chx(5), src: &dma1_config_a2),
        6: (m2m,    len: dma1_config_b0.len(), dst: dma1_chx(2), src: &dma1_config_b0),
    ];
    dma1_config_a2 = dma_configs![
        5: (m2m|en, len: dma1_config_a2.len(), dst: dma1_chx(5), src: &dma1_config_a2),
        6: (m2m|en, len: dma1_config_b0.len(), dst: dma1_chx(2), src: &dma1_config_b0),
    ];

    dma1_config_b0 = dma_configs![
        2: (m2m,    len:                    1, dst: gpio_bsrr,   src: &gpio_clrb),
        3: (m2p|en, len:                    1, dst: dma1_chx(4), src: &dma_control!(m2m|en)),
        4: (m2m,    len: dma1_config_b1.len(), dst: dma1_chx(2), src: &dma1_config_b1),
        5: (m2m,    len: dma1_config_b2.len(), dst: dma1_chx(5), src: &dma1_config_b2),
        6: (m2m,    len: dma1_config_a0.len(), dst: dma1_chx(2), src: &dma1_config_a0),
    ];
    dma1_config_b1 = dma_configs![
        2: (m2m|en, len:                    1, dst: gpio_bsrr,   src: &gpio_clrb),
        3: (m2p,    len:                    1, dst: dma1_chx(4), src: &dma_control!(m2m|en)),
        4: (m2m|en, len: dma1_config_b1.len(), dst: dma1_chx(2), src: &dma1_config_b1),
        5: (m2m|en, len: dma1_config_b2.len(), dst: dma1_chx(5), src: &dma1_config_b2),
        6: (m2m,    len: dma1_config_a0.len(), dst: dma1_chx(2), src: &dma1_config_a0),
    ];
    dma1_config_b2 = dma_configs![
        5: (m2m|en, len: dma1_config_b2.len(), dst: dma1_chx(5), src: &dma1_config_b2),
        6: (m2m|en, len: dma1_config_a0.len(), dst: dma1_chx(2), src: &dma1_config_a0),
    ];

    pac::RCC.ahbenr().modify(|r| r.set_dma1en(true));
    unsafe {
        dma1_setup_ch(3, dma1_config_0.as_ref());
        dma1_setup_ch(2, dma1_config_a0.as_ref());
    }

    pac::RCC.apb1enr().modify(|r| r.set_tim6en(true));
    pac::TIM6.psc().modify(|r| r.set_psc(8000));
    pac::TIM6.arr().modify(|r| r.set_arr(500));
    pac::TIM6.dier().modify(|r| r.set_ude(true));
    pac::TIM6.cr2().modify(|r| r.set_mms(pac::timer::vals::Mms::UPDATE));
    pac::TIM6.cr1().modify(|r| r.set_cen(true));

    cortex_m::interrupt::disable();
    cortex_m::asm::wfi();
    unreachable!()
}
