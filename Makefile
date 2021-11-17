root_dir      := $(PWD)
src_dir       := ./src
inc_dir       := ./include
bld_dir       := ./build
sim_dir       := ./sim
flist         := designlist.f
err_ignore    := 2> /dev/null || :

INIT_MMAP     := ./script/build_mmap -i 
XTEND_MMAP    := ./script/build_mmap -x 

TMDL_PARSE_C  := ./script/tmdl_parse -c
TMDL_PARSE_S  := ./script/tmdl_parse -s

ISA           := $(wildcard ../riscv-tests/isa/rv32*i-*)
ISA           := $(patsubst ../riscv-tests/isa/%,%,$(ISA))
ISA           := $(patsubst %.dump,,$(ISA))

.PHONY: all

${bld_dir}:
	mkdir -p $(bld_dir)

sim: all | ${bld_dir}
	@if [ "$(prog)" == "3" ] && [ "${isa}" == "" ]; then \
	    for i in $(ISA); do \
	        make -C $(root_dir)/$(sim_dir)/prog$(prog) isa=$${i} > /dev/null; \
	        res=$$(cd $(bld_dir); ncverilog -sv -f $(root_dir)/$(sim_dir)/$(flist) +prog=$(root_dir)/$(sim_dir)/prog$(prog) +nclinedebug;); \
	        res=$$(echo "$${res}" | grep "ENDCODE = 00000001"); \
	        if [ "$${res}" == "" ]; then \
	            echo "There are some error in $${i}"; \
	        else \
				echo "$${i} pass"; \
	        fi; \
	    done; \
	else \
	    make -C $(root_dir)/$(sim_dir)/prog$(prog) isa=${isa}; \
	    cd $(bld_dir); \
	    ncverilog -sv -f $(root_dir)/$(sim_dir)/$(flist) +prog=$(root_dir)/$(sim_dir)/prog$(prog) +nclinedebug; \
	fi;

axi: | ${bld_dir}
	# @cd $(root_dir)/$(src_dir)/bus/; \
	# ../../script/gen_axi_dec.sh 2 4 ../../script/axi_sideband.cfg ../../script/axi_mmap.cfg
	# @cd $(root_dir)/mdl; \
	# ../script/gen_axi_mon.sh 1 2 ../script/axi_sideband.cfg ../script/axi_mmap.cfg
	# @cd $(root_dir)/$(sim_dir); \
	# ../script/gen_axi_tb.sh 1 2 ../script/axi_sideband.cfg
	# @cd $(bld_dir); \
	# ncverilog -sv -f $(root_dir)/$(sim_dir)/axi_verify.f;

verdi: ${bld_dir}
	@cd $(bld_dir); \
	verdi -sverilog -f $(root_dir)/$(sim_dir)/$(flist) &

verdi_axi: ${bld_dir}
	@cd $(bld_dir); \
    verdi -sverilog -f $(root_dir)/$(sim_dir)/axi_verify.f &

superlint: | ${bld_dir}
	@cd $(bld_dir); \
	jg -superlint ../script/superlint.tcl &

clean:
	@rm -rf ./build .*.swo .*.swp;
	@make -C $(sim_dir) clean;
