#ifndef __IOLIB_H__
#define __IOLIB_H__

#define __LOAD_U16(ptr) (((__U8P) ptr)[0] | ((__U8P) ptr)[1] << 8);

#define __FAT12  0x3
#define __FAT16  0x4
#define __FAT32  0x5

#define __SEEK_BEG 0
#define __SEEK_CUR 1
#define __SEEK_END 2

typedef struct {
    __U16 bytes_sect;
    __U16 sects_fat;
    __U16 fat_base;
    __U16 fat_end;
    __U32 max_clst;
    __U16 n_root_dir;
    __U16 dir_base;
    __U16 data_base;
    __U8  sects_clst;
    __U8  n_fats;
    __U8  fs_type;
    __U32 fat[512/4];
    __U16 fat_cur;
} __BPB;

typedef struct {
    __U8   fname[8];
    __U8   subfname[3];
    __U8   attr;
    __U8   rsv;
    __U8   bld_time_ms;
    __U16  bld_time;
    __U16  bld_date;
    __U16  acc_date;
    __U16  entry_h;
    __U16  mdf_time;
    __U16  mdf_date;
    __U16  entry_l;
    __U32  size;
    __BPB *bpb;
    __U32  seek;
    __U32  sect;
    __U32  cur_clst_idx;
    __U32  max_clst_idx;
    __U32  clst[512];
    __U32  superclst[512];
    __U8   buff[512];
} __FILE;

__U8 __fat_bpb_init(__BPB *__bpb);
__U8 __fopen(__FILE *__file, const char *__fname);
__U8 __fseek(__FILE *file, __U32 offset, __U8 whence);
__U8 __fread(__FILE *file, void *buff, __U32 size);

#endif
