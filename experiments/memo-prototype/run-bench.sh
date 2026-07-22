#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Sequential benchmark orchestrator for the memo-prototype cache-variant
# comparison. Runs each (workload, variant, strategy, limit) driver N times
# on the PR-165 runtime, ALWAYS one process at a time (never in parallel --
# wall times must be clean), redirecting the full echo-heavy stdout+stderr to
# results/raw/<name>_rep<i>.log. Timing comes primarily from the in-script
# BENCH_T0/BENCH_T1 (current-time) markers printed inside each log; this
# script also wraps every rep with the shell's own `time` builtin as a
# process-level cross-check (no /usr/bin/time -v available on this machine --
# GNU time is not installed here, so no max-RSS numbers are collected; this
# is noted as a threat to validity in results/results.md).
#
# Usage: bash experiments/memo-prototype/run-bench.sh
# ---------------------------------------------------------------------------
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME=/home/yab/PeTTa-pr165/run.sh
RAW_DIR="$HERE/results/raw"
mkdir -p "$RAW_DIR"

REPS_DEFAULT=5

run_cell() {
  local driver_name="$1"   # e.g. drv_majority3_space (no .metta)
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
    # No GNU /usr/bin/time on this machine -- use bash's own `time` builtin
    # for a process-level wall-clock cross-check (no max-RSS available; the
    # in-script current-time markers inside $log are the primary measurement).
    { time "$RUNTIME" "$driver_path" > "$log" 2>&1; } 2> "$timelog"
  done
}

echo "=== Variant S: 4 workloads x 5 reps ==="
for w in majority3 mux6 parity3 rand12; do
  run_cell "drv_${w}_space" "$REPS_DEFAULT"
done

echo "=== Variant M full sweep: majority3 + mux6, {wtinylfu,lru} x {100,1000,10000,distinct} x 5 reps ==="
for w_d in majority3:192 mux6:1125; do
  w="${w_d%%:*}"; d="${w_d##*:}"
  for strat in wtinylfu lru; do
    for lim in 100 1000 10000 "$d"; do
      run_cell "drv_${w}_memo_${strat}_${lim}" "$REPS_DEFAULT"
    done
  done
done

echo "=== Variant M single config (wtinylfu, unique-limit=distinct-count): parity3 + rand12 x 5 reps ==="
run_cell "drv_parity3_memo_wtinylfu_977" "$REPS_DEFAULT"
run_cell "drv_rand12_memo_wtinylfu_652" "$REPS_DEFAULT"

echo "=== DONE ==="
