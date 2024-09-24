$env:Path = 'C:\questasim64_2024.1\win64;' + $env:Path

$REPO = Get-Location
$REPO = $REPO -replace "\\","/"
Write-Host $REPO

vlib work
vmap work work
vlog -sv $REPO/uni_rand/imem_tb.sv $REPO/uni_rand/imem.sv
vsim -c work.imem_tb -do "add wave *; run -all; quit -f;"
#vsim -view vsim.wlf
