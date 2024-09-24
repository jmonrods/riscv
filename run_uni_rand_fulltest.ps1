$env:Path = 'C:\questasim64_2024.1\win64;' + $env:Path

$REPO = Get-Location
$REPO = $REPO -replace "\\","/"
Write-Host $REPO

vlib work
vmap work work
vlog -sv +cover $REPO/uni_rand_fulltest/cpu_tb.sv $REPO/uni_rand_fulltest/cpu.sv $REPO/uni_rand_fulltest/imem.sv $REPO/uni_rand_fulltest/alu.sv
vsim -c -coverage work.cpu_tb -do "coverage save -onexit coverage.ucdb; run -all; quit -f;"
vcover report $REPO/coverage.ucdb
#vsim -view vsim.wlf
