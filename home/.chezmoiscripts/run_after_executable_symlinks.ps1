## Symlink program config outside ~/.config directory ##
gsudo {
  function Set-Symlink {
    param(
      [string]$target,
      [string]$source
    )
    try {
      if (Test-Path $target) {
        Remove-Item -Path $target -Force -Recurse -ErrorAction Stop
      }
      New-Item -ItemType SymbolicLink -Path $target -Target $source -ErrorAction Stop | Out-Null
      Write-Host "Symlink from $source to $target created" -ForegroundColor Green
    }
    catch {
      Write-Error "Script execution failed: $_"
      exit 1
    }
  }
  
  # Windows Terminal #
  Set-Symlink -Target "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Source "$HOME\.config\wt\settings.json"

  # PowerShell #
  Set-Symlink -Target "$HOME\Documents\PowerShell\profile.ps1" -Source "$HOME\.config\pwsh\profile.ps1"

  # VSCodium #
  Set-Symlink -Target "$env:APPDATA\VSCodium\User\keybindings.json" -Source "$HOME\.config\codium\keybindings.json"
  Set-Symlink -Target "$env:APPDATA\VSCodium\User\settings.json" -Source "$HOME\.config\codium\settings.json"

  # Btop #
  Set-Symlink -Target "$env:APPDATA\btop\btop.conf" -Source "$HOME\.config\btop\btop.conf"
  Set-Symlink -Target "$env:APPDATA\btop\themes" -Source "$HOME\.config\btop\themes"

  # Docker #
  Set-Symlink -Target "$HOME\.docker\config.json" -Source "$HOME\.config\docker\config.json"

  Write-Host 'Symlinks created' -ForegroundColor Green
}