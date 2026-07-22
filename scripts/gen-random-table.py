"""
Deterministic generator for the rand12 (or rand8 fallback) capture workload.

Emits a CSV with N boolean input columns X1..XN plus a target column `out`,
covering the FULL 2**N enumeration of inputs (all rows, no sampling), so the
resulting truth table is a legitimate (if arbitrary) boolean function with no
duplicate/conflicting rows.

The target function is a fixed, seeded "random" boolean formula built from a
small random subset of the input variables (majority-of-3 by default) so the
table isn't just an existing demo problem in disguise, while still being
reproducible: same --seed and --n-inputs always produce byte-identical CSVs.

Usage:
    python3 scripts/gen-random-table.py --n-inputs 12 --seed 12345 \
        --out experiments/memo-prototype/captures/rand12.csv

    python3 scripts/gen-random-table.py --n-inputs 8 --seed 12345 \
        --out experiments/memo-prototype/captures/rand8.csv
"""

import argparse
import csv
import itertools
import random


def build_target_fn(n_inputs, seed):
    """Pick 3 distinct input indices (0-based) via a seeded RNG and return a
    function computing majority-of-those-3 for a given input row (tuple of
    0/1 ints). Returns (fn, chosen_indices) so the choice can be logged.
    """
    rng = random.Random(seed)
    chosen = sorted(rng.sample(range(n_inputs), 3))

    def target(row):
        a, b, c = (row[i] for i in chosen)
        return 1 if (a + b + c) >= 2 else 0

    return target, chosen


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--n-inputs", type=int, default=12,
                     help="number of boolean input columns (default: 12)")
    ap.add_argument("--seed", type=int, default=12345,
                     help="RNG seed controlling which 3 input vars the "
                          "target majority function is computed over "
                          "(default: 12345)")
    ap.add_argument("--out", required=True, help="output CSV path")
    args = ap.parse_args()

    n = args.n_inputs
    labels = ["X{}".format(i + 1) for i in range(n)] + ["out"]
    target_fn, chosen = build_target_fn(n, args.seed)

    with open(args.out, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(labels)
        for row in itertools.product([0, 1], repeat=n):
            y = target_fn(row)
            w.writerow([str(v) for v in row] + [str(y)])

    n_rows = 2 ** n
    chosen_names = ["X{}".format(i + 1) for i in chosen]
    print("Wrote {} ({} rows, {} input cols) - target = majority({}), seed={}"
          .format(args.out, n_rows, n, ", ".join(chosen_names), args.seed))


if __name__ == "__main__":
    main()
