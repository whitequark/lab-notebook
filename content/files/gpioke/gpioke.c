/*
 * See:
 * - http://lxr.free-electrons.com/source/drivers/mfd/lpc_ich.c
 * - http://lxr.free-electrons.com/source/drivers/gpio/gpio-ich.c
 * - Intel document 252516-001 (ICH5)
 * - Intel document 330550-002 (9 Series PCH)
 * - Intel documents 332690-004 and 332691-002EN (100 Series PCH)
 */

#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <pci/pci.h>
#include <sys/io.h>
#include <sys/mman.h>
#include <sys/errno.h>

/*
 * GPIO register offsets in GPIO I/O space.
 * Each chunk of 32 GPIOs is manipulated via its own USE_SELx, IO_SELx, and
 * LVLx registers.  Logic in the read/write functions takes a register and
 * an absolute bit number and determines the proper register offset and bit
 * number in that register.  For example, to read the value of GPIO bit 50
 * the code would access offset ichx_regs[2(=GPIO_LVL)][1(=50/32)],
 * bit 18 (50%32).
 */
enum GPIO_REG {
  GPIO_USE_SEL = 0,
  GPIO_IO_SEL,
  GPIO_LVL,
};

static const uint8_t ichx_regs[4][3] = {
  {0x00, 0x30, 0x40},     /* USE_SEL[1-3] offsets */
  {0x04, 0x34, 0x44},     /* IO_SEL[1-3] offsets */
  {0x0c, 0x38, 0x48},     /* LVL[1-3] offsets */
};

/*
 * Generic PCI configuration space registers.
 */
#define REG_VENDOR          0x00
#define REG_DEVICE          0x04

/*
 * D31:F0 configuration space registers.
 */
#define REG_ICH0_GPIOBASE   0x58
#define REG_ICH0_GC         0x5c

#define REG_ICH6_GPIOBASE   0x48
#define REG_ICH6_GC         0x4c

#define REG_ICHx_GC_EN      0x10
#define REG_ICHx_GC_GLE     0x01

/*
 * D31:F1 configuration space registers.
 */
#define REG_P2SB_BAR        0x10
#define REG_P2SB_BARH       0x14
#define REG_P2SB_CTRL       0xe0

#define REG_P2SB_CTRL_HIDE  0x0100

/*
 * P2SB private registers.
 */
#define P2SB_PORTID_SHIFT   16
#define P2SB_PORT_GPIO3     0xAC
#define P2SB_PORT_GPIO2     0xAD
#define P2SB_PORT_GPIO1     0xAE
#define P2SB_PORT_GPIO0     0xAF

/*
 * GPIO sideband registers.
 */
#define REG_PCH_GPIO_FAMBAR 0x8
#define REG_PCH_GPIO_PADBAR 0xc

#define REG_PCH_GPIO_PAD_OWN      0x20
#define REG_PCH_GPIO_HOSTSW_OWN   0xd0
#define REG_PCH_GPIO_GPI_IS       0x100
#define REG_PCH_GPIO_GPI_IE       0x120
#define REG_PCH_GPIO_GPE_STS      0x140
#define REG_PCH_GPIO_GPE_EN       0x160
#define REG_PCH_GPIO_SMI_STS      0x184
#define REG_PCH_GPIO_SMI_EN       0x1a4
#define REG_PCH_GPIO_NMI_STS      0x1c4
#define REG_PCH_GPIO_NMI_EN       0x1e4

#define REG_PCH_GPIO_DW0_PMODE    0x1600
#define REG_PCH_GPIO_DW0_RXDIS    0x0200
#define REG_PCH_GPIO_DW0_TXDIS    0x0100
#define REG_PCH_GPIO_DW0_RXSTATE  0x0002
#define REG_PCH_GPIO_DW0_TXSTATE  0x0001

#define REG_PCH_GPIO_DW1_TERM_NONE    0x0
#define REG_PCH_GPIO_DW1_TERM_5K_PD   0x2
#define REG_PCH_GPIO_DW1_TERM_20K_PD  0x4
#define REG_PCH_GPIO_DW1_TERM_5K_PU   0xa
#define REG_PCH_GPIO_DW1_TERM_20K_PU  0xc
#define REG_PCH_GPIO_DW1_TERM_NATIVE  0xf

/*
 * Helper functions.
 */

#define MSG(...) do { \
    fprintf(stderr, "[*] " __VA_ARGS__); fprintf(stderr, "\n"); \
  } while(0)
#define ERR(...) do { \
    fprintf(stderr, "[-] " __VA_ARGS__); fprintf(stderr, "\n"); \
    return 1; \
  } while(0)
#define DIE(...) do { *fatal = 1; ERR(__VA_ARGS__) } while(0)

struct pci_dev *pci_find_dev(struct pci_access *pci, uint8_t bus, uint8_t dev, uint8_t func) {
  for(struct pci_dev *it = pci->devices; it; it = it->next) {
    if(it->bus == bus && it->dev == dev && it->func == func) return it;
  }
  return NULL;
}

/*
 * Finally, our main logic!
 */

int try_ich(struct pci_access *pci,
            uint16_t reg_gpiobase, uint16_t reg_gc,
            const char *desc, int *fatal) {
  MSG("Checking for a %s system", desc);

  struct pci_dev *d31f0 = pci_find_dev(pci, 0, 31, 0);
  uint32_t gpiobase = pci_read_long(d31f0, reg_gpiobase);
  uint8_t gc = pci_read_byte(d31f0, reg_gc);
  MSG("GPIOBASE=%08x, GC=%02x", gpiobase, gc);

  if(gpiobase == 0xffffffff) {
    *fatal = 1;
    ERR("Cannot read GPIOBASE, are you running me as root?");
  } else if(gpiobase == 0) {
    ERR("GPIOBASE not implemented at %04x", reg_gpiobase);
  } else if(!(gpiobase & 1)) {
    *fatal = 1;
    ERR("GPIOBASE is not an I/O BAR");
  }

  if(!(gpiobase & 0xfffc)) {
    const uint32_t DEFAULT_GPIOBASE = 0x0480;

    MSG("GPIOBASE is not configured, setting to %08x and hoping this works", DEFAULT_GPIOBASE);
    pci_write_long(d31f0, reg_gpiobase, DEFAULT_GPIOBASE);
    gpiobase = pci_read_long(d31f0, reg_gpiobase);
    if((gpiobase & 0xfffc) != DEFAULT_GPIOBASE) {
      ERR("Cannot set GPIOBASE");
    }
  }

  MSG("GPIO decoding is %s", (gc & REG_ICHx_GC_EN) ? "enabled" : "disabled");
  MSG("GPIO lockdown is %s", (gc & REG_ICHx_GC_GLE) ? "enabled" : "disabled");

  if(!(gc & REG_ICHx_GC_EN)) {
    MSG("Enabling GPIO decoding");
    pci_write_byte(d31f0, reg_gc, gc | REG_ICHx_GC_EN);
    gc = pci_read_byte(d31f0, reg_gc);
    if(!(gc & REG_ICHx_GC_EN)) {
      ERR("Cannot enable GPIO decoding");
    }
  }

  gpiobase &= 0xfffc;
  if(ioperm(gpiobase, 128, 1) == -1) {
    ERR("Cannot access I/O ports %04x:%04x", gpiobase, gpiobase + 128);
  }

  for(int n = 1; n < 3; n++) {
    MSG("USE_SEL%d=%08x", n, inl(gpiobase + ichx_regs[GPIO_USE_SEL][n]));
    MSG("IO_SEL%d=%08x", n, inl(gpiobase + ichx_regs[GPIO_IO_SEL][n]));
    MSG("LVL%d=%08x", n, inl(gpiobase + ichx_regs[GPIO_LVL][n]));
  }

  return 0;
}

int get_pch_sbreg_addr(struct pci_access *pci, pciaddr_t *sbreg_addr) {
  MSG("Checking for a Series 10 PCH system");

  struct pci_dev *d31f1 = pci_get_dev(pci, 0, 0, 31, 1);
  pci_fill_info(d31f1, PCI_FILL_IDENT);
  if(d31f1->vendor_id == 0xffff) {
    MSG("Cannot find D31:F1, assuming it is hidden by firmware");

    uint32_t p2sb_ctrl = pci_read_long(d31f1, REG_P2SB_CTRL);
    MSG("P2SB_CTRL=%02x", p2sb_ctrl);
    if(!(p2sb_ctrl & REG_P2SB_CTRL_HIDE)) {
      ERR("D31:F1 is hidden but P2SB_E1 is not 0xff, bailing out");
    }

    MSG("Unhiding P2SB");
    pci_write_long(d31f1, REG_P2SB_CTRL, p2sb_ctrl & ~REG_P2SB_CTRL_HIDE);

    p2sb_ctrl = pci_read_long(d31f1, REG_P2SB_CTRL);
    MSG("P2SB_CTRL=%02x", p2sb_ctrl);
    if(p2sb_ctrl & REG_P2SB_CTRL_HIDE) {
      ERR("Cannot unhide PS2B");
    }

    pci_fill_info(d31f1, PCI_FILL_RESCAN | PCI_FILL_IDENT);
    if(d31f1->vendor_id == 0xffff) {
      ERR("P2SB unhidden but does not enumerate, bailing out");
    }
  }

  pci_fill_info(d31f1, PCI_FILL_RESCAN | PCI_FILL_IDENT | PCI_FILL_BASES);
  if(d31f1->vendor_id != 0x8086) {
    ERR("Vendor of D31:F1 is not Intel");
  } else if((uint32_t)d31f1->base_addr[0] == 0xffffffff) {
    ERR("SBREG_BAR is not implemented in D31:F1");
  }

  *sbreg_addr = d31f1->base_addr[0] &~ 0xf;
  MSG("SBREG_ADDR=%08lx", *sbreg_addr);

  MSG("Hiding P2SB again");
  uint32_t p2sb_ctrl = pci_read_long(d31f1, REG_P2SB_CTRL);
  pci_write_long(d31f1, REG_P2SB_CTRL, p2sb_ctrl | REG_P2SB_CTRL_HIDE);

  pci_fill_info(d31f1, PCI_FILL_RESCAN | PCI_FILL_IDENT);
  if(d31f1->vendor_id != 0xffff) {
    ERR("Cannot hide P2SB");
  }

  return 0;
}

uint32_t sideband_read(void *sbmap, uint8_t port, uint16_t reg) {
  uintptr_t addr = ((uintptr_t)sbmap + (port << P2SB_PORTID_SHIFT) + reg);
  return *((volatile uint32_t *)addr);
}

int try_pch(struct pci_access *pci) {
  pciaddr_t sbreg_addr;
  if(get_pch_sbreg_addr(pci, &sbreg_addr)) {
    MSG("Re-enumerating PCI devices will probably crash the system");
    ERR("Probing Series 100 PCH failed");
  }

  int memfd = open("/dev/mem", O_RDWR);
  if(memfd == -1) {
    ERR("Cannot open /dev/mem");
  }

  void *sbmap = mmap((void*)sbreg_addr, 1<<24, PROT_READ|PROT_WRITE, MAP_SHARED,
                     memfd, sbreg_addr);
  if(sbmap == MAP_FAILED) {
    if(errno == EPERM) {
      // The requirement might be relaxed to CONFIG_IO_DEVMEM_STRICT=n, but I'm not sure.
      MSG("Is your kernel configured with CONFIG_DEVMEM_STRICT=n?");
    }
    ERR("Cannot map SBREG");
  }

  close(memfd);

  for(unsigned port = 0; port < 4; port++) {
    uint16_t port_id = P2SB_PORT_GPIO0 - port;
    uint32_t padbar = sideband_read(sbmap, port_id, REG_PCH_GPIO_PADBAR);
    MSG("GPIO%d_PADBAR=%x", port, padbar);

    for(unsigned pad = 0; pad < 32; pad++) {
      uint32_t dw0 = sideband_read(sbmap, port_id, padbar + pad * 8);
      uint32_t dw1 = sideband_read(sbmap, port_id, padbar + pad * 8 + 4);
      if(dw1 == 0) {
        // Not documented as such, but appears to be a reliable last pad marker.
        break;
      }

      const char *state = "???", *rxstate = "", *txstate = "";
      if((dw0 & REG_PCH_GPIO_DW0_PMODE) != 0) {
        state = "Native";
      } else if((dw0 & REG_PCH_GPIO_DW0_TXDIS) != 0 &&
                (dw0 & REG_PCH_GPIO_DW0_RXDIS) != 0) {
        state = "Off";
      } else {
        state = "GPIO";
        if((dw0 & REG_PCH_GPIO_DW0_RXDIS) == 0) {
          if((dw0 & REG_PCH_GPIO_DW0_RXSTATE) != 0) {
            rxstate = " InHigh";
          } else {
            rxstate = " InLow";
          }
        }

        if((dw0 & REG_PCH_GPIO_DW0_TXDIS) == 0) {
          if((dw0 & REG_PCH_GPIO_DW0_TXSTATE) != 0) {
            txstate = " OutHigh";
          } else {
            txstate = " OutLow";
          }
        }
      }

      const char *pull = "???";
      switch(dw1 >> 10) {
        case REG_PCH_GPIO_DW1_TERM_NONE:   pull = "None";   break;
        case REG_PCH_GPIO_DW1_TERM_5K_PD:  pull = "Dn5k";   break;
        case REG_PCH_GPIO_DW1_TERM_20K_PD: pull = "Dn20k";  break;
        case REG_PCH_GPIO_DW1_TERM_5K_PU:  pull = "Up5k";   break;
        case REG_PCH_GPIO_DW1_TERM_20K_PU: pull = "Up20k";  break;
        case REG_PCH_GPIO_DW1_TERM_NATIVE: pull = "Native"; break;
      }

      printf("[+] GPIO%d_PAD%d: DW0=%08x DW1=%08x State=%s%s%s Pull=%s\n",
              port, pad, dw0, dw1, state, rxstate, txstate, pull);
    }
  }

  return 0;
}

int create_pci(int method, struct pci_access **pci_out)  {
  struct pci_access *pci = pci_alloc();
  pci->method = method;
  pci_init(pci);
  pci_scan_bus(pci);

  struct pci_dev *d31f0 = pci_find_dev(pci, 0, 31, 0);
  if(!d31f0) {
    ERR("Cannot find D31:F0");
  }

  pci_fill_info(d31f0, PCI_FILL_IDENT | PCI_FILL_BASES);
  if(d31f0->vendor_id != 0x8086) {
    ERR("Vendor of D31:F0 is not Intel");
  }

  *pci_out = pci;
  return 0;
}

int main() {
  struct pci_access *pci;
  if(create_pci(PCI_ACCESS_AUTO, &pci)) {
    MSG("Is this an Intel platform?");
    return 1;
  }

  int fatal = 0;
  if(try_ich(pci, REG_ICH0_GPIOBASE, REG_ICH0_GC,
             "ICH0..ICH5", &fatal) && fatal) {
    return 1;
  } else if(try_ich(pci, REG_ICH6_GPIOBASE, REG_ICH6_GC,
                    "ICH6..ICH9 or Series 5..9 PCH", &fatal) && fatal) {
    return 1;
  } else {
    pci_cleanup(pci);

    // Letting Linux discover P2SB (and reassign its BAR) hangs the system,
    // so we need to enumerate the device bypassing it.
    if(create_pci(PCI_ACCESS_I386_TYPE1, &pci)) {
      return 1;
    }

    if(try_pch(pci)) {
      return 1;
    }
  }

  printf("[+] Done\n");
  return 0;
}
