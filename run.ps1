vlib work
vmap work work
vlog -sv $REPO/uni/cpu_tb.sv $REPO/uni/cpu.sv 
vsim -c -voptargs=+acc work.cpu_tb -do "add wave *; run -all; quit -f;"
#vsim -view vsim.wlf
