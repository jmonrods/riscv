# ./alu/: directed test for alu
alu: clean
	vlib work
	vmap work work
	vlog -sv ./alu/alu_tb.sv ./alu/alu.sv
	vsim -c work.alu_tb -do "run -all; quit -f;"

# ./cpu_single/: single-cycle riscv cpu
cpu_single: clean
	vlib work
	vmap work work
	vlog -sv ./cpu_single/cpu_tb.sv ./cpu_single/cpu.sv ./alu/alu.sv
	vsim -c work.cpu_tb -do "run -all; quit -f;"

# ./cpu_multi/: multi-cycle riscv cpu
cpu_multi: clean
	vlib work
	vmap work work
	vlog -sv ./cpu_multi/cpu_tb.sv ./cpu_multi/cpu.sv ./alu/alu.sv
	vsim -c work.cpu_tb -do "run -all; quit -f;"

# ./cpu_pipeline/: pipelined riscv cpu
cpu_pipeline: clean
	vlib work
	vmap work work
	vlog -sv \
		./cpu_pipeline/top_tb.sv \
		./cpu_pipeline/top.sv \
		./cpu_pipeline/cpu.sv \
		./cpu_pipeline/dmem.sv \
		./cpu_pipeline/imem.sv \
		./alu/alu.sv
	vsim -c work.cpu_tb -do "run -all; quit -f;"

# ./uvm/: single-cycle uvm testbench
cpu_single_uvm: clean
	vlib work
	vmap work work
	vlog -sv \
		./alu/alu.sv \
		./uvm/cpu/cpu.sv \
		./uvm/uvm_tb/cpu_pkg.sv \
		./uvm/uvm_tb/cpu_bfm.sv \
		./uvm/top.sv \
		+incdir+./uvm/uvm_tb
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
