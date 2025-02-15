### Open regedit key to manipulate taskbar ###

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" -Name "LastKey" -PropertyType String -Value "Computer\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force

Start-Process regedit -Verb RunAS