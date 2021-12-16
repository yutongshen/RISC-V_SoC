root_dir      := $(PWD)
src_dir       := ./src
syn_dir       := ./syn
inc_dir       := ./include
bld_dir       := ./build
sim_dir       := ./sim
scrp_dir      := ./script
flist         := designlist.f
simlist       := sim.f
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

$(syn_dir):
	mkdir -p $(syn_dir)

verdi.f: | ${bld_dir}
	@make merge;
	@rm -f ${bld_dir}/verdi.f;
	@touch ${bld_dir}/verdi.f;
	@cat $(root_dir)/$(sim_dir)/$(simlist) >> ${bld_dir}/verdi.f;
	#@echo "../src/cpu_wrap_nodef.all.sv"   >> ${bld_dir}/verdi.f;
	@cat $(root_dir)/$(sim_dir)/$(flist)   >> ${bld_dir}/verdi.f;

merge:
	@cd ${src_dir};\
	$(root_dir)/${scrp_dir}/merge_sv.sh $(root_dir)/$(sim_dir)/$(flist) cpu_wrap.all.sv;
	@cd ${src_dir};\
	$(root_dir)/${scrp_dir}/expand_def.sh $(root_dir)/$(sim_dir)/$(flist) cpu_wrap.all.sv cpu_wrap_nodef.all.sv;
	@cd ${src_dir};\
	echo "\`define DC" > cpu_wrap.dc.sv;
	@cd ${src_dir};\
	cat cpu_wrap_nodef.all.sv >> cpu_wrap.dc.sv;

sim: all | ${bld_dir}
	@make verdi.f;
	if [ "$(prog)" == "3" ] && [ "${isa}" == "" ]; then \
	    for i in $(ISA); do \
	        make -C $(root_dir)/$(sim_dir)/prog$(prog) isa=$${i} > /dev/null; \
	        res=$$(cd $(bld_dir); ncverilog -sv -f verdi.f +prog=$(root_dir)/$(sim_dir)/prog$(prog) +isa=$${i} +nclinedebug;); \
            cpi=$$(echo "$${res}" | grep "CPI:"); \
            inst=$$(echo "$${res}" | grep "minstret:"); \
            cycl=$$(echo "$${res}" | grep "mcycle:"); \
	        res=$$(echo "$${res}" | grep "ENDCODE = 00000001"); \
	        if [ "$${res}" == "" ]; then \
	            echo "There are some error in $${i}"; \
	        else \
				printf "%-20s pass (%-20s, %-20s, %-20s)\n" "$${i}" "$${cpi}" "$${inst}" "$${cycl}" ; \
	        fi; \
	    done; \
	else \
	    make -C $(root_dir)/$(sim_dir)/prog$(prog) isa=${isa}; \
	    cd $(bld_dir); \
	    ncverilog -sv -f verdi.f +prog=$(root_dir)/$(sim_dir)/prog$(prog) +isa=${isa} +nclinedebug; \
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
	@make verdi.f;
	@cd $(bld_dir); \
	verdi -sverilog -f verdi.f &

verdi_axi: ${bld_dir}
	@cd $(bld_dir); \
    verdi -sverilog -f $(root_dir)/$(sim_dir)/axi_verify.f &

superlint: | ${bld_dir}
	@cd $(bld_dir); \
	jg -superlint ../script/superlint.tcl &

synthesize: | $(bld_dir) $(syn_dir)
	make merge;
	cp script/synopsys_dc.setup $(bld_dir)/.synopsys_dc.setup; \
	cd $(bld_dir); \
	dc_shell -no_home_init -f ../script/synthesis.tcl

clean:
	@rm -rf ./build .*.swo .*.swp;
	@rm -f ./src/cpu/.*.swp ./src/bus/.*.swp
	@make -C $(sim_dir) clean;
