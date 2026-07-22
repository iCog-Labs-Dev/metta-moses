#!/usr/bin/env python3
"""
Fill driver-template-zipform.metta placeholders and write a concrete zipform
bench driver .metta file directly under experiments/memo-prototype/ (sibling
to gen-driver.py; that script is untouched -- the zipform scoring path
composes two functions, (evalZipTerm|evalZipTermCached (rewriteTreeCached
$e)), rather than gen-driver.py's single $EVAL_FN slot, so it needs its own
template + generator rather than an extra branch bolted onto the old one).

Variants:
  S         -- space-backed eval cache (evalZipTermCached) + space-backed
               rewrite cache (rewrite-cache-space.metta).
  M         -- memoized eval (evalZipTerm) + memoized rewrite
               (rewrite-cache-memo.metta), wtinylfu, unique-limit 100000.
  M_content -- bonus: M's rewrite chain unchanged, but a DRIVER-LOCAL
               evalZipTermContent (copied structure of evaluator-common's
               evalZipTermCore -- module files are off-limits, driver-local
               code is not) routes the binary zipWith combine step through a
               separately-memoized `zipEval $f $colA $colB`, keyed on actual
               column VALUES rather than the zip-subterm expression (the
               boss's alternative "content-addressed" keying). Only
               majority3/mux6 per the plan.

Usage:
    python3 experiments/memo-prototype/gen-driver-zipform.py S majority3
    python3 experiments/memo-prototype/gen-driver-zipform.py M mux6
    python3 experiments/memo-prototype/gen-driver-zipform.py M_content mux6
"""

import sys
import os

HERE = os.path.dirname(os.path.abspath(__file__))
TEMPLATE_PATH = os.path.join(HERE, "driver-template-zipform.metta")
# Same constraint as gen-driver.py: generated drivers must live directly in
# experiments/memo-prototype/ (NOT a subdirectory) -- relative import! paths
# resolve against the ENTRY file's own directory for the whole process, so a
# driver written under a subdirectory would silently fail every downstream
# import! (import!'s catch/3 swallows all errors) -- gen-driver.py's header
# documents this the hard way; not re-deriving it here, just respecting it.
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
# correctness-harness-zipform-{memo,space}.metta's own single-choke-point
# import block; common/reference-formulas is NOT needed here since the bench
# drivers score replay-captured candidates, not the hand-written reference
# formulas).
_COMMON_CHAIN = [
    "!(import! &self common/list-helpers)",
    "!(import! &self common/kernel-common)",
    "!(import! &self zipform/ops)",
    "!(import! &self zipform/rewriter)",
    "!(import! &self zipform/evaluator-common)",
]

# Driver-local content-addressed bonus definitions (see module docstring).
# Two measurement-only counters stand in for the per-function stats lib_memo
# does not expose (get-memoize-stats is a GLOBAL aggregate across every
# memoized function in the process -- see lib_memo_doc.md -- so with THREE
# memoized functions live in this driver (rewriteTreeCached, evalZipTermContent,
# zipEval) the aggregate alone cannot isolate zipEval's own hit/miss count):
#   &zipEvalCallCount  -- incremented at the call SITE, every time the
#                         zipWith branch is reached (hit or miss of zipEval).
#   &zipEvalMissCount  -- incremented INSIDE zipEval's own equation body,
#                         which lib_memo only ever evaluates on a cache MISS
#                         (a hit short-circuits before the body runs, per
#                         evaluator-common.metta's documented memo-hit
#                         short-circuit note) -- so this is an EXACT count of
#                         distinct content-keys reached, not a derived
#                         estimate.
#   &evalZipTermContentMissCount -- same trick, for evalZipTermContent's own
#                         subterm-level miss count, directly comparable to
#                         zipform_M's evalZipTerm (whose own miss count can
#                         only be recovered indirectly for the M cell, by
#                         subtracting the known distinct-candidate count from
#                         the aggregate -- see results-zipform.md).
_CONTENT_DEFS = """
;; --- content-addressed bonus (driver-local; NOT a zipform/*.metta module
;; edit): memoize the binary combine step itself, keyed on actual column
;; VALUES (f, colA, colB), not the zip-subterm expression. evalZipTermCoreContent
;; is a driver-local copy of evaluator-common.metta's evalZipTermCore
;; structure (module files are off-limits, driver-local code is not) whose
;; ONLY change is the zipWith branch: it calls zipEval instead of handing
;; (f, evalled-colA, evalled-colB) straight to List.zipWith.
!(change-state! &zipEvalCallCount 0)
!(change-state! &zipEvalMissCount 0)
!(change-state! &evalZipTermContentMissCount 0)

!(memoize zipEval 3)
(= (zipEval $f $colA $colB)
   (let $_ (change-state! &zipEvalMissCount (+ 1 (get-state &zipEvalMissCount)))
     (List.zipWith $f $colA $colB)))

(= (evalZipTermCoreContent $term $eval)
   (if (== (get-metatype $term) Grounded)
       (List.repeat (param zipRowCount) $term)
       (let $h (car-atom $term)
         (if (== $h col)
             (let (col $label) $term (varColumn (param zipTable) $label))
             (if (== $h fmap)
                 (let (fmap $f $c) $term
                   (map-atom ($eval $c) $v ($f $v)))
                 (if (== $h zipWith)
                     (let (zipWith $f $a $b) $term
                       (let* (($colA ($eval $a))
                              ($colB ($eval $b))
                              ($_calls (change-state! &zipEvalCallCount (+ 1 (get-state &zipEvalCallCount)))))
                         (zipEval $f $colA $colB)))
                     (if (== $h zipWithN)
                         (let (zipWithN $op $children) $term
                           (let $cols (map-atom $children $c ($eval $c))
                             (map-atom (transposeCols $cols) $row ($op $row))))
                         (Error $term "evalZipTermCoreContent: unknown zip-term head"))))))))

!(memoize evalZipTermContent 1)
(= (evalZipTermContent $term)
   (let $_ (change-state! &evalZipTermContentMissCount (+ 1 (get-state &evalZipTermContentMissCount)))
     (evalZipTermCoreContent $term evalZipTermContent)))
"""


def gen(variant, workload):
    assert workload in TABLE_CALL, f"unknown workload {workload}"
    with open(TEMPLATE_PATH) as f:
        tpl = f.read()

    if variant == "S":
        import_lines = (
            _COMMON_CHAIN
            + [
                "!(import! &self zipform/evaluator-space)",
                "!(import! &self zipform/rewrite-cache-space)",
                TABLE_IMPORT[workload],
            ]
        )
        import_block = "\n".join(import_lines)
        score_expr = "(evalZipTermCached (rewriteTreeCached $e))"
        reset_block = "!(resetZipCache)"
        set_table = "setZipTable"
        stats_call = "(getZipSpaceStats)"
        extra_stats_line = (
            "(let $_e (println! (ENTRIES (size-atom (collapse (match &zipSubtermCache $e $e)))))\n"
            "     (println! (REWRITE_ENTRIES (size-atom (collapse (match &rewriteTermCache $e $e))))))"
        )
        label = f"{workload}_zipform_S"

    elif variant == "M":
        import_lines = (
            ["!(import! &self (library lib_memo))"]
            + _COMMON_CHAIN
            + [
                "!(import! &self zipform/evaluator-memo)",
                "!(import! &self zipform/rewrite-cache-memo)",
                TABLE_IMPORT[workload],
            ]
        )
        import_block = "\n".join(import_lines)
        score_expr = "(evalZipTerm (rewriteTreeCached $e))"
        reset_block = (
            "!(clear-memoize)\n"
            "!(clear-memoize-stats)\n"
            "!(config-memoize (strategy wtinylfu) (unique-limit 100000) (size-limit 5))"
        )
        set_table = "setZipTable"
        stats_call = "(get-memoize-stats)"
        extra_stats_line = "(println! (ENTRIES NA))"
        label = f"{workload}_zipform_M"

    elif variant == "M_content":
        assert workload in ("majority3", "mux6"), (
            "M_content bonus is only defined for majority3/mux6 per the plan"
        )
        # Deliberately does NOT import zipform/evaluator-memo: this variant
        # never calls the module's own evalZipTerm at all (it defines its own
        # evalZipTermContent below instead), so importing that module would
        # only add an unused memoized function to the process.
        import_lines = (
            ["!(import! &self (library lib_memo))"]
            + _COMMON_CHAIN
            + [
                "!(import! &self zipform/rewrite-cache-memo)",
                TABLE_IMPORT[workload],
            ]
        )
        import_block = "\n".join(import_lines) + "\n" + _CONTENT_DEFS
        score_expr = "(evalZipTermContent (rewriteTreeCached $e))"
        reset_block = (
            "!(clear-memoize)\n"
            "!(clear-memoize-stats)\n"
            "!(config-memoize (strategy wtinylfu) (unique-limit 100000) (size-limit 5))\n"
            "!(change-state! &zipEvalCallCount 0)\n"
            "!(change-state! &zipEvalMissCount 0)\n"
            "!(change-state! &evalZipTermContentMissCount 0)"
        )
        set_table = "setZipTable"
        stats_call = "(get-memoize-stats)"
        extra_stats_line = (
            "(let* (($_a (println! (ENTRIES NA)))\n"
            "       ($_b (println! (CONTENT_CALLS (get-state &zipEvalCallCount))))\n"
            "       ($_c (println! (CONTENT_MISSES (get-state &zipEvalMissCount)))))\n"
            "  (println! (EVALTERM_MISSES (get-state &evalZipTermContentMissCount))))"
        )
        label = f"{workload}_zipform_M_content"

    else:
        raise ValueError(f"unknown variant {variant}")

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
    if len(sys.argv) != 3:
        print("usage: gen-driver-zipform.py <S|M|M_content> <workload>", file=sys.stderr)
        sys.exit(1)
    gen(sys.argv[1], sys.argv[2])
