SHELL := /bin/bash
.ONESHELL:

PROJECT_ROOT := $(abspath $(CURDIR)/../..)
RTL := $(PROJECT_ROOT)/rtl
UVM := $(PROJECT_ROOT)/uvm

# directed test for alu
alu: clean setup
	source $(PROJECT_ROOT)/tools/vcs/setup.sh
	vcs -full64 -R -sverilog $(RTL)/alu/alu_tb.sv $(RTL)/alu/alu.sv

# single-cycle riscv cpu
cpu_single: clean
	source $(PROJECT_ROOT)/tools/vcs/setup.sh
	vcs -full64 -R -sverilog $(RTL)/cpu_single/cpu_tb.sv $(RTL)/cpu_single/cpu.sv $(RTL)/alu/alu.sv

# multi-cycle riscv cpu
cpu_multi: clean
	source $(PROJECT_ROOT)/tools/vcs/setup.sh
	vcs -full64 -R -sverilog $(RTL)/cpu_multi/cpu_tb.sv $(RTL)/cpu_multi/cpu.sv $(RTL)/alu/alu.sv

# pipelined riscv cpu
cpu_pipeline: clean
	source $(PROJECT_ROOT)/tools/vcs/setup.sh
	vcs -full64 -R -sverilog \
		$(RTL)/cpu_pipeline/top_tb.sv \
		$(RTL)/cpu_pipeline/top.sv \
		$(RTL)/cpu_pipeline/cpu.sv \
		$(RTL)/cpu_pipeline/dmem.sv \
		$(RTL)/cpu_pipeline/imem.sv \
		$(RTL)/alu/alu.sv

# single-cycle uvm testbench
cpu_single_uvm: clean
	source $(PROJECT_ROOT)/tools/vcs/setup.sh
	vcs -full64 -sverilog -ntb_opts uvm-1.2 -debug_access+all -timescale=1ns/1ps \
		$(RTL)/alu/alu.sv \
		$(UVM)/cpu/cpu.sv \
		$(UVM)/uvm_tb/cpu_pkg.sv \
		$(UVM)/uvm_tb/cpu_bfm.sv \
		$(UVM)/top.sv \
		+incdir+$(UVM)/uvm_tb
	./simv +UVM_TESTNAME="add_test"

# clean: removes output files
clean:
	rm ./csrc/ -rf
	rm ./simv.daidir/ -rf



