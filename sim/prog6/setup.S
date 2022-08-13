#define _test_end 0x3fffc

.section .text
.align 2
.globl _start
_start:
 li x1, 0
 li x2, 0
 li x3, 0
 li x4, 0
 li x5, 0
 li x6, 0
 li x7, 0
 li x8, 0
 li x9, 0
 li x10, 0
 li x11, 0
 li x12, 0
 li x13, 0
 li x14, 0
 li x15, 0
 li x16, 0
 li x17, 0
 li x18, 0
 li x19, 0
 li x20, 0
 li x21, 0
 li x22, 0
 li x23, 0
 li x24, 0
 li x25, 0
 li x26, 0
 li x27, 0
 li x28, 0
 li x29, 0
 li x30, 0
 li x31, 0

 /* initialize global pointer */
 la gp, _gp

init_bss:
  /* init bss section */
  la a0, __bss_start
  la a1, __bss_end-4 /* section end is actually the start of the next section */
  li a2, 0x0
  jal fill_block

init_sbss:
  /* init bss section */
  la a0, __sbss_start
  la a1, __sbss_end-4 /* section end is actually the start of the next section */
  li a2, 0x0
  jal fill_block

write_stack_pattern:
  /* init stack section */
  la a0, _stack_end  /* note the stack grows from top to bottom */
  la a1, __stack-4   /* section end is actually the start of the next section */
  li a2, 0x0
  jal fill_block

init_stack:
  /* set stack pointer */
  la sp, _stack

init_mtvec:
  la a0, trap_entry;
  csrw mtvec, a0;
  csrsi mstatus, 1<<3;

SystemInit:
  jal main;

SystemExit:
  li t0, _test_end
  li t1, 1;
  sw a0, -4(t0);
  sw t1, 0(t0);
dead_loop:
  j dead_loop

/* Fills memory blocks */
fill_block:
  bgtu a0, a1, fb_end;
  sw a2, 0(a0);
  addi a0, a0, 4;
  j fill_block;
fb_end:
  ret;

.section .text
.align 2
.globl test_func
test_func:
  li s4, 0;
  li a2, 0x400;
1:
  mv a3, a0;
  divu a0, a0, a2;
  addiw s4, s4, 1;
  bgeu a0, a2, 1b;
  remu a4, a3, a2;

  mv a0, a3;
  ret;
