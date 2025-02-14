function Invoke-Chezmoi-Managed {
  $managed = @(
    @{path="~/utils"; attributes=@("exact", "readonly")},
    @{path="~/.ssh"; attributes=@("exact", "readonly")},
    @{path="~/.config/ahk"; attributes=@("exact", "readonly")},
    @{path="~/.config/bat"; attributes=@("exact", "readonly")},
    @{path="~/.config/btop"; attributes=@("exact", "readonly")},
    @{path="~/.config/delta"; attributes=@("exact", "readonly")},
    @{path="~/.config/git"; attributes=@("exact", "readonly")},
    @{path="~/.config/nvim"; attributes=@("exact", "readonly")},
    @{path="~/.config/omp"; attributes=@("exact", "readonly")},
    @{path="~/.config/pwsh"; attributes=@("exact", "readonly")},
    @{path="~/.config/wt"; attributes=@("exact", "readonly")}
  )

  foreach ($i in $managed) {
    $path = Resolve-Path $i.path
    chezmoi add --secrets ignore $path
    foreach ($attr in $i.attributes) {
      chezmoi chattr +"$($attr)" $path
    }
    Write-Host "$($path) added to managed files" -ForegroundColor Cyan 
  }
}

