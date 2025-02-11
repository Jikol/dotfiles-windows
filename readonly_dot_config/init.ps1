# Helper functions
function ln {
    param (
        [string]$Link,
        [string]$Target
    )
    if (Test-Path $Link) { Remove-Item $Link -Force -Recurse }
    New-Item -ItemType SymbolicLink -Path $Link -Target $Target | Out-Null
}

## Symlink program config outside ~/.config directory ##

# SSH
ln "$HOME\.ssh" "$HOME\.config\.ssh"

# WindowsTerminal
ln "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" "$HOME\.config\wt\settings.json"

# PowerShell
ln "$HOME\Documents\PowerShell\profile.ps1" "$HOME\.config\pwsh\profile.ps1"

# Btop
ln "$HOME\scoop\apps\btop\current\btop.conf" "$HOME\.config\btop\btop.conf"
ln "$HOME\scoop\apps\btop\current\themes" "$HOME\.config\btop\themes"

Write-Host "Symbolic links created!" -ForegroundColor Green

