#!/usr/bin/env bash
# Restore tracked files touched by any integration variant (space or memo)
# back to their committed state. Safe to run whether or not a variant is
# currently swapped in. Does NOT touch anything under experiments/.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel)"

# Union of relative paths touched across all variants (currently: just
# scoring/fitness.metta -- see README.md in this directory).
paths=(
  "scoring/fitness.metta"
)

cd "$repo_root"
echo "Restoring tracked files: ${paths[*]}"
git checkout -- "${paths[@]}"
echo "Done. git diff should now be empty for these paths."
