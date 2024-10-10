## run.ps1
# Wrapper script to run simulations using Questa under Windows
#
# Usage: from the top-level directory, call the script with one argument
# The argument is the complete name of the problem without the file extension
# Read the script to look for the available "targets"
#
# Example:
# .\run.ps1 cpu_02

param(
    [string]$Argument
)

# Path to Questa
$env:Path = 'C:\questasim64_2024.1\win64;' + $env:Path

# Path to Repo
$REPO = Get-Location
$REPO = $REPO -replace "\\","/"
Write-Host $REPO
New-Item -ItemType Directory -Force -Path $REPO\target

# This line converts all backlashes into forward slashes for Questa
$REPO = $REPO -replace "\\","/"
Write-Host $REPO


# Run the simulation now
if ($Argument -eq "clean") {
    Remove-Item $REPO\work\ -Recurse           -ErrorAction SilentlyContinue
	Remove-Item $REPO\target\ -Recurse         -ErrorAction SilentlyContinue
    Remove-Item $REPO\modelsim.ini             -ErrorAction SilentlyContinue
    Remove-Item $REPO\transcript               -ErrorAction SilentlyContinue
    Remove-Item $REPO\vsim.wlf                 -ErrorAction SilentlyContinue
	Remove-Item $REPO\vsim_stacktrace.vstf     -ErrorAction SilentlyContinue
    Remove-Item $REPO\coverage.ucdb            -ErrorAction SilentlyContinue
} elseif ($Argument -eq "alu") {
    vlib work
	vmap work work
	vlog -sv ./alu/alu_tb.sv ./alu/alu.sv
	vsim -c work.alu_tb -do "run -all; quit -f;"
} elseif ($Argument -eq "cpu_single") {
    vlib work
	vmap work work
	vlog -sv ./cpu_single/cpu_tb.sv ./cpu_single/cpu.sv ./alu/alu.sv
	vsim -c work.cpu_tb -do "run -all; quit -f;"
} elseif ($Argument -eq "cpu_multi") {
    vlib work
	vmap work work
	vlog -sv ./cpu_multi/cpu_tb.sv ./cpu_multi/cpu.sv ./alu/alu.sv
	vsim -c work.cpu_tb -do "run -all; quit -f;"
} elseif ($Argument -eq "cpu_pipeline") {
    vlib work
	vmap work work
	vlog -sv `
		./cpu_pipeline/top_tb.sv `
		./cpu_pipeline/top.sv `
		./cpu_pipeline/cpu.sv `
		./cpu_pipeline/imem.sv `
		./cpu_pipeline/dmem.sv
	vsim -c work.top_tb -do "run -all; quit -f;"
} elseif ($Argument -eq "cpu_single_uvm") {
	# UVM testbench
    vlib work
	vmap work work
	vlog -sv `
		./alu/alu.sv `
		./uvm/cpu/cpu.sv `
		./uvm/uvm_tb/cpu_pkg.sv `
		./uvm/uvm_tb/cpu_bfm.sv `
		./uvm/top.sv `
		+incdir+./uvm/uvm_tb
	vopt top -o top_optimized +cover=sbfec+cpu
	vsim -c +UVM_TESTNAME="add_test" top_optimized -coverage -do "set NoQuitOnFinish 1; onbreak {resume}; log /* -r; run -all; coverage save -onexit coverage.ucdb; quit;"
	vcover report coverage.ucdb
	vsim -c +UVM_TESTNAME="random_test" top_optimized -coverage -do "set NoQuitOnFinish 1; onbreak {resume}; log /* -r; run -all; coverage save -onexit coverage.ucdb; quit;"
	vcover report coverage.ucdb
} else {
    Write-Host "Target not specified OR the specified target was not found."
    Write-Host "Call the command from the top as: > .\run.ps1 cpu_02"
}
