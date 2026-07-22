#!/usr/bin/env python3
"""
Fill driver-template-zipform.metta placeholders and write a concrete
zipform-REDUCE bench driver .metta file directly under
experiments/memo-prototype/ (sibling to gen-driver-zipform.py, which is
untouched -- variant R uses a different evaluator module and scoring
expression, `(evalZipTermR (rewriteTreeCached $e))` against zipform/
evaluator-reduce-memo.metta's reduce-dispatch memoized combinators, rather
than gen-driver-zipform.py's evalZipTerm/evalZipTermCached slots, so it gets
its own small generator rather than an extra branch bolted onto that one).

Variant:
  R -- reduce-dispatch memoized combinators (col/fmap/zipWith/zipWithN each
       individually memoized, dispatched via PR-165's `reduce`), wtinylfu,
       unique-limit 100000 (same preset as zipform_M, for direct
       comparability -- see results/results-zipform.md's "Variant R" section
       for the max-observed-keys check).

Usage:
    python3 experiments/memo-prototype/gen-driver-zipform-reduce.py majority3
    python3 experiments/memo-prototype/gen-driver-zipform-reduce.py mux6
"""

import sys
import os

HERE = os.path.dirname(os.path.abspath(__file__))
TEMPLATE_PATH = os.path.join(HERE, "driver-template-zipform.metta")
# Same constraint as gen-driver.py / gen-driver-zipform.py: generated drivers
# must live directly in experiments/memo-prototype/ (NOT a subdirectory) --
# relative import! paths resolve against the ENTRY file's own directory for
# the whole process, so a driver under a subdirectory would silently fail
# every downstream import! (import!'s catch/3 swallows all errors).
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

# Shared leaf chain every zipform variant needs, in dependency order (mirrors
# gen-driver-zipform.py's own _COMMON_CHAIN / correctness-harness-zipform-
# {memo,space,reduce}.metta's single-choke-point import block).
_COMMON_CHAIN = [
    "!(import! &self common/list-helpers)",
    "!(import! &self common/kernel-common)",
    "!(import! &self zipform/ops)",
    "!(import! &self zipform/rewriter)",
    "!(import! &self zipform/evaluator-common)",
]


def gen(workload):
    assert workload in TABLE_CALL, f"unknown workload {workload}"
    with open(TEMPLATE_PATH) as f:
        tpl = f.read()

    import_lines = (
        ["!(import! &self (library lib_memo))"]
        + _COMMON_CHAIN
        + [
            "!(import! &self zipform/evaluator-reduce-memo)",
            "!(import! &self zipform/rewrite-cache-memo)",
            TABLE_IMPORT[workload],
        ]
    )
    import_block = "\n".join(import_lines)
    score_expr = "(evalZipTermR (rewriteTreeCached $e))"
    reset_block = (
        "!(clear-memoize)\n"
        "!(clear-memoize-stats)\n"
        "!(config-memoize (strategy wtinylfu) (unique-limit 100000) (size-limit 5))"
    )
    set_table = "setZipTable"
    stats_call = "(get-memoize-stats)"
    extra_stats_line = "(println! (ENTRIES NA))"
    label = f"{workload}_zipform_R"

    out = (
        tpl.replace("$IMPORT_BLOCK", import_block)
        .replace("$WORKLOAD", workload)
        .replace("$RESET_BLOCK", reset_block)
        .replace("$SET_TABLE", set_table)
        .replace("$TABLE_CALL", TABLE_CALL[workload])
        .replace("$SCORE_EXPR", score_expr)
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
    if len(sys.argv) != 2:
        print("usage: gen-driver-zipform-reduce.py <workload>", file=sys.stderr)
        sys.exit(1)
    gen(sys.argv[1])
