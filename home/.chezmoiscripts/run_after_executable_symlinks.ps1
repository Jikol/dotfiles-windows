## Symlink program config outside ~/.config directory ##
Import-Module -Name Utils -Force

function Invoke-SelfRunAs {
  $principal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
  $dateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
  $stdErrFile = "$env:TEMP\stderr_$dateTime.log"; $stdOutFile = "$env:TEMP\stdout_$dateTime.log"
  if (! $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $command = "& \`"$PSCommandPath\`" 2>\`"$stdErrFile\`" >\`"$stdOutFile\`""
    $shell = if (Get-Command pwsh -ErrorAction SilentlyContinue) {
      "pwsh.exe"
    }
    else {
      "powershell.exe"
    }
    $process = Start-Process $shell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command $command" -Wait -Verb RunAs -PassThru
    if ((Test-Path $stdErrFile) -and ((Get-Item $stdErrFile).Length -ne 0)) {
      $stdErr = (Get-Content $stdErrFile) -join "`n"; Remove-Item $stdErrFile -Force
      Write-Host $stdErr -ForegroundColor Red
    }
    if ((Test-Path $stdOutFile) -and ((Get-Item $stdOutFile).Length -ne 0)) {
      $stdOut = Get-Content $stdOutFile; Remove-Item $stdOutFile -Force
      Write-Host $stdOut -ForegroundColor Green
    }
    exit $process.ExitCode
  }
}

Invoke-SelfRunAs

# Windows Terminal #
Set-Symlink -Target "$env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json" -Source "$HOME/.config/wt/settings.json"

# PowerShell #
Set-Symlink -Target "$HOME/Documents/PowerShell/profile.ps1" -Source "$HOME/.config/pwsh/profile.ps1"

# Btop #
Set-Symlink -Target "$HOME/scoop/apps/btop/current/btop.conf" -Source "$HOME/.config/btop/btop.conf"

# Sunlime-Text #
$userSettings = Get-ChildItem -Path "$HOME/.config/subl"
foreach ($file in $userSettings) {
  Set-Symlink -Target (Join-Path -Path "$HOME/scoop/persist/sublime-text/Data/Packages/User" -ChildPath $file.Name) -Source (Join-Path -Path "$HOME/.config/subl" -ChildPath $file.Name)
}

Write-Output "Symlinks created"