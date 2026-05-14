param(
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$lib = Join-Path $root "lib"
$missing = @()

foreach ($dll in @("SDRSharp.Common.dll", "SDRSharp.Radio.dll")) {
    if (-not (Test-Path (Join-Path $lib $dll))) {
        $missing += $dll
    }
}

if ($missing.Count -gt 0) {
    Write-Host "Ontbrekende SDR# SDK referenties in ${lib}:" -ForegroundColor Yellow
    $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    Write-Host ""
    Write-Host "Download de SDR# Plugin SDK van Airspy en kopieer SDRSharp.Common.dll en SDRSharp.Radio.dll naar de lib map."
    exit 1
}

$msbuild = "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
if (-not (Test-Path $msbuild)) {
    $msbuild = "msbuild"
}

& $msbuild (Join-Path $root "SDRSharp.FmMeter.csproj") /p:Configuration=$Configuration /restore
if ($LASTEXITCODE -eq 0) {
    exit 0
}

Write-Host ""
Write-Host "MSBuild SDK build faalde; probeer directe csc build tegen de lokale .NET 9 runtime..." -ForegroundColor Yellow

$runtimeRoot = "${env:ProgramFiles(x86)}\dotnet\shared"
$netCore = Join-Path $runtimeRoot "Microsoft.NETCore.App\9.0.6"
$desktop = Join-Path $runtimeRoot "Microsoft.WindowsDesktop.App\9.0.6"
$csc = "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\Roslyn\csc.exe"

if (-not (Test-Path $csc)) {
    throw "csc.exe niet gevonden: $csc"
}
if (-not (Test-Path $netCore) -or -not (Test-Path $desktop)) {
    throw ".NET 9 x86 runtime niet gevonden onder $runtimeRoot"
}

$outDir = Join-Path $root "bin\$Configuration\net9.0-windows"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$refs = @()
foreach ($path in @($netCore, $desktop)) {
    Get-ChildItem $path -Filter *.dll | ForEach-Object {
        try {
            [Reflection.AssemblyName]::GetAssemblyName($_.FullName) | Out-Null
            $refs += "/reference:$($_.FullName)"
        }
        catch {
        }
    }
}
$refs += "/reference:$(Join-Path $lib 'SDRSharp.Common.dll')"
$refs += "/reference:$(Join-Path $lib 'SDRSharp.Radio.dll')"
$src = Get-ChildItem (Join-Path $root "src\*.cs") | ForEach-Object { $_.FullName }
$outArg = "/out:$(Join-Path $outDir 'SDRSharp.FmMeter.dll')"

& $csc /noconfig /nostdlib /target:library /unsafe /optimize+ /nullable:enable /langversion:latest $outArg @refs @src
exit $LASTEXITCODE
