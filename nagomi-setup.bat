@echo off
REM ============================================================
REM Nagomi Cert Setup - Windows Launcher
REM ============================================================
REM Double click this file to run the setup wizard
REM ============================================================

title Nagomi Cert Setup

echo.
echo Starting setup wizard...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-Location '%~dp0'; & '%~dp0nagomi-setup.ps1'"

if errorlevel 1 (
    echo.
    echo Error occurred. Please check the output above.
    pause
)
