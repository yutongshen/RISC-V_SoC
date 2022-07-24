#include "mmap_soc.h"
#include "typedef.h"
#include "iolib.h"
#include "util.h"
#include "elf_loader.h"
#include "spi.h"

#define __PHNUM_MAX 8

void *__elf_loader(__FILE *file) {

    return __elf_loader_reloc(file, 0);
}

void *__elf_loader_reloc(__FILE *file, __U64 relocate) {
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
            __fread(file, (void *) (prog_header[j].p_paddr + relocate), prog_header[j].p_filesz);

            if (prog_header[j].p_filesz < prog_header[j].p_memsz) {
                __dma_memfill((__U8P) (prog_header[j].p_paddr + relocate + prog_header[j].p_filesz), 0,
                              prog_header[j].p_memsz - prog_header[j].p_filesz);
            }
        }
        i += phnum_max;
    }

    return (void *) elf.e_entry;
}
