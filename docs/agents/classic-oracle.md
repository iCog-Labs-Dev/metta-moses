# Classic MOSES as the oracle

Read this file when you need an expected value, port a classic function, or compare this port with classic MOSES.

## 1. The rule

- Classic OpenCog MOSES (C++, `github.com/opencog/moses`; the README also links `opencog/asmoses`) is the ground truth for behaviour.
- The tests in this repo can be wrong. When a test and classic disagree, report both values. Do not pick one alone.
- Every expected value, constant, default and limit has a source: a classic file and line, a classic run, or a measurement. Write the source in the PR or in a short comment. Never invent a number. ("Where did you get that number and why did you use it?")
- A deliberate difference from classic is a decision of the lead. Record it with its reason (for example: this RTE has no `Delete`/`Disconnect` verdict, `logical_rules.h`). Classic informs the design; it does not dictate it.
- Use classic names where the function does the same thing. A reader then does not need to read the whole code to see that it matches.
- When you explain classic to a person, explain it from first principles, with a small example. Do not assume that they know the C++.

## 2. Ask classic, do not guess

1. Find the classic code for the behaviour (for example `moses/comboreduct/reduct/logical_rules.{h,cc}` for ENF reduction).
2. Run classic on the same input. Do not answer from memory or from a web search.
3. Compare the results by meaning (section 4).
4. Report the classic value, the port value, the command and the classic version.

"Done" for a ported feature means: implemented, compared with classic, and benchmarked. For a larger feature, make a checklist of the classic features (for example deme subsampling) and mark each one.

## 3. The reduct oracle: `test_reduct`

Classic has a small program that reduces one boolean tree. Build it in your classic build folder:

```sh
cd <classic-moses>/build/tests/comboreduct/reduct && make test_reduct
./test_reduct 'or($7 and($1 $2 or(not($3) not($4) $5)))'     # default effort 3
./test_reduct '<tree>' 2                                     # effort 2
```

- The second argument is the reduction **effort** (0 to 3), not an arity. The source calls it `reduce_arity`, but it goes to `logical_reduce(effort, ...)`. A value such as 7 aborts.
- Effort 1 = simple, 2 = medium (this one runs `subtree_to_enf`), 3 = complex (adds truth-table pruning).
- **Pin the effort when you cite a result.** `and($1 or())` gives `and($1)` at effort 1 and `$1` at efforts 2 and 3. Run all three. If the result is the same at 1, 2 and 3, it is not an artefact of the truth-table pass.
- Combo syntax: `$1`-style arguments, `!$1` or `not($1)`, `and(...)`, `or(...)`, `true`, `false`.
- `and()` and `or()` in classic input are dangling placeholders. Classic deletes them (`or(and() and($6))` gives `$6`). They are not the identity constants. A bare `and()` or `or()` makes `test_reduct` abort. A tree with no variable cannot be measured; count it apart, not as a difference.
- Read the result from the `Simplified tree:` line.
- `test_reduct` writes `opencog.log` into its working folder. Run it from a scratch folder, not from this repo.

## 4. Compare meaning, not shape

- Compare **truth tables**. Classic's effort-2 output is not always minimal. This port sometimes returns a smaller equivalent tree. A shape comparison then overstates the difference.
- Report two numbers: semantic agreement (same truth table) and syntactic agreement (same tree after canonical form). The semantic number is the metric.
- Run the MeTTa side in a production-shaped load: the `moses.metta` import order, the `rte-helpers-fast.pl` consult, and `scoring/boolean-ops`. Pass every tree through `quote`. (A MeTTa-only edit to a helper that a native stub overrides has no effect in the real pipeline.)
- Make each result line carry its own index, for example `(RES <i> ...)`. A tree that gives no solution then has no line, and the gap is visible. A list without indexes shifts and hides the failure.
- Use a corpus with many shapes: trees taken from the reduct and tree tests, random trees, and adversarial trees with 2 to 3 variables and about 50% negation. The adversarial set finds contradiction bugs.

## 5. Where the harness is

The lead has a differential harness (`classic.sh`, corpus generators, `diff.py`) on a local branch. It is not in the shared repo, because it holds machine paths. Ask the lead before you build a new one. Keep any harness that you build outside the repo, or in an untracked folder. Do not commit it to a feature PR.

## 6. Classic for the rest of MOSES

- The same rule applies to scoring, representation, feature selection and the optimizers. Compare with the classic code path and a classic run on the same table and seed.
- A deviation in a hyperparameter default needs a classic reference. If no classic value exists, say so and ask the lead.
