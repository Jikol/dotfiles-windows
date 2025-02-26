@echo off
setlocal

taskkill /f /im explorer.exe
cd /d %USERPROFILE%\AppData\Local
del /a IconCache.db
start explorer.exe

endlocal