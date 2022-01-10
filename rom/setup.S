.section .text
.align 2
.globl _start
_start:
  csrr a0, mhartid
  la a1, _DTB
  csrr t0, misa
  bltz t0, rv64
  lw ra, dram
  ret
rv64:
  ld ra, dram
  ret
.align 3
dram:
  .dword 0x80000000
