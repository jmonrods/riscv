SHELL := /bin/tcsh
.ONESHELL:

PROJECT_ROOT := $(abspath $(CURDIR)/../..)
RTL := $(PROJECT_ROOT)/rtl
UVM := $(PROJECT_ROOT)/uvm

# directed test for alu
alu: clean
	source $(PROJECT_ROOT)/tools/xcelium/setup.csh
	xrun -64bit -sv $(RTL)/alu/alu_tb.sv $(RTL)/alu/alu.sv

# single-cycle riscv cpu
cpu_single: clean
	source $(PROJECT_ROOT)/tools/xcelium/setup.csh
	xrun -64bit -sv $(RTL)/cpu_single/cpu_tb.sv $(RTL)/cpu_single/cpu.sv $(RTL)/alu/alu.sv

# multi-cycle riscv cpu
cpu_multi: clean
	source $(PROJECT_ROOT)/tools/xcelium/setup.csh
	xrun -64bit -sv $(RTL)/cpu_multi/cpu_tb.sv $(RTL)/cpu_multi/cpu.sv $(RTL)/alu/alu.sv

# pipelined riscv cpu
cpu_pipeline: clean
	source $(PROJECT_ROOT)/tools/xcelium/setup.csh
	xrun -64bit -sv \
		$(RTL)/cpu_pipeline/top_tb.sv \
		$(RTL)/cpu_pipeline/top.sv \
		$(RTL)/cpu_pipeline/cpu.sv \
		$(RTL)/cpu_pipeline/dmem.sv \
		$(RTL)/cpu_pipeline/imem.sv \
		$(RTL)/alu/alu.sv

# single-cycle uvm testbench
cpu_single_uvm: clean
	source $(PROJECT_ROOT)/tools/xcelium/setup.csh
	xrun -64bit -sv -uvm -timescale 1ns/1ps -coverage all +UVM_TESTNAME=add_test \
		$(RTL)/alu/alu.sv \
		$(UVM)/cpu/cpu.sv \
		$(UVM)/uvm_tb/cpu_pkg.sv \
		$(UVM)/uvm_tb/cpu_bfm.sv \
		$(UVM)/top.sv \
		+incdir+$(UVM)/uvm_tb

# clean: removes output files
clean:
	rm ./xcelium.d -rf
	rm ./cov_work -rf
	rm xrun.history -f
	rm xrun.log -f


