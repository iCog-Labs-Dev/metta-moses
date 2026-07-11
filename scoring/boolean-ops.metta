;; Native boolean evaluation -- operator clauses + evaluation helpers.
;;
;; ---- Big picture (production path) ----
;; scoreTree (scoring/bscore.metta) evaluates each candidate against every
;; table row with no strings, no parse, no name->var dict:
;;   1. `preOrderExp` (here) walks the Tree once, emitting the wrapped
;;      eval shape ((Op (kids)) / (NOT child)) with label SYMBOLS at leaf
;;      positions.
;;   2. `indexLeaves` (bscore) replaces each label symbol with (lbl N),
;;      N = the label's column position — done once per candidate.
;;   3. Per row, `reduceRow` (bscore) substitutes the row's values for the
;;      (lbl N) leaves and forces the root through `forceB`, firing the
;;      AND/OR/NOT clauses below; their lazy bodies short-circuit.
;;
;; ---- Test-support layer (no production callers) ----
;; The var-template path is retained for the boolean-ops tests
;; (boolean-ops-test's callBE): `expToExp` converts a raw test expression
;; to the wrapped eval shape, `foldTemplate`/`substExp` build a
;; labels->fresh-var template from it, and `evalParsed` seals the label
;; vars per row and evals the row-bound expression. It exercises the same
;; operator clauses through the eval path.
;;
;; ---- Operator-name collision containment: quote ----
;; The eval clauses below share their names with the AND/OR/NOT data
;; constructors that pervade candidate trees and reduct expressions.
;; Once these clauses register, any bare source-level tuple whose head
;; is one of them — `(NOT $x)` anywhere, arity-1 `(AND ...)`/`(OR ...)`
;; such as the membership list `(AND OR)` — compiles as a CALL in every
;; module loaded after this one. The containment discipline is
;; `(quote ...)` at every such data site: quote returns the tuple as
;; data, so the clauses fire only under forceB's runtime dispatch or
;; evalParsed's explicit `(eval $expP)`. Guarded sites: this file
;; (preOrderExp emissions, is-member list), scoring/bscore
;; (replaceVarWithTruth),
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
;; Constructed terms only reach eval position via forceB's runtime
;; dispatch (production) or evalParsed's explicit `(eval $expP)` (tests).

;; ---- Wrapped-list operators: single arity-1 clause = n-ary ----
;; The clause bodies are LAZY: children may arrive as unevaluated
;; row-substituted expressions (the reduceRow path dispatches only the
;; root), and allLazy/anyLazy force each child on demand via forceB,
;; short-circuiting on the first decisive value — subtrees on the decided
;; side are never dispatched at all. Children that arrive already
;; evaluated (evalParsed's eval path, direct test calls) pass through
;; forceB unchanged, so both calling conventions work.
;;
;; Extensibility contract: a NEW operator's clause receives its children
;; in whatever state the caller left them — force any child it consumes
;; with (forceB $kid) before using the value.
(= (AND $args) (allLazy $args))
(= (OR  $args) (anyLazy $args))
(= (NOT $x)    (not (forceB $x)))

;; Force one child: expressions dispatch through their registered clause
;; (firing these clauses recursively, again lazily); atoms — booleans,
;; numbers, symbols — pass through.
;;
;; Portable dynamic dispatch of a wrapped arity-1 operator term (Op Arg):
;; the var-headed application ($h ...) is lowered to the runtime meta-call
;; by BOTH PeTTa runtimes. Do NOT use (reduce $var) here: PeTTaV1 extends
;; the reduce special form to accept a variable, but stock PeTTa (the CI
;; image) requires a literal call form and mis-compiles a variable
;; argument — the clause then fails silently at runtime. Terms that are
;; not arity-1 with an atom head (row-bound value tuples, data) pass
;; through unchanged, mirroring reduce's leave-unevaluated rule.
(= (forceB $x)
   (if (== (get-metatype $x) Expression)
       (if (== $x ())
           ()
           (let ($h $t) (decons-atom $x)
             (if (== (get-metatype $h) Expression)
                 $x
                 (if (== $t ())
                     $x
                     (if (== (cdr-atom $t) ())
                         ($h (car-atom $t))
                         $x)))))
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

;; ---- Per-row core: template in, bool out. ----
;; sealed freshens only the labels vars in the body; unification binds
;; those fresh copies to the row; eval fires AND/OR/NOT on the fresh
;; expression. Original template's vars remain unbound for the next row.
;; Mechanism: sealed compiles to SWI-Prolog's copy_term/4 — only the
;; variables are freshened; ground (label-free) subterms are shared
;; between the template and the copy, not duplicated per row.

(= (evalParsed $template $row)
   (let ($labelsP $expP) $template
        (sealed $labelsP
                (let $labelsP $row
                     (eval $expP)))))

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
