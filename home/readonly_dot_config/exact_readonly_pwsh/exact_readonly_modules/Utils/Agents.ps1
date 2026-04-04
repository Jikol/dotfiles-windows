function Invoke-CopilotCommit {
  copilot `
    -p "Create new commit for staged files with appropriate message.
    Commit message rules:
     - Check git status, diff and last 10 commits to match project style
     - Format: <type>: <summary>
     - bullet
     - bullet
     - Types: feat/fix/refactor/chore/docs/style/test
     - No Co-authored-by trailer" `
    --yolo --no-ask-user --model claude-haiku-4.5
}
