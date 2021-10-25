OUTPUT_ARCH("riscv")

_STACK_SIZE = DEFINED(_STACK_SIZE) ? _STACK_SIZE : 0x1000;
_TEST_SIZE  = DEFINED(_TEST_SIZE)  ? _TEST_SIZE  : 0x1000;

/*****************************************************************************
 * Define memory layout
 ****************************************************************************/
/* Specify the default entry point to the program */
MEMORY {
  sram_0 : ORIGIN = 0x00000000, LENGTH = 0x00010000
  sram_1 : ORIGIN = 0x00010000, LENGTH = 0x00010000
}

ENTRY(_start)

/*****************************************************************************
 * Define the sections, and where they are mapped in memory 
 ****************************************************************************/
SECTIONS {
  .text : {
    __text_start = .;
    setup.o(.text);
    main.o(.text);
    *(.text);
    *(.text.*);
    __text_end = .;
  } > sram_0

  .init : {
    KEEP (*(.init))
  } > sram_0

  .fini : {
    KEEP (*(.fini))
  } > sram_0

  .rodata : {
    __rodata_start = .;
    *(.rodata)
    *(.rodata.*)
    *(.gnu.linkonce.r.*)
    __rodata_end = .;
  } > sram_0

  . = ALIGN(0x1000);
  _test : {
    . = ALIGN(4);
    _dmem_start = .;
    _test_start = .;
    . += _TEST_SIZE;
    _test_end = .;
  } > sram_1

  .sbss : {
    __sbss_start = .;
    *(.sbss)
    *(.sbss.*)
    *(.gnu.linkonce.sb.*)
    __sbss_end = .;
  } > sram_1

  .sdata : {
    __sdata_paddr_start = LOADADDR(.sdata);
    __sdata_start = .;
    _gp = . + 0x800;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
    __sdata_end = .;
  } > sram_1

  .data : {
    . = ALIGN(4);
    __data_paddr_start = LOADADDR(.data);
    __data_start = .;
    *(.data)
    *(.data.*)
    *(.gnu.linkonce.d.*)
    __data_end = .;
  } > sram_1

  .bss : {
    . = ALIGN(4);
    __bss_start = .;
    *(.bss)
    *(.bss.*)
    *(.gnu.linkonce.b.*)
    *(COMMON)
    . = ALIGN(4);
    __bss_end = .;
  } > sram_1

  .stack : {
    . = ALIGN(4);
    _stack_end = .;
    . += _STACK_SIZE;
    _stack = .;
    __stack = _stack;
  } > sram_1
}
