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
    Remove-Item $REPO\modelsim.ini             -ErrorAction SilentlyContinue
    Remove-Item $REPO\transcript               -ErrorAction SilentlyContinue
    Remove-Item $REPO\vsim.wlf                 -ErrorAction SilentlyContinue
	Remove-Item $REPO\vsim_stacktrace.vstf     -ErrorAction SilentlyContinue
    Remove-Item $REPO\coverage.ucdb            -ErrorAction SilentlyContinue
} elseif ($Argument -eq "cpu_00") {
    vlib work
	vmap work work
	vlog -sv ./uni/cpu_tb.sv ./uni/cpu.sv ./uni/alu.sv
	vsim -c work.cpu_tb -do "run -all; quit -f;"
} elseif ($Argument -eq "alu_00") {
    vlib work
	vmap work work
	vlog -sv ./uni/alu_tb.sv ./uni/alu.sv
	vsim -c work.alu_tb -do "run -all; quit -f;"
} elseif ($Argument -eq "cpu_01") {
    vlib work
	vmap work work
	vlog -sv +cover ./uni/cpu_tb.sv ./uni/cpu.sv ./uni/alu.sv
	vsim -c -coverage work.cpu_tb -do "coverage save -onexit coverage.ucdb; run -all; quit -f;"
	vcover report coverage.ucdb
} elseif ($Argument -eq "cpu_02") {
    vlib work
	vmap work work
	vlog -sv ./uni_rand/imem_tb.sv ./uni_rand/imem.sv
	vsim -c work.imem_tb -do "run -all; quit -f;"
} elseif ($Argument -eq "cpu_03") {
    vlib work
	vmap work work
	vlog +cover -sv ./uni_rand_cov/imem_tb.sv ./uni_rand_cov/imem.sv
	vsim -c -coverage work.imem_tb -do "coverage save -onexit coverage.ucdb; run -all; quit -f;"
	vcover report coverage.ucdb
} elseif ($Argument -eq "cpu_04") {
    vlib work
	vmap work work
	vlog +cover -sv ./uni_rand_fulltest/cpu_tb.sv ./uni_rand_fulltest/cpu.sv ./uni_rand_fulltest/imem.sv ./uni_rand_fulltest/alu.sv
	vsim -c -coverage work.cpu_tb -do "coverage save -onexit coverage.ucdb; run -all; quit -f;"
	vcover report coverage.ucdb
} elseif ($Argument -eq "uvm_primer_tinyalu") {
    vlib work
	vmap work work
	vcom -f ./uvm_primer_tinyalu/dut.f
	vlog -f ./uvm_primer_tinyalu/tb.f
	vopt top -o top_optimized +cover=sbfec
    vsim -c top_optimized -coverage -do "set NoQuitOnFinish 1; onbreak {resume}; log /* -r; run -all; coverage save -onexit coverage.ucdb; quit;"
	vcover report coverage.ucdb
} elseif ($Argument -eq "cpu_05") {
    vlib work
	vmap work work
	vlog -sv -f ./uni_rand_oop/dut.f
	vlog -f ./uni_rand_oop/tb.f
	vopt top -o top_optimized +cover=sbfec
    vsim -c top_optimized -coverage -do "set NoQuitOnFinish 1; onbreak {resume}; log /* -r; run -all; coverage save -onexit coverage.ucdb; quit;"
	#vcover report coverage.ucdb
} else {
    Write-Host "Target not specified OR the specified target was not found."
    Write-Host "Call the command from the top as: > .\run.ps1 cpu_02"
}
