# Git, branches, PRs and releases

Read this file when you commit, name a branch, write a PR, or prepare a release.

## 1. Branch model (git flow, see `.github/CONTRIBUTING.md`)

| Branch | Role |
|---|---|
| `main` | Released code. Each merge is a release with a tag (`v0.1.0` ... `v0.6.0`). |
| `dev` | Latest development. The base for features and fixes. |
| Integration branches (the lead names them; earlier ones were `feat/ActionGeneralization` and `feat/ActionDomainExtension`, both now merged into `dev`) | Long feature work. Contributors open PRs against them. The lead merges them into `dev`. |
| `feat/...`, `fix/...`, `ref/...`, `perf/...` | One task each. CI runs on pushes to `main`, `dev`, `feat/*`, `fix/*`, `ref/*`, `merge/*`, and on PRs to `main`, `dev`, `feat/*`, `fix/*`, `ref/*`. A `perf/*` or `exp/*` branch gets CI only through a PR to one of these. |
| `exp/...` | Experiments and prototypes. Not merged without a normal review. |

- Follow the names in use: `feat/ActionGeneralization`, `fix/column-major-consumers`, `ref/DemeAtomspacePlacement`.
- **Pick the right base.** Use `dev`, or the integration branch of your task. Never open a feature PR against `main`. (PRs #512 and #514 targeted `main` and showed more than 9,000 changed lines; the same work against `feat/ActionDomainExtension` was about 100 lines.)
- Contributors push to their fork and open the PR to `iCog-Labs-Dev/metta-moses`. Keep the fork's base up to date before you open the PR, so that the diff shows only your work.
- Delete a merged branch and its worktree.

## 2. Commits

- Conventional Commits (`https://www.conventionalcommits.org/en/v1.0.0/`) with a scope: `fix(reduct): ...`, `refactor(scoring): ...`, `test(reduct): ...`, `perf(scoring): ...`, `feat: ...`, `chore: ...`. The history also uses `ref:` for refactors and `ref!:` for a breaking internal change.
- The subject says what changed. The body says why. Use bullets when a commit touches several files.
- One logical change per commit. Keep a rename or move apart from a behaviour change.
- Commit as yourself only. No AI co-author line, no "Generated with" line, no session link.
- Commit only your own changes (`git add -p`). Never commit scratch files, logs, local tools, or files with home paths.

## 3. Pull requests

- Use `.github/pull_request_template.md`. Fill every section ("Review order" is optional for a small PR). Do not invent new sections.
- Keep the description short enough for a person to read in two minutes, without loss of important detail. Put long drafts in an untracked file (`notes/`).
- Describe the **whole branch** from its base (`git log --format=%B <base>..HEAD`, full bodies, not `--oneline`), not only the last commit.
- Small PRs. One purpose per PR. A large PR needs a review order: say which files to read first.
- "How has this been tested" holds evidence: the exact commands (with `ulimit` and `timeout`), the runtime commit, and the result per file (✅ against asserts). For a performance claim, give the benchmark table (`benchmarks.md`). For a behaviour claim, give the classic comparison (`classic-oracle.md`).
- List every test change, each with its reason. A removed or weakened test needs the lead's approval before the PR.
- Link the issue: `Fixes #123`.
- Open the PR as a draft while CI or review is not ready.
- When an agent writes a PR, commit message or comment for a person, it writes as that person, in the first person. It does not refer to that person in the third person, and it does not describe the collaboration with the agent.

## 4. Approval for outward actions

- These need the lead's (or the PR owner's) explicit approval, each time: every push (also to your own feature branch or fork), open or edit a PR, post a comment or review, approve, request changes, open an issue, merge, tag, release.
- Approval for one item does not cover the next one.
- A push to your own feature branch also needs approval for that push. [A push is outward, and it starts CI.] When another person or agent needs the work, say so and ask.
- Do not merge another person's PR until its owner says that it is ready.

## 5. Other people's work

- Do not change another person's branch, worktree, or uncommitted files. Ask the owner.
- If the main checkout has uncommitted changes that are not yours, leave them. Do not stash, reset, check out or clean over them. Make your own worktree.
- If you leave a checkout in the middle of a merge or rebase, the owner cannot switch branches. Finish or abort your own operation before you hand over.

## 6. Releases and versions

- Versions are tags `v0.MINOR.PATCH`. The release PR goes from `dev` to `main` (for example #467 for `v0.6.0`). The lead tags the release.
- Only the lead decides a release and a version bump.
- Release notes list the highlights and every breaking change (`ref!`). Draft them in an untracked file first.
