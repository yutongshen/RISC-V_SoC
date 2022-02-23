#ifndef __ELF_LOADER_H__
#define __ELF_LOADER_H__

#define EI_NIDENT 16

#define SHT_NULL     0
#define SHT_PROGBITS 1
#define SHT_SYMTAB   2
#define SHT_STRTAB   3
#define SHT_RELA     4
#define SHT_HASH     5
#define SHT_DYNAMIC  6
#define SHT_NOTE     7
#define SHT_NOBITS   8
#define SHT_REL      9
#define SHT_SHLIB    10
#define SHT_DYNSYM   11
#define SHT_LOPROC   0x70000000
#define SHT_HIPROC   0x7FFFFFFF
#define SHT_LOUSER   0x80000000
#define SHT_HIUSER   0x8FFFFFFF

#define SHF_WRITE     (1 << 0)
#define SHF_ALLOC     (1 << 1)
#define SHF_EXECINSTR (1 << 2)
#define SHF_MASKPROC  0xF0000000

typedef struct {
    __U8  e_ident[EI_NIDENT];
    __U16 e_type;
    __U16 e_machine;
    __U32 e_version;
    __U64 e_entry;
    __U64 e_phoff;
    __U64 e_shoff;
    __U32 e_flags;
    __U16 e_ehsize;
    __U16 e_phentsize;
    __U16 e_phnum;
    __U16 e_shentsize;
    __U16 e_shnum;
    __U16 e_shstrndx;
} __EHDR64;

typedef struct {
    __U8  e_ident[EI_NIDENT];
    __U16 e_type;
    __U16 e_machine;
    __U32 e_version;
    __U32 e_entry;
    __U32 e_phoff;
    __U32 e_shoff;
    __U32 e_flags;
    __U16 e_ehsize;
    __U16 e_phentsize;
    __U16 e_phnum;
    __U16 e_shentsize;
    __U16 e_shnum;
    __U16 e_shstrndx;
} __EHDR32;

typedef struct {
    __U32 p_type;
    __U32 p_flags;
    __U64 p_offset;
    __U64 p_vaddr;
    __U64 p_paddr;
    __U64 p_filesz;
    __U64 p_memsz;
    __U64 p_align;
} __PHDR64;

typedef struct {
    __U32   sh_name;
    __U32   sh_type;
    __U64   sh_flags;
    __U64   sh_addr;
    __U64   sh_offset;
    __U64   sh_size;
    __U32   sh_link;
    __U32   sh_info;
    __U64   sh_addralign;
    __U64   sh_entsize;
} __SHDR64;

void *__elf_loader(__FILE *file);

#endif
