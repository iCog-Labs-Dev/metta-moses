;; Native boolean evaluation -- fold-substitute template, sealed per-row.
;;
;; ---- Big picture ----
;; scoreTree builds a `($labelsTerm $expTerm)` template ONCE per candidate
;; via `candTemplate`. No strings, no parse, no name->var dict.
;;
;; `candTemplate` runs in two stages:
;;   1. `preOrderExp` walks the Tree once, emitting an Expression that
;;      mirrors the tree's structure with label SYMBOLS at leaf positions
;;      (still placeholders — no vars yet).
;;   2. `foldTemplate` folds over the labels list. Each iteration mints
;;      a fresh MeTTa var `$v` (lexical scoping ⇒ fresh Prolog var per
;;      recursive call) and calls `substExp` to replace ALL occurrences
;;      of that label symbol in the expression with `$v`. Same-labelled
;;      leaves get the same var because they're all substituted in one
;;      sweep. The `$v` is also consed onto the growing labels-term, so
;;      labels-term and expression share the SAME var at each label's
;;      position — no dict, no name lookup.
;;
;; Per row, `evalParsed` uses `sealed` on the labels-term to freshen the
;; label vars inside a body that (a) unifies fresh labels-term against
;; the row and (b) evals the fresh expression. The original template
;; stays pristine so the next row starts from unbound vars.
;;
;; ---- sealed ----
;; sealed compiles to `copy_term/4(Vars, Body, _, FreshBody)` — renames
;; only the listed vars and shares subterms that don't contain them.
;; The invariant boolean-op scaffolding (AND/OR/NOT, ()) has no label
;; vars, so those subterms are shared with the original instead of
;; copied every row.
;;
;; ---- Operator-name collision containment: quote ----
;; The eval clauses below share their names with the AND/OR/NOT data
;; constructors that pervade candidate trees and reduct expressions.
;; Once these clauses register, any bare source-level tuple whose head
;; is one of them — `(NOT $x)` anywhere, arity-1 `(AND ...)`/`(OR ...)`
;; such as the membership list `(AND OR)` — compiles as a CALL in every
;; module loaded after this one. The containment discipline is
;; `(quote ...)` at every such data site: quote returns the tuple as
;; data, so the clauses fire only under evalParsed's explicit
;; `(eval $expP)`. Guarded sites: this file (preOrderExp emissions,
;; is-member list), scoring/bscore (replaceVarWithTruth),
;; representation/build-logical, representation/logical-canonize,
;; representation/sample-logical-perms (getArgs emissions), and
;; utilities/tree (membership lists + nullary preOrder emissions —
;; order-protected under moses.metta but quoted so test files are safe
;; regardless of their import order).
;;
;; ---- Data terms via cons-atom ----
;; Every constructed term is built with `cons-atom` (a builtin that
;; returns data) or under `quote` rather than as a bare literal
;; expression, so the reducer doesn't fire the clauses at build time.
;; The template only reaches eval position via the explicit `(eval $expP)`
;; in `evalParsed`.

;; ---- Wrapped-list operators: single arity-1 clause = n-ary ----
;; The clause bodies are LAZY: children may arrive as unevaluated
;; row-substituted expressions (the reduceRow path dispatches only the
;; root), and allLazy/anyLazy force each child on demand via forceB,
;; short-circuiting on the first decisive value — subtrees on the decided
;; side are never dispatched at all. Children that arrive already
;; evaluated (evalParsed's eval path, reduceParsed, direct test calls)
;; pass through forceB unchanged, so both calling conventions work.
;;
;; Extensibility contract: a NEW operator's clause receives its children
;; in whatever state the caller left them — force any child it consumes
;; with (forceB $kid) before using the value.
(= (AND $args) (allLazy $args))
(= (OR  $args) (anyLazy $args))
(= (NOT $x)    (not (forceB $x)))

;; Force one child: expressions dispatch through reduce (firing these
;; clauses recursively, again lazily); atoms — booleans, numbers, symbols
;; — pass through. reduce leaves non-callable heads as data. The reduce
;; argument is let-bound: reduce on a bare var-form would dispatch the
;; constructor call rather than the term.
(= (forceB $x)
   (if (== (get-metatype $x) Expression)
       (if (== $x ())
           ()
           (let $call $x (reduce $call)))
       $x))

;; Short-circuit conjunction/disjunction over a kids tuple. Semantics
;; match general-helpers' all/any (is-member scan): all = True unless
;; some child forces to False; any = False unless some child forces to
;; True; non-boolean values pass through unless decisive.
(= (allLazy $kids)
   (if (== $kids ())
       True
       (let ($k $rest) (decons-atom $kids)
         (if (== (forceB $k) False)
             False
             (allLazy $rest)))))
(= (anyLazy $kids)
   (if (== $kids ())
       False
       (let ($k $rest) (decons-atom $kids)
         (if (== (forceB $k) True)
             True
             (anyLazy $rest)))))

;; ---- preOrderExp: Tree -> Expression form, leaves still as symbols. ----
;; Mirrors `preOrder` in utilities/tree.metta but returns an Expression
;; shape that matches the eval clauses above: (Op ( c1 c2 …)) for AND/OR,
;; (NOT <child>) for NOT, `sym` at label leaves, (Op ()) at nullary
;; AND/OR leaves. Knob passthroughs mirror preOrder. Every emission is
;; quote-protected so the clauses cannot fire at template-build time.
(= (preOrderExp (mkTree (mkNode $r) ()))
   (if (once (is-member $r (quote (AND OR))))
       (quote ($r ()))
       $r))
(= (preOrderExp (mkKnob (mkNullVex $tree) $lsk $i)) ())
(= (preOrderExp (mkKnob (mkTree $node $children) $lsk $i))
   (preOrderExp (mkTree $node $children)))
(= (preOrderExp (mkTree (mkNode $r) (cons $x $xs)))
   (let $childrenExp (childrenExp (cons $x $xs))
        (if (== $r NOT)
            (let $child (car-atom $childrenExp)
                 (quote (NOT $child)))
            (quote ($r $childrenExp)))))

;; childrenExp: Expression of Trees -> Expression of child forms.
;; map-atom applies preOrderExp; filter-atom drops empty knob passthroughs.
;; Both bodies capture nothing from outer scope, so yall's per-iteration
;; copy_term is harmless here (unlike in substExp).
(= (childrenExp $children)
   (filter-atom (map-atom $children $c (preOrderExp $c)) $x (not (== $x ()))))

;; ---- substExp: replace every leaf occurrence of $target in $exp with $repl. ----
;; Manual recursion (NOT map-atom / foldl-atom): those compile to a
;; SWI yall lambda `[X,Y]>>Body` which is copy_term'd per iteration,
;; breaking identity for any free vars captured from the outer scope
;; (like $repl). Standard recursion passes $repl as an argument, whose
;; identity is preserved by Prolog's call/1.
;;
;; A List.foldl variant threading (target, repl, revResult) through the
;; accumulator was tried and works correctly, but benched ~3% slower --
;; the tuple-acc unpack and final reverse cost more than they save.
(= (substExp $target $repl $exp)
   (if (== (get-metatype $exp) Expression)
       (if (== $exp ())
           ()
           (let*
             (
              (($h $rest) (decons-atom $exp))
              ($newH (substExp $target $repl $h))
              ($newRest (substExp $target $repl $rest))
             )
             (cons $newH $newRest)))
       (if (== $exp $target) $repl $exp)))

;; ---- foldTemplate: iterate labels, mint fresh var per iteration, ----
;; ---- substitute label -> var everywhere in $exp. ----
;; Returns ($labelsTerm $finalExp). Recurse-then-cons preserves original
;; labels order in $labelsTerm (matching positional row unification).
;; $v is fresh per recursive call (lexical scoping).
;;
;; A List.foldl variant with a named `foldTemplateStep` and a tuple
;; accumulator ($labelsAcc $expAcc) was tried and works correctly, but
;; benched ~3% slower — the tuple unpack per iteration and terminal
;; reverse cost more than the fold saves.
(= (foldTemplate $labels $exp)
   (if (== $labels ())
       (() $exp)
       (let*
         (
          (($h $rest) (decons-atom $labels))
          ($newExp (substExp $h $v $exp))
          (($restLabels $finalExp) (foldTemplate $rest $newExp))
          ($head (cons $v $restLabels))
         )
         ($head $finalExp))))

;; ---- candTemplate: entry called ONCE per candidate by scoreTree. ----
(= (candTemplate $labels $tree)
   (let $exp (preOrderExp $tree)
        (foldTemplate $labels $exp)))
;; ---- Per-row core: template in, bool out. ----
;; sealed freshens only the labels vars in the body; unification binds
;; those fresh copies to the row; eval fires AND/OR/NOT on the fresh
;; expression. Original template's vars remain unbound for the next row.

(= (evalParsed $template $row)
   (let ($labelsP $expP) $template
        (sealed $labelsP
                (let $labelsP $row
                     (eval $expP)))))

;; ---- reduce-based per-row core: same contract as evalParsed, no eval. ----
;; `eval` re-translates the whole expression per row — the historical
;; scoring bottleneck. `reduceExp` instead walks the row-bound template
;; bottom-up as plain compiled recursion and dispatches each operator with
;; a single `reduce` call into its compiled clause. Two reduce gotchas
;; honored: reduce is single-step, so children are evaluated BEFORE the
;; parent dispatch; and the dispatched term is let-bound first, so reduce
;; sees the constructed term rather than the constructor call. Heads that
;; are not callable (e.g. a row-bound boolean at the head of the wrapped
;; kids tuple) come back from reduce as data, mirroring eval's behavior.
(= (reduceExp $e)
   (if (not (== (get-metatype $e) Expression))
       $e
       (if (== $e ())
           ()
           (let* (
                  ($kids (map-atom $e $k (reduceExp $k)))
                  ($h (car-atom $kids))
                 )
             (if (== (get-metatype $h) Expression)
                 $kids
                 (reduce $kids))))))

(= (reduceParsed $template $row)
   (let ($labelsP $expP) $template
        (sealed $labelsP
                (let $labelsP $row
                     (reduceExp $expP)))))


;; ---- expToExp: Expression -> Expression form for test-side callers. ----
;; Tests pass raw expressions like `(AND A B)` instead of Trees, so we
;; need the same shape transform (children wrapped into a single tuple)
;; but starting from an Expression. cons-atom keeps every constructed
;; term as data.
(= (expToExp $e)
   (if (== (get-metatype $e) Expression)
       (let ($h $rest) (decons-atom $e)
            (if (== $h NOT)
                (let $child (expToExp (car-atom $rest))
                     (let $node (cons-atom NOT (cons-atom $child ())) $node))
                (let $childrenTerm (map-atom $rest $c (expToExp $c))
                     (let $node (cons-atom $h (cons-atom $childrenTerm ())) $node))))
       $e))
