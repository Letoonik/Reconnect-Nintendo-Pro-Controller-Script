@echo off
setlocal enabledelayedexpansion

rem === Config ===
set "DEVICE_NAME=Pro Controller"
set "BLUETOOTHCL=BluetoothCL.exe"
set "BTPAIR=btpair.exe"
set "TIMEOUT=1"
set "PIN=0000"
rem ======================

where "%BLUETOOTHCL%" >nul 2>&1
if errorlevel 1 (
  echo Error: %BLUETOOTHCL% not found.
  pause
  goto :eof
)
where "%BTPAIR%" >nul 2>&1
if errorlevel 1 (
  echo Error: %BTPAIR% not found.
  pause
  goto :eof
)

echo Scan for "%DEVICE_NAME%" (timeout=%TIMEOUT%s)...
"%BLUETOOTHCL%" -timeout %TIMEOUT% > "%temp%\bt_scan.txt" 2>nul
findstr /i "%DEVICE_NAME%" "%temp%\bt_scan.txt" > "%temp%\bt_result.txt" 2>nul

set "MAC="
for /f "usebackq tokens=1* delims= " %%A in ("%temp%\bt_result.txt") do (
  set "MAC=%%A"
  set "DEVLINE=%%B"
  goto :found
)

:found
if defined MAC (
  echo Found: !DEVLINE!   MAC=!MAC!
  echo Unpair...
  "%BTPAIR%" -u -b !MAC!
  timeout /t 1 >nul
  echo Trying to pair...
  if "%PIN%"=="" (
    "%BTPAIR%" -p -b !MAC!
  ) else (
    "%BTPAIR%" -p%PIN% -b !MAC!
  )
) else (
  echo No Pro Controller found, check if controller is in paring mode
)

del "%temp%\bt_scan.txt" 2>nul
del "%temp%\bt_result.txt" 2>nul

pause
endlocal
