@AGENTS.md

## Claude Code notes

- Claude Code worktree tools can create worktrees in `.claude/worktrees/<name>`. Edits there are fine. Do not report a test or benchmark result from there: PeTTa resolves imports from the current directory first and can load the main checkout's files. Make a standalone `../wt-<task>/metta-moses` worktree for results (`docs/agents/running-metta.md`, section 3).
- Use the Bash `timeout` parameter as well as `timeout` and `ulimit -v` inside the command. A Bash call without them can hang or exhaust RAM.
- Run long MeTTa jobs in the background. Give the absolute log path and one command to watch it.
- Subagents: give each one its owned files and success criteria (`docs/agents/parallel-agents.md`). Use a separate reviewer subagent. Check `git status` in each worker worktree after each wave.
- If a `pr-review` skill is installed, use it for PR reviews. `docs/agents/reviewing-prs.md` is the same method.
- Turn off commit and PR attribution in your settings (`"attribution": { "commit": "", "pr": "", "sessionUrl": false }` in `settings.json`).
