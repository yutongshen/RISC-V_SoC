SHELL     := /bin/bash
ELF_NAME  := main
SRAM_START := 0x00020000
DRAM_START := 0x80000000

ifeq ($(isa),)
  ISA := rv32ui-v-add
else
  ISA := $(isa)
endif

export CROSS_PREFIX ?= riscv64-unknown-elf-
export RISCV_GCC ?= $(CROSS_PREFIX)gcc
export RISCV_OBJDUMP ?= $(CROSS_PREFIX)objdump -xsd
export RISCV_OBJCOPY ?= $(CROSS_PREFIX)objcopy -O verilog

INCDIR := ./include/
LDFILE := link.ld
CFLAGS  := -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -march=rv64i -mabi=lp64 -I$(INCDIR)
LDFLAGS := -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -march=rv64i -mabi=lp64 -T$(LDFILE) -lgcc

SRC_C   := $(wildcard *.c)
OBJ_C   := $(patsubst %.c,%.o,$(SRC_C))
SRC_S   := $(wildcard *.S)
OBJ_S   := $(patsubst %.S,%.o,$(SRC_S))
BMP     := $(wildcard *.bmp)
OBJ_BMP := $(patsubst %.bmp,%.o,$(BMP))
SRC     := $(SRC_C) $(SRC_S)
OBJ     := $(OBJ_C) $(OBJ_S) $(OBJ_BMP)

.SUFFIXES: .o .S .c

.PHONY: all

all: build_elf build_log build_hex

build_elf:
	# $(RISCV_GCC) $^ $(LDFLAGS) -o $(ELF_NAME)
	cp bbl $(ELF_NAME)

build_log: $(ELF_NAME)
	$(RISCV_OBJDUMP) $< > $(ELF_NAME).log

build_hex: $(ELF_NAME)
	# @rm -f bss.hex
	# @touch bss.hex
	# @val="00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00";          \
	# bss=$$(riscv64-unknown-elf-objdump -h $< | grep .bss);           \
	# if [[ "$${bss}" != "" ]]; then                                   \
	#     bss=($${bss});                                               \
	#     printf -v addr "%x" $$(((0x$${bss[3]} - ${SRAM_START}) / 4)); \
	#     echo @$${addr} >> bss.hex;                                   \
	#     for (( i = 0; i < $$((0x$${bss[2]})); i = i + 64 )); do      \
	#         echo $${val} >> bss.hex;                                 \
	#     done                                                         \
	# fi
	# @rm -f sbss.hex
	# @touch sbss.hex
	# @val="00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00";           \
	# sbss=$$(riscv64-unknown-elf-objdump -h $< | grep .sbss);          \
	# if [[ "$${sbss}" != "" ]]; then                                   \
	#     sbss=($${sbss});                                              \
	#     printf -v addr "%x" $$(((0x$${sbss[3]} - ${SRAM_START}) / 4)); \
	#     echo @$${addr} >> sbss.hex;                                   \
	#     for (( i = 0; i < $$((0x$${sbss[2]})); i = i + 64 )); do      \
	#         echo $${val} >> sbss.hex;                                 \
	#     done                                                          \
	# fi
	# @$(RISCV_OBJCOPY) $< -i 4 -b 0 --change-addresses -${SRAM_START} main_0.hex
	# @$(RISCV_OBJCOPY) $< -i 4 -b 1 --change-addresses -${SRAM_START} main_1.hex
	# @$(RISCV_OBJCOPY) $< -i 4 -b 2 --change-addresses -${SRAM_START} main_2.hex
	# @$(RISCV_OBJCOPY) $< -i 4 -b 3 --change-addresses -${SRAM_START} main_3.hex
	# @rm -f sram_*.hex
	# @cat bss.hex    >> sram_0.hex
	# @cat bss.hex    >> sram_1.hex
	# @cat bss.hex    >> sram_2.hex
	# @cat bss.hex    >> sram_3.hex
	# @cat sbss.hex   >> sram_0.hex
	# @cat sbss.hex   >> sram_1.hex
	# @cat sbss.hex   >> sram_2.hex
	# @cat sbss.hex   >> sram_3.hex
	# @cat main_0.hex >> sram_0.hex
	# @cat main_1.hex >> sram_1.hex
	# @cat main_2.hex >> sram_2.hex
	# @cat main_3.hex >> sram_3.hex
	@rm -f bss.hex
	@touch bss.hex
	@val="00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00";          \
	bss=$$(riscv64-unknown-elf-objdump -h $< | grep .bss);           \
	if [[ "$${bss}" != "" ]]; then                                   \
	    bss=($${bss});                                               \
	    printf -v addr "%x" $$(((0x$${bss[3]} - ${DRAM_START}) / 4)); \
	    echo @$${addr} >> bss.hex;                                   \
	    for (( i = 0; i < $$((0x$${bss[2]})); i = i + 64 )); do      \
	        echo $${val} >> bss.hex;                                 \
	    done                                                         \
	fi
	@rm -f sbss.hex
	@touch sbss.hex
	@val="00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00";           \
	sbss=$$(riscv64-unknown-elf-objdump -h $< | grep .sbss);          \
	if [[ "$${sbss}" != "" ]]; then                                   \
	    sbss=($${sbss});                                              \
	    printf -v addr "%x" $$(((0x$${sbss[3]} - ${DRAM_START}) / 4)); \
	    echo @$${addr} >> sbss.hex;                                   \
	    for (( i = 0; i < $$((0x$${sbss[2]})); i = i + 64 )); do      \
	        echo $${val} >> sbss.hex;                                 \
	    done                                                          \
	fi
	@$(RISCV_OBJCOPY) $< -i 4 -b 0 --change-addresses -${DRAM_START} main_0.hex
	@$(RISCV_OBJCOPY) $< -i 4 -b 1 --change-addresses -${DRAM_START} main_1.hex
	@$(RISCV_OBJCOPY) $< -i 4 -b 2 --change-addresses -${DRAM_START} main_2.hex
	@$(RISCV_OBJCOPY) $< -i 4 -b 3 --change-addresses -${DRAM_START} main_3.hex
	@rm -f dram_*.hex
	@cat bss.hex    >> ddr_0.hex
	@cat bss.hex    >> ddr_1.hex
	@cat bss.hex    >> ddr_2.hex
	@cat bss.hex    >> ddr_3.hex
	@cat sbss.hex   >> ddr_0.hex
	@cat sbss.hex   >> ddr_1.hex
	@cat sbss.hex   >> ddr_2.hex
	@cat sbss.hex   >> ddr_3.hex
	@cat main_0.hex >> ddr_0.hex
	@cat main_1.hex >> ddr_1.hex
	@cat main_2.hex >> ddr_2.hex
	@cat main_3.hex >> ddr_3.hex

	@touch sram_0.hex
	@touch sram_1.hex
	@touch sram_2.hex
	@touch sram_3.hex

%.o: %.bmp
	$(RISCV_OBJCOPY) -I binary -O elf32-littleriscv -B riscv:rv32 $^ $@

%.o: %.S
	$(RISCV_GCC) -c $(CFLAGS) $^

%.o: %.c
	$(RISCV_GCC) -c $(CFLAGS) $^

auto-format:
	@if [ "${SRC_H}" != "" ] || [ "${SRC_C}" != "" ] || [ "${SRC_CPP}" != "" ]; then \
	    clang-format -i ${SRC_H} ${SRC_C} ${SRC_CPP}; \
    fi

.PHONY: clean

clean:
	rm -rf $(ELF_NAME) $(ELF_NAME).log *.hex *.o .*.swp .*.swo
