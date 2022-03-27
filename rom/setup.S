#define pmacfg0   0x3c0
#define pmacfg1   0x3c1
#define pmacfg2   0x3c2
#define pmacfg3   0x3c3
#define pmaaddr15 0x3df
#define ENABLE_CACHE
// #define ENABLE_UART_IRQ

.section .text
.align 2
.globl _start
_start:
    li x1, 0;
    li x2, 0;
    li x3, 0;
    li x4, 0;
    li x5, 0;
    li x6, 0;
    li x7, 0;
    li x8, 0;
    li x9, 0;
    li x10, 0;
    li x11, 0;
    li x12, 0;
    li x13, 0;
    li x14, 0;
    li x15, 0;
    li x16, 0;
    li x17, 0;
    li x18, 0;
    li x19, 0;
    li x20, 0;
    li x21, 0;
    li x22, 0;
    li x23, 0;
    li x24, 0;
    li x25, 0;
    li x26, 0;
    li x27, 0;
    li x28, 0;
    li x29, 0;
    li x30, 0;
    li x31, 0;
   
fill_stack:
    ;/* init stack section */
    la a0, _stack_end;  /* note the stack grows from top to bottom */
    la a1, __stack-4;   /* section end is actually the start of the next section */
    li a2, 0x0;
    jal fill_block;

init_stack:
    ;/* set stack pointer */
    la sp, _stack;

init_system:
#ifdef ENABLE_UART_IRQ
    li t0, 0x10000000;
    li t1, 7;
    sw t1, 0x10(t0);
#endif
    # check RV64/32
    csrr t0, misa;
    bltz t0, rv64;
#ifdef ENABLE_CACHE
    # set DDR cacheable
    li t0, 0x1a000000;
    csrw pmacfg3, t0;
    lw t0, sysram_base;
    lw t1, sysram_size;
    addi t1, t1, -1;
    srli t1, t1, 1;
    or t0, t0, t1;
    srli t0, t0, 2;
    csrw pmaaddr15, t0;
#endif
    lw s0, sysram_base;
    j goto_main;
rv64:
#ifdef ENABLE_CACHE
    # set DDR cacheable
    li t0, 0x1a00000000000000;
    csrw pmacfg2, t0;
    ld t0, sysram_base;
    ld t1, sysram_size;
    addi t1, t1, -1;
    srli t1, t1, 1;
    or t0, t0, t1;
    srli t0, t0, 2;
    csrw pmaaddr15, t0;
#endif
    ld s0, sysram_base;

goto_main:
#ifdef REAL_ROM
    jal main;
#endif
    csrr a0, mhartid;
    la a1, _DTB;
    jr s0;

dead_loop:
  j dead_loop

;/* Fills memory blocks */
fill_block:
    bgtu a0, a1, fb_end;
    sw a2, 0(a0);
    addi a0, a0, 4;
    j fill_block;
fb_end:
    ret;


#ifndef JUMP_DDR
.align 3
sysram_base:
  .dword 0x00020000
sysram_size:
  .dword 0x00020000
#else
.align 3
sysram_base:
  .dword 0x80000000
sysram_size:
  .dword 0x80000000
#endif
