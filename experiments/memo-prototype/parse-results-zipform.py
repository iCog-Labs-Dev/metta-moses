#!/usr/bin/env python3
"""
Scrape results/raw/*_zipform_*_rep*.log (written by run-bench-zipform.sh)
for the BENCH_* / CHECKSUM / STATS / ENTRIES / REWRITE_ENTRIES /
CONTENT_CALLS / CONTENT_MISSES / EVALTERM_MISSES markers printed by
driver-template-zipform.metta, group by cell, and print a compact table.
Sibling to parse-results.py (untouched -- its filename regex only knows the
old space/memo cells).

Usage: python3 experiments/memo-prototype/parse-results-zipform.py
"""

import glob
import os
import re
import statistics
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RAW_DIR = os.path.join(HERE, "results", "raw")

NAME_RE = re.compile(
    r"^(?P<workload>parity3|majority3|mux6|rand12)_zipform_"
    r"(?P<variant>S|M|M_content|R|P)"
    r"_rep(?P<rep>\d+)\.log$"
)

EXPECTED_CK = {"majority3": 3977, "mux6": 140043, "parity3": 30354, "rand12": 3912064}


def parse_log(path):
    text = open(path).read()

    def grab(pattern, cast=float):
        m = re.search(pattern, text)
        return cast(m.group(1)) if m else None

    d = dict(
        elapsed=grab(r"\(BENCH_ELAPSED_SEC ([\d.eE+-]+)\)"),
        checksum=grab(r"\(CHECKSUM (\d+)\)", int),
        hits=grab(r"cache_hit (\d+)", int),
        misses=grab(r"cache_miss (\d+)", int),
        streamlen=grab(r"\(BENCH_STREAMLEN (\d+)\)", int),
        entries=grab(r"\(ENTRIES (\d+)\)", int),
        rewrite_entries=grab(r"\(REWRITE_ENTRIES (\d+)\)", int),
        content_calls=grab(r"\(CONTENT_CALLS (\d+)\)", int),
        content_misses=grab(r"\(CONTENT_MISSES (\d+)\)", int),
        evalterm_misses=grab(r"\(EVALTERM_MISSES (\d+)\)", int),
    )
    d["ok"] = all(
        d[k] is not None for k in ("elapsed", "checksum", "hits", "misses", "streamlen")
    )
    return d


def main():
    logs = sorted(glob.glob(os.path.join(RAW_DIR, "*_zipform_*_rep*.log")))
    if not logs:
        print(f"no zipform logs found under {RAW_DIR}", file=sys.stderr)
        sys.exit(1)

    cells = {}
    for path in logs:
        m = NAME_RE.match(os.path.basename(path))
        if not m:
            print(f"WARNING: unmatched filename {os.path.basename(path)}", file=sys.stderr)
            continue
        key = (m.group("workload"), m.group("variant"))
        cells.setdefault(key, []).append(parse_log(path))

    print("=== zipform cell summary ===")
    hdr = (
        f"{'workload':10} {'variant':10} {'n':2} {'median_s':9} {'stdev_s':9} "
        f"{'min_s':9} {'hits':7} {'misses':7} {'hitrate':7} {'entries':8} "
        f"{'rw_entr':8} {'checksum':10} {'ck_ok':6}"
    )
    print(hdr)
    for key in sorted(cells.keys()):
        workload, variant = key
        runs = [r for r in cells[key] if r["ok"]]
        if not runs:
            print(f"{workload:10} {variant:10}  NO VALID RUNS")
            continue
        elapsed = [r["elapsed"] for r in runs]
        median = statistics.median(elapsed)
        stdev = statistics.stdev(elapsed) if len(elapsed) > 1 else 0.0
        hits, misses = runs[-1]["hits"], runs[-1]["misses"]
        hitrate = hits / (hits + misses) if (hits + misses) else 0.0
        checksums = {r["checksum"] for r in runs}
        ck = checksums.pop() if len(checksums) == 1 else "MIXED"
        ck_ok = "YES" if ck == EXPECTED_CK[workload] else "NO"
        print(
            f"{workload:10} {variant:10} {len(runs):2} {median:9.4f} {stdev:9.4f} "
            f"{min(elapsed):9.4f} {hits:7} {misses:7} {hitrate:7.3f} "
            f"{str(runs[-1]['entries']):8} {str(runs[-1]['rewrite_entries']):8} "
            f"{str(ck):10} {ck_ok:6}"
        )
        if variant == "M_content":
            r = runs[-1]
            print(
                f"{'':10} {'':10}    content_calls={r['content_calls']} "
                f"content_misses={r['content_misses']} "
                f"evalterm_misses={r['evalterm_misses']}"
            )

    print()
    print("=== checksum verdict per workload ===")
    by_wl = {}
    for (wl, _v), runs in cells.items():
        by_wl.setdefault(wl, set()).update(r["checksum"] for r in runs if r["ok"])
    for wl, cks in sorted(by_wl.items()):
        exp = EXPECTED_CK[wl]
        status = "OK" if cks == {exp} else f"MISMATCH (expected {exp}, saw {sorted(cks)})"
        print(f"  {wl:10} {status}")


if __name__ == "__main__":
    main()
