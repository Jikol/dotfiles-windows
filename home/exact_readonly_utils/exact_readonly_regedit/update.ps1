
$registryKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\Favorites"
try {
  Get-ItemProperty -Path $registryKey | 
  Get-Member -MemberType Properties | 
  Where-Object { $_.Name -notmatch "^PS" } | 
  ForEach-Object { 
    Remove-ItemProperty -Path $registryKey -Name $_.Name -ErrorAction Stop
  };
  reg import ".\favourites.reg"
  Write-Host "Regedit favourites items has been successfully updated" -ForegroundColor Green
}
catch {
  Write-Host "Failed to update regedit fevourites items: $_" -ForegroundColor Red
}
#>