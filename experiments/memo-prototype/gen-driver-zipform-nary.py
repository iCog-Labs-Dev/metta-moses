#!/usr/bin/env python3
"""
Fill driver-template-zipform-nary.metta placeholders and write a concrete
zipform-nary (variant-P, production-style n-ary AND/OR/NOT clause dispatch)
bench driver .metta file directly under experiments/memo-prototype/ (sibling
to gen-driver-zipform.py; that script and driver-template-zipform.metta are
UNTOUCHED -- variant P needs its own template because its candidate stream
comes from the quoted replay files, captures/<wl>.replay-quoted.metta, with
a different benchGetCandidate match pattern than variant M/S use).

Only one variant (P) -- unlike gen-driver-zipform.py's S/M/M_content
selector -- since production-style combine strategy + verbatim reuse of
zipform/evaluator-memo.metta is the entire point of this variant.

Usage:
    python3 experiments/memo-prototype/gen-driver-zipform-nary.py majority3
    python3 experiments/memo-prototype/gen-driver-zipform-nary.py mux6
    python3 experiments/memo-prototype/gen-driver-zipform-nary.py parity3
    python3 experiments/memo-prototype/gen-driver-zipform-nary.py rand12
"""

import sys
import os

HERE = os.path.dirname(os.path.abspath(__file__))
TEMPLATE_PATH = os.path.join(HERE, "driver-template-zipform-nary.metta")
# Same constraint as gen-driver.py / gen-driver-zipform.py: generated drivers
# must live directly in experiments/memo-prototype/ (NOT a subdirectory).
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


def gen(workload):
    assert workload in TABLE_CALL, f"unknown workload {workload}"
    with open(TEMPLATE_PATH) as f:
        tpl = f.read()

    label = f"{workload}_zipform_P"

    out = (
        tpl.replace("$TABLE_IMPORT", TABLE_IMPORT[workload])
        .replace("$WORKLOAD", workload)
        .replace("$TABLE_CALL", TABLE_CALL[workload])
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
        print("usage: gen-driver-zipform-nary.py <majority3|mux6|parity3|rand12>", file=sys.stderr)
        sys.exit(1)
    gen(sys.argv[1])
