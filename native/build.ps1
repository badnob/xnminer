$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuildDir = Join-Path $Root "build"
$EngineDir = Join-Path $Root "engine"

$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vswhere) {
    $vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    $vcvars = Join-Path $vsPath "VC\Auxiliary\Build\vcvars64.bat"
    if (Test-Path $vcvars) {
        cmd /c "`"$vcvars`" && cmake -S `"$EngineDir`" -B `"$BuildDir`" -G Ninja -DCMAKE_BUILD_TYPE=Release && cmake --build `"$BuildDir`" --config Release"
        exit $LASTEXITCODE
    }
}

cmake -S $EngineDir -B $BuildDir -DCMAKE_BUILD_TYPE=Release
cmake --build $BuildDir --config Release
exit $LASTEXITCODE