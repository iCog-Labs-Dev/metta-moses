# Several agents on one repo

Read this file when you run several agents, use worktrees, or hand work over to another agent or person.

## 1. Isolation

- One task = one branch = one worktree. Never let two agents write in the same checkout.
- Branch from current upstream: `git fetch origin`, then branch from `origin/dev` or from the integration branch that the lead names.
- Put the worktree outside the main checkout, in a folder named `metta-moses`:

  ```sh
  git worktree add ../wt-<task>/metta-moses -b <type>/<Name> origin/dev
  ```

  The pattern in use is `../wt-<task>/metta-moses` (for example `../wt-colmajor/metta-moses`). (Legacy tests import `../../../metta-moses/...`. PeTTa resolves imports from the current directory first, so a run inside `.claude/worktrees/<name>` can load files from the main checkout.)
- An editor or agent tool can make its worktrees in `.claude/worktrees/`. That is fine for edits. Do every test run that you report in a standalone `metta-moses` worktree (`running-metta.md`, section 3).
- Remove only the worktrees that you made, by their exact path. Never remove worktrees in a loop over `git worktree list`.

## 2. Ownership

- The orchestrator writes a brief for each worker: objective, the files it owns, constraints, success criteria, how to test, output format, what not to do.
- A worker edits only the files that it owns. If it needs another file, it stops and asks the orchestrator.
- Shared files have one owner at a time: `moses.metta` (import order), `parameters/defaults.metta`, `moses/tests/rte-helpers-fast.pl`, `utilities/general-helpers.metta`, `.github/*`, `.gitignore`.
- Two workers never change the same function on different branches. Split the work by module.

## 3. Shared machine resources

- RAM is the limit. A PeTTa run can take 8 GB or more. On a 14 GB machine, run at most 1 to 2 PeTTa runs at the same time, and at most 3 agents. Every run has `ulimit -v` and `timeout`.
- A benchmark runs alone. Pause other runs first (`benchmarks.md`).
- Each worker writes run output to its own worktree or its own folder. `scripts/test_moses.py` writes to `--outdir` (default `sandbox`); give each worker its own `--outdir`.
- Do not edit a file that a running batch reads. Snapshot the inputs of a long batch.
- `/tmp` can be RAM-backed and can be wiped. Keep results that must survive in the worktree (untracked) or in a folder that the lead names.

## 4. Commits

- Commit only your own changes. Check `git status` and `git diff --staged` before each commit. Use `git add -p` when a file also holds other changes.
- Small, logical commits. One logical change per commit. Not one giant commit, and not dozens of micro-commits.
- Conventional Commits with a scope, as in the history: `fix(reduct): ...`, `refactor(scoring): ...`, `test(reduct): ...`, `perf(scoring): ...`.
- If the lead says "do not commit", leave all changes uncommitted for review.
- Never commit scratch, probe, unmask or debug files, or a local harness.

## 5. Working state

Keep working notes out of git. `.gitignore` on `dev` ignores `notes/`. PR and release drafts already live there (for example `notes/pr-dev-to-main.md`).

| File | Use |
|---|---|
| `notes/WORK-<branch>.md` | Task state across sessions: goal, success criteria, plan, status, decisions, what is not verified. |
| `notes/BACKLOG.md` | Out-of-scope bugs, ideas, review nits. |
| `notes/pr-<branch>.md` | Draft PR description. |
| `reviews/PR-<n>-<YYYY-MM-DD>.md` | PR review records (`reviewing-prs.md`). |

When the work is for another agent later, write a hand-off plan in `notes/WORK-<branch>.md`: what was done, what was there before and why it was removed, what not to do again, how the team works (review loop), and how to test.

## 6. Hand-off from a worker

Reply only when the work is ready for review. Give:

- the absolute worktree path, the branch, and the first and last commit hash
- each commit subject
- the test commands that you ran and their result (✅ count against assert count per file)
- the files changed
- what you did not verify, and each assumption that a reviewer can want to reverse

## 7. Review loop

- A separate reviewer agent checks each worker's result against the success criteria. The reviewer did not write the code.
- The reviewer checks correctness first: behaviour, tests (no removed or weakened test), classic alignment. Style comes last.
- A neutral agent applies the fixes, then the reviewer checks again.
- At most 3 rounds. Stop when no blocking finding remains. Put the nits in `notes/BACKLOG.md`.
- Treat findings of a review agent as leads. Verify each one before you act on it.
- For an uncertain cause, run two agents: one argues for the cause, one argues against it. The orchestrator decides with the evidence.
- After each wave, check `git log`, `git status` and new files in every worker's worktree. Workers have committed against instructions before.

## 8. When to stop and notify

Stop and tell the lead (use a desktop notification such as `notify-send` if the lead asked for it) when:

- a test must change meaning or must be removed
- classic and an existing test disagree
- a step is an outward action (any push, PR, comment, issue, merge)
- a run is OOM-killed or times out twice
- the work needs a file that another worker owns
- the task is done
