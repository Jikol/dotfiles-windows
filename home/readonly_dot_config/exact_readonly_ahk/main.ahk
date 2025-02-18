#Requires AutoHotkey v2.0
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

^!l::
{
	SpawnWindowsTerminal("Tmux", "wt --fullscreen -p Tmux")
	return
}

^!z::
{
	SpawnWindowsTerminal("Btop", "wt --fullscreen btop")
	return
}

#b::
{
	Run("chrome")
	return
}

#f::
{
	Run("explorer")
	return
}

#q::
{
	WinClose("A")
	return
}