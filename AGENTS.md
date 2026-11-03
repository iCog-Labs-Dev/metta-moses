# AGENTS.md: metta-moses

For every agent and every person in this repo. This file is complete for this repo and wins over a global agent file. Read a file in `docs/agents/` only when the "Read when" table names your task.

## What this is

A port of classic OpenCog MOSES (C++) to MeTTa. It runs on PeTTa (MeTTa to Prolog, on SWI-Prolog). Research code: correct and aligned with classic comes first, readable code is equal to speed. Entry point `moses.metta`. Configuration only in `parameters/`. Contributors push to forks and open PRs to `iCog-Labs-Dev/metta-moses`. The runtime that counts is **PeTTaV1** (`github.com/Yagth/PeTTa`, `main`; ask the lead for the commit). CI uses `indominyus/petta:latest`.

## Commands

Run from the repo root. Set `export PETTA=/path/to/PeTTaV1/run.sh` once. Every MeTTa run, also a one-line probe, has a memory cap and a time limit.

| Task | Command |
|---|---|
| One test file | `( ulimit -v 8000000; timeout 600 sh "$PETTA" deme/tests/score-deme-test.metta -s )` |
| All tests (as CI) | `( ulimit -v 8000000; PATH="$(dirname "$PETTA"):$PATH" timeout 1800 python3 scripts/run-tests.py )` |
| Asserts in a file | `grep -v '^[[:space:]]*;' <file> \| grep -c '!(assertEqual'` |
| Hyperparameters | `( ulimit -v 8000000; timeout 120 sh "$PETTA" moses.metta -s --help )` |
| Demo problem | `( ulimit -v 12000000; timeout 1200 sh "$PETTA" moses.metta -s --problem=mux6 --nEval=1000 --maxGen=10 )` |

Demo problems: `parity3`, `parity4`, `disjunction3`, `majority3`, `majority5`, `mux3`, `mux6`. Add `--profile` before `moses.metta` to profile. No formatter or linter exists for MeTTa.

## Repo map (only the parts that mislead)

- `scoring/boolean-ops.metta` makes `AND`/`OR`/`NOT` live function heads. After it loads, a bare `(AND ...)` is a call, not data.
- `utilities/general-helpers.metta`, `utilities/list-methods.metta`: higher-order helpers. Reuse them before you write a function.
- Tests live in `*/tests/` or `*/test/`. `*testold.metta` files do not run.
- Team conventions: `.github/CONTRIBUTING.md`, `.github/TypeConvention.md`.

## Hard rules

1. **Never remove a test or change what it means without the lead's approval.** A seed or result-order change needs a reason in the PR. [Edited expectations hid a regression in PR #495.]
2. **Bound every MeTTa run** with `ulimit -v` and `timeout`. [An unbounded run can kill the session and other agents' work.]
3. **Classic MOSES is the oracle.** Each expected value, constant and default comes from classic or from a measurement. Say the source.
4. **PeTTaV1 is the runtime that counts, and CI must stay green.** Do not change the runtime. Solve the problem in MeTTa.
5. **Keep the change minimal.** Replace code. Do not add a second path next to it.
6. **No outward action without approval for that item:** push (also to your own branch), PR, comment, review, issue, merge.
7. **Commit as the human author only.** No AI co-author or "Generated with" line. No home paths, local tools, scratch files or debug `println!` in commits.
8. **Match the mode.** A question gets an answer. "Find the cause" gets the cause and the evidence, not a fix. Plan first for large or risky work.
9. **Done means evidence.** Run each touched test file and compare the ✅ count with the assert count. Then run the full suite in a standalone `metta-moses` worktree. Report the commands and the output.

## Shared work

- One task, one branch, one worktree outside the main checkout, in a folder named `metta-moses`: `git worktree add ../wt-<task>/metta-moses -b <branch> origin/dev`.
- Commit only your own changes. Never stash, reset or overwrite work that is not yours.
- Shared files (`moses.metta`, `parameters/defaults.metta`, `rte-helpers-fast.pl`, `.github/*`) have one owner at a time. At most 2 PeTTa runs at the same time.
- Base branch: `dev` or the integration branch that the lead names. Never a feature PR against `main`.

## Writing

Write in ASD-STE100: at most 20 words in an instruction and 25 in a description, active voice, simple tenses, simple words with one meaning, articles kept, lists for steps, no idioms. Technical names are permitted.

## Read when

| Read this file | When your task ... |
|---|---|
| `docs/agents/running-metta.md` | runs MeTTa, sets up PeTTa, debugs a silent failure, or needs a clean test environment |
| `docs/agents/testing.md` | adds, changes or fixes a test, or must show that work is done |
| `docs/agents/metta-style.md` | writes or reviews MeTTa code |
| `docs/agents/classic-oracle.md` | needs an expected value or compares with classic MOSES |
| `docs/agents/benchmarks.md` | makes or checks a performance claim |
| `docs/agents/parallel-agents.md` | runs several agents, uses worktrees, or hands work over |
| `docs/agents/git-and-prs.md` | commits, names a branch, writes a PR or prepares a release |
| `docs/agents/reviewing-prs.md` | reviews a PR or writes an issue |
