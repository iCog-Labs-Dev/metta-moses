# MeTTa style and PeTTa pitfalls

Read this file when you write or review MeTTa code in this repo.

The team conventions are in `.github/CONTRIBUTING.md` (naming, formatting, comments, file layout) and `.github/TypeConvention.md` (porting C++ types). This file adds the rules that reviews keep asking for, and the PeTTa behaviour that breaks code in silence.

## 1. Naming

- `camelCase` for functions and variables. `PascalCase` for types. `is*` for predicates. Type constructors start with `mk` (`mkDeme`, `mkITable`).
- Prefix a data-structure function with its structure: `List.foldl`, `Map.insert`.
- Use descriptive names. `$c` and `$c2` say nothing. Short names are fine for short-lived variables.
- Use the Haskell name for an algebraic or higher-order idea: `mempty`, `foldr1`, `fmap`, `zipWith`, `allM`, `anyM`. Do not invent names such as `foldUntil`.
- Use the classic MOSES name when the function does the same thing.
- Use general names in general code. Do not put a domain word (for example `action`) on an engine function or parameter. A shared concept has one parameter name (`hcMaxDist`, not a second copy per domain).
- When two functions differ only in the number of arguments, give them one name with different arities. Do not add `Fast`, `New` or `2` suffixes.
- Write `children` and `child`, never `kids`.
- The boolean operators are `AND`, `OR`, `NOT`. The reduct constants are the symbols `TRUE` and `FALSE` (on `dev`). Do not use `And`/`Or`/`Not`.
- Comments and code are public. Do not write personal or interpersonal references in them.

## 2. Structure

- **Higher-order functions first.** Use `map-atom`, `filter-atom`, `foldl-atom`, `List.foldl`, `zipWith`, partial application and functions as arguments. Write a new recursive function only when no higher-order function fits, and say why in a comment. Use the higher-order version only if it is also simpler to read.
- **Reuse helpers.** Search `utilities/general-helpers.metta` and `utilities/list-methods.metta` first. Example: `genList` is the inclusive range; do not write `List.enumFromTo`. Delete thin wrappers that only call another function.
- **Few new functions.** Extend or parameterise a function that exists. A reviewer will ask why each new definition exists.
- **One code path.** Replace the old code. Do not keep a second path "for safety". A special case of a general path is deleted when the general path covers it.
- **Open for extension.** Adding an operator (for example `XOR`) must need only its own definition. It must not need edits in scoring or in the engine. Dispatch by name (bare heads plus `reduce`), not with a per-operator list.
- **Configuration goes through `parameters/`.** Read tunables with `param`; set them with `set-param`. No hard-coded tunables, no separate state for global config, no parameter that nothing reads.
- **No extra pass.** Fold new work into a tree walk that exists.
- **Prefer MeTTa built-ins** over hand-written loops, unless a measured hazard (for example variable copying) forces your own version.
- Code must read top-down: the entry function first, then the functions that it calls. For a new feature, give one small runnable top-level example, not many walkthrough files.

## 3. Constructs

- `let` for one binding step, also one destructuring pattern: `(let ($op $children) $exp ...)`. `let*` for several steps. Never nest `let`s.
- Destructure in the clause head or with `let`. Prefer `(cons $head $tail)` or `($op $children)` over `car-atom` and `cdr-atom` chains.
- Make clauses mutually exclusive. If one clause matches `()`, the other matches `(cons $x $xs)`. Overlapping clauses give extra solutions or an infinite loop.
- Write data as literals: `(1 2 (3))`, not `cons` chains. Use `cons`/`cons-atom` only to build a list from runtime values.
- At a **live-head hazard site** (a term whose head is a defined function, for example `(NOT $x)` after `boolean-ops` loads) use `quote`, not `cons-atom`. Evaluate the parts into `let*` bindings first, then quote the variables-only shape. **Comment every hazard site.** (A style tidy once removed an unmarked hazard, and a `partial` term leaked into the final result.)
- Use `;;` for comments, never `;`.

### Rewrite patterns (from PR 515)

Write the form in the second column. The PR 515 rewrite of `reduct/action-reduct/` used these forms. The review measured it as about 25% faster, with the same results except one lost guard (rule 1 below).

| Instead of | Write | Why |
|---|---|---|
| A `let` of a computed value, then an `if` chain of `==` tests on it | `(case (getActionResult $c) ((True $a) (False $b) ($else Unknown)))` | The value is computed once. The value-to-result table is visible. |
| `car-atom`/`cdr-atom` chains for fixed positions | `(let ($cond $br1 $br2) $args ...)` | One step binds all parts. The match checks the arity. |
| `unify` plus an `if` chain that tests literal parts of one shape | `case` with one pattern for each rule: `((action_bool_if True $t $e) $t)` | One pattern gives one result. |
| `(== $x $y)` to test that two parts are equal | The same variable two times in one pattern: `(action_bool_if $c $t $t)`, `(($act $act) ...)` | The pattern tests the equality and binds the value. |
| An is-expression guard, then `decons`, then a test of the head | `(unify $h (action_while $body) <match> <else>)` | One `unify` does the shape test, the head test and the binding. All fall-through paths become one else. |
| The same recursive call at the end of each branch | Compute only the changing part in the branches, then make one call | A later change to the call cannot miss a branch. |
| A parameter that the function can rebuild from its other parameters | Remove the parameter | Shorter call sites. The two values cannot disagree. |
| Nested `if`s for "non-empty expression" | `(if (and (== (get-metatype $e) Expression) (!= $e ())) ... $e)` | One condition and one fallback. |

Rules for a safe rewrite:

1. **Keep every guard.** When you replace a guard ladder with `unify` or `case`, keep each metatype or emptiness check that protected a `car-atom`, `cdr-atom` or `decons`. `unify` proves only the outer shape: `(action_while $seq)` also matches `(action_while move_forward)`, and then `(car-atom $seq)` gives zero solutions. (PR 515 lost this guard. Commit `ef28ad4c` put it back.)
2. **`case` only on a value with no unbound variables** (section 5, `case` row).
3. **A `unify` pattern with a defined head** (`NOT`, `action_while`) is safe only while `utilities/general-helpers.metta` declares the type of `unify` (section 5, `unify` row).
4. **In `and`, put no call that needs an earlier argument to be true.** `and` runs all its arguments. `(and (== (get-metatype $x) Expression) (== (car-atom $x) NOT))` gives zero solutions on a symbol. Nest the `if` there.
5. **A tuple destructure fails in silence on the wrong arity.** Use it only where the shape is fixed.
6. **Prove "same behaviour" with a differential run.** Run the base and the new code on the same inputs. Include a plain symbol, `()` and each guarded shape. Add a test for each guard that you keep. (CI stayed green on PR 515 because no test had a symbol body.)

## 4. Comments

- Keep comments short. Explain design decisions, hazards and non-obvious function applications.
- Give a function a one- or two-line comment on its purpose when its name and type do not say it.
- Do not write change-log comments, comments that narrate the code, or long essays. "No one is going to read all of that."
- Do not leave dead code in comments. Git keeps it.

## 5. PeTTa pitfalls (silent failures)

Most PeTTa errors give zero solutions, not an error message. Know these cases.

| Case | Effect | What to do |
|---|---|---|
| Head with no definition in this load context | The expression comes back unreduced | Check import order (`running-metta.md`, section 4). |
| Defined head, too few arguments | A `(partial f (args))` term. It is junk if the call never completes. | Fix the arity. Never pass a `partial` on as data. |
| Defined head, too many arguments | A `partial` that counts as a solution | A test for "no such arity" must check that the result is unusable. |
| No clause head matches the arguments | Zero solutions | Check shapes before you destructure. |
| `car-atom`, `decons-atom`, `map-atom` on a symbol (for example `TRUE`) | Zero solutions | Guard constants with `isConstant` before you walk. |
| `(unify $l (NOT $x) ...)`: a pattern with a defined head (`NOT` after `boolean-ops` loads) | Correct on `dev` since #518 (2026-10-28). Without the type declaration of `unify` in `utilities/general-helpers.metta`, PeTTa evaluates the arguments: a plain literal gives `SAFE` two times, and a negated literal goes to the else branch two times. | Keep `(: unify (-> Expression Expression Expression Expression %Undefined%))` active. It was a comment before #518. Do not `quote` the pattern: `(quote (NOT $x))` never matches. A negation test that is correct with or without the declaration: `(if (== (get-metatype $l) Expression) (== (car-atom $l) NOT) False)`. |
| `(NOT $l)` built bare in an evaluated position after `boolean-ops` loads | Zero solutions | Build it with `(quote (NOT $l))` (section 3). |
| `reduce` on a node with a child that is still symbolic | Zero solutions | Evaluate the children first. Let-bind the argument of `reduce`. |
| `(reduce (quote X))` written inline | The quote is not stripped | Bind the quoted term to a variable first. |
| `superpose` on a call | It superposes the call term, not its result | Let-bind the collection first. |
| `and` used as a guard | Not short-circuit: all arguments run | Nest `if`s. |
| `is-member` | One solution per match | Wrap in `once`. |
| `union-atom` | Concatenates, keeps duplicates | Add an explicit membership guard for a set. |
| `get-metatype` of a symbol that has a clause anywhere | `Grounded`, not `Symbol` | Test `(or (== $x True) (== $x False))`, or test the Expression case positively. |
| `case` on a term with unbound variables | Plain unification binds them to the first pattern | Use guarded `if` chains plus `let` destructuring. |
| A type declaration `(: f (-> ...))` on an operator | Static source calls to `f` give zero solutions | Call declared operators through `reduce` only. Never declare a type for a function that is partially applied. |
| A clause body that ends in `if`/`case`/`collapse`, used through eta-expansion | The clause compiles one arity short; programs score worst in silence | End the body in a call. Keep the context parameter explicit. |

When a behaviour is not in this table, probe it in a small file and read `src/translator.pl` and `src/metta.pl` in PeTTa. Write down what you found in the PR.
