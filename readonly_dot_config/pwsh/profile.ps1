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

## Function aliases
function ll { wsl exec exa -l --icons }
function la { wsl exec exa -la --icons }
function l { wsl exec tmux new-session -A -s main }
function chcd { cd $(chezmoi source-path) }
function chsync {
  chezmoi list --path-style absolute | ForEach-Object {
    chezmoi add "$($_)"
  }
}
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
function Invoke-Ls { wsl exec exa --icons }
function Invoke-Path-Set {
    param ([string]$newEntry)
    if ([string]::IsNullOrEmpty($newEntry)) {
        "Missing positional argument", "Synopsis: envset [path]" | Write-Error
        return
    }
    if (-not (Test-Path $newEntry)) {
        Write-Error "The specified path does not exist: $newEntry"
        return
    }

    $actualPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($actualPath -notlike "*$newEntry") {
        $newPath = "$actualPath;$newEntry"
        [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")

        $userEnvs = [System.Environment]::GetEnvironmentVariable("Path", "User")
        $machineEnvs = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        $env:Path = "$userEnvs;$machineEnvs"
        path
    } else {
        Write-Host "'$newEntry' path is already in Path environment variable" -ForegroundColor Cyan
    }
}
function Invoke-Path-Unset {
    param ([string]$existEntry)
    if ([string]::IsNullOrEmpty($existEntry)) {
        "Missing positional argument", "Synopsis: envset [path]" | Write-Error
        return
    }
    if (-not (Test-Path $existEntry)) {
        Write-Error "The specified path does not exist: $existEntry"
        return
    }

    $previousPath = [System.Environment]::GetEnvironmentVariable("Path", "User") -split ";" |
      Where-Object { $_ -ne $existEntry }
    $newPath = ($previousPath -join ";")
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")

    $userEnvs = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $machineEnvs = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $env:Path = "$userEnvs;$machineEnvs"
    path
}


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
