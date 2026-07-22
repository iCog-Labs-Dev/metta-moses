#!/usr/bin/env python3
"""
Fill driver-template.metta placeholders and write a concrete driver .metta
file under drivers/. One driver file per (kernel, workload, strategy, limit)
cell; reps just re-run the same generated driver file N times (no per-rep
file needed since the driver has no randomness).

Usage:
    python3 experiments/memo-prototype/gen-driver.py space majority3
    python3 experiments/memo-prototype/gen-driver.py memo majority3 wtinylfu 192
"""

import sys
import os

HERE = os.path.dirname(os.path.abspath(__file__))
TEMPLATE_PATH = os.path.join(HERE, "driver-template.metta")
# IMPORTANT: generated drivers must live directly in experiments/memo-prototype/
# (NOT a subdirectory) -- relative import! paths resolve against the ENTRY
# file's own directory for the whole process (working_dir/1, asserted once at
# startup), so a driver under drivers/foo.metta would resolve "kernel-space"
# to drivers/kernel-space.metta, which doesn't exist, and import! silently
# fails (its catch/3 swallows all errors) -- verified the hard way: an early
# version of this generator wrote to drivers/ and every downstream call
# (resetProtoCache, setProtoTable, evalColCached) silently no-op'd as inert
# unevaluated data with zero error output.
DRIVERS_DIR = HERE

TABLE_CALL = {
    "parity3": "(parity3Table)",
    "majority3": "(majority3Table)",
    "mux6": "(mux6Table)",
    "rand12": "(rand12Table)",
}
TABLE_IMPORT = {
    "parity3": "!(import! &self common/truth-tables)",
    "majority3": "!(import! &self common/truth-tables)",
    "mux6": "!(import! &self common/truth-tables)",
    "rand12": "!(import! &self captures/rand12-table)",
}


def gen(variant, workload, strategy=None, limit=None):
    assert workload in TABLE_CALL, f"unknown workload {workload}"
    with open(TEMPLATE_PATH) as f:
        tpl = f.read()

    if variant == "memo":
        assert strategy is not None and limit is not None, "memo needs strategy+limit"
        kernel_import_line = "!(import! &self kernel-memo)"
        set_table = "setMemoTable"
        eval_fn = "evalCol"
        stats_call = "(get-memoize-stats)"
        extra_stats_line = "(println! (ENTRIES NA))"
        reset_block = (
            "!(clear-memoize)\n"
            "!(clear-memoize-stats)\n"
            f"!(config-memoize (strategy {strategy}) (unique-limit {limit}) (size-limit 5))"
        )
        label = f"{workload}_memo_{strategy}_{limit}"
    elif variant == "space":
        kernel_import_line = "!(import! &self kernel-space)"
        set_table = "setProtoTable"
        eval_fn = "evalColCached"
        stats_call = "(getSpaceStats)"
        extra_stats_line = (
            "(println! (ENTRIES (size-atom (collapse "
            "(match &protoSubtreeCache $e $e)))))"
        )
        reset_block = "!(resetProtoCache)"
        label = f"{workload}_space"
    else:
        raise ValueError(f"unknown variant {variant}")

    out = (
        tpl.replace("$KERNEL_IMPORT_LINE", kernel_import_line)
        .replace("$TABLE_IMPORT_LINE", TABLE_IMPORT[workload])
        .replace("$WORKLOAD", workload)
        .replace("$RESET_BLOCK", reset_block)
        .replace("$SET_TABLE", set_table)
        .replace("$TABLE_CALL", TABLE_CALL[workload])
        .replace("$EVAL_FN", eval_fn)
        .replace("$STATS_CALL", stats_call)
        .replace("$EXTRA_STATS_LINE", extra_stats_line)
        .replace("$LABEL", label)
    )

    os.makedirs(DRIVERS_DIR, exist_ok=True)
    out_path = os.path.join(DRIVERS_DIR, f"drv_{label}.metta")
    with open(out_path, "w") as f:
        f.write(out)
    print(out_path)
    return out_path


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("usage: gen-driver.py <memo|space> <workload> [strategy] [limit]", file=sys.stderr)
        sys.exit(1)
    variant = sys.argv[1]
    workload = sys.argv[2]
    strategy = sys.argv[3] if len(sys.argv) > 3 else None
    limit = sys.argv[4] if len(sys.argv) > 4 else None
    gen(variant, workload, strategy, limit)
