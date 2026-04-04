@echo off
pwsh -ExecutionPolicy Bypass -NoLogo -Command "& { . $PROFILE; commit %*}"
