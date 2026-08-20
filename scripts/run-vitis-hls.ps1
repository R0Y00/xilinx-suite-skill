[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Source,
    [string]$VitisRunBat = 'D:\Xilinx\2025.2\Vitis\bin\vitis-run.bat',
    [string]$CleanUserProfile
)

$ErrorActionPreference = 'Stop'
if (-not $env:PROCESSOR_ARCHITECTURE) { $env:PROCESSOR_ARCHITECTURE = 'AMD64' }
$env:PYTHONIOENCODING = 'utf-8'
$sourcePath = (Resolve-Path -LiteralPath $Source).Path
if (-not (Test-Path -LiteralPath $VitisRunBat -PathType Leaf)) {
    throw "Vitis HLS launcher not found: $VitisRunBat"
}
if ($CleanUserProfile) {
    $profilePath = [System.IO.Path]::GetFullPath($CleanUserProfile)
    New-Item -ItemType Directory -Path $profilePath -Force | Out-Null
    $env:USERPROFILE = $profilePath
}

$ErrorActionPreference = 'Continue'
$output = @(& $VitisRunBat --mode hls --tcl $sourcePath 2>&1)
$nativeExit = $LASTEXITCODE
$ErrorActionPreference = 'Stop'
$output | ForEach-Object { Write-Output $_ }
$hasMarker = [bool]($output | Where-Object { "$_" -eq 'HLS_FLOW_PASS' })
if ($nativeExit -ne 0 -or -not $hasMarker) {
    Write-Error "Vitis HLS failed or omitted HLS_FLOW_PASS. Native exit code: $nativeExit" -ErrorAction Continue
    exit 1
}
exit 0
