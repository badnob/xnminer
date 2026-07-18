@echo off
setlocal
cd /d "%~dp0"

REM Keep the window open if PowerShell fails to start the script
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Start-Miner.ps1"
set "ERR=%ERRORLEVEL%"

if not "%ERR%"=="0" (
  echo.
  echo Start-Miner failed with exit code %ERR%.
  echo If the window closed before, run from a terminal:
  echo   cd /d "%~dp0"
  echo   python main.py
  echo.
  pause
)

exit /b %ERR%
