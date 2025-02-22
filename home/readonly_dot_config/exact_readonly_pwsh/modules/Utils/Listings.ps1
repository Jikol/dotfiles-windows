function Move-LocationParent {
  Set-Location (Split-Path -Path (Get-Location) -Parent)
}
  
function Show-Listings {
  wsl exec exa --icons
}
  
function Show-ListingsList {
  wsl exec exa -l --icons
}

function Show-ListingsListHidden {
  wsl exec exa -la --icons
}   
