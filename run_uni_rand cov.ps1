$env:Path = 'C:\questasim64_2024.1\win64;' + $env:Path

$REPO = Get-Location
$REPO = $REPO -replace "\\","/"
Write-Host $REPO

vlib work
vmap work work
vlog -sv $REPO/uni_rand_cov/imem_tb.sv $REPO/uni_rand_cov/imem.sv +cover
vsim -c -coverage work.imem_tb -do "coverage save -onexit coverage.ucdb; run -all; quit -f;"
vcover report $REPO/coverage.ucdb
#vsim -view vsim.wlf
