#!/bin/bash


git clone https://github.com/patham9/PeTTa

cd PeTTa || exit

$gitHash = "c04c01295dffb875af1287a3f7283a7bd6acee09"
git checkout $gitHash

if ! grep -q "^#!/bin/bash" run.sh; then
    sed -i '1i#!/bin/bash' run.sh
fi

SCRIPT_DIR="$(pwd)/src/main.pl"
MORK_DIR="$(pwd)/mork_ffi/target/release/libmork_ffi.so"

sed -i "s|./src/main.pl|$SCRIPT_DIR|" run.sh
sed -i "s|./mork_ffi/target/release/libmork_ffi.so|$MORK_DIR|" run.sh

chmod +x run.sh

repo_path=$(pwd)
if ! echo "$PATH" | grep -q "$repo_path"; then
    export PATH="$PATH:$repo_path"
    echo "PATH=$PATH" >> $GITHUB_ENV
fi