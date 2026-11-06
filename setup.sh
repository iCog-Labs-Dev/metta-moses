#!/bin/bash
# Clone PeTTaV2 (the runtime that counts) at the pinned commit and add it to PATH.
# run.sh finds src/main.pl from its own folder, so no path rewrite is necessary.

PETTA_REPO="https://github.com/Yagth/PeTTa"
PETTA_COMMIT="5cc0a154f8526ac568c52f41531a4359f8e1277a"

git clone "$PETTA_REPO" PeTTa || exit 1
cd PeTTa || exit 1
git checkout "$PETTA_COMMIT" || exit 1
chmod +x run.sh

repo_path=$(pwd)
if ! echo "$PATH" | grep -q "$repo_path"; then
    export PATH="$repo_path:$PATH"
    if [ -n "$GITHUB_ENV" ]; then
        echo "PATH=$PATH" >> "$GITHUB_ENV"
    fi
fi
