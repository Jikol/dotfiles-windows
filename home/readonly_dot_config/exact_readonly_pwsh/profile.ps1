## Aliases
Set-Alias csl cls
Set-Alias sudo gsudo
Set-Alias vim nvim
Set-Alias ip ipconfig
Set-Alias cat bat
Set-Alias ch chezmoi
Set-Alias pathset Invoke-Path-Set
Set-Alias pathunset Invoke-Path-Unset
Set-Alias ls Invoke-Ls
Set-Alias chsync Invoke-Chezmoi-Managed

## Function aliases
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
function pathrld {
    $env:Path = "$([System.Environment]::GetEnvironmentVariable("Path", "User"));$([System.Environment]::GetEnvironmentVariable("Path", "Machine"))"
}
function path { 
    Write-Host "System Path Variables" -ForegroundColor Cyan
    [System.Environment]::GetEnvironmentVariable("Path", "Machine") -split ";" |
      Where-Object { $_ -ne "" }
    Write-Host "User Path Variables" -ForegroundColor Cyan
    [System.Environment]::GetEnvironmentVariable("Path", "User") -split ";" |
      Where-Object { $_ -ne "" }
}
function .. { cd .. }
function rld { & $profile }

## Import modules
Import-Module -Name PSFzf
Import-Module -Name PSReadLine

## Shell variables
Set-Variable "PROFILE" "$HOME\.config\pwsh\profile.ps1"
Set-Variable "CONFIG_POWERSHELL" "$HOME\.config\pwsh\profile.ps1"
Set-Variable "CONFIG_VIM" "$HOME\.config\nvim\init.vim"

## Functions
. $HOME\.config\pwsh\functions\path_set.ps1
. $HOME\.config\pwsh\functions\chezmoi_managed.ps1
function Invoke-Ls { wsl exec exa --icons }

## Themes
oh-my-posh init pwsh --config $HOME\.config\omp\fluent.json | Invoke-Expression
$env:FZF_DEFAULT_OPTS=@"
--color=bg+:#45475a,spinner:#f5e0dc,hl:#f38ba8
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
--color=selected-bg:#45475a
--multi
"@

## Initialization
Invoke-Expression (& { (zoxide init powershell | Out-String) })
Set-PsFzfOption -PSReadlineChordReverseHistory "Ctrl+y"
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

clear
