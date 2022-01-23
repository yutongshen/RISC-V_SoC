OUTPUT_ARCH("riscv")

ENTRY(_start)

SECTIONS {
  . = 0x00020000;

  .text : {
    __text_start = .;
    setup.o(.text);
    main.o(.text);
    *(.text);
    *(.text.*);
    __text_end = .;
  }

  .init : {
    KEEP (*(.init))
  }

  .fini : {
    KEEP (*(.fini))
  }

  .rodata : {
    __rodata_start = .;
    *(.rodata)
    *(.rodata.*)
    *(.gnu.linkonce.r.*)
    __rodata_end = .;
  }

  .sbss : {
    __sbss_start = .;
    *(.sbss)
    *(.sbss.*)
    *(.gnu.linkonce.sb.*)
    __sbss_end = .;
  }

  .sdata : {
    __sdata_paddr_start = LOADADDR(.sdata);
    __sdata_start = .;
    _gp = . + 0x800;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
    __sdata_end = .;
  }

  .data : {
    . = ALIGN(4);
    __data_paddr_start = LOADADDR(.data);
    __data_start = .;
    *(.data)
    *(.data.*)
    *(.gnu.linkonce.d.*)
    __data_end = .;
  }

  .bss : {
    . = ALIGN(4);
    __bss_start = .;
    *(.bss)
    *(.bss.*)
    *(.gnu.linkonce.b.*)
    *(COMMON)
    . = ALIGN(4);
    __bss_end = .;
  }

  . = ALIGN(0x1000);

  .stack : {
    . = ALIGN(4);
    _stack_end = .;
    . += 0x1000;
    _stack = .;
    __stack = _stack;
  }
}
