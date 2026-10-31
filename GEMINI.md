@AGENTS.md

## Gemini CLI notes

- This file replaces the earlier generated `GEMINI.md`. Its facts about MeTTaLog, SWI-Prolog 9.3.25, `./run.sh` and kebab-case names were out of date. `AGENTS.md` holds the current facts.
- Wrap every shell command that runs MeTTa in `( ulimit -v 8000000; timeout <sec> ... )`. Gemini CLI does not limit memory for you.
- Do not use `--yolo` for work that pushes, opens PRs or posts comments. Those are outward actions and need approval each time.
