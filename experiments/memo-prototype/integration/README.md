# Full-pipeline integration variants

Two variants of the memoize-backed scoring kernel wired into the real
metta-moses pipeline, for full mux6-solve benchmarking (see
`experiments/memo-prototype/results/fullrun-results.md`).

Both variants touch exactly ONE tracked file: `scoring/fitness.metta`.
`scoring/cacheSpace.metta`, `scoring/bscore.metta`, and `scoring/boolean-ops.metta`
are unchanged by either variant.

## space/ -- Variant S-control

- Touches: `scoring/fitness.metta`
- Same `&subtreeCache` match/add-atom memo mechanism as production
  (`evalSubtree` unchanged in structure). Only the combine step (child
  columns -> node column) changes: `mkNodeTemplate`/`evalRow`/
  `transposeCols`/`combineNode` (sealed/reduce row-templates, PeTTaV1-only)
  are replaced by the stock-safe `combineOp` fold, ported from
  `experiments/memo-prototype/common/kernel-common.metta`.
- Runs on BOTH PeTTaV1 and PR-165.
- Purpose: isolate the cache-mechanism comparison (M vs S) from the
  combine-primitive change -- both variants use the same `combineOp`, so any
  M-vs-S delta at full-pipeline scale is attributable to the memo mechanism
  (lib_memo vs hand-rolled `&subtreeCache`), not to the combine rewrite
  itself.

## memo/ -- Variant M

- Touches: `scoring/fitness.metta`
- Adds `!(import! &self (library lib_memo))`, `!(config-memoize
  (unique-limit 100000) (strategy <S>) (size-limit 5))`, and
  `!(memoize evalColM 1)` (declared immediately before `evalColM`'s
  definition, per the in-tree memoize-before-def convention).
- `evalSubtree` keeps its 3-arg signature for existing callers but becomes a
  thin wrapper: publishes `$itable`/`$n` into state cells
  (`&evalColMTable` / `&evalColMRowCount`) then delegates to a NEW arity-1
  `evalColM $exp`, memoized end-to-end by lib_memo.
- NO `&subtreeCache` reads/writes anywhere in this variant.
- PR-165 ONLY -- PeTTaV1 (production) has no `lib_memo`.
## memo-lru/ -- Variant M-lru

- Touches: `scoring/fitness.metta`
- Byte-identical to `memo/` except `(strategy lru)` instead of
  `(strategy wtinylfu)` in the `config-memoize` call -- a second
  full-pipeline benchmark cell, since lru was cheaper than wtinylfu at ample
  capacity in the standalone `kernel-memo.metta` benchmark (see
  `experiments/memo-prototype/results/results.md`).
- PR-165 ONLY, same caveat as `memo/`.

## Usage

```sh
# From anywhere; resolves the repo root itself.
experiments/memo-prototype/integration/swap.sh space   # or: memo, memo-lru
# ... run the benchmark ...
experiments/memo-prototype/integration/restore.sh       # git checkout -- scoring/fitness.metta
```

Never leave a variant swapped in when committing. `restore.sh` is safe to
run unconditionally (idempotent) and touches nothing under `experiments/`.
