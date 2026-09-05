SHELL := /bin/bash
.ONESHELL:

PROJECT_ROOT := $(abspath $(CURDIR)/../..)
RTL := $(PROJECT_ROOT)/rtl
UVM := $(PROJECT_ROOT)/uvm

# directed test for alu
alu: clean
	source $(PROJECT_ROOT)/tools/questa/setup.sh
	vlib work
	vmap work work
	vlog -sv $(RTL)/alu/alu_tb.sv $(RTL)/alu/alu.sv
	vsim -c work.alu_tb -do "run -all; quit -f;"

# single-cycle riscv cpu
cpu_single: clean
	source $(PROJECT_ROOT)/tools/questa/setup.sh
	vlib work
	vmap work work
	vlog -sv $(RTL)/cpu_single/cpu_tb.sv $(RTL)/cpu_single/cpu.sv $(RTL)/alu/alu.sv
	vsim -c work.cpu_tb -do "run -all; quit -f;"

# multi-cycle riscv cpu
cpu_multi: clean
	source $(PROJECT_ROOT)/tools/questa/setup.sh
	vlib work
	vmap work work
	vlog -sv $(RTL)/cpu_multi/cpu_tb.sv $(RTL)/cpu_multi/cpu.sv $(RTL)/alu/alu.sv
	vsim -c work.cpu_tb -do "run -all; quit -f;"

# pipelined riscv cpu
cpu_pipeline: clean
	source $(PROJECT_ROOT)/tools/questa/setup.sh
	vlib work
	vmap work work
	vlog -sv \
		$(RTL)/cpu_pipeline/top_tb.sv \
		$(RTL)/cpu_pipeline/top.sv \
		$(RTL)/cpu_pipeline/cpu.sv \
		$(RTL)/cpu_pipeline/dmem.sv \
		$(RTL)/cpu_pipeline/imem.sv \
		$(RTL)/alu/alu.sv
	vsim -c work.top_tb -do "run -all; quit -f;"

# single-cycle uvm testbench
cpu_single_uvm: clean
	source $(PROJECT_ROOT)/tools/questa/setup.sh
	vlib work
	vmap work work
	vlog -sv \
		$(RTL)/alu/alu.sv \
		$(UVM)/cpu/cpu.sv \
		$(UVM)/uvm_tb/cpu_pkg.sv \
		$(UVM)/uvm_tb/cpu_bfm.sv \
		$(UVM)/top.sv \
		+incdir+$(UVM)/uvm_tb
	vopt top -o top_optimized +cover=sbfec+cpu
	vsim -c +UVM_TESTNAME="add_test" top_optimized -coverage -do "set NoQuitOnFinish 1; onbreak {resume}; log /* -r; run -all; coverage save -onexit coverage.ucdb; quit;"
	vcover report coverage.ucdb
	vsim -c +UVM_TESTNAME="random_test" top_optimized -coverage -do "set NoQuitOnFinish 1; onbreak {resume}; log /* -r; run -all; coverage save -onexit coverage.ucdb; quit;"
	vcover report coverage.ucdb

# clean: removes output files
clean:
	rm ./vsim.wlf -f
	rm ./vsim.dbg -f
	rm ./modelsim.ini -f
	rm ./coverage.ucdb -f
	rm ./coverage.txt -f
	rm ./work/ -rf
	rm ./transcript -f


