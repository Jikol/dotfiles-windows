### Script for installing development tools and their settings in Windows 11 21H2 ###

## Helper functions ##
function Get-Env{[OutputType([string])][CmdletBinding()]param([string]$name,[System.EnvironmentVariableTarget]$scope=[System.EnvironmentVariableTarget]::User)return [Environment]::GetEnvironmentVariable($name,$scope)}
function Set-Env{param([string]$name,[string]$value,[switch]$delete,[System.EnvironmentVariableTarget]$scope=[System.EnvironmentVariableTarget]::User)if($delete){[Environment]::SetEnvironmentVariable($name,$null,$scope)}[Environment]::SetEnvironmentVariable($name,$value,$scope)}
function Sync-Env{$userName=$env:USERNAME;$architecture=$env:PROCESSOR_ARCHITECTURE;$psModulePath=$env:PSModulePath;$scopeList="Process","Machine";if("SYSTEM","${env:COMPUTERNAME}`$"-notcontains $userName){$scopeList+="User"}foreach($scope in $scopeList){$envList=[string]::Empty;switch($scope){"User"{$envList=Get-Item "HKCU:\Environment" -ErrorAction SilentlyContinue|Select-Object -ExpandProperty Property}"Machine"{$envList=Get-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"|Select-Object -ExpandProperty Property}"Process"{$envList=Get-ChildItem Env:\|Select-Object -ExpandProperty Key}};$envList|ForEach-Object{Set-Item "Env:$_"-Value(Get-Env -scope $scope -name $_)}};$paths="Machine","User"|ForEach-Object{(Get-Env -name "Path" -scope $_)-split ';'}|Select-Object -Unique;$env:Path=$paths-join ';';$env:PSModulePath=$psModulePath;if($userName){$env:USERNAME=$userName};if($architecture){$env:PROCESSOR_ARCHITECTURE=$architecture}}
function Stop-Instalation {
  param(
    [string]$message
  )
  Write-Host $message -ForegroundColor Red
  Stop-Transcript
  pause
  Set-Env -Name "EXIT_MESSAGE" -Value $message
  Stop-Process -Id $PID -Force
}
function Install-Script {
  param(
    [string]$url,
    [string]$programName,
    [string]$programCli
  )
  try {
    Write-Host "Installing $programName package manager ($programCli)" -ForegroundColor Cyan
    Invoke-RestMethod -Uri $url | Invoke-Expression
    Sync-Env
    Get-Command $programCli -ErrorAction Stop
    Write-Host "$programName has been successfully installed" -ForegroundColor Green
    & $programCli --version
  } catch {
    $errorMessage = "Failed to download and install $programName (Error: $_)"
    Stop-Instalation -Message $errorMessage
  }
}

## Leverage access control (ensuring that the script is always run as administrator, otherwise it will not run) ##
$principal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (! $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "Attempt to start elevated process" -ForegroundColor Yellow
  try {
    $scriptPath = $null
    if ($MyInvocation.MyCommand.Path) {
      $scriptPath = $MyInvocation.MyCommand.Path
    } else {
      $scriptContent = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Jikol/dotconfig-windows/refs/heads/master/install.ps1"
      Set-Content -Path "$env:TEMP\install.ps1" -Value $scriptContent 
      $scriptPath = "$env:TEMP\install.ps1"
    }
    $proc = Start-Process powershell.exe -ArgumentList "-NoExit -File `"$scriptPath`"" -Verb RunAs -PassThru
    if ($null -eq $proc) { throw "Could not start the elevated process" }
    $proc.WaitForExit()
    if ($proc.ExitCode -ne 0) { throw "Script execution failed: $(Get-Env -Name "EXIT_MESSAGE")" }
    Write-Host "Installation script run succesfully" -ForegroundColor Green

    if ($MyInvocation.MyCommand.Path) { exit } else { return }
  } catch {
    Write-Host "$_" -ForegroundColor Red
    Set-Env -Name "EXIT_MESSAGE" -Delete

    if ($MyInvocation.MyCommand.Path) { exit 1 } else { return }
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
  $errorMessage = "Failed to create system restore point"
  Stop-Instalation -Message $errorMessage
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
if (! (Test-Connection -ComputerName 8.8.8.8 -Count 3 -Quiet)) {
  $errorMessage = "Network is unavailable, check your connection and try again"
  Stop-Instalation -Message $errorMessage
}

## Package Managers installation ##

# WSL #
$url = "https://github.com/microsoft/WSL/releases/download/2.4.11/wsl.2.4.11.0.x64.msi"
$destinationPath = "$env:TEMP\wsl.2.4.11.0.x64.msi"
try {
  Write-Host "Installing windows subsystem for linux (WSL)" -ForegroundColor Cyan
  Invoke-WebRequest -Uri $url -OutFile $destinationPath -ErrorAction Stop
  Start-Process -FilePath $destinationPath -ArgumentList "/quiet" -Wait -ErrorAction Stop
  Sync-Env
  Get-Command wsl -ErrorAction Stop
  wsl --update
  Write-Host "WSL has been successfully installed" -ForegroundColor Green
  wsl --version
  wsl --status
} catch {
  $errorMessage = "Failed to download and install WSL (Error: $_)"
  Stop-Instalation -Message $errorMessage
}

# Winget #
$url = "https://github.com/microsoft/winget-cli/releases/download/v1.9.25200/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$destinationPath = "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
try {
  Write-Host "Installing windows package manager (Winget)" -ForegroundColor Cyan
  Invoke-WebRequest -Uri $url -OutFile $destinationPath -ErrorAction Stop
  Add-AppxPackage -Path $destinationPath -ErrorAction Stop
  Sync-Env
  Get-Command winget -ErrorAction Stop
  Write-Host "Winget has been successfully installed" -ForegroundColor Green
  winget --version
  winget --info
} catch {
  $errorMessage = "Failed to download and install Winget (Error: $_)"
  Stop-Instalation -Message $errorMessage
}

# Chocolatey #
Install-Script -Url "https://community.chocolatey.org/install.ps1" -ProgramName "Chocolatey" -ProgramCli "choco"

# Scoop #
Install-Script -Url "https://get.scoop.sh" -ProgramName "Scoop" -ProgramCli "scoop"

## Program installation ##

# Stop logging #
Stop-Transcript

[System.Environment]::Exit(0)