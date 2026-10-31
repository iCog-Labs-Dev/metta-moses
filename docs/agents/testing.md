# Testing

Read this file when you add, change or fix a test, or when a test fails after your change.

## 1. Tests are evidence

- **Never remove a test case without the lead's approval.** No exception for "low signal", "slow", "blocked by a known bug" or "old helper".
- **Never change what a test means without the lead's approval.** This covers a changed expected value, a weaker check, a smaller input, or a skipped case.
- These changes need only a stated reason in the PR: a new random seed, a hyperparameter change, a different result order.
- When you must convert a test file (for example a new data shape), convert every assertion and keep its meaning. If a converted assertion fails or the conversion is not clear, leave it in place, failing if necessary, and ask.
- Never edit an expected value to the value that the code now prints. That hides the bug and destroys the evidence. (PR #495 changed a best score from 0 to -1 in `moses/tests/input-file-test.metta` and hid a real regression.)
- A pure refactor or a data-layout change (for example row-major to column-major `mkITable`) must not change any expected value. If an expected value changes, a consumer still reads the old layout. Fix the consumer. Change every `mkITable` literal in the tree at the same time.

## 2. When your fix makes expectations fail: unmask first

A failing assert halts the file. So the first stale expectation hides all later ones. Do this:

1. Copy the test file to a scratch name (for example `<name>__unmask.metta`).
2. Comment out the blocking assertion: the whole balanced form, `;;` on each line. Run again. Repeat until the file runs to the end.
3. Record each blocker with its actual value and its expected value.
4. Show that the target assertions now pass.
5. Justify each changed expectation on its own, two ways: (a) it keeps the meaning of its own input (compute it by hand or from the truth table), and (b) it agrees with classic MOSES on the same input (`classic-oracle.md`).
6. Ask the lead to approve each changed expectation. Do not touch other test cases. Report new failures that you find; do not fix them on your own.
7. Delete the scratch copies: `find . -name '*__unmask.metta'`.

Find an assertion by its expected text. Do not map the Nth ✅ to the Nth `!(assertEqual`: some asserts print several ✅.

## 3. Writing a good test

- A regression test must fail without the fix and pass with it. Show both runs. ("Does this test case fail if your change vanishes? Otherwise there is no point in adding it.")
- Pin the exact expected value, not only a property. A reader then sees the result without a run.
- Write data as literals: `(A B)`, not `(cons A (cons B ()))`. Build trees with `buildTree` where a test already does so.
- Put a test next to its module, in `<folder>/tests/` (or `test/` where the folder already uses it). Name it `<module>-test.metta`. The runner only finds files that end in `test.metta`.
- Copy the import block of a test in the same folder. Do not use the `../../../metta-moses/` anchor in new tests.
- A test that pins random output depends on the position of the random stream. Add a new random-consuming call or a reseed **after** the existing pinned asserts, never before them.
- A demo or end-to-end test must not start from the answer. If the start exemplar already holds what the knobs must find, the test proves nothing. State what the start state gives.

## 4. `assertEqual`, `test` and quote

- `run-tests.py` counts every line that contains `!(assertEqual` and is not a `;` comment. A file passes when the ✅ count reaches that number and no ❌ shows. `!(test ...)` lines are not counted. Check them by hand.
- `test` collects all solutions. It catches zero solutions and duplicate solutions. `assert` calls once and hides both. For a new probe, use `test`.
- The expected side of `test` is evaluated. If it is data with a defined head (a written program, a list of operator names), it gives zero solutions and the check vanishes without output. `quote` such an expected side. Inert heads (`mkTree`, numbers, type names, plain symbols) need no quote.
- An `assertEqual` whose left side gives no result prints nothing. It can pass in silence. Count ✅ against assert lines every time.

## 5. Running tests

- While you work: run the files that your change touches, one by one. The aggregate runner can hide which file broke, and one OOM can stop all of it.
- Before you hand over: run the full suite in a standalone `metta-moses` worktree (`running-metta.md`, section 3).
- If a file fails, run it on the merge base too. Report "pre-existing" or "introduced".
- Python helpers have `unittest` tests next to them (for example `utilities/python-helpers/test_python_helpers.py`). Run them with `python3 -m unittest <path>` (not verified for every file).

## 6. Closing checks (every implementation)

1. Duplicate solutions: for a representative call, `(size-atom (collapse <call>))` is 1 where you expect one result. No doubled lines in output.
2. Junk values: grep the run output for `partial` (zero allowed in data) and `Error` (only the errors that you meant).
3. Single values: after a parameter switch, `&params` holds one value per name.
4. Files: no scratch, probe, unmask or debug file is left. `git status` shows only deliverables.
