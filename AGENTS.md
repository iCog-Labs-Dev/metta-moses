# AGENTS.md: metta-moses

Read this file before you change anything. It applies to every agent (Claude Code, Codex, Gemini CLI, opencode) and to every person in this repo. If the global engineering guide is installed, it also applies. For this repo, this file wins.

## What this project is

- A port of MOSES (Meta-Optimizing Semantic Evolutionary Search) from classic OpenCog MOSES (C++) to MeTTa.
- It runs on PeTTa, a MeTTa-to-Prolog translator on SWI-Prolog.
- It is research code. Correct and aligned with classic comes first. Readable code is a goal equal to speed. ("A slower implementation but correct is better than an incorrect but fast implementation.")
- One lead (the maintainer) and several interns and contributors work here. Contributors push to their forks and open PRs to `iCog-Labs-Dev/metta-moses`.

## Stack

- MeTTa source: `*.metta`. Entry point: `moses.metta` (on `dev`). Hyperparameters: `parameters/` (`defaults.metta`, `registry.metta`, `cli.metta`).
- Native Prolog stubs for hot mechanical walks: `moses/tests/rte-helpers-fast.pl`. `moses.metta` consults it after the reduct imports.
- Python: `scripts/run-tests.py` (test runner, also in CI), `scripts/test_moses.py` (batch runner), `scripts/csv_helper.py` (CSV input tables), `utilities/python-helpers/`.
- Runtime that counts: **PeTTaV1**, the PeTTa fork that the lead uses (`github.com/Yagth/PeTTa`, branch `main`; ask the lead for the commit). CI runs the Docker image `indominyus/petta:latest` (`.github/workflows/MeTTa-CI.yml`).

## Commands

Run from the repo root. In this file, `$PETTA` is the path to the `run.sh` of your PeTTaV1 checkout. Set it once: `export PETTA=/path/to/PeTTaV1/run.sh`.

**Wrap every MeTTa run in a memory cap and a time limit, also a one-line probe.** The commands below already do this.

| Task | Command |
|---|---|
| Run one test file | `( ulimit -v 8000000; timeout 600 sh "$PETTA" deme/tests/score-deme-test.metta -s )` |
| Run all tests (as CI) | `( ulimit -v 8000000; PATH="$(dirname "$PETTA"):$PATH" timeout 1800 python3 scripts/run-tests.py )` |
| Count asserts in a file (as `run-tests.py` does) | `grep -v '^[[:space:]]*;' <file> \| grep -c '!(assertEqual'` |
| List hyperparameters | `( ulimit -v 8000000; timeout 120 sh "$PETTA" moses.metta -s --help )` |
| Run a demo problem | `( ulimit -v 12000000; timeout 1200 sh "$PETTA" moses.metta -s --problem=mux6 --nEval=1000 --maxGen=10 )` |
| Profile a run | add `--profile` before `moses.metta` |

- `run-tests.py` finds every `*test.metta` under the current directory. It calls `run.sh` from `PATH`. It runs one file at a time.
- Demo problems (`moses/demo-problems.metta`): `parity3`, `parity4`, `disjunction3`, `majority3`, `majority5`, `mux3`, `mux6`. Other flags: `--name=value` for any name that `--help` prints (for example `--seed`, `--maxGen`, `--nDeme`, `--fsAlgo`, `--optAlgo`, `--inputFile`).
- No formatter and no linter exist for MeTTa. Format by hand (see `docs/agents/metta-style.md`).

## Repo map (non-obvious parts)

| Path | What it holds |
|---|---|
| `reduct/boolean-reduct/` | Boolean reduction (reduce-to-elegance). Shared reduct helpers: `rte-helpers.metta`. |
| `scoring/boolean-ops.metta` | Defines `AND`/`OR`/`NOT` as live function heads. After it loads, a bare `(AND ...)` is a call, not data. |
| `parameters/` | The only place for global configuration (`&params`, `param`, `set-param`). |
| `utilities/general-helpers.metta`, `utilities/list-methods.metta` | Higher-order helpers (`map`, `zipWith`, `List.foldl`, `genList`, ...). Reuse them. |
| `*/tests/`, `*/test/` | Tests live next to their module. Both folder names exist. `*testold.metta` files are not run. |
| `.github/CONTRIBUTING.md`, `.github/TypeConvention.md` | Team conventions: git flow, naming, formatting, type porting. |

## Hard rules

1. **Never remove a test, and never change what a test means, without the lead's approval.** A seed, hyperparameter or result-order change needs a stated reason in the PR. (Every test exists for a reason. Removed deep cases once hid a hang. Edited expectations once hid an end-to-end regression, PR #495.)
2. **Bound every MeTTa run** with `ulimit -v` and `timeout`. (An unbounded run can use all RAM and kill the session and the work of other agents.)
3. **Classic OpenCog MOSES is the oracle.** Every expected value, constant and default comes from classic or from a measurement. Say where each number came from. (Tests in the port can be wrong. Classic is the ground truth.)
4. **PeTTaV1 is the runtime that counts.** Results on other PeTTa builds are diagnostic only. CI must also stay green. (Builds differ in special forms such as `until` and `reduce`. A pass on another build proves nothing about the shipped runtime.)
5. **Do not change the PeTTa runtime.** Solve the problem in MeTTa in this repo. (The repo must run on a clean runtime.)
6. **Benchmarks are controlled.** Same base, seeds, parameters and runtime build. AC power. Nothing else running. See `docs/agents/benchmarks.md`. (A quiet-mode laptop once made a false 55 s to 81 s "regression".)
7. **Keep the change minimal.** Change only what the task needs. Replace code; do not add a second path next to it. (Two paths go stale and double the maintenance.)
8. **No machine junk in commits:** no home paths, no local tools, no scratch or debug files, no debug `println!`. (A local `tools/` folder and hard-coded `/home/...` paths once reached a PR.)
9. **No outward action without approval for that item:** every push (also to your own branch), open or edit a PR, comment, review, open an issue, merge. (Approval for one item does not cover the next.)
10. **Commit as the human author only.** No AI co-author line or "Generated with" line. (Branch history was rewritten before, for example for PR #464, to remove such trailers.)
11. **Match the mode.** A question gets an answer, not an edit. "Find the cause" gets the cause and the evidence, not a fix. Plan first and wait for approval on large or risky work.

## Done means

Before you say "done", "fixed" or "passes", do all of these. Report the commands and output.

- Run each test file that your change touches, one by one. Compare the ✅ count with the assert count. Fewer ✅ with a ❌ means the run stopped there. Fewer ✅ with no ❌ means checks vanished.
- Run the full suite in a standalone worktree named `metta-moses` (see `docs/agents/running-metta.md`).
- Show that a new regression test fails without your fix and passes with it.
- Check for duplicate solutions and junk: no `partial` in data output, no unexpected `Error`, one solution where one is expected.
- Delete scratch files and debug lines. `git status` shows only your deliverables.

## Several agents on this repo

- One task = one branch = one worktree. Put the worktree outside the main checkout, in a folder named `metta-moses`: `git worktree add ../wt-<task>/metta-moses -b <branch> origin/dev`. (Eight tests import `../../../metta-moses/...`, and PeTTa resolves imports from the current directory first.)
- Commit only your own changes. Use `git add -p` when a file has other changes. Never stash, reset or check out over work that is not yours.
- The orchestrator gives each worker a list of files it owns. Shared files (`moses.metta`, `parameters/defaults.metta`, `rte-helpers-fast.pl`, `.github/*`) have one owner at a time.
- RAM is the shared resource. Run at most 1 to 2 PeTTa runs at the same time on a 14 GB machine. Never run a benchmark while other runs are active.
- Details, hand-off format and the reviewer loop: `docs/agents/parallel-agents.md`.

## Several people on this repo

- Base branch: `dev`, or the integration branch that the lead names in the task. Never open a feature PR against `main`. Only the lead opens the release PR `dev` to `main`.
- Use the PR template. Keep the description short enough for a person to read. Describe the whole branch from its base.
- Do not touch another person's branch, worktree or uncommitted files. Ask first.
- Only the lead decides version bumps and releases (tags `v0.x.y`).
- Details: `docs/agents/git-and-prs.md`. Review of other people's PRs: `docs/agents/reviewing-prs.md`.

## Read when

| Read this file | When your task ... |
|---|---|
| `docs/agents/running-metta.md` | runs MeTTa, sets up PeTTa, debugs a silent failure, or needs a clean test environment |
| `docs/agents/testing.md` | adds, changes or fixes a test, or a test fails after your change |
| `docs/agents/classic-oracle.md` | needs an expected value, ports a classic function, or compares with classic MOSES |
| `docs/agents/benchmarks.md` | makes or checks a performance claim |
| `docs/agents/metta-style.md` | writes or reviews MeTTa code |
| `docs/agents/parallel-agents.md` | runs several agents, uses worktrees, or hands work over |
| `docs/agents/git-and-prs.md` | commits, names a branch, writes a PR or prepares a release |
| `docs/agents/reviewing-prs.md` | reviews a PR, mostly an intern's PR, or writes an issue |
