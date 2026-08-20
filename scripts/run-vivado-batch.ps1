[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Source,

    [string]$VivadoBat
)

$ErrorActionPreference = 'Stop'

# Some managed shells omit this variable. AMD's Windows loader may then exit
# silently before starting Vivado. Limit the fallback to this child process.
if (-not $env:PROCESSOR_ARCHITECTURE) {
    $env:PROCESSOR_ARCHITECTURE = 'AMD64'
}

$sourcePath = (Resolve-Path -LiteralPath $Source).Path
$driverPath = Join-Path $PSScriptRoot 'vivado-batch-driver.tcl'

if (-not $VivadoBat) {
    $command = Get-Command vivado -ErrorAction Stop
    $VivadoBat = $command.Source
}

& $VivadoBat -mode batch -nolog -nojournal -source $driverPath -tclargs $sourcePath
exit $LASTEXITCODE
