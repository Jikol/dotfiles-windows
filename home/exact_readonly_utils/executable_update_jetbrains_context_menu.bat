@echo off

:: change the path below to match your installed version
SET WebStormPath=C:\Users\Jikol\AppData\Local\Programs\WebStorm\bin\webstorm64.exe
SET PyCharmPath=C:\Users\Jikol\AppData\Local\Programs\PyCharm Professional\bin\pycharm64.exe
 
echo Adding file entries
@reg add "HKEY_CLASSES_ROOT\*\shell\WebStorm" /t REG_SZ /v "" /d "Open in WebStorm"   /f
@reg add "HKEY_CLASSES_ROOT\*\shell\WebStorm" /t REG_EXPAND_SZ /v "Icon" /d "%WebStormPath%,0" /f
@reg add "HKEY_CLASSES_ROOT\*\shell\WebStorm\command" /t REG_SZ /v "" /d "%WebStormPath% \"%%1\"" /f
::
@reg add "HKEY_CLASSES_ROOT\*\shell\PyCharm" /t REG_SZ /v "" /d "Open in PyCharm"   /f
@reg add "HKEY_CLASSES_ROOT\*\shell\PyCharm" /t REG_EXPAND_SZ /v "Icon" /d "%PyCharmPath%,0" /f
@reg add "HKEY_CLASSES_ROOT\*\shell\PyCharm\command" /t REG_SZ /v "" /d "%PyCharmPath% \"%%1\"" /f
 
echo Adding within a folder entries
@reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\WebStorm" /t REG_SZ /v "" /d "Open in WebStorm"   /f
@reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\WebStorm" /t REG_EXPAND_SZ /v "Icon" /d "%WebStormPath%,0" /f
@reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\WebStorm\command" /t REG_SZ /v "" /d "%WebStormPath% \"%%V\"" /f
::
@reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\PyCharm" /t REG_SZ /v "" /d "Open in PyCharm"   /f
@reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\PyCharm" /t REG_EXPAND_SZ /v "Icon" /d "%PyCharmPath%,0" /f
@reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\PyCharm\command" /t REG_SZ /v "" /d "%PyCharmPath% \"%%V\"" /f

echo Adding folder entries
@reg add "HKEY_CLASSES_ROOT\Directory\shell\WebStorm" /t REG_SZ /v "" /d "Open in WebStorm"   /f
@reg add "HKEY_CLASSES_ROOT\Directory\shell\WebStorm" /t REG_EXPAND_SZ /v "Icon" /d "%WebStormPath%,0" /f
@reg add "HKEY_CLASSES_ROOT\Directory\shell\WebStorm\command" /t REG_SZ /v "" /d "%WebStormPath% \"%%1\"" /f
::
@reg add "HKEY_CLASSES_ROOT\Directory\shell\PyCharm" /t REG_SZ /v "" /d "Open in PyCharm"   /f
@reg add "HKEY_CLASSES_ROOT\Directory\shell\PyCharm" /t REG_EXPAND_SZ /v "Icon" /d "%PyCharmPath%,0" /f
@reg add "HKEY_CLASSES_ROOT\Directory\shell\PyCharm\command" /t REG_SZ /v "" /d "%PyCharmPath% \"%%1\"" /f

pause