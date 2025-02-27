@echo off
setlocal

powershell -ExecutionPolicy Bypass -File "%~dp0update.ps1"
pause

endlocal