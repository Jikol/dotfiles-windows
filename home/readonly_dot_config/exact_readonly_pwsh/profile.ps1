Write-Host "Reloading User Profile..." -ForegroundColor Cyan

## Import modules
Import-Module -Name PSFzf
Import-Module -Name PSReadLine

## Import functions ##
. $HOME\.config\pwsh\functions\environment.ps1
. $HOME\.config\pwsh\functions\chezmoi.ps1

## Aliases ##
Set-Alias csl cls
Set-Alias sudo gsudo
Set-Alias vim nvim
Set-Alias ip ipconfig
Set-Alias cat bat
Set-Alias ch chezmoi
Set-Alias ls override-ls
Set-Alias path Invoke-List-Path
Set-Alias env Invoke-List-Variable
Set-Alias envrld Invoke-Env-Reload
Set-Alias chsync Invoke-Chezmoi-Sync

## Function aliases ##
# Listings #
function .. { cd .. }
# (needs to be as function due to 'ls' is already alias for Set-Location)
function override-ls { wsl exec exa --icons }
function ll { wsl exec exa -l --icons }
function la { wsl exec exa -la --icons }
function l { wsl exec tmux new-session -A -s main }
function chcd { cd $(chezmoi source-path) }
function ff {
  $env:FZF_DEFAULT_COMMAND="fd --hidden"
  $output = fzf --preview "bat -pf {} || ls -a {}" --height ~100% --layout reverse --style minimal
  if ($output -and (Test-Path $output -PathType Container)) { Set-Location $output }
  elseif ($output -and (Test-Path $output -PathType Leaf)) { vim $output }
}

## PowerShell variables ##
Set-Variable "PROFILE" "$HOME\.config\pwsh\profile.ps1"
Set-Variable "CONFIG_POWERSHELL" "$HOME\.config\pwsh\profile.ps1"
Set-Variable "CONFIG_VIM" "$HOME\.config\nvim\init.vim"
Set-Variable "CONFIG_CHEZMOI" "$HOME\.config\ch\managed.json"

## Themes ##
oh-my-posh init pwsh --config $HOME\.config\omp\fluent.json | Invoke-Expression
$env:FZF_DEFAULT_OPTS=@"
--color=bg+:#45475a,spinner:#f5e0dc,hl:#f38ba8
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
--color=selected-bg:#45475a
--multi
"@

## Initialization ##
Invoke-Expression (& { (zoxide init powershell | Out-String) })
Set-PsFzfOption -PSReadlineChordReverseHistory "Ctrl+y"
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

clear
