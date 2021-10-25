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

.PHONY: all

${bld_dir}:
	mkdir -p $(bld_dir)

sim: all | ${bld_dir}
	@make -C $(root_dir)/$(sim_dir)/prog$(prog);
	@cd $(bld_dir); \
	ncverilog -sv -f $(root_dir)/$(sim_dir)/$(flist) +prog=$(root_dir)/$(sim_dir)/prog$(prog);

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
