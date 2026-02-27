function Invoke-Codium {
  $bad = Join-Path $PSHOME 'Modules'
  $env:PSModulePath = ($env:PSModulePath -split ';' |
    Where-Object { $_ -ne $bad }) -join ';'

  codium $args
}