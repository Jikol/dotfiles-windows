Write-Host "Reloading User Profile..." -ForegroundColor Cyan

## Import modules
Import-Module -Name PSReadLine

## Import functions ##
. $HOME\.config\pwsh\functions\environment.ps1
. $HOME\.config\pwsh\functions\chezmoi.ps1

## Aliases ##
Set-Alias csl cls
Set-Alias g git
Set-Alias gg lazygit
Set-Alias d docker
Set-Alias dd lazydocker
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
function .. { cd .. }
# (needs to be as function due to 'ls' is already alias for Set-Location)
function override-ls { wsl exec exa --icons }
function ll { wsl exec exa -l --icons }
function la { wsl exec exa -la --icons }
function l { wsl exec tmux new-session -A -s main }
function chcd { cd "$env:CHEZMOI_LOCAL_PATH" }
function chmanaged { vim "$env:CHEZMOI_LOCAL_PATH\managed.json" }
function f {
  $env:FZF_DEFAULT_COMMAND="fd --hidden --no-ignore --type d"
  $output = fzf --height ~100% --layout reverse --style minimal --preview-window wrap | Set-Location
}
function ff {
  $env:FZF_DEFAULT_COMMAND="fd --hidden --no-ignore --type d && fd --hidden --no-ignore --type f"
  $output = fzf --preview "bat -pf {} || ls -a {}" --height ~100% --layout reverse --style minimal --preview-window wrap
  if ($output -and (Test-Path $output -PathType Container)) { Set-Location $output }
  elseif ($output -and (Test-Path $output -PathType Leaf)) { vim $output }
}
function fs {
  $apps = New-Object System.Collections.ArrayList
  Get-ChildItem "$(Split-Path $(Get-Command scoop -ErrorAction Ignore).Path)\..\buckets" | ForEach-Object {
    $bucket = $_.Name
    Get-ChildItem "$($_.FullName)\bucket" | ForEach-Object {
      $apps.Add($bucket + '/' + ($_.Name -replace '.json', '')) > $null
    }
  }
  $output = $apps | fzf --preview "scoop info {}" --height ~100% --layout reverse --style minimal --multi --preview-window wrap
  if ($null -ne $output) {
    Invoke-Expression "scoop install $($output -join ' ')"
  }
}

## Utility scripts ##
function winutil { . $HOME\.config\pwsh\scripts\winutil.ps1 }

## PowerShell variables ##
Set-Variable "PROFILE" "$HOME\.config\pwsh\profile.ps1"
Set-Variable "CONFIG_POWERSHELL" "$HOME\.config\pwsh\profile.ps1"
Set-Variable "CONFIG_VIM" "$HOME\.config\nvim\init.vim"

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
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

clear
