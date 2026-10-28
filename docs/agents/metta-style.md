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
| `(unify $l (NOT $x) ...)` after `boolean-ops` loads | Wrong count or zero solutions. `quote` does not help. | Use a structural check: `(== (car-atom $l) NOT)`. |
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
