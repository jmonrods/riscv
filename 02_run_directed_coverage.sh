#!/bin/bash
source ./00_setup_questa.sh
export REPO=/mnt/vol_NFS_mentordata/profesores/JJMONTERO/Work/riscv

vlib work
vmap work work
vlog -sv $REPO/uni/cpu_tb.sv $REPO/uni/cpu.sv $REPO/uni/alu.sv +cover
vsim -c -coverage work.cpu_tb -do "coverage report -output coverage.txt; coverage save coverage.ucdb; run -all; quit -f;"
vcover report coverage.ucdb
#vsim -view vsim.wlf

