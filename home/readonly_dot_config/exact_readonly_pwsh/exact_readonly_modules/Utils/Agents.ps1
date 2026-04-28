function Invoke-ClaudeWrapper {
  if ($args[0] -in @("c", "commit")) {
    Invoke-ClaudeCommit
  } else {
    claude @args
  }
}

function Invoke-ClaudeCommit {
  $skill = Get-Content "$env:CLAUDE_CONFIG_DIR\skills\git\SKILL.md" -Raw
  claude `
    -p "Create new commit for staged files with appropriate message." `
    --append-system-prompt $skill `
    --allowed-tools "Bash" `
    --model claude-haiku-4-5-20251001 `
    --dangerously-skip-permissions
}
