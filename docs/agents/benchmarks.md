# Benchmarks and performance claims

Read this file when you make or check a performance claim, in your own work or in a PR.

## 1. Control every variable

A benchmark compares like with like. Before you run, write down:

| Item | Example |
|---|---|
| Base | `origin/dev` at `<sha>`, or the integration branch, at a commit hash |
| Arm under test | branch and commit hash |
| Command and parameters | `moses.metta -s --problem=mux6 --nEval=1000 --maxGen=10` |
| Seeds | the same seeds for both arms |
| Runtime | PeTTaV1 at `<sha>`, the same build for both arms |
| Machine state | on AC power, CPU governor `performance`, no other heavy job |

- Check power and governor first. On battery the same run was about 40% slower. A laptop in quiet mode once made a false 55 s to 81 s "regression". After a change of power or mode, run again before you believe a result.
- Run each arm in its own standalone worktree named `metta-moses`, outside the main checkout (`running-metta.md`, section 3). Never benchmark in the main checkout.
- Run one benchmark at a time on the machine. Parallel runs share CPU and change the timing.
- Make sure that the benchmark executes the changed code. Trace the flags and defaults from the command to the changed lines. A benchmark that never reaches the diff measures noise.
- If the experiment depends on a special runtime or branch, check that it is the one in use before you start. A run on the wrong setup has no value.

## 2. Method

1. Record the baseline first, before any change.
2. Alternate the arms: A B A B ... At least 3 runs per arm. Do not run all of A and then all of B. (Block runs on mux6 gave +2.4% and -5.6% for the same comparison.)
3. Measure the noise floor: run the base against itself (A A). A delta inside that spread is "parity".
4. Bound every run: `( cd <arm> && ulimit -v 12000000 && timeout 1200 sh "$PETTA" moses.metta -s <params> )`. Time it with `date +%s.%N`.
5. Check that both arms give the same output. Save the full output of each run. Strip ANSI colour codes. Replace Prolog variable names (`$_123`) with a canonical name before you diff. A summary number can match while the behaviour changes.
6. For several candidate optimisations: apply one at a time, measure it against the baseline, remove it, then apply the next. Report all of them before you merge any. The lead decides which to keep.
7. Profile with `--profile` before `moses.metta` when you need to know where time goes.

## 3. Report

- Give a table: arm, commit, runs, mean, min to max, output identical yes or no.
- State the verdict plainly: faster, parity or slower, on PeTTaV1.
- State the conditions where a gain holds (for example "only for large tables"). Do not round a scale-dependent result up to a general claim.
- Every number in a report has a source: a run that you did, with its command. Never repeat a number from a PR or from memory as your own result. ("So where did you get the number on the 1.85x faster?")
- Add new arms as new columns to the earlier table. Keep one format for one comparison.
- For research comparisons, also state the environment: seeds, problems, CPU and RAM.

## 4. What counts as a good change

- "No performance drop" is the minimum for a refactor. A readability gain counts as a benefit.
- A small speed gain does not justify code that is harder to read. A simpler design can win even if it is 1 to 2% slower.
- Do not add a second pass over the tree. Fold new work into a pass that exists.
- Native Prolog stubs in `moses/tests/rte-helpers-fast.pl` are for mechanical, domain-free walks (for example `removeEmptyAND`, `getLiterals`, set operations). Never move candidate evaluation or scoring into a native stub. (A native scorer hard-coded `AND`/`OR`/`NOT` and boolean leaves, so a new operator was scored wrong in silence.)
- Do not raise a stack or memory limit to make a run finish.
- Rules for a new native stub in `rte-helpers-fast.pl`:
  - Start with `:- dynamic(...)` and `:- retractall(...)`, as the stubs that exist do.
  - If the MeTTa module that defines the function is imported **after** the consult, `retractall` removes nothing and the MeTTa clauses are added after yours. Then end every native clause with `!`, the catch-all too, or calls leak extra solutions.
  - Compare with `==/2` only. Do not pattern-match a head position that can hold a variable. Do not use `copy_term`, `memberchk` or `subtract`.
  - Verify with a differential: compute results with pure MeTTa, consult the file, compute again, compare with `==`. `quote` tree literals in argument positions.
