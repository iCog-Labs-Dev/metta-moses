#!/usr/bin/env bash
# Swap an integration variant's file set into the main tree.
#
# Usage: swap.sh <space|memo>
#
# Copies every file under integration/<variant>/ over the corresponding
# tracked path at the repo root (integration/<variant>/scoring/fitness.metta
# -> <repo-root>/scoring/fitness.metta). Run restore.sh (in this same
# directory) to put the tracked files back afterward -- do NOT git commit
# while a variant is swapped in.
set -euo pipefail

variant="${1:-}"
case "$variant" in
  space|memo|memo-lru) ;;
  *)
    echo "usage: $0 <space|memo|memo-lru>" >&2
    exit 1
    ;;
esac

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel)"
variant_dir="$script_dir/$variant"

if [[ ! -d "$variant_dir" ]]; then
  echo "no such variant dir: $variant_dir" >&2
  exit 1
fi

echo "Swapping in variant '$variant' (files below) into $repo_root:"
while IFS= read -r -d '' src; do
  rel="${src#"$variant_dir"/}"
  dest="$repo_root/$rel"
  echo "  $rel"
  cp "$src" "$dest"
done < <(find "$variant_dir" -type f -print0)

echo "Done. Run restore.sh to revert before switching variants or committing."
