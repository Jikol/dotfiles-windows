﻿#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent(true)

SpawnWindowsTerminal(title, runCommand) {
    if WinExist(title) {
        if WinActive(title) {
            WinMinimize
        } else {
            WinMaximize
        }
        return
    }
    Run(runCommand)
    WinWaitActive("ahk_class CASCADIA_HOSTING_WINDOW_CLASS")
    WinSetTitle(title)
}

MinimizeWindowsTerminal(title) {
	if WinActive(title) {
		WinMinimize
	}
}

^!e::SpawnWindowsTerminal("Tmux1", "wt --fullscreen -p Tmux")
^!z::SpawnWindowsTerminal("Btop", "wt --fullscreen btop")
#b::Run("chrome")
#f::Run("explorer")
#q::WinClose("A")

#HotIf WinActive("ahk_exe sublime_text.exe")
!w::Send "^s"
#HotIf
