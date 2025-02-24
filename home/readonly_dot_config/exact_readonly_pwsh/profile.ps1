Write-Host "Reloading User Profile..." -ForegroundColor Cyan
 
## Modules ##
Import-Module -Name PSReadLine -Force
Import-Module -Name Catppuccin -Force
Import-Module -Name Utils -Force

Sync-Env

## Aliases ##
Set-Alias csl cls
Set-Alias g git
Set-Alias gg lazygit
Set-Alias d docker
Set-Alias dd lazydocker
Set-Alias sudo gsudo
Set-Alias vim nvim
Set-Alias edit subl
Set-Alias ip ipconfig
Set-Alias cat bat
Set-Alias ch chezmoi

## Variables ##
Set-Variable "PROFILE" "$HOME\.config\pwsh\profile.ps1"
Set-Variable "CONFIG_POWERSHELL" "$HOME\.config\pwsh\profile.ps1"
Set-Variable "CONFIG_VIM" "$HOME\.config\nvim\init.vim"

## Themes ##
$catppuccinMocha = $Catppuccin["Mocha"]
oh-my-posh init pwsh --config $HOME\.config\omp\fluent.json | Invoke-Expression
$ENV:FZF_DEFAULT_OPTS = @"
--color=bg+:$($catppuccinMocha.Surface0),spinner:$($catppuccinMocha.Sapphire)
--color=hl:$($catppuccinMocha.Red),fg:$($catppuccinMocha.Text),header:$($catppuccinMocha.Red)
--color=info:$($catppuccinMocha.Sapphire),pointer:$($catppuccinMocha.Rosewater),marker:$($catppuccinMocha.Rosewater)
--color=fg+:$($catppuccinMocha.Text),prompt:$($catppuccinMocha.Blue),hl+:$($catppuccinMocha.Blue)
--color=border:$($catppuccinMocha.Surface2)
"@
Set-PSReadLineOption -Colors @{
  ContinuationPrompt = $catppuccinMocha.Teal.Foreground()
	Emphasis = $catppuccinMocha.Sky.Foreground()
	Selection = $catppuccinMocha.Surface0.Background()
	InlinePrediction = $catppuccinMocha.Overlay0.Foreground()
	ListPrediction = $catppuccinMocha.Rosewater.Foreground()
	ListPredictionSelected = $catppuccinMocha.Surface0.Background()
	Command = $catppuccinMocha.Blue.Foreground()
	Comment = $catppuccinMocha.Green.Foreground()
	Default = $catppuccinMocha.Rosewater.Foreground()
	Error = $catppuccinMocha.Red.Foreground()
	Keyword = $catppuccinMocha.Blue.Foreground()
	Member = $catppuccinMocha.Rosewater.Foreground()
	Number = $catppuccinMocha.Pink.Foreground()
	Operator = $catppuccinMocha.Sky.Foreground()
	Parameter = $catppuccinMocha.Teal.Foreground()
	String = $catppuccinMocha.Green.Foreground()
	Type = $catppuccinMocha.Yellow.Foreground()
	Variable = $catppuccinMocha.Sky.Foreground()
}

## Initialization ##
Invoke-Expression (& { (zoxide init powershell | Out-String) })
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Clear-Host
