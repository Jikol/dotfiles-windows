Write-Host "TEST"

<#
### Script for installing development tools and their settings in Windows 11 21H2 ###

## Leverage access control (ensuring that the script is always run as administrator, otherwise it will not run) ##
$principal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (! $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
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

# Generate log file & start logging #
$dateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logPath = "$env:localappdata\install\logs"
[System.IO.Directory]::CreateDirectory("$logPath") | Out-Null
Start-Transcript -Path "$logPath\install_$dateTime.log" -Append -Force -NoClobber | Out-Null
Write-Host "Creating log file at $logPath\install_$dateTime.log" -ForegroundColor Cyan

# Create a system restore point #
Write-Host "Creating a system restore point" -ForegroundColor Cyan
$restorePointName = "pre_install_$currentDateTime"
try {
  Checkpoint-Computer -Description $restorePointName -RestorePointType "MODIFY_SETTINGS"
  Write-Host "System restore point created successfully" -ForegroundColor Green
} catch {
  Write-Host "Failed to create system restore point" -ForegroundColor Red
  Stop-Transcript
  
  exit 1
}

# Setting PowerShell to UTF-8 encoding #
Write-Host "Setting PowerShell to UTF-8 encoding" -ForegroundColor Cyan
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Enabling script execution #
Write-Host "Enabling script execution" -ForegroundColor Cyan
Set-ExecutionPolicy Bypass -Scope Process -Force

# Update TLS 1.2 protocol for communication with web services #
Write-Host "Updating TLS 1.2 protocol for communication with web services" -ForegroundColor Cyan
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Disabling User Access Control (UAC) #
Write-Host "Disabling User Access Control (UAC)" -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0

# Preventing the system from going to sleep #
Write-Host "Preventing the system from going to sleep during installation" -ForegroundColor Cyan
powercfg -change -standby-timeout-ac 0
powercfg -change -monitor-timeout-ac 0
powercfg -change -disk-timeout-ac 0

# Check for network availability #
Write-Host "Checking for network availability" -ForegroundColor Cyan
if (-Not Test-Connection -ComputerName 8.8.8.8 -Count 3 -Quiet) {
  Write-Host "Network is unavailable, check your connection and try again" -ForegroundColor Red
  Stop-Transcript
  
  exit 1
}

## Programs & Package Managers installation ##

# WSL
$url = "https://github.com/microsoft/WSL/releases/download/2.4.11/wsl.2.4.11.0.x64.msi"
$destinationPath = "$env:TEMP\wsl.2.4.11.0.x64.msi"
try {
  Invoke-WebRequest -Uri $url -OutFile $destinationPath -ErrorAction Stop
  Start-Process -FilePath $destinationPath -ArgumentList "/quiet" -Wait -ErrorAction Stop
} catch {
  Write-Host "Failed to download and install WSL (Error: $_)" -ForegroundColor Red
  Stop-Transcript

  exit 1
}

# Stop logging #
Stop-Transcript
#>

cmd /c pause
