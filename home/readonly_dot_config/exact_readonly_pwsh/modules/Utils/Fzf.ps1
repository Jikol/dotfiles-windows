function Invoke-FzfDir {
    $env:FZF_DEFAULT_COMMAND = "fd --hidden --no-ignore --type d"
    fzf --height ~100% --layout reverse --style minimal --preview-window wrap | Set-Location
}

function Invoke-FzfFile {
    $env:FZF_DEFAULT_COMMAND = "fd --hidden --no-ignore --type d && fd --hidden --no-ignore --type f"
    $output = fzf --preview "bat -pf {} || ls -a {}" --height ~100% --layout reverse --style minimal --preview-window wrap
    if ($output -and (Test-Path $output -PathType Container)) {
        Set-Location $output
    }
    elseif ($output -and (Test-Path $output -PathType Leaf)) {
        vim $output
    }
}

function Invoke-FzfScoop {
    $apps = New-Object System.Collections.ArrayList
    Get-ChildItem "$( Split-Path $( Get-Command scoop -ErrorAction Ignore ).Path )\..\buckets" | ForEach-Object {
        $bucket = $_.Name
        Get-ChildItem "$( $_.FullName )\bucket" | ForEach-Object {
            $apps.Add($bucket + '/' + ($_.Name -replace '.json', '')) > $null
        }
    }
    $output = $apps | fzf --preview "scoop info {}" --height ~100% --layout reverse --style minimal --multi --preview-window wrap
    if ($null -ne $output) {
        Invoke-Expression "scoop install $( $output -join ' ' )"
    }
}