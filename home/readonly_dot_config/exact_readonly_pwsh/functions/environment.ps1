function Invoke-List-Variable {
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [Parameter(Mandatory = $true)][string] $name,
    [Parameter(Mandatory = $true)][System.EnvironmentVariableTarget] $scope
  )

  return [Environment]::GetEnvironmentVariable($name, $scope)
}

function Invoke-List-Path {
  Invoke-Env-Reload

  Write-Host "System Path Variables" -ForegroundColor Cyan
  (Invoke-List-Variable -scope "Machine" -name "Path") -split ";" |
    Where-Object { $_ -ne "" } |
    Select-Object -Unique

  Write-Host "User Path Variables" -ForegroundColor Cyan
  (Invoke-List-Variable -scope "User" -name "Path") -split ";" |
    Where-Object { $_ -ne "" } |
    Select-Object -Unique
}

function Invoke-Env-Reload {
  $userName = $env:USERNAME
  $architecture = $env:PROCESSOR_ARCHITECTURE
  $psModulePath = $env:PSModulePath

  $scopeList = "Process", "Machine"
  if ("SYSTEM", "${env:COMPUTERNAME}`$" -notcontains $userName) {
    $scopeList += "User"
  }

  foreach ($scope in $scopeList) {
    $envList = [string]::Empty
    switch ($scope) {
      "User" {
        $envList = Get-Item "HKCU:\Environment" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property
      }
      "Machine" {
        $envList = Get-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" | Select-Object -ExpandProperty Property
      }
      "Process" {
        $envList = Get-ChildItem Env:\ | Select-Object -ExpandProperty Key
      }
    }
    $envList | ForEach-Object {
      Set-Item "Env:$_" -Value (Invoke-List-Variable -scope $scope -name $_)
    }
  }

  $paths = "Machine", "User" | ForEach-Object {
    (Invoke-List-Variable -name "Path" -scope $_) -split ';'
  } | Select-Object -Unique
  $env:Path = $paths -join ';'

  $env:PSModulePath = $psModulePath
  if ($userName) {
    $env:USERNAME = $userName;
  }
  if ($architecture) {
    $env:PROCESSOR_ARCHITECTURE = $architecture;
  }
}

Write-Host "Reloading Environment Variables..." -ForegroundColor Cyan
Invoke-Env-Reload