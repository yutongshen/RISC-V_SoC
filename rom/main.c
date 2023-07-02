#include "mmap_soc.h"
#include "typedef.h"
#include "uart.h"
#include "spi.h"
#include "iolib.h"
#include "util.h"
#include "elf_loader.h"

#define die(msg) { \
    __puts(msg);   \
    while (1);     \
}

__U64 main(void) {
    __U64  __res;
    __U8   __sd_type;
    __BPB  __bpb;
    __FILE __file;
    __U8   __version[24] = "[BROM] HW ver:  ";

    __file.bpb = &__bpb;

    *PLIC_INT_TYPE_32P = -1;
    __uart_init();
    __puts("[BROM] UART init done");

    /* Show hardware version */
    __dec2hex(__version + 15, CFGREG_VER_32P[0]);
    // __dec2hex(__version + 23, CFGREG_VER_32P[1]);
    __version[23] = 0;
    __puts(__version);


#ifndef FAKE_SD
    __puts("[BROM] SD card init");
    __sd_init(&__sd_type);
#endif
    __puts("[BROM] FAT BPB init");
    if (!__fat_bpb_init(&__bpb))
        die("[BROM] FAT BPB init fail");

    // load bbl
    __puts("[BROM] load bbl");
    if (!__fopen(&__file, "bbl"))
        goto nofile;
    __res = (__U32)__elf_loader(&__file);

    // // load openSBI
    // __puts("[BROM] load openSBI");
    // if (!__fopen(&__file, "fw_payld.elf"))
    //     goto nofile;
    // __res = (__U64)__elf_loader(&__file);

    // load linux
    if (!*CFGREG_RSVREG0_32P) {
        __puts("[BROM] load vmlinux");
        if (!__fopen(&__file, "vmlinux"))
            goto nofile;
        __elf_loader_reloc(&__file, 0x80200000);
    }
    else {
        __puts("[BROM] load vmlinux.tst");
        if (!__fopen(&__file, "vmlinux.tst"))
            goto nofile;
        __elf_loader_reloc(&__file, 0x80200000);
    }

    __puts("[BROM] boot rom init done");
    return __res;
nofile:
    die("[BROM] File not found");
    return 0;
}
