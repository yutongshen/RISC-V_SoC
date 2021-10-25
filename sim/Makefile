prog_dir := $(wildcard */)

clean:
	@rm -rf ./build .*.swo .*.swp
	@for dir in ${prog_dir}; do \
	    make -C $${dir} clean; \
	done
