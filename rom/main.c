#include "mmap_soc.h"
#include "typedef.h"
#include "uart.h"
#include "spi.h"
#include "iolib.h"
#include "util.h"
#include "elf_loader.h"

__U32 main(void) {
    __U32  __i;
    __U8   __sd_type;
    __BPB  __bpb;
    __FILE __file;
    __U8   __version[36] = "[BROM] HW version:  ";

    __file.bpb = &__bpb;

    *PLIC_INT_TYPE_32P = -1;
    __uart_init();
    __puts("[BROM] UART init done");

    /* Show hardware version */
    __dec2hex(__version + 19, CFGREG_VER_32P[0]);
    __dec2hex(__version + 27, CFGREG_VER_32P[1]);
    __version[35] = 0;
    __puts(__version);


#ifndef FAKE_SD
    __puts("[BROM] SD card init");
    __sd_init(&__sd_type);
#endif
    __puts("[BROM] FAT BPB init");
    __fat_bpb_init(&__bpb);

    // load bbl
    __puts("[BROM] load bbl");
    __fopen(&__file, "bbl");
    __elf_loader(&__file);

    // load linux
    __puts("[BROM] load vmlinux");
    __fopen(&__file, "vmlinux");
    __elf_loader_reloc(&__file, 0x80200000);

    __puts("[BROM] boot rom init done");
    return 0;
}
