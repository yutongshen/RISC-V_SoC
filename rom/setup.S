#define pmacfg0   0x3c0
#define pmacfg1   0x3c1
#define pmacfg2   0x3c2
#define pmacfg3   0x3c3
#define pmaaddr15 0x3df
#define ENABLE_DDR_CACHE
// #define ENABLE_UART_IRQ

.section .text
.align 2
.globl _start
_start:
#ifdef ENABLE_UART_IRQ
  li t0, 0x10000000;
  li t1, 7;
  sw t1, 0x10(t0);
#endif
  csrr a0, mhartid;
  la a1, _DTB;
  # check RV64/32
  csrr t0, misa;
  bltz t0, rv64;
#ifdef ENABLE_DDR_CACHE
  # set DDR cacheable
  li t0, 0x1a000000;
  csrw pmacfg3, t0;
  lw t0, dram_base;
  lw t1, dram_size;
  addi t1, t1, -1;
  srli t1, t1, 1;
  or t0, t0, t1;
  srli t0, t0, 2;
  csrw pmaaddr15, t0;
#endif
  
  lw ra, dram_base;
  ret;
rv64:
#ifdef ENABLE_DDR_CACHE
  # set DDR cacheable
  li t0, 0x1a00000000000000;
  csrw pmacfg2, t0;
  ld t0, dram_base;
  ld t1, dram_size;
  addi t1, t1, -1;
  srli t1, t1, 1;
  or t0, t0, t1;
  srli t0, t0, 2;
  csrw pmaaddr15, t0;
#endif
  
  ld ra, dram_base;
  ret;
.align 3
dram_base:
  .dword 0x00020000
dram_size:
  .dword 0x00020000
