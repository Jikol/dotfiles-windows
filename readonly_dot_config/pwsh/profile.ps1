# Aliases
Set-Alias sudo gsudo
Set-Alias vim nvim
Set-Alias ip ipconfig
Set-Alias cat bat
Set-Alias ch chezmoi

# Short Functions
function ls { wsl exec exa --icons }
function ll { wsl exec exa -l --icons }
function la { wsl exec exa -la --icons }
function l { wsl exec tmux new-session -A -s main }
function .. { cd .. }
function rld { . $PROFILE }
function chcd { cd $(chezmoi source-path) }
function pathrld {
    $env:Path = "$([System.Environment]::GetEnvironmentVariable("Path", "User"));$([System.Environment]::GetEnvironmentVariable("Path", "Machine"))"
}
function path { 
    Write-Host "System Path Variables" -ForegroundColor Cyan
    [System.Environment]::GetEnvironmentVariable("Path", "Machine") -split ";"
    Write-Host "User Path Variables" -ForegroundColor Cyan
    [System.Environment]::GetEnvironmentVariable("Path", "User") -split ";"
}

# Modules
Import-Module -Name Microsoft.WinGet.CommandNotFound

# Variables
Set-Variable "PROFILE" "$HOME\.config\pwsh\profile.ps1"
Set-Variable "CONFIG_POWERSHELL" "$HOME\.config\pwsh\profile.ps1"
Set-Variable "CONFIG_VIM" "$HOME\AppData\Local\nvim\init.vim"

# Prompt Theme
oh-my-posh init pwsh --config $HOME\.config\omp\fluent.json | iex

# Zoxide init
iex (& { (zoxide init powershell | Out-String) })

# Longer Functions
function pathset {
    param (
        [string]$newEntry
    )
    if ([string]::IsNullOrEmpty($newEntry)) {
        "Missing positional argument", "Synopsis: envset [path]" | Write-Host -ForegroundColor Red
        return
    }
    if (-not (Test-Path $newEntry)) {
        Write-Host "The specified path does not exist: $newEntry" -ForegroundColor Red
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
function pathunset {
    param (
        [string]$existEntry
    )
    if ([string]::IsNullOrEmpty($existEntry)) {
        "Missing positional argument", "Synopsis: envset [path]" | Write-Host -ForegroundColor Red
        return
    }
    if (-not (Test-Path $existEntry)) {
        Write-Host "The specified path does not exist: $existEntry" -ForegroundColor Red
        return
    }

    $previousPath = [System.Environment]::GetEnvironmentVariable("Path", "User") -split ";" | Where-Object { $_ -ne $existEntry }
    $newPath = ($previousPath -join ";")
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")

    $userEnvs = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $machineEnvs = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $env:Path = "$userEnvs;$machineEnvs"
    path
}

# Entrypoint
clear
