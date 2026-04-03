# Agent Instructions

## Git Commits

When asked to "make a commit" (or similar):

1. Run `git --no-pager status` and `git --no-pager diff --cached` to understand all staged changes.
2. Also check recent commit messages with `git --no-pager log --oneline -10` and `git --no-pager log -1 --format="%B"` to match the project's commit style.
3. Commit **only staged changes** (do not stage unstaged files unless explicitly asked).
4. Use this message format ÔÇö match existing commits exactly:

```
<type>: <short summary>

- <bullet describing change 1>
- <bullet describing change 2>
...
```

- Type is one of: `feat`, `fix`, `refactor`, `chore`, `docs`, `style`, `test`.
- Bullets are concise English sentences, no trailing period.
- **Do NOT add a `Co-authored-by` trailer.**
