OUTPUT_ARCH("riscv")

MEMORY {
  brom : ORIGIN = 0x00000000, LENGTH = 0x00001000
}

ENTRY(_start)

SECTIONS {
  .text : {
    *(.text);
  } > brom
}
