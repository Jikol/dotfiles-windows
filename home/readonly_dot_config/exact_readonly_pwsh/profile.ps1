Write-Host "Reloading User Profile..." -ForegroundColor Cyan
 
## Modules ##
Import-Module -Name PSReadLine -Force
Import-Module -Name Utils -Force

Sync-Env

## Aliases ##
Set-Alias csl cls
Set-Alias g git
Set-Alias gg lazygit
Set-Alias d docker
Set-Alias dd lazydocker
Set-Alias sudo gsudo
Set-Alias vim nvim
Set-Alias edit subl
Set-Alias ip ipconfig
Set-Alias cat bat
Set-Alias ch chezmoi

## Variables ##
Set-Variable "PROFILE" "$HOME\.config\pwsh\profile.ps1"
Set-Variable "CONFIG_POWERSHELL" "$HOME\.config\pwsh\profile.ps1"
Set-Variable "CONFIG_VIM" "$HOME\.config\nvim\init.vim"

## Themes ##
oh-my-posh init pwsh --config $HOME\.config\omp\fluent.json | Invoke-Expression
$env:FZF_DEFAULT_OPTS = @"
--color=bg+:#45475a,spinner:#f5e0dc,hl:#f38ba8
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
--color=selected-bg:#45475a
--multi
"@

## Initialization ##
Invoke-Expression (& { (zoxide init powershell | Out-String) })
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Clear-Host
