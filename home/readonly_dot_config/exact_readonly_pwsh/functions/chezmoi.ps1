function Invoke-Chezmoi-Sync {
  $paths = (chezmoi list --path-style source-absolute) -split "`n" | 
    Where-Object { $_ -notmatch "chezmoiscripts" }

  foreach ($path in $paths) {
    Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "$path removed from managed files" -ForegroundColor Yellow
  }

  $managed = Get-Content -Path "$HOME\.config\ch\managed.json" | ConvertFrom-Json
  foreach ($i in $managed) {
    $path = Resolve-Path $i.path
    chezmoi add --secrets ignore $path
    foreach ($attr in $i.attributes) {
      chezmoi chattr +"$($attr)" $path
    }
    Write-Host "$path added to managed files" -ForegroundColor Cyan 
  }
}