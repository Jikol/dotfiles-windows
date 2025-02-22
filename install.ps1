### Script for installing & initializing tools for development in Windows 11 21H2 ###

## Global parameters ## 
param (
  [ValidateSet("personal", "work")]
  [string]$scope,
  [switch]$backup
)

## Helper functions ##
function Get-Env { [OutputType([string])]param([string]$name, [System.EnvironmentVariableTarget]$scope = [System.EnvironmentVariableTarget]::User)return [Environment]::GetEnvironmentVariable($name, $scope) } # noqa: *
function Set-Env { param([string]$name, [string]$value, [switch]$delete, [System.EnvironmentVariableTarget]$scope = [System.EnvironmentVariableTarget]::User)if ($delete) { [Environment]::SetEnvironmentVariable($name, $null, $scope) }[Environment]::SetEnvironmentVariable($name, $value, $scope) }
function Sync-Env { $userName = $env:USERNAME; $architecture = $env:PROCESSOR_ARCHITECTURE; $psModulePath = $env:PSModulePath; $scopeList = "Process", "Machine"; if ("SYSTEM", "${env:COMPUTERNAME}`$" -notcontains $userName) { $scopeList += "User" }foreach ($scope in $scopeList) { $envList = [string]::Empty; switch ($scope) { "User" { $envList = Get-Item "HKCU:\Environment" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property }"Machine" { $envList = Get-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" | Select-Object -ExpandProperty Property }"Process" { $envList = Get-ChildItem Env:\ | Select-Object -ExpandProperty Key } }; $envList | ForEach-Object { Set-Item "Env:$_"-Value(Get-Env -scope $scope -name $_) } }; $paths = "Machine", "User" | ForEach-Object { (Get-Env -name "Path" -scope $_) -split ';' } | Select-Object -Unique; $env:Path = $paths -join ';'; $env:PSModulePath = $psModulePath; if ($userName) { $env:USERNAME = $userName }; if ($architecture) { $env:PROCESSOR_ARCHITECTURE = $architecture } }
function Add-Path { param([string]$path)$currentPath = Get-Env -Name "PATH"; if ($currentPath -notlike "*$path*") { Set-Env -Name "PATH" -Value "$currentPath;$path" } }
function New-Shortcut { param([string]$path, [string]$target, [string]$dir)$shell = New-Object -ComObject WScript.Shell; $shortcut = $shell.CreateShortcut($path); $shortcut.TargetPath = $target; $shortcut.WorkingDirectory = $dir; $shortcut.IconLocation = $target; $shortcut.Save() }
function Stop-Execution { param([string]$message)Write-Host $message -ForegroundColor Red; Stop-Transcript; pause; Set-Env -Name "EXIT_MESSAGE" -Value $message; Stop-Process -Id $PID -Force }

## Leverage access control (ensuring that the script is always run as administrator, otherwise it will not run) ##
$principal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (! $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "Attempt to start elevated process" -ForegroundColor Yellow
  try {
    $scriptPath = $null
    if ($MyInvocation.MyCommand.Path) {
      $scriptPath = $MyInvocation.MyCommand.Path
    }
    else {
      $scriptContent = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Jikol/dotconfig-windows/refs/heads/master/install.ps1"
      Set-Content -Path "$env:TEMP/install.ps1" -Value $scriptContent
      $scriptPath = "$env:TEMP/install.ps1"
    }
    $proc = Start-Process powershell.exe -ArgumentList "-NoExit -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs -PassThru
    if ($null -eq $proc) { throw "Could not start the elevated process" }
    $proc.WaitForExit()
    if ($proc.ExitCode -ne 0) { throw "Script execution failed: $(Get-Env -Name "EXIT_MESSAGE")" }
    Write-Host "Installation script run succesfully" -ForegroundColor Green

    if ($MyInvocation.MyCommand.Path) { exit } else { return }
  }
  catch {
    Write-Host "$_" -ForegroundColor Red
    Set-Env -Name "EXIT_MESSAGE" -Delete

    if ($MyInvocation.MyCommand.Path) { exit 1 } else { return }
  }
}

## Setup initialization ##

# Global variables #
$dateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$autoStartupRegistry = (Resolve-Path -Path "HKCU:/Software/Microsoft/Windows/CurrentVersion/Run")
$startmenuShortcuts = @(
  (Resolve-Path -Path "$env:APPDATA/Microsoft/Windows/Start Menu/Programs"),
  (Resolve-Path -Path "$env:PROGRAMDATA/Microsoft/Windows/Start Menu/Programs")
)

# Generate log file & start logging #
$logPath = "$env:LOCALAPPDATA/install/logs"
[System.IO.Directory]::CreateDirectory("$logPath") | Out-Null
Start-Transcript -Path "$logPath/install_$dateTime.log" -Append -Force -NoClobber | Out-Null
Write-Host "Creating log file at $logPath/install_$dateTime.log" -ForegroundColor Cyan

# Enabling user script execution #
Write-Host "Enabling script execution" -ForegroundColor Cyan
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force

# Setting PowerShell to UTF-8 encoding #
Write-Host "Setting PowerShell to UTF-8 encoding" -ForegroundColor Cyan
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Update TLS 1.2 protocol for communication with web services #
Write-Host "Updating TLS 1.2 protocol for communication with web services" -ForegroundColor Cyan
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Reset User Access Control (UAC) #
Write-Host "Disabling User Access Control (UAC)" -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:/Software/Microsoft/Windows/CurrentVersion/Policies/System" -Name "EnableLUA" -Value 1

# Preventing the system from going to sleep during script execution #
Write-Host "Preventing the system from going to sleep during installation" -ForegroundColor Cyan
powercfg -change -standby-timeout-ac 0
powercfg -change -monitor-timeout-ac 0
powercfg -change -disk-timeout-ac 0

# Check for network availability #
Write-Host "Checking for network availability" -ForegroundColor Cyan
if (! (Test-Connection -ComputerName 8.8.8.8 -Count 3 -Quiet)) {
  $errorMessage = "Network is unavailable, check your connection and try again"
  Stop-Execution -Message $errorMessage
}

## Backup actions ##

# Create a system restore point #
Write-Host "Creating a system restore point" -ForegroundColor Cyan
$restorePointName = "pre_install_$currentDateTime"
try {
  Checkpoint-Computer -Description $restorePointName -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
  Write-Host "System restore point created successfully" -ForegroundColor Green
}
catch {
  $errorMessage = "Failed to create system restore point"
  Stop-Execution -Message $errorMessage
}

# Create registry backup #
$backupPath = "$env:LOCALAPPDATA/install/backups"
[System.IO.Directory]::CreateDirectory("$backupPath") | Out-Null
$backupFile = "$backupPath/RegistryBackup_$dateTime.reg"
try {
  Write-Host "Creating a registry backup at $backupPath/RegistryBackup_$dateTime.reg" -ForegroundColor Cyan
  reg export HKLM $backupFile /y
  Write-Host "Registry backup created at $backupFile" -ForegroundColor Green
}
catch {
  $errorMessage = "Failed to create registry backup (Error: $_)"
  Stop-Execution -Message $errorMessage
}

## Software installation ##

# WSL #
$url = "https://github.com/microsoft/WSL/releases/download/2.4.11/wsl.2.4.11.0.x64.msi"
$destinationPath = "$env:TEMP/wsl.2.4.11.0.x64.msi"
try {
  Get-Command wsl -ErrorAction Stop | Out-Null
  Write-Host "WSL is already installed" -ForegroundColor Green
}
catch {
  try {
    Write-Host "Installing windows subsystem for linux (WSL)" -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $destinationPath -ErrorAction Stop
    Start-Process -FilePath $destinationPath -ArgumentList "/quiet" -Wait -ErrorAction Stop
    Sync-Env
    Get-Command wsl -ErrorAction Stop | Out-Null
    Write-Host "WSL has been successfully installed" -ForegroundColor Green
  }
  catch {
    $errorMessage = "Failed to download and install WSL (Error: $_)"
    Stop-Execution -Message $errorMessage
  }
}
Write-Host "Attempt to update" -ForegroundColor Yellow
wsl --update
Write-Host "Current state & version" -ForegroundColor Cyan
wsl --version
wsl --status

# Winget #
$url = "https://github.com/microsoft/winget-cli/releases/download/v1.9.25200/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$destinationPath = "$env:TEMP/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
try {
  Get-Command winget -ErrorAction Stop | Out-Null
  Write-Host "WinGet is already installed" -ForegroundColor Green
}
catch {
  try {
    Write-Host "Installing windows package manager (Winget)" -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $destinationPath -ErrorAction Stop
    Add-AppxPackage -Path $destinationPath -ErrorAction Stop
    Sync-Env
    Get-Command winget -ErrorAction Stop | Out-Null
    Write-Host "Winget has been successfully installed" -ForegroundColor Green
  }
  catch {
    $errorMessage = "Failed to download and install Winget (Error: $_)"
    Stop-Execution -Message $errorMessage
  }
}
Write-Host "Current info & version" -ForegroundColor Cyan
winget --version
winget --info

# Chocolatey #
$url = "https://community.chocolatey.org/install.ps1"
try {
  Get-Command choco -ErrorAction Stop | Out-Null
  Write-Host "Chocolatey is already installed" -ForegroundColor Green
}
catch {
  try {
    Write-Host "Installing Chocolatey package manager" -ForegroundColor Cyan
    Invoke-RestMethod -Uri $url | Invoke-Expression -ErrorAction Stop
    Sync-Env
    Get-Command choco -ErrorAction Stop | Out-Null
    Write-Host "Chocolatey has been successfully installed" -ForegroundColor Green
  }
  catch {
    $errorMessage = "Failed to download and install Chocolatey (Error: $_)"
    Stop-Execution -Message $errorMessage
  }
}
Write-Host "Attempt to update" -ForegroundColor Yellow
choco upgrade chocolatey
Write-Host "Current version" -ForegroundColor Cyan
choco --version

# Scoop #
$url = "https://get.scoop.sh"
try {
  Get-Command scoop -ErrorAction Stop | Out-Null
  Write-Host "Scoop is already installed" -ForegroundColor Green
}
catch {
  try {
    Write-Host "Installing Scoop package manager" -ForegroundColor Cyan
    Invoke-RestMethod -Uri $url | Invoke-Expression -ErrorAction Stop
    Sync-Env
    Get-Command scoop -ErrorAction Stop | Out-Null
    Write-Host "Scoop has been successfully installed" -ForegroundColor Green
  }
  catch {
    $errorMessage = "Failed to download and install Scoop (Error: $_)"
    Stop-Execution -Message $errorMessage
  }
}
Write-Host "Attempt to update" -ForegroundColor Yellow
scoop update
Write-Host "Current bucket versions & status" -ForegroundColor Cyan
scoop --version
scoop status

## Packages installation ##

# Chezmoi #
try {
  scoop install chezmoi
  scoop update chezmoi
  Get-Command chezmoi -ErrorAction Stop | Out-Null
  chezmoi init --force jikol/dotfiles-windows
  chezmoi apply --force
}
catch {
  Write-Host "Failed to install & setup chezmoi (Error: $_)" -ForegroundColor Red
}

# Delete default start menu shortcuts #
foreach ($dir in $startmenuShortcuts) {
  try {
    Get-ChildItem -Path $dir -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction Stop
    Write-Host "All start menu shortcuts in $dir have been deleted" -ForegroundColor Yellow
  }
  catch {
    $errorMessage = "Failed to delete files in $dir (Error: $_)"
    Stop-Execution -Message $errorMessage
  }
}

# Delete default startup logon shortcuts #
try {
  Get-Item -Path $autoStartupRegistry | Get-ItemProperty | ForEach-Object {
    $names = $_.PSObject.Properties.Name
    foreach ($name in $names) {
      if ($name -notin @("PSPath", "PSParentPath", "PSChildName", "PSDrive", "PSProvider")) {
        Remove-ItemProperty -Path $autoStartupRegistry -Name $name -ErrorAction Stop
      }
    }
  }
  Write-Host "All startup program entries in $autoStartupRegistry have been deleted" -ForegroundColor Yellow
}
catch {
  $errorMessage = "Failed to clear startup programs in $autoStartupRegistry (Error: $_)"
  Stop-Execution -Message $errorMessage
}

# Chocolatey #
$packages = Get-Content -Path "$env:CHEZMOI_LOCAL_PATH/packages/chocolatey.json" | ConvertFrom-Json
foreach ($package in $packages.data) {
  try {
    choco install $package.name -y
    Sync-Env
    $execPath = Resolve-Path -Path ([Environment]::ExpandEnvironmentVariables($package.execPath)) -ErrorAction Stop
    if ($package.shell) {
      Add-Path -Path (Resolve-Path -Path ([Environment]::ExpandEnvironmentVariables($package.shell.path)) -ErrorAction Stop)
      Sync-Env
      Get-Command $package.shell.cmd -ErrorAction Stop | Out-Null
      Write-Host "Added shell command $($package.shell.cmd)" -ForegroundColor Green
    }
    if ($package.envAdd) {
      foreach ($env in $package.envAdd) {
        Set-Env -Name $env.name -Value $env.value
        Write-Host "Added [$($env.name):$($env.value)] environment variable" -ForegroundColor Green
      }
    }
    if ($package.autoStartup) {
      Set-ItemProperty -Path $autoStartupRegistry -Name $package.autoStartup -Value $execPath -Type String -ErrorAction Stop
      Write-Host "Added $($package.autoStartup) program to run after login ($autoStartupRegistry)" -ForegroundColor Green
    }
    if ($package.startShortcut) {
      New-Shortcut -Target $execPath -Path (
        Join-Path -Path $startmenuShortcuts[0] -ChildPath "$($package.startShortcut).lnk"
      ) -Dir $startmenuShortcuts[0]
      Write-Host "Added start menu shortcut $($package.startShortcut) to $($startmenuShortcuts[0])" -ForegroundColor Green
    }
  }
  catch {
    Write-Host "Failed to install & setup $($package.name) chocolatey package (Error: $_)" -ForegroundColor Red
  }
}

# Stop logging #
Stop-Transcript

pause
[System.Environment]::Exit(0)
