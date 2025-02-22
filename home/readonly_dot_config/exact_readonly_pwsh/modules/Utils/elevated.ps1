function Invoke-SelfRunAs {
    $principal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
    $dateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $stdErrFile = "$env:TEMP\stderr_$dateTime.log"; $stdOutFile = "$env:TEMP\stdout_$dateTime.log"
    if (! $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $command = "& \`"$PSCommandPath\`" 2>\`"$stdErrFile\`" >\`"$stdOutFile\`""
        $shell = if (Get-Command pwsh -ErrorAction SilentlyContinue) {
            "pwsh.exe"
        }
        else {
            "powershell.exe"
        }
        $process = Start-Process $shell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command $command" -Wait -Verb RunAs -PassThru
        if ((Test-Path $stdErrFile) -and ((Get-Item $stdErrFile).Length -ne 0)) {
            $stdErr = (Get-Content $stdErrFile) -join "`n"; Remove-Item $stdErrFile -Force
            Write-Host $stdErr -ForegroundColor Red
        }
        if ((Test-Path $stdOutFile) -and ((Get-Item $stdOutFile).Length -ne 0)) {
            $stdOut = Get-Content $stdOutFile; Remove-Item $stdOutFile -Force
            Write-Host $stdOut -ForegroundColor Green
        }
        exit $process.ExitCode
    }
}