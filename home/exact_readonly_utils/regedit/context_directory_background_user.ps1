### Open regedit key to manipulate folder background shell kontext menu ###

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" -Name "LastKey" -PropertyType String -Value "HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell" -Force

Start-Process regedit -Verb RunAS