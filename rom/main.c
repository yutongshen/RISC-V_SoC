#include "mmap_soc.h"
#include "typedef.h"
#include "uart.h"
#include "spi.h"
#include "iolib.h"
#include "util.h"

__U32 main(void) {
    __U8   __sd_type;
    __BPB  __bpb;
    __FILE __file;
    __file.bpb = &__bpb;

    __uart_init();
    __sd_init(&__sd_type);
    __fat_bpb_init(&__bpb);
    __fopen(&__file, "boot.bin");

    __fseek(&__file, 0xdc10, __SEEK_CUR);
    __fread(&__file, (void *) 0x20000, 1024);

    *TMDL_TM_SIMEND_32P = 0;

    return 0;
}
