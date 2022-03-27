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

    __uart_init();
#ifndef FAKE_SD
    __sd_init(&__sd_type);
#endif
    __fat_bpb_init(&__bpb);
    __fopen(&__file, "boot.bin");

    __elf_loader(&__file);

    return 0;
}
