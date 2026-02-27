function Get-Env {
  [OutputType([string])]
  param(
    [string]$name,
    [System.EnvironmentVariableTarget]$scope = [System.EnvironmentVariableTarget]::User
  )
  if (-not [string]::IsNullOrEmpty($name)) {
    return [Environment]::GetEnvironmentVariable($name, $scope)
  }
  else {
    return [Environment]::GetEnvironmentVariables($scope)
  }
}

function Set-Env {
  param(
    [string]$name,
    [string]$value,
    [switch]$delete,
    [System.EnvironmentVariableTarget]$scope = [System.EnvironmentVariableTarget]::User
  )
  if ($delete) {
    [Environment]::SetEnvironmentVariable($name, $null, $scope)
  }
  [Environment]::SetEnvironmentVariable($name, $value, $scope)
}

function Add-Path {
  param(
    [string]$path
  )
  $currentPath = Get-Env -Name 'PATH'
  if ($currentPath -notlike "*$path*") {
    Set-Env -Name 'PATH' -Value "$currentPath;$path"
  }
}

function Sync-Env {
  Write-Host 'Reloading Environment Variables...' -ForegroundColor Cyan
  $userName = $env:USERNAME
  $architecture = $env:PROCESSOR_ARCHITECTURE
  $psModulePath = $env:PSModulePath
  $scopeList = 'Process', 'Machine'
  if ('SYSTEM', "${env:COMPUTERNAME}`$" -notcontains $userName) {
    $scopeList += 'User'
  }
  foreach ($scope in $scopeList) {
    $envList = [string]::Empty
    switch ($scope) {
      'User' {
        $envList = Get-Item 'HKCU:\Environment' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property
      }
      'Machine' {
        $envList = Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' | Select-Object -ExpandProperty Property
      }
      'Process' {
        $envList = Get-ChildItem Env:\ | Select-Object -ExpandProperty Key
      }
    }
    $envList | ForEach-Object {
      Set-Item "Env:$_" -Value (Get-Env -Scope $scope -Name $_)
    }
  }
  $paths = 'Machine', 'User' | ForEach-Object {
    (Get-Env -Name 'Path' -Scope $_) -split ';'
  } | Select-Object -Unique
  $env:Path = $paths -join ';'
  $env:PSModulePath = $psModulePath
  if ($userName) {
    $env:USERNAME = $userName
  }
  if ($architecture) {
    $env:PROCESSOR_ARCHITECTURE = $architecture
  }
}

function Show-Env {
  Sync-Env
  Get-ChildItem Env:
}

function Show-Path {
  Sync-Env
  Write-Host 'System Path Variables' -ForegroundColor Cyan
  (Get-Env -Scope 'Machine' -Name 'Path') -split ';' |
  Where-Object { $_ -ne '' } |
  Select-Object -Unique
  Write-Host 'User Path Variables' -ForegroundColor Cyan
  (Get-Env -Scope 'User' -Name 'Path') -split ';' |
  Where-Object { $_ -ne '' } |
  Select-Object -Unique
}