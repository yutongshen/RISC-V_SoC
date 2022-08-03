#include "mmap_soc.h"
#include "typedef.h"
#include "uart.h"
#include "spi.h"
#include "iolib.h"
#include "util.h"
#include "elf_loader.h"

__U32 main(void) {
    __U8   __sd_type;
    __BPB  __bpb;
    __FILE __file;
    __file.bpb = &__bpb;

    *PLIC_INT_TYPE_32P = -1;
    __uart_init();
    __puts("[BROM] UART init done");
#ifndef FAKE_SD
    __puts("[BROM] SD card init");
    __sd_init(&__sd_type);
#endif
    __puts("[BROM] FAT BPB init");
    __fat_bpb_init(&__bpb);

    if (*CFGREG_RSVREG0_32P == 0) {
        // load bbl
        __puts("[BROM] load bbl");
        __fopen(&__file, "boot.bin");
        __elf_loader(&__file);

        // load rootfs
        __puts("[BROM] load rootfs");
        __fopen(&__file, "riscv.fs");
        __fread(&__file, (void *) 0x90000000, __file.size);

        *CFGREG_RSVREG0_32P = 0xcafecafe;
    }

    // load linux
    __puts("[BROM] load vmlinux");
    __fopen(&__file, "vmlinux");
    __elf_loader_reloc(&__file, 0x80200000);

    __puts("[BROM] boot rom init done");
    return 0;
}
