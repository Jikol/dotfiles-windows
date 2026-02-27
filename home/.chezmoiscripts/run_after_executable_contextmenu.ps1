## Install context menu for explorer.exe ##
$contextMenus = @(
  @{
    keyName  = 'Terminal'
    menuText = 'Open in Terminal'
    icon     = '%USERPROFILE%\.local\share\chezmoi\assets\WindowsTerminal.ico'
    command  = '%LOCALAPPDATA%\Microsoft\WindowsApps\wt.exe -d "%V"'
    target   = 'background'  
  },
  @{   
    keyName  = 'Linux'
    menuText = 'Open in Linux'
    icon     = '%USERPROFILE%\.local\share\chezmoi\assets\WSL.ico'
    command  = '%LOCALAPPDATA%\Microsoft\WindowsApps\wt.exe -p Linux'
    target   = 'background'
  },
  @{
    keyName  = 'Codium'
    menuText = 'Open in Codium'
    icon     = '%USERPROFILE%\.local\share\chezmoi\assets\VSCodium.ico'
    command  = '%PROGRAMFILES%\VSCodium\VSCodium.exe "%V"'
    target   = 'background'
  },
  @{
    keyName  = 'Codium'
    menuText = 'Open in Codium'
    icon     = '%USERPROFILE%\.local\share\chezmoi\assets\VSCodium.ico'
    command  = '%PROGRAMFILES%\VSCodium\VSCodium.exe "%V"'
    target   = 'directory'
  },
  @{
    keyName  = 'Codium'
    menuText = 'Open in Codium'
    icon     = '%USERPROFILE%\.local\share\chezmoi\assets\VSCodium.ico'
    command  = '%PROGRAMFILES%\VSCodium\VSCodium.exe "%1"'
    target   = 'file'
  },
  @{
    keyName  = 'WebStorm'
    menuText = 'Open in WebStorm'
    icon     = '%USERPROFILE%\.local\share\chezmoi\assets\WebStorm.ico'
    command  = '%LOCALAPPDATA%\Programs\WebStorm\bin\webstorm64.exe "%V"'
    target   = 'background'
  },
  @{
    keyName  = 'WebStorm'
    menuText = 'Open in WebStorm'
    icon     = '%USERPROFILE%\.local\share\chezmoi\assets\WebStorm.ico'
    command  = '%LOCALAPPDATA%\Programs\WebStorm\bin\webstorm64.exe "%V"'
    target   = 'directory'
  },
  @{
    keyName  = 'WebStorm'
    menuText = 'Open in WebStorm'
    icon     = '%USERPROFILE%\.local\share\chezmoi\assets\WebStorm.ico'
    command  = '%LOCALAPPDATA%\Programs\WebStorm\bin\webstorm64.exe "%1"'
    target   = 'file'
  },
  @{
    keyName  = 'PyCharm'
    menuText = 'Open in PyCharm'
    icon     = '%USERPROFILE%\.local\share\chezmoi\assets\PyCharm.ico'
    command  = '%LOCALAPPDATA%\Programs\PyCharm\bin\pycharm64.exe "%V"'
    target   = 'background'
  },
  @{
    keyName  = 'PyCharm'
    menuText = 'Open in PyCharm'
    icon     = '%USERPROFILE%\.local\share\chezmoi\assets\PyCharm.ico'
    command  = '%LOCALAPPDATA%\Programs\PyCharm\bin\pycharm64.exe "%V"'
    target   = 'directory'
  },
  @{
    keyName  = 'PyCharm'
    menuText = 'Open in PyCharm'
    icon     = '%USERPROFILE%\.local\share\chezmoi\assets\PyCharm.ico'
    command  = '%LOCALAPPDATA%\Programs\PyCharm\bin\pycharm64.exe "%1"'
    target   = 'file'
  }
)
     
function Get-RegistryBasePath($target) {
  switch ($target) {
    'background' { 
      return 'Software\Classes\Directory\Background\shell'
    }
    'directory' { 
      return 'Software\Classes\Directory\shell'
    }
    'file' { 
      return 'Software\Classes\*\shell'
    }
    default {
      throw "Unknown target type: $target"
    }
  }
}

foreach ($path in @(
    'Software\Classes\Directory\shell',
    'Software\Classes\Directory\Background\shell',
    'Software\Classes\*\shell'
  )) {
  $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($path, $true)

  if ($key) {
    foreach ($subKeyName in $key.GetSubKeyNames()) {
      $key.DeleteSubKeyTree($subKeyName)
      Write-Host "Removed $path\$subKeyName" -ForegroundColor Red
    }

    $key.Close()
  }
}

Write-Host 'User context menu cleaned safely' -ForegroundColor Green

foreach ($menu in $contextMenus) {
  $basePath = Get-RegistryBasePath $menu.target
  $fullBase = "$basePath\$($menu.keyName)"
  $commandPath = "$fullBase\command"

  $baseKey = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($fullBase)
  $cmdKey = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($commandPath)
  $baseKey.SetValue('', $menu.MenuText, [Microsoft.Win32.RegistryValueKind]::String)

  if ($menu.icon) {
    $baseKey.SetValue('Icon', $menu.icon, [Microsoft.Win32.RegistryValueKind]::ExpandString)
  }

  $cmdKey.SetValue('', $menu.command, [Microsoft.Win32.RegistryValueKind]::ExpandString)
  $baseKey.Close()
  $cmdKey.Close()
    
  Write-Host 'Installed: ' -ForegroundColor Green -NoNewline
  Write-Host "'$($menu.menuText)'" -ForegroundColor Cyan -NoNewline
  Write-Host ' to ' -ForegroundColor Green -NoNewline
  Write-Host "$fullBase" -ForegroundColor Yellow -NoNewline
  Write-Host ' with ' -ForegroundColor Green -NoNewline
  Write-Host "$($menu.command)" -ForegroundColor Magenta -NoNewline
  Write-Host ' command' -ForegroundColor Green
}