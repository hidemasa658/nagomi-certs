@echo off
REM ============================================================
REM Nagomi Cert Setup - Online One-Click Installer
REM ============================================================
REM This bat downloads the PowerShell script from GitHub and runs it
REM Only this file needs to be sent to end users
REM ============================================================

title Nagomi Cert Setup (Online)

echo.
echo ============================================================
echo   Nagomi Cert Setup - Online Installer
echo ============================================================
echo.
echo   GitHub から 最新の セットアップスクリプトを ダウンロード
echo   実行中...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "iex (Invoke-WebRequest -Uri 'https://github.com/hidemasa658/nagomi-certs/raw/main/nagomi-setup.ps1' -UseBasicParsing).Content"

if errorlevel 1 (
    echo.
    echo Error occurred. Please check the output above.
    pause
)
