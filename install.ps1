### Script for installing development tools and their settings in Windows 11 21H2 ###

## Leverage access control (ensuring that the script is always run as administrator, otherwise it will not run) ##
$principal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "Attempt to start elevated process" -ForegroundColor Yellow
  try {
    $proc = Start-Process powershell.exe -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs -PassThru
    if ($proc -eq $null) { throw }
    Write-Host "Installation script run succesfully" -ForegroundColor Green
    cmd /c pause
    
    exit
  } catch {
    Write-Host "Failed to start script with elevated access" -ForegroundColor Red
    cmd /c pause
    
    exit 1
  }
}

## Precursor initialization ##

# Enabling script execution #
Set-ExecutionPolicy Bypass -Scope Process -Force

# Update TLS 1.2 protocol for communication with web services #
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072


