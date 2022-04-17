OUTPUT_ARCH("riscv")

MEMORY {
  brom   : ORIGIN = 0x00000000, LENGTH = 0x00002000
  sysram : ORIGIN = 0x00020000, LENGTH = 0x00020000
}

ENTRY(_start)

SECTIONS {
  .text : {
    __text_start = .;
    setup.o(.text);
    main.o(.text);
    *(.text);
    *(.text.*);
    __text_end = .;
  } > brom

  .rodata : {
    *(.rodata)
    . = ALIGN(0x8);
  } > brom

  .data : {
    __data_paddr_start = LOADADDR(.data);
    __data_start = .;
    _DTB = .;
    rv64.o(.data)
    *(.data)
    *(.data.*)
    *(.gnu.linkonce.d.*)
    . = ALIGN(0x8);
    __data_end = .;
  } > brom

/*
  .bss : {
    __bss_start = .;
    *(.bss)
    *(.bss.*)
    *(.gnu.linkonce.b.*)
    *(COMMON)
    __bss_end = .;
  } > brom
*/

  .stack : {
    . += 0x1f000;
    _stack_end = .;
    . += 0x1000;
    _stack = .;
    __stack = _stack;
  } > sysram
}
