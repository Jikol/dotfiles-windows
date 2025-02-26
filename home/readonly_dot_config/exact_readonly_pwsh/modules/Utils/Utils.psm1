## Functions ##
. "$PSScriptRoot\Helpers.ps1"
. "$PSScriptRoot\Listings.ps1"
. "$PSScriptRoot\Environment.ps1"
. "$PSScriptRoot\Fzf.ps1"

## Aliases ##
Set-Alias ls Show-Listings -ErrorAction SilentlyContinue
Set-Alias ll Show-ListingsList
Set-Alias la Show-ListingsListHidden
Set-Alias .. Move-LocationParent

Set-Alias path Show-Path
Set-Alias env Get-Env
Set-Alias envrld Sync-Env

Set-Alias f Invoke-FzfDir
Set-Alias ff Invoke-FzfFile
Set-Alias fs Invoke-FzfScoop

Set-Alias chcd Move-LocationChezmoi
Set-Alias chmanaged Open-ChezmoiManaged
Set-Alias chsync Invoke-ChezmoiSync

Set-Alias l Invoke-Tmux
Set-Alias winutil Open-Winutil

## Export ##
Export-ModuleMember -Function *
Export-ModuleMember -Alias *