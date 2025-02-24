### Open regedit key to manipulate machine environment variables ###

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" -Name "LastKey" -PropertyType String -Value "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" -Force

Start-Process regedit -Verb RunAS