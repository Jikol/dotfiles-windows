### Open regedit key to manipulate file shell kontext menu ###

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" -Name "LastKey" -PropertyType String -Value "HKEY_CLASSES_ROOT\*\shell" -Force

Start-Process regedit -Verb RunAS

