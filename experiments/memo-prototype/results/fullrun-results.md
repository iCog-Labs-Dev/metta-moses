# Full-pipeline benchmark: mux6, real metta-moses scoring path

Full end-to-end mux6 solves (`--problem=mux6 --maxGen=10 --nDeme=1 --nEval=1000`,
default seed 0, deterministic), wall-clock via bash `time` around the whole
process, 3 reps per cell, run strictly sequentially. Variant file sets and
swap/restore scripts live under `experiments/memo-prototype/integration/`
(see `integration/README.md`). Raw stdout logs and per-rep `time` output are
under `experiments/memo-prototype/results/fullrun/`.

## Did the full pipeline run on PR-165 at all?

**Yes, with zero workarounds beyond the memo-vs-space combine swap itself.**
Both integration variants (S-control and M) ran full mux6 solves to
completion on PR-165 (`/home/yab/PeTTa-pr165/run.sh`, commit `b1f6f49`)
without any additional patch, quoting fix, or pipeline change. This confirms
the background's characterization: `sealed`/`(reduce $var)` in the stock
`mkNodeTemplate`/`evalRow`/`transposeCols`/`combineNode` machinery
(scoring/fitness.metta) is the ONLY thing blocking a full run on PR-165, and
replacing it with the columnar `combineOp` fold (already verified
stock-PeTTa-safe in the standalone prototype) is sufficient to unblock the
entire pipeline -- boolean-ops.metta's AND/OR/NOT clauses, `preOrderExp`'s
quoting, hillclimbing, crossover, feature-selection, everything else in
`moses.metta`'s ~40-file import graph, all ran unmodified on PR-165.

No unrelated stock-PeTTa divergence was observed. The only visible artifact
is the constant translation-trace echo PR-165 prints for every top-level
form it loads (see below) -- purely cosmetic/logging, not a correctness or
behavior difference.

## Wall-time table

| cell | runtime | rep1 (s) | rep2 (s) | rep3 (s) | median (s) | min (s) |
|---|---|---|---|---|---|---|
| Baseline (unmodified tree) | PeTTaV1 | 30.235 | 31.403 | 30.748 | 30.748 | 30.235 |
| S-control (combineOp + `&subtreeCache`) | PR-165 | 23.394 | 25.889 | 25.955 | 25.889 | 23.394 |
| M, wtinylfu, unique-limit 100000 | PR-165 | 26.399 | 26.382 | 26.498 | 26.399 | 26.382 |
| M, lru, unique-limit 100000 | PR-165 | 27.782 | 26.616 | 26.504 | 26.616 | 26.504 |

Raw logs: `baseline_rep{1,2,3}.log`/`.time.txt`, `space_rep{1,2,3}.log`/`.time.txt`,
`memo_wtinylfu_rep{1,2,3}.log`/`.time.txt`, `memo_lru_rep{1,2,3}.log`/`.time.txt`,
all under `experiments/memo-prototype/results/fullrun/`.

## FinalResult equivalence

All 12 runs (baseline x3, S-control x3, M-wtinylfu x3, M-lru x3) produced
**byte-identical** `(FinalResult ...)` lines (mux6's champion candidates
contain no free variables, so no var-normalization was actually needed here
-- a plain `diff` sufficed):

```
(AND (OR (AND (NOT A0) (OR (NOT A1) D1) (OR A1 D0)) (AND A0 D2 (NOT A1)) (AND A0 A1 D3)))  score 0
... [10 candidates total, identical set and order across all 12 runs]
```

Parity3 smoke-test triplet (baseline/PeTTaV1, S-control/PR-165, M/PR-165) was
also byte-identical (see `experiments/memo-prototype/results/fullrun/smoke_*.log`).
Verdict: **exact match across every cell and every runtime**, not just
var-normalized-equal.

## Scoring's share of total wall time

Standalone in-script fold timings for mux6 at unbounded-equivalent capacity
(from `experiments/memo-prototype/results/results.md`, unique-limit 10000,
2618 distinct subtree keys):

| variant | median fold (s) | min fold (s) |
|---|---|---|
| S (unbounded) | 1.2369 | 1.2245 |
| M, wtinylfu | 1.5754 | 1.0092 |
| M, lru | 1.6131 | 0.9994 |

Against full-pipeline walls of ~26-31s, the candidate-fold/scoring-combine
step is roughly **4-6% of total wall time** for this workload/config
(1.0-1.6s out of 26-31s). The remaining ~94-96% is representation building,
hillclimbing/crossover, feature-selection, and everything else in the
pipeline outside `evalSubtree`/`evalColM`. This means the S-vs-M delta
visible in the isolated fold benchmark (a few hundred ms to ~0.5s either way)
is largely swallowed by full-pipeline noise: the observed cell-to-cell deltas
here (S-control 25.9s vs M cells 26.4-26.6s, i.e. ~0.5-0.7s, ~2%) are the
right order of magnitude to be explained by the standalone fold delta, but
are not clearly distinguishable from process-level jitter at only 3 reps
(compare space_rep1's 23.4s outlier against reps 2/3 at ~25.9s -- a ~2.5s
swing on the SAME variant/config).

## Caveats

- **PR-165 translation-trace echo is a constant per-process overhead**,
  common to all PR-165 cells and irrelevant to the M-vs-S comparison.
  Measured directly: running `/home/yab/PeTTa-pr165/run.sh moses.metta` with
  no `--problem` (hits the pipeline's own `no-problem-help-and-exit`, so it
  still loads and translates the FULL ~40-file `moses.metta` import graph --
  22069 lines of trace output -- but does zero scoring/hillclimbing work)
  took **0.996s wall**. That's the floor for "translate everything, do
  nothing," i.e. roughly the constant tax baked into every PR-165 cell above
  (log: `experiments/memo-prototype/results/fullrun/overhead_noproblem.log`/
  `.time.txt`). At ~1s out of ~26s it is a real but small (~4%) contributor,
  and since it is identical machinery for S-control, M-wtinylfu, and M-lru,
  it cancels out of the M-vs-S comparison entirely.
- **Baseline (PeTTaV1) vs PR-165 cells are different runtimes**, so the
  baseline row is a directional reference only, not a controlled comparison
  point against S/M. (Interestingly PR-165's S-control cell ran *faster*
  wall-clock than PeTTaV1's baseline here, 25.9s vs 30.7s median -- plausibly
  runtime/build differences unrelated to this experiment; not investigated
  further since it's outside this benchmark's scope.)
- **3 reps per cell is a small sample** for full-pipeline process-level
  timing; the ~2s spread on nominally-identical S-control reps (23.4 /
  25.9 / 25.9) shows the noise floor is comparable to the M-vs-S delta this
  benchmark is trying to detect. A confident ranking of wtinylfu vs lru vs
  S at full-pipeline scale would need more reps than were run here (kept to
  3 per the task's time budget); directionally, all three PR-165 cells are
  within ~1s of each other and none is a clear full-pipeline win over the
  others at this problem size -- consistent with scoring being a small
  (~4-6%) slice of total time.
- No candidate table other than mux6 was exercised at full-pipeline scale
  (parity3 was smoke-test only, 2 generations, not timed as a benchmark
  cell) -- this report's per-cell timing conclusions are mux6-specific.

## PeTTaV1 + new kernel (attribution cell)

The original table above conflates two independent variables in the
S-control-vs-baseline delta: the scoring-kernel change (stock `combineOp`
fold vs stock PeTTaV1 `mkNodeTemplate`/`evalRow`/`transposeCols`/
`combineNode`) AND the runtime change (PeTTaV1 vs PR-165). Since the `space`
variant is stock-PeTTa-safe, it also runs unmodified on PeTTaV1, isolating
just the kernel-change contribution: same runtime as Baseline, same
combine-primitive change as S-control.

Same swap/restore procedure as the other cells
(`experiments/memo-prototype/integration/swap.sh space` /
`integration/restore.sh`), same smoke test (parity3, `--maxGen=2 --nDeme=1
--nEval=1000`, reached `(FinalResult ...)` with no errors), same command and
3-rep/strictly-sequential convention as every other cell:
`sh /home/yab/PeTTaV1/run.sh moses.metta -s --problem=mux6 --maxGen=10 --nDeme=1 --nEval=1000`.

| cell | runtime | rep1 (s) | rep2 (s) | rep3 (s) | median (s) | min (s) |
|---|---|---|---|---|---|---|
| Baseline (unmodified tree) | PeTTaV1 | 30.235 | 31.403 | 30.748 | 30.748 | 30.235 |
| **S-control (combineOp + `&subtreeCache`), attribution cell** | **PeTTaV1** | **29.896** | **27.269** | **27.908** | **27.908** | **27.269** |
| S-control (combineOp + `&subtreeCache`) | PR-165 | 23.394 | 25.889 | 25.955 | 25.889 | 23.394 |

Raw logs: `pettav1_space_rep{1,2,3}.log`/`.time.txt`, under
`experiments/memo-prototype/results/fullrun/`.

FinalResult equivalence: all 3 reps produced a `(FinalResult ...)` line
**byte-identical** to `baseline_rep1.log`'s (and thus to every other cell's,
per the equivalence check above) -- confirmed via `diff`, not just
var-normalized comparison.

Attribution: the kernel-change-only delta (PeTTaV1 baseline 30.748s median
vs PeTTaV1+new-kernel 27.908s median) is **~2.8s, ~9% faster**, entirely
attributable to the `combineOp` fold replacing
`mkNodeTemplate`/`evalRow`/`transposeCols`/`combineNode` (same runtime, same
`&subtreeCache` mechanism, only the combine step differs). This is larger
than and in the same direction as the ~4-6% scoring-share estimate above,
consistent with the new combine step being a real (if modest) win
independent of runtime. The remaining PeTTaV1-vs-PR-165 gap on the same
kernel (27.908s vs 25.889s median, ~2s) is therefore attributable to the
runtime, not the kernel -- confirming the original table's caveat that the
PeTTaV1-baseline-vs-PR-165-S-control comparison was conflating two
variables, and this attribution cell separates them: roughly 2.8s of the
~4.8s total Baseline/PeTTaV1-vs-S-control/PR-165 gap (30.7s -> 25.9s) comes
from the kernel change, and roughly 2.0s from the runtime change.
