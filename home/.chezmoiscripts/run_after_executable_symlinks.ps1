## Symlink program config outside ~/.config directory ##
sudo {
  function Set-Symlink {
    param(
      [string]$target,
      [string]$source
    )
    try {
      Remove-Item -Path $target -Force -Recurse -ErrorAction Stop
      New-Item -ItemType SymbolicLink -Path $target -Target $source -ErrorAction Stop | Out-Null
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

  # Btop #
  Set-Symlink -Target "$HOME\scoop\apps\btop\current\btop.conf" -Source "$HOME\.config\btop\btop.conf"
  Set-Symlink -Target "$HOME\scoop\apps\btop\current\themes" -Source "$HOME\.config\btop\themes"

  # Sublime-Text #
  Set-Symlink -Target "$env:APPDATA\Sublime Text\Packages\User" -Source "$HOME\.config\subl"

  Write-Host "Symlinks created" -ForegroundColor Green
}