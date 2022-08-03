root_dir      := $(PWD)
src_dir       := ./src
syn_dir       := ./syn
inc_dir       := ./include
bld_dir       := ./build
sim_dir       := ./sim
rom_dir       := ./rom
scrp_dir      := ./script
flist         := designlist.f
simlist       := sim.f
tmdl_msg_log  := tmdl_msg.log
err_ignore    := 2> /dev/null || :

INIT_MMAP     := ./script/build_mmap -i 
XTEND_MMAP    := ./script/build_mmap -x 

TMDL_PARSE_C  := ./script/tmdl_parse -c
TMDL_PARSE_S  := ./script/tmdl_parse -s

ISA           += $(wildcard ../riscv-tests/isa/rv*i-*)
ISA           += $(wildcard ../riscv-tests/isa/rv*c-*)
ISA           += $(wildcard ../riscv-tests/isa/rv*m-*)
ISA           += $(wildcard ../riscv-tests/isa/rv*a-*)
#ISA           += $(wildcard ../riscv-tests/isa/rv32*i-*)
#ISA           += $(wildcard ../riscv-tests/isa/rv32*c-*)
#ISA           += $(wildcard ../riscv-tests/isa/rv32*m-*)
#ISA           += $(wildcard ../riscv-tests/isa/rv32*a-*)
ISA           := $(patsubst ../riscv-tests/isa/%,%,$(ISA))
ISA           := $(patsubst %.dump,,$(ISA))

.PHONY: all

${bld_dir}:
	mkdir -p $(bld_dir);
	# ln -s /home/nfs_home/fred2/sim_tmp $(bld_dir);
	# ln -s sim_tmp/cpu_tracer.log $(bld_dir);
	# ln -s sim_tmp/top.fsdb $(bld_dir);

$(syn_dir):
	mkdir -p $(syn_dir);

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
	# Gen MMAP head file
	@${INIT_MMAP} ${inc_dir}/mmap.h ${bld_dir}/mmap_soc.h
	@for file in ${inc_dir}/*_mmap.h; do \
	    ${XTEND_MMAP} ${bld_dir}/mmap_soc.h $${file}; \
	done
	
	@make verdi.f;
		
	@cp ${bld_dir}/mmap_soc.h rom/mmap_soc.h;
	@make -C ${rom_dir} clean;
	@make -C ${rom_dir} def=${def};
	@cp ${rom_dir}/*.hex ${bld_dir};
	
	# Move prog to build directory
	@rm -f ${bld_dir}/${tmdl_msg_log};
	@rm -rf ${bld_dir}/prog;
	@mkdir ${bld_dir}/prog;
	@mkdir ${bld_dir}/prog/include;
	@for file in ${sim_dir}/prog${prog}/*; do \
	    if [[ ! "$${file}" == "${sim_dir}/prog${prog}/*" ]]; then \
	        _file=$$(basename $${file}); \
	        if [[ "$${_file#*.}" == "c" ]]; then \
	            ${TMDL_PARSE_C} $${file} ${bld_dir}/prog/$${_file} ${bld_dir}/${tmdl_msg_log}; \
	        elif [[ "$${_file#*.}" == "S" ]] || [[ "$${_file#*.}" == "s" ]]; then \
	            ${TMDL_PARSE_S} $${file} ${bld_dir}/prog/$${_file} ${bld_dir}/${tmdl_msg_log}; \
	        else \
	            cp $${file} ${bld_dir}/prog/ ${err_ignore}; \
	        fi; \
	    fi; \
	done;
	@touch ${bld_dir}/${tmdl_msg_log};
	@cp ${bld_dir}/mmap_soc.h ${bld_dir}/prog/include
	
	@if [ "$(prog)" == "3" ] && [ "${isa}" == "" ]; then \
	    for i in $(ISA); do \
	        make -C $(bld_dir)/prog isa=$${i} > /dev/null; \
	        res=$$(cd $(bld_dir); ncverilog -sv -f verdi.f +prog_path=prog +prog=prog$(prog) +isa=$${i} +define+NOFSDB +define+MAX_CYCLE=500000;); \
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
	    make -C $(bld_dir)/prog isa=${isa}; \
	    cd $(bld_dir); \
	    ncverilog -sv -f verdi.f +prog_path=prog +prog=prog$(prog) +isa=${isa} +define+MAX_CYCLE=1000000000 +nclinedebug; \
	fi;

axi: | ${bld_dir}
	@cd $(root_dir)/$(src_dir)/bus/; \
	../../script/gen_axi_biu.sh 5 5 4 1 ../../script/axi_sideband.cfg ../../script/axi_mmap.cfg
	@cd $(root_dir)/$(src_dir)/bus/; \
	../../script/gen_axi_mux.sh 2 ../../script/axi_sideband_2to1_id8.cfg id8
	@cd $(root_dir)/$(src_dir)/bus/; \
	../../script/gen_axi_mux.sh 2 ../../script/axi_sideband_2to1_id9.cfg id9
	# @cd $(root_dir)/mdl; \
	# ../script/gen_axi_mon.sh 1 2 ../script/axi_sideband.cfg ../script/axi_mmap.cfg
	# @cd $(root_dir)/$(sim_dir); \
	# ../script/gen_axi_tb.sh 1 2 ../script/axi_sideband.cfg
	# @cd $(bld_dir); \
	# ncverilog -sv -f $(root_dir)/$(sim_dir)/axi_verify.f;

verdi: ${bld_dir}
	@make verdi.f;
	@cd $(bld_dir); \
	verdi -sverilog -f verdi.f -ssf top.fsdb &

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

submit:
	scp src/cpu_wrap_nodef.all.sv fred2@140.116.245.115:/home/fred2/RISC-V_SoC/src/
	scp rom/rom_*.hex fred2@140.116.245.115:/home/fred2/RISC-V_SoC/src/

clean:
	@rm -rf ${bld_dir} .*.swo .*.swp;
	@rm -f ./src/cpu/.*.sw* ./src/bus/.*.sw* ./src/dbg/.*.sw* ./src/peri/.*.sw* ./include/.*.sw* ./mdl/.*.sw*
	@make -C $(sim_dir) clean;
	@make -C rom clean;
