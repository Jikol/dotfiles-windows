function Set-Symlink {
  param(
    [string]$target,
    [string]$source
  )
  try {
    $target = Resolve-Path -Path $target -ErrorAction SilentlyContinue
    Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
    New-Item -ItemType SymbolicLink -Path $target -Target $source -ErrorAction Stop | Out-Null
  }
  catch {
    Write-Error "Script execution failed: $_"
    exit 1
  }
}

function Invoke-ChezmoiSync {
  param(
    [switch]$force 
  )
  $diff = chezmoi diff
  if ( [string]::IsNullOrWhiteSpace($diff) -and !$force) {
    Write-Host "No need to perform sync operation" -ForegroundColor Green
    return
  }

  $sourcePath = $( chezmoi source-path )
  $paths = (chezmoi list --path-style source-absolute) -split "`n" |
  Where-Object { $_ -notmatch ".chezmoiscripts" -and $_ -ne $sourcePath }

  foreach ($sourcePath in $paths) {
    Remove-Item -Path $sourcePath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "$sourcePath removed from managed files" -ForegroundColor Yellow
  }

  $managed = Get-Content -Path "$env:CHEZMOI_LOCAL_PATH\managed.json" | ConvertFrom-Json
  foreach ($data in $managed.data) {
    $sourcePath = Resolve-Path $data.path
    chezmoi add --secrets ignore $sourcePath
    foreach ($attr in $data.attributes) {
      chezmoi chattr +"$( $attr )" $sourcePath
    }
    Write-Host "$sourcePath added to managed files" -ForegroundColor Cyan
  }

  $diff = chezmoi diff
  if ( [string]::IsNullOrWhiteSpace($diff)) {
    chezmoi apply
    Write-Host "All chezmoi files synced to source path ($( chezmoi source-path ))" -ForegroundColor Green
  }
  else {
    Write-Host "Chezmoi synced files are inconsistent!" -ForegroundColor Red
    Write-Output $diff
  }
}

function Move-LocationChezmoi {
  Set-Location "$env:CHEZMOI_LOCAL_PATH"
}

function Open-ChezmoiManaged {
  vim "$env:CHEZMOI_LOCAL_PATH\managed.json"
}

function Invoke-Tmux {
  wsl exec tmux new-nession -A -s main
}

function Open-Winutil {
  Invoke-RestMethod -Path "https://christitus.com/win" | Invoke-Expression
}