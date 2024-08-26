all:
	vlib work
	vmap work work
	vlog -sv cpu_tb.sv cpu.sv
	vsim -c work.cpu_tb -do "add wave *; run -all; quit -f;"
	vsim -view vsim.wlf
clean:
	rm ./vsim.wlf
