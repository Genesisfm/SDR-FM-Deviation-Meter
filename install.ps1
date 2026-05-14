param(
    [string]$SdrSharpRoot = "C:\SDRSharp",
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$source = Join-Path $root "bin\$Configuration\net9.0-windows\SDRSharp.FmMeter.dll"
$plugins = Join-Path $SdrSharpRoot "Plugins\FmMeter"

if (-not (Test-Path $source)) {
    throw "Build output niet gevonden: $source"
}

New-Item -ItemType Directory -Force -Path $plugins | Out-Null
Copy-Item -Force -Path $source -Destination $plugins

Write-Host "Geinstalleerd naar $plugins"
Write-Host "Voor oudere SDR# builds kun je deze magic line gebruiken:"
Write-Host '<add key="FM Deviation Meter" value="SDRSharp.FmMeter.FmMeterPlugin,SDRSharp.FmMeter" />'
