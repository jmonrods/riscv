#!/bin/bash
source ./00_setup_questa.sh
export REPO=/mnt/vol_NFS_mentordata/profesores/JJMONTERO/Work/riscv

vlib work
vmap work work
vlog -sv $REPO/uni/cpu_tb.sv $REPO/uni/cpu.sv $REPO/uni/alu.sv
vsim -c work.cpu_tb -do "add wave *; run -all; quit -f;"
#vsim -view vsim.wlf

