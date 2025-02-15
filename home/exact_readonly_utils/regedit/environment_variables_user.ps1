### Open regedit key to manipulate user environment variables ###

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" -Name "LastKey" -PropertyType String -Value "Computer\HKEY_CURRENT_USER\Environment" -Force

Start-Process regedit -Verb RunAS
