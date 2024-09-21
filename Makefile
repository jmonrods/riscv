cpu_directed: clean
	vlib work
	vmap work work
	vlog -sv ./uni/cpu_tb.sv ./uni/cpu.sv ./uni/alu.sv
	vsim -c work.cpu_tb -do "run -all; quit -f;"

cpu_directed_cov: clean
	vlib work
	vmap work work
	vlog -sv +cover ./uni/cpu_tb.sv ./uni/cpu.sv ./uni/alu.sv
	vsim -c -coverage work.cpu_tb -do "coverage save -onexit coverage.ucdb; run -all; quit -f;"
	vcover report coverage.ucdb

imem_randomizer: clean
	vlib work
	vmap work work
	vlog -sv ./uni_rand/imem_tb.sv ./uni_rand/imem.sv
	vsim -c work.imem_tb -do "run -all; quit -f;"

imem_rand_cov: clean
	vlib work
	vmap work work
	vlog +cover -sv ./uni_rand_cov/imem_tb.sv ./uni_rand_cov/imem.sv
	vsim -c -coverage work.imem_tb -do "coverage save -onexit coverage.ucdb; run -all; quit -f;"
	vcover report coverage.ucdb
	
cpu_fulltest: clean
	vlib work
	vmap work work
	vlog +cover -sv ./uni_rand_fulltest/cpu_tb.sv ./uni_rand_fulltest/cpu.sv ./uni_rand_fulltest/imem.sv ./uni_rand_fulltest/alu.sv
	vsim -c -coverage work.cpu_tb -do "coverage save -onexit coverage.ucdb; run -all; quit -f;"
	vcover report coverage.ucdb

clean:
	rm ./vsim.wlf -f
	rm ./vsim.dbg -f
	rm ./modelsim.ini -f
	rm ./coverage.ucdb -f
	rm ./coverage.txt -f
	rm ./work/ -rf
	rm ./transcript -f

