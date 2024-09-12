$env:Path = 'C:\intelFPGA\20.1\modelsim_ase\win32aloem;' + $env:Path

$REPO = Get-Location
$REPO = $REPO -replace "\\","/"
Write-Host $REPO

vlib work
vmap work work
vlog -sv $REPO/uni/cpu_tb.sv $REPO/uni/cpu.sv 
vsim -c -voptargs=+acc work.cpu_tb -do "add wave *; run -all; quit -f;"
#vsim -view vsim.wlf
