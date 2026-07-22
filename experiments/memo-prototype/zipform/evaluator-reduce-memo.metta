;; ---------------------------------------------------------------------------
;; zipform/evaluator-reduce-memo.metta -- "reduce-dispatch, memoized
;; combinators" backend (variant R). PR-165 PeTTa ONLY -- needs BOTH `reduce`
;; (translator.pl:284, PR-165 extension) and lib_memo.
;;
;; Unlike evaluator-common.metta's evalZipTermCore (a single function that
;; manually if-chain-dispatches on car-atom, with recursion routed through an
;; explicit `$eval` callback parameter so the CALLER's cache wrapper decides
;; what "recurse" means), this module makes the term-language heads
;; THEMSELVES real, individually memoized functions: col/fmap/zipWith/
;; zipWithN. Each is dispatched via PR-165's `(reduce $term)` head-only
;; dispatch (matched clause's body runs for real; the term's stored children
;; arrive AS-IS, unevaluated -- probe-zip-reduce-groundterm.metta), and each
;; is memoized at exactly its own defined arity (probe-zip-arity-inertness.
;; metta: defining a function at one arity turns OTHER-arity occurrences of
;; the same symbol into corrupting partial(F,args) wrappers, so col/fmap/
;; zipWith/zipWithN below are defined ONLY at the arities zipform/rewriter.
;; metta ever emits: col/1, fmap/2, zipWith/3, zipWithN/2).
;;
;; Because lib_memo's cache key is the function's RAW args (verified,
;; probes/probe-reduce-memo-combinators.metta Q1: `reduce([F|Args], Out)` in
;; translator.pl calls resolve_runtime_call, which tries lib_memo's
;; metta_try_dispatch_call hook FIRST -- so a memoized function reached via
;; `reduce` is cached exactly like one reached by a direct call, keyed on the
;; UNEVALUATED cons-built subterm args), each combinator's cache key is the
;; raw materialized subterm itself -- per-node caching for free, with no
;; separate "subterm" concept needed the way evaluator-common.metta's
;; `$eval`-callback plumbing requires.
;;
;; evalChild: the ONE guard every combinator's child-handling routes
;; through. `(reduce <Grounded atom>)` does NOT dispatch the way a column
;; consumer wants -- probe Q3 found it fails SILENTLY (zero solutions, no
;; error) when given a let-bound Grounded value (a bare atom does not unify
;; with reduce's own `[F|Args]` pattern). Constant-leaf children (a monoid
;; op applied to zero args rewrites straight to a Grounded True/False --
;; zipform/rewriter.metta's k==0 arm) must instead be broadcast via
;; List.repeat. This guard is deliberately NOT memoized itself (the user's
;; design memoizes the combinators, not a child-eval choke point); it is a
;; plain helper inlined into every child-reduce site. Consequence: a
;; constant-leaf column is recomputed (a cheap List.repeat) every time it
;; appears as a child, even under a cache hit miss elsewhere in the same
;; parent -- same recomputation profile evaluator-common.metta's Grounded
;; branch already has (never cached there either).
;;
;; NOTE ON IMPORTS: this file only imports (library lib_memo). It needs
;; common/list-helpers (List.zipWith/List.repeat), common/kernel-common
;; (varColumn), and zipform/evaluator-common (setZipTable -- the table
;; installer -- and transposeCols, reused verbatim rather than duplicated;
;; evaluator-common.metta never itself defines a `(= (col ...) ...)` /
;; `(= (fmap ...) ...)` / `(= (zipWith ...) ...)` / `(= (zipWithN ...) ...)`
;; clause -- its own evalZipTermCore dispatches on these as DATA via
;; car-atom -- so this module's real clauses for those same heads do not
;; collide with it) already loaded; the entry harness/driver is the single
;; choke point that imports each exactly once, in dependency order, before
;; importing this file (same "import! does not dedupe" discipline as every
;; other zipform module here). NEVER import zipform/evaluator-memo.metta or
;; zipform/evaluator-space.metta in the same process as this file -- neither
;; conflicts by name, but doing so would just waste cache slots on an unused
;; parallel evaluator.
;;
;; STALENESS: exactly like evaluator-memo.metta's evalZipTerm, EVERY one of
;; col/fmap/zipWith/zipWithN reads the table via the (param zipTable)/
;; (param zipRowCount) registry but is keyed purely on its own term-shaped
;; args -- so all four caches go stale after a table switch, and a caller
;; must `(invalidate-memoize col)`/`(invalidate-memoize fmap)`/
;; `(invalidate-memoize zipWith)`/`(invalidate-memoize zipWithN)` (or a full
;; `(clear-memoize)`) after `(setZipTable ...)`, exactly the discipline the
;; harness demonstrates.
;; ---------------------------------------------------------------------------

!(import! &self (library lib_memo))

;; Reproducible cache preset (lib_memo_doc.md "Clear before experiments");
;; matches evaluator-memo.metta's own module-level default. Callers
;; (benchmark drivers) may reconfigure via their own reset block, same
;; convention as evaluator-memo.metta.
!(config-memoize (unique-limit 10000) (strategy wtinylfu) (size-limit 5))

;; evalChild: Grounded-guard child resolver shared by every combinator below.
(= (evalChild $c)
   (if (== (get-metatype $c) Grounded)
       (List.repeat (param zipRowCount) $c)
       (reduce $c)))

!(memoize col 1)
(= (col $label) (varColumn (param zipTable) $label))

!(memoize fmap 2)
(= (fmap $f $c)
   (let $cv (evalChild $c)
     (map-atom $cv $v ($f $v))))

!(memoize zipWith 3)
(= (zipWith $f $a $b)
   (let* (($av (evalChild $a))
          ($bv (evalChild $b)))
     (List.zipWith $f $av $bv)))

!(memoize zipWithN 2)
(= (zipWithN $op $children)
   (let $cols (map-atom $children $c (evalChild $c))
     (map-atom (transposeCols $cols) $row ($op $row))))

;; evalZipTermR: scoring entry point. `$term` is the function's own
;; parameter (already a plain variable), so `(reduce $term)` is the
;; supported direct form (production evalRow idiom, scoring/fitness.metta:
;; 149-151) -- no extra let-binding needed. A whole-formula rewrite CAN
;; itself land on a bare Grounded constant (a monoid applied to zero
;; children, e.g. `(AND ())` -> True -- zipform/rewriter.metta's k==0 arm),
;; which is not a `[F|Args]` cons-list at all, so `reduce` would silently
;; fail on it exactly like the Grounded-child case above -- guarded the same
;; way at the top level.
(= (evalZipTermR $term)
   (if (== (get-metatype $term) Grounded)
       (List.repeat (param zipRowCount) $term)
       (reduce $term)))
