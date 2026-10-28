# Running MeTTa in this repo

Read this file when your task runs MeTTa, sets up PeTTa, debugs a silent failure, or needs a clean test environment.

## 1. Runtimes

| Runtime | Use | Notes |
|---|---|---|
| PeTTaV1 (`github.com/Yagth/PeTTa`, branch `main`) | The runtime that counts. Tests must pass here. Benchmarks run here. | Ask the lead for the exact commit. It has native `until`, `argv`, `--profile` and `(library ...)` imports. |
| CI image `indominyus/petta:latest` | CI (`.github/workflows/MeTTa-CI.yml`) runs `python3 scripts/run-tests.py` in it. | CI must stay green. A CI-only failure is a real bug to report. |
| Other PeTTa builds | Diagnostic only. | A result there is never a reason to merge. |

- `setup.sh` clones stock `patham9/PeTTa` and adds it to `PATH` (it writes to `$GITHUB_ENV`, a CI variable). Its line `$gitHash = "..."` is not valid bash, so the pinned commit is not checked out (read from the script, not run). Do not use it as your local setup. Ask the lead which PeTTaV1 commit to use.
- Do not edit the PeTTa checkout. If you need a changed runtime for an experiment, copy it to another folder and call it by its absolute path. Tell the lead.
- `run.sh` usage: `run.sh [-p|--profile] [-s|--silent] <file.metta>`. The repo scripts pass `-s` after the file. Both orders work.
- `run.sh` starts `swipl --stack_limit=8g`. Do not raise the stack limit to make a run pass. A run that needs more is a bug.

## 2. Bound every run

Wrap every call to `run.sh`, also a one-line probe, in a memory cap and a time limit.

```sh
( ulimit -v 8000000;  timeout 600  sh "$PETTA" path/to/file.metta -s )     # probe or one test
( ulimit -v 12000000; timeout 1200 sh "$PETTA" moses.metta -s --problem=mux6 --nEval=1000 --maxGen=10 )   # full solve
```

- Use `8000000` KB for probes and tests. Use up to `12000000` KB for full solves on a 14 GB machine.
- Know the expected run time before you start. In June 2026 the full suite finished in less than 5 minutes. A much longer run, no output, or the same output again and again means a bug. Stop the run and find the cause.
- An OOM kill or a timeout is a code bug, not a slow test. A common cause: a probe that puts a live function head (`zipWith`, `AND`, `NOT`) in an evaluated position on data that is not a list. `quote` the data.
- When a job runs in the background, give its absolute log path and one command to watch it.
- Time a run with `date +%s.%N` before and after. Do not depend on `/usr/bin/time`; it is not on every machine.

## 3. A clean test environment

PeTTaV1 resolves a relative import against the **current directory first**, then against the file. This has two effects.

1. A run from inside `<main checkout>/.claude/worktrees/<name>` can load files from the main checkout, not from your worktree. A test then passes with old code. (This hid a real regression on 2026-07-29.)
2. Eight legacy tests (for example `metapopulation/tests/*`) import `../../../metta-moses/...`. They load only when the checkout folder is named `metta-moses`.

So, for any result that you report (full suite, regression gate, benchmark):

```sh
git worktree add --detach ../wt-<task>/metta-moses <commit>     # outside the main checkout
cd ../wt-<task>/metta-moses
( ulimit -v 8000000; PATH="$(dirname "$PETTA"):$PATH" timeout 1800 python3 scripts/run-tests.py )
```

- The canonical result is what `run-tests.py` shows with the current directory at the suite root. A file can show one ✅ less when you run it from its own folder. Check both before you call a difference a regression.
- `run-tests.py` scans all subfolders. Do not run it from a checkout that contains other worktrees (for example `.claude/worktrees/`). It then also runs their copies.
- When you remove gate worktrees, remove only the paths that you made. Never loop over `git worktree list` with `remove --force`. (That once deleted the worktrees of other sessions.)

## 4. Import order

- `import!` order changes behaviour. A call to a function that is not imported yet compiles as plain data. It never reduces.
- `import!` does not remove duplicates. A module imported twice gives every call two solutions.
- A probe or test that must show production behaviour copies the import block of `moses.metta`, in the same order. A helper that passes in a small test context proves nothing about the pipeline.
- After `scoring/boolean-ops` loads, `AND`, `OR` and `NOT` are live heads. Pass boolean trees through `quote` in that context.
- Do not add `!(import! ...)` lines to source modules. Only entry files and tests import.

## 5. Read the failure signature first

| What you see | What it means |
|---|---|
| Fewer ✅ than asserts, and a ❌ | The run stopped at the ❌. A failing `test` or `assertEqual` halts the file. Later checks did not run. |
| Fewer ✅ than asserts, no ❌, exit 0 | Checks vanished. The call or the expected side gave zero solutions (wrong arity, failed destructure, undefined head in a filtered path, missing import). |
| More ✅ than asserts | Some asserts have more than one solution. `run-tests.py` still passes the file. Check that the right value is among them and that you expect several. |
| `(partial f (args))` in output | A call with the wrong number of arguments. It is junk data. Find the call site. |
| An expression comes back unchanged | The head has no definition in this load context (often an import order problem). |
| Results doubled | A duplicate import or a duplicate clause. |

## 6. Debugging

- Make the smallest reproduction on the real functions, with the real import list. Give the exact command so that another person can run it.
- Start with the smallest function. Make it work. Then go to the function that calls it. Do not start from `moses`.
- Add `println!` lines to find where a run stops. Note: `println!` output is buffered and can appear before other output, so it is not an exact position marker.
- Remove every debug line before you hand over, unless the lead asks you to keep them.
- When PeTTa behaviour is not clear, read the runtime source: `src/translator.pl`, `src/metta.pl` and the PeTTa docs. Probe in a file that imports nothing first.
- A causal claim must explain why the bug shows here and not at the other call sites of the same function.
- Find out if a problem is new: run the same reproduction on the merge base. Report "pre-existing" or "introduced".
