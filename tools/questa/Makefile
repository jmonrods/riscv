SHELL := /bin/bash
PROJECT_ROOT := $(abspath $(CURDIR)/.$(PROJECT_ROOT)/..)

# directed test for alu
alu: clean setup
	vlib work
	vmap work work
	vlog -sv $(PROJECT_ROOT)/alu/alu_tb.sv $(PROJECT_ROOT)/alu/alu.sv
	vsim -c work.alu_tb -do "run -all; quit -f;"

# single-cycle riscv cpu
cpu_single: clean setup
	vlib work
	vmap work work
	vlog -sv $(PROJECT_ROOT)/cpu_single/cpu_tb.sv $(PROJECT_ROOT)/cpu_single/cpu.sv $(PROJECT_ROOT)/alu/alu.sv
	vsim -c work.cpu_tb -do "run -all; quit -f;"

# multi-cycle riscv cpu
cpu_multi: clean setup
	vlib work
	vmap work work
	vlog -sv $(PROJECT_ROOT)/cpu_multi/cpu_tb.sv $(PROJECT_ROOT)/cpu_multi/cpu.sv $(PROJECT_ROOT)/alu/alu.sv
	vsim -c work.cpu_tb -do "run -all; quit -f;"

# pipelined riscv cpu
cpu_pipeline: clean setup
	vlib work
	vmap work work
	vlog -sv \
		$(PROJECT_ROOT)/cpu_pipeline/top_tb.sv \
		$(PROJECT_ROOT)/cpu_pipeline/top.sv \
		$(PROJECT_ROOT)/cpu_pipeline/cpu.sv \
		$(PROJECT_ROOT)/cpu_pipeline/dmem.sv \
		$(PROJECT_ROOT)/cpu_pipeline/imem.sv \
		$(PROJECT_ROOT)/alu/alu.sv
	vsim -c work.top_tb -do "run -all; quit -f;"

# single-cycle uvm testbench
cpu_single_uvm: clean setup
	vlib work
	vmap work work
	vlog -sv \
		$(PROJECT_ROOT)/alu/alu.sv \
		$(PROJECT_ROOT)/uvm/cpu/cpu.sv \
		$(PROJECT_ROOT)/uvm/uvm_tb/cpu_pkg.sv \
		$(PROJECT_ROOT)/uvm/uvm_tb/cpu_bfm.sv \
		$(PROJECT_ROOT)/uvm/top.sv \
		+incdir+$(PROJECT_ROOT)/uvm/uvm_tb
	vopt top -o top_optimized +cover=sbfec+cpu
	vsim -c +UVM_TESTNAME="add_test" top_optimized -coverage -do "set NoQuitOnFinish 1; onbreak {resume}; log /* -r; run -all; coverage save -onexit coverage.ucdb; quit;"
	vcover report coverage.ucdb
	vsim -c +UVM_TESTNAME="random_test" top_optimized -coverage -do "set NoQuitOnFinish 1; onbreak {resume}; log /* -r; run -all; coverage save -onexit coverage.ucdb; quit;"
	vcover report coverage.ucdb

# clean: removes output files
clean:
	rm $(PROJECT_ROOT)/vsim.wlf -f
	rm $(PROJECT_ROOT)/vsim.dbg -f
	rm $(PROJECT_ROOT)/modelsim.ini -f
	rm $(PROJECT_ROOT)/coverage.ucdb -f
	rm $(PROJECT_ROOT)/coverage.txt -f
	rm $(PROJECT_ROOT)/work/ -rf
	rm $(PROJECT_ROOT)/transcript -f

# setup
setup:
	source $(PROJECT_ROOT)/tools/questa/setup.sh


