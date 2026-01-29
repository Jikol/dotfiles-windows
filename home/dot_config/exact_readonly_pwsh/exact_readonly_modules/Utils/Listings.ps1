function Move-LocationParent {
  Set-Location (Split-Path -Path (Get-Location) -Parent)
}
  
function Show-Listings {
  wsl -e exa --color always --icons
}
  
function Show-ListingsList {
  wsl -e exa -l --color always --icons
}

function Show-ListingsListHidden {
  wsl -e exa -la --color always --icons
}   
