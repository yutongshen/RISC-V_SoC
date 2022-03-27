#include "mmap_soc.h"
#include "typedef.h"
#include "iolib.h"
#include "util.h"
#include "elf_loader.h"

#define __PHNUM_MAX 8

__U8 __dma_memfill(__U8P __buff, __U32 __data, __U32 len) {
    *DMA_SRC_32P  = __data;
    *DMA_DEST_32P = (__U32) __buff;
    *DMA_LEN_32P  = len;
    
    *DMA_CON_32P  = 0;
    // Set SRC CONST / DEST INCR
    *DMA_CON_32P  |= 0x7 << 4;

    // Set SRC BYTE / DEST WORD
    *DMA_CON_32P  |= 0xa << 8;

    // Start
    *DMA_CON_32P  |= 0x1;

    while (*DMA_CON_32P & 0x80000000);
    return 1;
}

void *__elf_loader(__FILE *file) {
    __U32 i = 0, j, phnum_max;
    __EHDR64 elf;
    __PHDR64 prog_header[__PHNUM_MAX];

    __fseek(file, 0, __SEEK_BEG);
    __fread(file, &elf, sizeof(__EHDR64));

    while (i < elf.e_phnum) {
        phnum_max = __PHNUM_MAX < (elf.e_phnum - i) ? __PHNUM_MAX : elf.e_phnum;
        __fseek(file, sizeof(__PHDR64) * i + elf.e_phoff, __SEEK_BEG);
        __fread(file, &prog_header, sizeof(__PHDR64) * phnum_max);
        for (j = 0; j < phnum_max; ++j) {
            __fseek(file, prog_header[j].p_offset, __SEEK_BEG);
            __fread(file, (void *) prog_header[j].p_paddr, prog_header[j].p_filesz);

            if (prog_header[j].p_filesz < prog_header[j].p_memsz) {
                __dma_memfill((__U8P) (prog_header[j].p_paddr + prog_header[j].p_filesz), 0,
                              prog_header[j].p_memsz - prog_header[j].p_filesz);
            }
            // k = 0;
            // while (prog_header[j].p_filesz + k < prog_header[j].p_memsz) {
            //     *(__U64P) (prog_header[j].p_paddr + prog_header[j].p_filesz + k) = 0;
            //     k += 8;
            // }
        }
        i += phnum_max;
    }

    return (void *) elf.e_entry;
}
