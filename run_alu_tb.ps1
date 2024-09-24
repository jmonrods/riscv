$env:Path = 'C:\questasim64_2024.1\win64;' + $env:Path

$REPO = Get-Location
$REPO = $REPO -replace "\\","/"
Write-Host $REPO

vlib work
vmap work work
vlog -sv $REPO/uni/alu_tb.sv $REPO/uni/alu.sv 
vsim -c -voptargs=+acc work.alu_tb -do "add wave *; run -all; quit -f;"
#vsim -view vsim.wlf
