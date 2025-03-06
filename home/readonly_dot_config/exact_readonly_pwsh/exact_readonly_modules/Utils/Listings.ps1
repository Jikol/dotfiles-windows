function Move-LocationParent {
  Set-Location (Split-Path -Path (Get-Location) -Parent)
}
  
function Show-Listings {
  wsl exec exa --color always --icons
}
  
function Show-ListingsList {
  wsl exec exa -l --color always --icons
}

function Show-ListingsListHidden {
  wsl exec exa -la --color always --icons
}   
