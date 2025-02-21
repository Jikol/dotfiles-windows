## Symlink program config outside ~/.config directory ##

Import-Module Utils

Invoke-SelfRunAs

# Windows Terminal #
Set-Symlink -Target "$env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json" -Source "$HOME/.config/wt/settings.json"

# PowerShell #
Set-Symlink -Target "$HOME/Documents/PowerShell/profile.ps1" -Source "$HOME/.config/pwsh/profile.ps1"

# Btop #
Set-Symlink -Target "$HOME/scoop/apps/btop/current/btop.conf" -Source "$HOME/.config/btop/btop.conf"
Set-Symlink -Target "$HOME/scoop/apps/btop/current/themes" -Source "$HOME/.config/btop/themes"

Write-Output "Symlinks created"