#!/usr/bin/env python3
"""
Scrape results/raw/*.log (written by run-bench.sh) for the BENCH_* / CHECKSUM
/ STATS / ENTRIES markers printed by driver-template.metta, group by cell
(workload/variant/strategy/limit), and print a compact table: median wall
(from in-script current-time deltas, the preferred measurement), stdev,
hits, misses, hit-rate, entries, and checksum (flagging any mismatch across
reps or between variants for the same workload -- a real correctness bug).

Usage: python3 experiments/memo-prototype/parse-results.py
"""

import glob
import os
import re
import statistics
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RAW_DIR = os.path.join(HERE, "results", "raw")

# filenames look like: <workload>_<variant...>_rep<i>.log
# variant is one of: space | memo_<strategy>_<limit>
NAME_RE = re.compile(
    r"^(?P<workload>parity3|majority3|mux6|rand12)_"
    r"(?:space|memo_(?P<strategy>wtinylfu|lru)_(?P<limit>\d+))"
    r"_rep(?P<rep>\d+)\.log$"
)


def parse_log(path):
    text = open(path).read()

    def grab(pattern, cast=float):
        m = re.search(pattern, text)
        return cast(m.group(1)) if m else None

    t0 = grab(r"\(BENCH_T0 ([\d.eE+-]+)\)")
    t1 = grab(r"\(BENCH_T1 ([\d.eE+-]+)\)")
    elapsed = grab(r"\(BENCH_ELAPSED_SEC ([\d.eE+-]+)\)")
    checksum = grab(r"\(CHECKSUM (\d+)\)", int)
    hits = grab(r"cache_hit (\d+)", int)
    misses = grab(r"cache_miss (\d+)", int)
    entries_m = re.search(r"\(ENTRIES (\S+?)\)", text)
    entries = entries_m.group(1) if entries_m else None
    streamlen = grab(r"\(BENCH_STREAMLEN (\d+)\)", int)
    ok = all(v is not None for v in (t0, t1, elapsed, checksum, hits, misses, streamlen))
    return dict(
        t0=t0, t1=t1, elapsed=elapsed, checksum=checksum, hits=hits,
        misses=misses, entries=entries, streamlen=streamlen, ok=ok,
    )


def main():
    logs = sorted(glob.glob(os.path.join(RAW_DIR, "*_rep*.log")))
    if not logs:
        print(f"no logs found under {RAW_DIR}", file=sys.stderr)
        sys.exit(1)

    cells = {}
    parse_failures = []
    for path in logs:
        base = os.path.basename(path)
        m = NAME_RE.match(base)
        if not m:
            print(f"WARNING: filename doesn't match expected pattern: {base}", file=sys.stderr)
            continue
        variant = "space" if m.group("strategy") is None else "memo"
        key = (m.group("workload"), variant, m.group("strategy"), m.group("limit"))
        parsed = parse_log(path)
        if not parsed["ok"]:
            parse_failures.append((base, parsed))
        cells.setdefault(key, []).append(parsed)

    if parse_failures:
        print("=== PARSE FAILURES (missing expected markers -- investigate!) ===")
        for base, parsed in parse_failures:
            print(f"  {base}: {parsed}")
        print()

    print("=== Cell summary ===")
    print(f"{'workload':10} {'variant':6} {'strategy':9} {'limit':7} "
          f"{'n':2} {'median_s':9} {'stdev_s':9} {'hits':7} {'misses':7} "
          f"{'hitrate':7} {'entries':8} {'checksum':10} {'ck_ok':6}")
    all_checksums_by_workload = {}
    for key in sorted(cells.keys()):
        workload, variant, strategy, limit = key
        runs = [r for r in cells[key] if r["ok"]]
        if not runs:
            print(f"{workload:10} {variant:6} {str(strategy):9} {str(limit):7}  NO VALID RUNS")
            continue
        elapsed = [r["elapsed"] for r in runs]
        median = statistics.median(elapsed)
        stdev = statistics.stdev(elapsed) if len(elapsed) > 1 else 0.0
        hits = runs[-1]["hits"]
        misses = runs[-1]["misses"]
        total = hits + misses
        hitrate = hits / total if total else 0.0
        entries = runs[-1]["entries"]
        checksums = {r["checksum"] for r in runs}
        ck_ok = "YES" if len(checksums) == 1 else "MISMATCH"
        checksum = checksums.pop() if len(checksums) == 1 else "/".join(str(c) for c in sorted(checksums))
        all_checksums_by_workload.setdefault(workload, set()).add(
            list({r["checksum"] for r in runs})[0] if len({r["checksum"] for r in runs}) == 1 else "MIXED"
        )
        print(f"{workload:10} {variant:6} {str(strategy):9} {str(limit):7} "
              f"{len(runs):2} {median:9.4f} {stdev:9.4f} {hits:7} {misses:7} "
              f"{hitrate:7.3f} {str(entries):8} {str(checksum):10} {ck_ok:6}")

    print()
    print("=== Cross-variant checksum agreement per workload (S vs M, all configs) ===")
    for workload, cks in sorted(all_checksums_by_workload.items()):
        status = "OK (all match)" if len(cks) == 1 and "MIXED" not in cks else f"MISMATCH: {cks}"
        print(f"  {workload:10} {status}")


if __name__ == "__main__":
    main()
