# Performance Comparison Log

## Benchmark

Benchmark file:

- `moses/tests/demo-problems-benchmark.metta`

Benchmark entrypoint:

- `!(runDemoProblem 0 2 1 None majority3)`

This benchmark was run in two configurations:

1. MeTTa-side `until`
2. PeTTa built-in `until`

Both runs completed successfully and printed the full `Result:` output before the profile section.

## Commands

MeTTa-side `until`:

```bash
sh /home/yab/PeTTaV1/run.sh -p --silent "/home/yab/Documents/Projects/iCog/HyperonRelated/MOSES/metta-moses/moses/tests/demo-problems-benchmark.metta"
```

Built-in `until`:

```bash
sh /home/yab/PeTTaV1/run.sh -p --silent "/home/yab/Documents/Projects/iCog/HyperonRelated/MOSES/metta-moses/moses/tests/demo-problems-benchmark.metta"
```

Captured outputs:

- MeTTa-side `until`: `/tmp/demo-benchmark-metta-until.txt`
- built-in `until`: `/tmp/demo-benchmark-native-until.txt`

## Top-Level Comparison

### MeTTa-side `until`

- `Samples: 8,245`
- `Profiled time: 35.590 s`
- `MeTTa predicates recorded: 310`

### Built-in `until`

- `Samples: 4,008`
- `Profiled time: 18.109 s`
- `MeTTa predicates recorded: 303`

### Delta

- profiled time reduced from `35.590 s` to `18.109 s`
- absolute improvement: `17.481 s`
- relative improvement: about `49.1%` faster

## Hotspot Comparison

### `getCandidate/3`

- MeTTa `until`: `33.091 s` (`93.0%`)
- built-in `until`: `16.104 s` (`88.9%`)
- delta: `-16.987 s`

### `cleanTree/2`

- MeTTa `until`: `24.154 s` (`67.9%`)
- built-in `until`: `8.017 s` (`44.3%`)
- delta: `-16.137 s`

### `reduce-to/2`

- MeTTa `until`: `24.013 s` (`67.5%`)
- built-in `until`: `7.902 s` (`43.6%`)
- delta: `-16.111 s`

### `reduceToElegance/5`

- MeTTa `until`: `23.127 s` (`65.0%`)
- built-in `until`: `7.508 s` (`41.5%`)
- delta: `-15.619 s`

### `applyAndTransformations/2`

- MeTTa `until`: `21.805 s` (`61.3%`)
- built-in `until`: `6.601 s` (`36.5%`)
- delta: `-15.204 s`

### `applyOrTransformations/2`

- MeTTa `until`: `16.113 s` (`45.3%`)
- built-in `until`: `4.883 s` (`27.0%`)
- delta: `-11.230 s`

### `List.foldl_Spec_[applyGetCandidateRec]/4`

- MeTTa `until`: `8.761 s` (`24.6%`)
- built-in `until`: `8.171 s` (`45.1%`)
- delta: `-0.590 s`

### `getCandidateRec/7`

- MeTTa `until`: `9.081 s` (`25.5%`)
- built-in `until`: `8.171 s` (`45.1%`)
- delta: `-0.910 s`

### `until_Spec_[reduceNotApplied,applyReduce]/4`

- MeTTa `until`: `8.167 s` (`22.9%`)
- built-in `until`: not present as a separate hotspot in the final flat table

Interpretation:

- the built-in `until` removes a large amount of overhead in the fixpoint/reduction loops
- the biggest gains show up in the reduction and cleanup pipeline:
  - `cleanTree`
  - `reduce-to`
  - `reduceToElegance`
  - `applyAndTransformations`
  - `applyOrTransformations`
- the candidate-construction path still remains expensive, but the reduction-side overhead drops sharply

## Behavioral Notes

Both configurations now:

- complete the benchmark successfully
- print the full `Result:` output
- reach the same high-level iteration sequence in the benchmark log

Observed benchmark milestones in both runs:

- `Generation 2`
- `Iteration 1` through `Iteration 4`
- `OptimizedDeme: 144`
- `Generation 1`
- `OptimizedDeme: 195`
- `Result: ...`

## Conclusion

Re-enabling the PeTTa built-in `until` produces a large performance improvement on the `runDemoProblem 0 2 1 None majority3` benchmark.

Main result:

- built-in `until` is about `49%` faster than the MeTTa-side `until` on this benchmark

Most of the win comes from reducing overhead in repeated reduction/fixpoint loops rather than from the candidate-building helpers themselves.
