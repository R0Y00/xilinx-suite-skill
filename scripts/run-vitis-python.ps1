[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Source,

    [string]$VitisBat = 'D:\Xilinx\2025.2\Vitis\bin\vitis.bat'
)

$ErrorActionPreference = 'Stop'
if (-not $env:PROCESSOR_ARCHITECTURE) {
    $env:PROCESSOR_ARCHITECTURE = 'AMD64'
}
$env:PYTHONIOENCODING = 'utf-8'

$sourcePath = (Resolve-Path -LiteralPath $Source).Path
if (-not (Test-Path -LiteralPath $VitisBat -PathType Leaf)) {
    $command = Get-Command vitis -ErrorAction Stop
    $VitisBat = $command.Source
}

$ErrorActionPreference = 'Continue'
$output = @(& $VitisBat -s $sourcePath 2>&1)
$nativeExit = $LASTEXITCODE
$ErrorActionPreference = 'Stop'
$output | ForEach-Object { Write-Output $_ }

$hasMarker = [bool]($output | Where-Object { "$_" -eq 'VITIS_SCRIPT_OK' })
if ($nativeExit -ne 0 -or -not $hasMarker) {
    Write-Error "Vitis script failed or omitted the required VITIS_SCRIPT_OK marker. Native exit code: $nativeExit" -ErrorAction Continue
    exit 1
}
exit 0
