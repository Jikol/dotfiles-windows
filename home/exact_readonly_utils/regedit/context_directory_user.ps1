### Open regedit key to manipulate folder shell kontext menu ###

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" -Name "LastKey" -PropertyType String -Value "HKEY_CURRENT_USER\Software\Classes\Directory\shell" -Force

Start-Process regedit -Verb RunAS