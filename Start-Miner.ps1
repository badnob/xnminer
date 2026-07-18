# XenBlocks Miner by Tony.x1
# Double-click Start-Miner.bat, or run:  .\Start-Miner.ps1

$ErrorActionPreference = "Stop"
$MinerRoot = $PSScriptRoot
if (-not $MinerRoot) {
    $MinerRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
}
Set-Location -LiteralPath $MinerRoot

function Read-IniValue {
    param(
        [string]$Section,
        [string]$Key,
        [string]$Path
    )
    $inSection = $false
    foreach ($line in Get-Content -LiteralPath $Path -ErrorAction SilentlyContinue) {
        $trimmed = $line.Trim()
        if ($trimmed -match '^\[(.+)\]$') {
            $inSection = ($Matches[1] -eq $Section)
            continue
        }
        if ($inSection -and $trimmed -match ("^" + [regex]::Escape($Key) + "\s*=\s*(.+)$")) {
            return $Matches[1].Trim()
        }
    }
    return $null
}

function Stop-ExistingMiners {
    param([string]$Root)
    $stopped = @()
    $minerMain = Join-Path $Root "main.py"
    Get-CimInstance Win32_Process -Filter "Name='python.exe'" -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.CommandLine -and ($_.CommandLine -like ("*" + $minerMain + "*"))) {
            $stopped += $_.ProcessId
            Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        }
    }
    return ,$stopped
}

try {
    $configPath = Join-Path $MinerRoot "miner.ini"
    $examplePath = Join-Path $MinerRoot "miner.ini.example"

    if (-not (Test-Path -LiteralPath $configPath)) {
        if (Test-Path -LiteralPath $examplePath) {
            Copy-Item -LiteralPath $examplePath -Destination $configPath
            Write-Host "Created miner.ini from miner.ini.example" -ForegroundColor DarkGray
        } else {
            Write-Host "miner.ini missing - Python will create a default on first run." -ForegroundColor DarkGray
        }
    }

    $wallet = Read-IniValue -Section "account" -Key "address" -Path $configPath
    $backend = Read-IniValue -Section "mining" -Key "backend" -Path $configPath
    if (-not $backend) { $backend = "cuda" }
    $cudaDll = Read-IniValue -Section "cuda" -Key "dll_path" -Path $configPath
    if (-not $cudaDll) { $cudaDll = "native\build\bin\xen_cuda.dll" }

    try {
        $pyVersion = & python --version 2>&1
        if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
            throw "python --version failed"
        }
    } catch {
        Write-Host "ERROR: Python not found. Install Python 3.10+ and add it to PATH." -ForegroundColor Red
        Write-Host "Download: https://www.python.org/downloads/  (tick Add Python to PATH)" -ForegroundColor DarkGray
        Write-Host "Press Enter to exit..."
        [void][System.Console]::ReadLine()
        exit 1
    }

    # Install / refresh deps so first run only needs Python + NVIDIA drivers + Start-Miner.bat
    $reqPath = Join-Path $MinerRoot "requirements.txt"
    if (Test-Path -LiteralPath $reqPath) {
        & python -c "import argon2, pynvml, psutil, rich" 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Installing Python packages (one-time)..." -ForegroundColor DarkGray
            & python -m pip install -r $reqPath
            if ($LASTEXITCODE -ne 0) {
                Write-Host "ERROR: pip install failed. Try:  python -m pip install -r requirements.txt" -ForegroundColor Red
                Write-Host "Press Enter to exit..."
                [void][System.Console]::ReadLine()
                exit 1
            }
        }
    }

    $dllFullPath = Join-Path $MinerRoot ($cudaDll -replace "/", "\")
    if (($backend -eq "cuda") -and -not (Test-Path -LiteralPath $dllFullPath)) {
        Write-Host ("WARNING: CUDA engine not found: " + $dllFullPath) -ForegroundColor Yellow
        Write-Host "Will try to start anyway. If CUDA fails, set backend = cpu in miner.ini" -ForegroundColor DarkGray
        Write-Host "Or rebuild with:  .\native\build.ps1" -ForegroundColor DarkGray
    }

    $lockPath = Join-Path $MinerRoot "data\miner.lock"
    $running = @(Stop-ExistingMiners -Root $MinerRoot)
    if ($running.Count -gt 0) {
        Write-Host ("Stopped existing miner process(es): " + ($running -join ", ")) -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
    Remove-Item -LiteralPath $lockPath -Force -ErrorAction SilentlyContinue

    if (-not $wallet -or $wallet -eq "0x") {
        $walletShort = "setup"
        Write-Host ("XenBlocks Miner by Tony.x1  -  first-run setup  -  " + $pyVersion) -ForegroundColor Cyan
        Write-Host "You will be asked for your EVM wallet (0x...). It is saved to miner.ini." -ForegroundColor DarkGray
    } else {
        if ($wallet.Length -gt 18) {
            $walletShort = $wallet.Substring(0, 10) + "..." + $wallet.Substring($wallet.Length - 6)
        } else {
            $walletShort = $wallet
        }
        Write-Host ("XenBlocks Miner by Tony.x1  -  " + $walletShort + "  -  " + $backend + "  -  " + $pyVersion) -ForegroundColor Cyan
    }
    Write-Host "Starting... (Ctrl+C to stop)  log: data\session.log" -ForegroundColor DarkGray
    Write-Host ""

    $exitCode = 0
    & python (Join-Path $MinerRoot "main.py")
    if ($null -ne $LASTEXITCODE) {
        $exitCode = $LASTEXITCODE
    }

    if ($exitCode -ne 0) {
        Write-Host ("Miner stopped (exit code " + $exitCode + "). Check data\session.log") -ForegroundColor Yellow
        Write-Host "Press Enter to close..."
        [void][System.Console]::ReadLine()
    } else {
        Write-Host "Miner stopped." -ForegroundColor Green
    }

    exit $exitCode
} catch {
    Write-Host ""
    Write-Host ("Launcher error: " + $_) -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    Write-Host "Press Enter to close..."
    [void][System.Console]::ReadLine()
    exit 1
}
