# Reviewing PRs and writing issues

Read this file when you review a PR (mostly a PR from an intern or another contributor) or write an issue.

Every statement in a review is backed by something that you ran, diffed or measured. A PR description, a benchmark number, and "all tests pass" are claims to check, not facts. Treat every explanation the same way, from an intern, a senior or an agent.

## 1. Rules

1. **Verify before you deliver.** Do not repeat a claim from the PR unless you reproduced it. If you could not verify it, say so.
2. **Record each review** in `reviews/PR-<n>-<YYYY-MM-DD>.md` (untracked). One file per review pass.
3. **Never post to GitHub** (comment, review, approve, request changes) without the lead's approval for that PR and that text. A draft for approval is fine.
4. **Comments are friendly, short and specific.** No blame. Put the finding and the evidence. Mark each comment "blocking" or "Nit:".

## 2. What the review covers

1. **Code failures:** crashes, broken entry points, dead code, new silent-failure paths (`metta-style.md`, section 5).
2. **Test changes:** read them first. Flag every deleted or weakened assertion, every changed expected value, every seed change without a reason, every file left with zero assertions. A deleted regression test blocks the merge until the lead approves it.
3. **Performance, measured** against the base branch (`benchmarks.md`). Never accept the PR's numbers.
4. **Higher-order functions:** say where `map`/`fold`/`zipWith` and composition make the **changed** code simpler. Scope this to the diff only.
5. **Design:** one code path, generic names, no hard-coded tunables, classic alignment (`classic-oracle.md`).

Order of attention: design and behaviour, then tests, then complexity, then names. Formatting is last.

## 3. Method

1. **Get the claims and the diff:** `gh pr view <n> --json title,body,author,baseRefName,baseRefOid,headRefOid,commits` and `gh pr diff <n>`.
2. **Scope the real diff.** Find `git merge-base` of the head and the base. If the fork is behind, the GitHub diff mixes upstream catch-up with the author's work. Review only the author's commits. Note the split in the record.
3. **Make the arms:** standalone worktrees named `metta-moses` for the PR head and its base, outside the main checkout (`running-metta.md`, section 3). Never test or benchmark in the main checkout.
4. **Claims table:** each claim in the title, body and comments, then ✅ verified, ❌ refuted or ⚠️ not verifiable, with evidence. Check that the description matches the pushed code. Check that a benchmark command reaches the changed lines.
5. **Correctness:**
   - Run the touched test files on both arms. Compare ✅ counts with assert counts.
   - For a claim of "same behaviour", run the same seeded probe on both arms. Diff the complete output, not a summary.
   - For reduct or scoring changes, compare with classic.
   - Check changed arities and signatures. Make sure that no caller (tests too) uses the old shape.
6. **Pre-existing or introduced:** reproduce each finding on the base. Report a pre-existing problem as pre-existing. Do not blame the PR for it.
7. **Record and deliver:** write the record (scope, what the diff does, claims table, findings F1, F2, ... with blockers first, evidence paths, performance table, verdict). Give a short summary that starts with the verdict and answers the five points in section 2.

## 4. Re-reviews

- Read the earlier record first.
- Start the new record with each earlier finding and a verdict: HANDLED, PARTIAL or NOT HANDLED.
- Then review only the new changes.

## 5. Intern PRs: extra points

- Check the base branch. Interns have opened PRs against `main` by mistake.
- Check for files that do not belong: scratch files, local tools, logs, home paths, `.vscode/`.
- Check that the description follows the template and that "How has this been tested" holds real commands and results.
- Ask for the change to be split when it mixes several purposes.
- Explain the reason for each blocking comment in one or two sentences, so the author learns the rule.

## 6. Writing an issue

- An issue for interns is an exercise. State the symptom and the exact reproduction (command, input, expected and actual output, base commit). Do not give the cause or the fix.
- Use the issue templates in `.github/ISSUE_TEMPLATE/`.
- Show the draft to the lead. Create the issue only after approval.
