# ./uni/: directed test for cpu
cpu_00: clean
	vlib work
	vmap work work
	vlog -sv ./uni/cpu_tb.sv ./uni/cpu.sv ./uni/alu.sv
	vsim -c work.cpu_tb -do "run -all; quit -f;"

# ./uni/: directed test for alu
alu_00: clean
	vlib work
	vmap work work
	vlog -sv ./uni/alu_tb.sv ./uni/alu.sv
	vsim -c work.alu_tb -do "run -all; quit -f;"

# ./uni/: directed test with coverage
cpu_01: clean
	vlib work
	vmap work work
	vlog -sv +cover ./uni/cpu_tb.sv ./uni/cpu.sv ./uni/alu.sv
	vsim -c -coverage work.cpu_tb -do "coverage save -onexit coverage.ucdb; run -all; quit -f;"
	vcover report coverage.ucdb

# ./uni_rand/: instruction randomizer
cpu_02: clean
	vlib work
	vmap work work
	vlog -sv ./uni_rand/imem_tb.sv ./uni_rand/imem.sv
	vsim -c work.imem_tb -do "run -all; quit -f;"

# ./uni_rand_cov/: instruction randomizer with coverage
cpu_03: clean
	vlib work
	vmap work work
	vlog +cover -sv ./uni_rand_cov/imem_tb.sv ./uni_rand_cov/imem.sv
	vsim -c -coverage work.imem_tb -do "coverage save -onexit coverage.ucdb; run -all; quit -f;"
	vcover report coverage.ucdb

# ./uni_rand_fulltest/: test 400k instructions with coverage	
cpu_04: clean
	vlib work
	vmap work work
	vlog +cover -sv ./uni_rand_fulltest/cpu_tb.sv ./uni_rand_fulltest/cpu.sv ./uni_rand_fulltest/imem.sv ./uni_rand_fulltest/alu.sv
	vsim -c -coverage work.cpu_tb -do "coverage save -onexit coverage.ucdb; run -all; quit -f;"
	vcover report coverage.ucdb

# ./uni_rand_oop/: object-oriented testbench
cpu_05: clean
	vlib work
	vmap work work
	vlog -sv -f ./uni_rand_oop/dut.f
	vlog -sv -f ./uni_rand_oop/tb.f
	vopt top -o top_optimized +cover=sbfec
	vsim -c top_optimized -coverage -do "set NoQuitOnFinish 1; onbreak {resume}; log /* -r; run -all; coverage save -onexit coverage.ucdb; quit;"
	#vcover report coverage.ucdb

# ./uni_uvm/: UVM testbench
cpu_06: clean
	vlib work
	vmap work work
	vlog -sv \
		./uni_uvm/cpu/alu.sv \
		./uni_uvm/cpu/cpu.sv \
		./uni_uvm/uvm_tb/cpu_pkg.sv \
		./uni_uvm/uvm_tb/cpu_bfm.sv \
		./uni_uvm/top.sv \
		+incdir+./uni_uvm/uvm_tb
	vopt top -o top_optimized +cover=sbfec+cpu
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

