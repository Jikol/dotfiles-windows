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
