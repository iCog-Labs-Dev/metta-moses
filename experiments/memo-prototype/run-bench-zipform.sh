#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Sequential benchmark orchestrator for the zipform (boss-literal zipWith
# kernel) comparison -- sibling to run-bench.sh (untouched), same
# conventions: each (workload, variant) driver runs N times on the PR-165
# runtime, ALWAYS one process at a time (never in parallel -- wall times
# must be clean), full echo-heavy stdout+stderr redirected to
# results/raw/<name>_rep<i>.log. Timing comes primarily from the in-script
# BENCH_T0/BENCH_T1 (current-time) markers printed inside each log; every
# rep is additionally wrapped in bash's own `time` builtin as a
# process-level cross-check written to the sibling .time.txt (no GNU
# /usr/bin/time on this machine, so no max-RSS -- same caveat as
# results/results.md).
#
# Cells (5 reps each; drop to 3 by re-running with REPS=3 for a cell whose
# single rep exceeds ~5 min, per the Phase 3 plan's time-box):
#   zipform_S         x {majority3, mux6, parity3, rand12}
#   zipform_M         x {majority3, mux6, parity3, rand12}   (wtinylfu, unique-limit 100000)
#   zipform_M_content x {majority3, mux6}                    (bonus)
#
# Usage: bash experiments/memo-prototype/run-bench-zipform.sh
# ---------------------------------------------------------------------------
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME=/home/yab/PeTTa-pr165/run.sh
RAW_DIR="$HERE/results/raw"
mkdir -p "$RAW_DIR"

REPS_DEFAULT=5

run_cell() {
  local driver_name="$1"   # e.g. drv_majority3_zipform_S (no .metta)
  local reps="$2"
  local driver_path="$HERE/${driver_name}.metta"
  if [ ! -f "$driver_path" ]; then
    echo "SKIP (missing driver): $driver_path"
    return
  fi
  for i in $(seq 1 "$reps"); do
    local log="$RAW_DIR/${driver_name#drv_}_rep${i}.log"
    local timelog="$RAW_DIR/${driver_name#drv_}_rep${i}.time.txt"
    echo "[$(date +%H:%M:%S)] RUN ${driver_name} rep ${i}/${reps} -> $(basename "$log")"
    { time "$RUNTIME" "$driver_path" > "$log" 2>&1; } 2> "$timelog"
  done
}

echo "=== zipform_S: 4 workloads x ${REPS_DEFAULT} reps ==="
for w in majority3 mux6 parity3 rand12; do
  run_cell "drv_${w}_zipform_S" "$REPS_DEFAULT"
done

echo "=== zipform_M (wtinylfu, unique-limit 100000): 4 workloads x ${REPS_DEFAULT} reps ==="
for w in majority3 mux6 parity3 rand12; do
  run_cell "drv_${w}_zipform_M" "$REPS_DEFAULT"
done

echo "=== zipform_M_content bonus: majority3 + mux6 x ${REPS_DEFAULT} reps ==="
for w in majority3 mux6; do
  run_cell "drv_${w}_zipform_M_content" "$REPS_DEFAULT"
done

echo "=== DONE ==="
