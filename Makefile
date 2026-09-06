vcs:
	make -C tools/vcs cpu_single_uvm

questa:
	make -C tools/questa cpu_single_uvm

xcelium:
	make -C tools/xcelium cpu_single_uvm

lint:
	make -C tools/spyglass lint
