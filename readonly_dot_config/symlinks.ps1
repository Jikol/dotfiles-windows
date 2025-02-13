## Leverage access control
$principal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "Attempt to start elevated process" -ForegroundColor Yellow
  try {
    $proc = Start-Process powershell.exe -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs -PassThru
    if ($proc -eq $null) { throw "zdek" }
    Write-Host "Symlinks created" -ForegroundColor Green
    cmd /c pause
    exit
  } catch {
    Write-Host "Failed to start elevated process" -ForegroundColor Red
    cmd /c pause
    exit 1
  }
}

## Helper functions
function ln {
  param ([string]$target, [string]$source)
  if (Test-Path $target) { 
    Remove-Item $target -Force -Recurse
  }
  New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
}

## Symlink program config outside ~/.config directory ##

# Windows Terminal
ln "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" "$HOME\.config\wt\settings.json"

# PowerShell
ln "$HOME\Documents\PowerShell\profile.ps1" "$HOME\.config\pwsh\profile.ps1"

# Btop
ln "$HOME\scoop\apps\btop\current\btop.conf" "$HOME\.config\btop\btop.conf"
ln "$HOME\scoop\apps\btop\current\themes" "$HOME\.config\btop\themes"

