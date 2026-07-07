;; Native boolean evaluation -- vars-at-leaves template, sealed per-row.
;;
;; `varize-itable` (moses/demo-problems.metta) swaps an ITable's symbolic
;; labels for fresh Prolog vars at the boundary. Representation building
;; threads those same var objects into candidate tree leaves. scoreTree
;; then pairs the labels list with `(preOrder $tree)` (utilities/tree.metta)
;; once per candidate -- no substitution pass, no string round-trip.
;;
;; Per row, `evalParsed` uses `sealed` (copy_term/4) to freshen only the
;; label vars in the body; unification against the row binds those fresh
;; copies; eval fires AND/OR/NOT on the fresh expression. The template's
;; vars stay unbound for the next row, and the invariant scaffolding
;; (AND/OR/NOT, ()) is shared with the original instead of copied.
;;
;; The eval clauses share names with the data-constructor pattern
;; `(mkNode AND)`, `(mkNode NOT)` etc. that pervades the codebase.
;; Anywhere a bare TUPLE of these symbols appears at a function-argument
;; position (e.g. `(List.contains $node (AND OR))`), the reducer treats
;; it as a call: `(AND OR)` matches `(AND $args)` with $args = OR,
;; reducing to `(all OR)`, then failing silently downstream. The fix is
;; `(quote (AND OR ...))` at every such site -- see utilities/tree.metta
;; (preOrder, isArgument, extractArgs, removeLiteral), scoring/bscore
;; (replaceVarWithTruth), representation/build-logical (buildLogical).

(= (AND $args) (all $args))
(= (OR  $args) (any $args))
(= (NOT $x)    (not $x))

;; Seal the WHOLE template, not just the labels: any tree var that is not
;; label-identical (e.g. a copy that leaked through a Space, whose atoms are
;; clause-database terms and come back renamed) would otherwise stay shared,
;; and eval would bind it to a boolean — permanently corrupting the candidate.
;; Sealing everything makes scoring side-effect-free on its input.
(= (evalParsed $template $row)
   (let ($labelsP $expP) $template
        (sealed ($labelsP $expP)
                (let $labelsP $row
                     (eval $expP)))))
