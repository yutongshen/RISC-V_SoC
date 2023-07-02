#include "mmap_soc.h"
#include "typedef.h"
#include "spi.h"
#include "iolib.h"
#include "util.h"
#include "uart.h"

__U8 __fat_bpb_init(__BPB *__bpb) {
    __U8  buff[512];
    __U16 sect = 0;
    __U32 tmp;
    // Read block check
    if (!__sd_readblk(sect, buff)) return 0;
    // Sector valid check
    if (*(__U16P) &buff[0x1fe] != 0xaa55) return 0;
    // Check fat type
    if      (!__strcmp(buff + 0x36, "FAT12   ", 8)) __bpb->fs_type = __FAT12;
    else if (!__strcmp(buff + 0x36, "FAT16   ", 8)) __bpb->fs_type = __FAT16;
    else if (!__strcmp(buff + 0x52, "FAT32   ", 8)) __bpb->fs_type = __FAT32;
    else {
        // Read BPB sector check
        sect = *((__U16P) &buff[0x1c6]);
        if (!__sd_readblk(sect, buff)) return 0;
        // Sector valid check
        if (*(__U16P) &buff[0x1fe] != 0xaa55) return 0;
        if      (!__strcmp(buff + 0x36, "FAT12   ", 8)) __bpb->fs_type = __FAT12;
        else if (!__strcmp(buff + 0x36, "FAT16   ", 8)) __bpb->fs_type = __FAT16;
        else if (!__strcmp(buff + 0x52, "FAT32   ", 8)) __bpb->fs_type = __FAT32;
        else return 0;
    }
    __bpb->bytes_sect = __LOAD_U16(&buff[0xb]);
    __bpb->sects_clst = buff[0xd];
    __bpb->sects_fat  = (__bpb->fs_type == __FAT32) ? *(__U16P) &buff[0x24]:
                                                    *(__U16P) &buff[0x16];
    __bpb->n_fats     = buff[0x10];
    __bpb->fat_base   = sect + __LOAD_U16(&buff[0xe]);
    __bpb->fat_end    = __bpb->n_fats * __bpb->sects_fat + __bpb->fat_base;
    __bpb->n_root_dir = __LOAD_U16(&buff[0x11]);
    if (__bpb->fs_type == __FAT32) {
        __bpb->dir_base  = *(__U16P) &buff[0x2c];
        __bpb->data_base = __bpb->fat_end;
    }
    else {
        __bpb->dir_base  = __bpb->fat_end;
        __bpb->data_base = (__bpb->n_root_dir >> 4) + __bpb->fat_end;
    }
    tmp = *(__U32P) &buff[0x20] ? *(__U32P) &buff[0x20] : __LOAD_U16(&buff[0x13]);
    __bpb->max_clst = (tmp - __bpb->data_base + sect) / __bpb->sects_clst + 2;

    // Read fat table check
    // if (!__sd_readblk(__bpb->fat_base, (__U8P) __bpb->fat)) return 0;
    __bpb->fat_cur = -1;

    return 1;
}

__U32 __nxt_clst(__BPB *__bpb, __U32 __clst) {
    __U32 tmp;

    tmp = __clst + __bpb->dir_base;

    if (tmp / 128 != __bpb->fat_cur) { 
        // Load FAT table
        __bpb->fat_cur = tmp / 128;
        if (!__sd_readblk(__bpb->fat_base + __bpb->fat_cur,
                          (__U8P) __bpb->fat)) return 0;
    }
    tmp = __bpb->fat[tmp % 128];
    return tmp == 0x0fffffff ? -1 : (tmp - __bpb->dir_base);
}

__U32 __get_clst(__FILE *__file, __U32 __idx) {
    __U16 super_clst; // super_clst must less than 512
    __U32 tmp;
    __U8  eof;
    __U16 i;
    
    super_clst = __idx / 512;
    if (super_clst != __file->cur_clst_idx) {
        while (super_clst > __file->max_clst_idx) {
            tmp = __file->superclst[__file->max_clst_idx];
            eof = 0;
            for (i = 0; i < 512 && !eof; ++i) {
                tmp = __nxt_clst(__file->bpb, tmp);
                eof = tmp == -1;
            }
            __file->superclst[++(__file->max_clst_idx)] = tmp;
            if (tmp == -1) return -1;
        }
        tmp = __file->superclst[super_clst];
        if (tmp == -1) return -1;

        __file->clst[0] = tmp;
        eof = 0;
        for (i = 1; i < 512; ++i) {
            if (!eof) {
                tmp = __nxt_clst(__file->bpb, tmp);
                eof = tmp == -1;
            }
            __file->clst[i] = tmp;
        }
        __file->cur_clst_idx = super_clst;
        __file->superclst[super_clst+1] = tmp == -1 ? -1 : __nxt_clst(__file->bpb, tmp);
    }
    return __file->clst[__idx % 512];
}

__U8 __fopen(__FILE *__file, const char *__fname) {
    __U8  fname[8];
    __U8  subfname[3];
    __U8  buff[512];
    __U16 i = 0, j;
    __U32 tmp;
    __U8  eof;
    __U8  msg[6+12] = "  ... ";

    while (i < 8 && *__fname && *__fname != '.')
        fname[i++] = *__fname++ & ~0x20;
    while (i < 8)
        fname[i++] = 0x20;
    if (*__fname == '.') ++__fname;
    i = 0;
    while (i < 3 && *__fname) subfname[i++] = *__fname++ & ~0x20;
    while (i < 3)             subfname[i++] = 0x20;

    for (j = 0; j < 4; ++j) {
        i = 0;

        // Read dir list check
        if (!__sd_readblk(__file->bpb->data_base + j, buff)) return 0;
        
        while (i < 512) {
            // Check dir list end
            if (!buff[i])
                return 0;
            // Check long file name
            if (!buff[i+2] || buff[i] == 0xe5) {
                i += 0x20;
                continue;
            }
            __memcpy(msg+6, buff+i, 11);
            msg[17] = 0;
            __puts(msg);
            // Check existence / fname / subfname
            if (__strcmp(&buff[i], fname, 8) ||
                __strcmp(&buff[i+8], subfname, 3)) {
                i += 0x20;
                continue;
            }
            // Match
            __memcpy(__file, &buff[i], 0x20);
            __file->seek         =  0;
            __file->sect         = -1;
            __file->cur_clst_idx = -1;
            __file->max_clst_idx =  0;
            __file->superclst[0] = ((__U32) (__file->entry_l) | (__U32) ((__file->entry_h) << 16)) - __file->bpb->dir_base;
            return 1;
        }
    }
    return 0;
}

__U8 __fseek(__FILE *file, __U32 offset, __U8 whence) {
    switch (whence) {
        case __SEEK_BEG: file->seek  = offset; break;
        case __SEEK_CUR: file->seek += offset; break;
        case __SEEK_END: file->seek  = file->size + offset; break;
        default: return 0;
    }
    return 1;
}

__U8 __fread(__FILE *file, void *buff, __U32 size) {
    __U8P cbuff = (__U8P) buff;
    __U32 sect, partial_size, i = 0, offset = file->seek % 0x200;

    while (i < size) {
        sect = file->seek / 0x200;
        if (size - i >= 0x200 && !offset) {
            if (sect != file->sect) {
                if (!__sd_readblk(file->bpb->data_base +
                                  sect % file->bpb->sects_clst +
                                  __get_clst(file, sect / file->bpb->sects_clst) * file->bpb->sects_clst,
                                  cbuff))
                    return 0;
            }
            else {
                __memcpy(cbuff, file->buff, 0x200);
            }
            cbuff += 0x200;
            file->seek += 0x200;
            i += 0x200;
        }
        else {
            if (sect != file->sect) {
                // Load sect
                if (!__sd_readblk(file->bpb->data_base +
                                  sect % file->bpb->sects_clst +
                                  __get_clst(file, sect / file->bpb->sects_clst) * file->bpb->sects_clst,
                                  file->buff))
                    return 0;
                file->sect = sect;
            }
            partial_size = 0x200 - file->seek % 0x200;
            if (i + partial_size >= size)
                partial_size = size - i;
            __memcpy(cbuff, file->buff + offset, partial_size);
            i += partial_size;
            cbuff += partial_size;
            file->seek += partial_size;
            offset = 0;
        }
    }
    return 1;
}

