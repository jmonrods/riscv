$env:Path = 'C:\questasim64_2024.1\win64;' + $env:Path

$REPO = Get-Location
$REPO = $REPO -replace "\\","/"
Write-Host $REPO

Remove-Item $REPO\work\ -Recurse
Remove-Item $REPO\modelsim.ini
Remove-Item $REPO\transcript
Remove-Item $REPO\vsim.wlf
Remove-Item $REPO\coverage.ucdb