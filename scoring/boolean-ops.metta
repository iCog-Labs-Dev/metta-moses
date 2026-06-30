;; Native boolean evaluation -- parse-based unification.
;;
;; The candidate is converted to its `$`-prefixed string form ONCE per
;; candidate (by scoreTree, before iterating rows). Per row, boolEval just:
;;   1. concatenates "(($labels-str) ($cand-str))"
;;   2. (parse ...) the string -- the parser's name->Prolog-var dict is
;;      shared within one call, so every $A occurrence becomes the same
;;      Prolog variable in both the labels list and the candidate
;;   3. destructure: ($labelsP $expP) (parse ...)
;;   4. (let $labelsP $rowExp) -- ONE Prolog unification binds every var
;;      in the labels list against the row in one shot
;;   5. (eval $expP) -- fires And/Or/Not with bound bools
;;
;; ---- Operator-name collision sidestep ----
;; The reduct module builds `(AND <single-expr>)` as a data wrapper
;; (n-ary-gather-junctors.metta, reduce-to-elegance.metta). Defining
;; `(= (AND $args) ...)` would silently dispatch on those wrappers.
;; The fix: define EVAL forms as `And/Or/Not` (CapFirst); `head-vstr`
;; rewrites AND->And etc. while emitting the parseable string, so the
;; rename costs nothing outside boolean-ops.metta itself.

;; ---- Wrapped-list operators: single arity-1 clause = n-ary ----
;; And/Or take their children as a single wrapped Expression; Not takes
;; its single bool directly (unary). tree-vstr emits And/Or children
;; wrapped, but Not's single child unwrapped.
(= (And $args) (all $args))
(= (Or  $args) (any $args))
(= (Not $x)    (not $x))

;; ---- head-vstr: translate operator names at string-build time ----
;; case-dispatch keeps this deterministic.
(= (head-vstr $h)
   (case $h
     ((AND "And")
      (OR  "Or")
      ($_  $h))))

;; ---- str-concat: emit string fragments, fold-concat once. ----
;; Replaces nested atom_concat chains everywhere; pass any list of
;; (computed-or-literal) string fragments and get the joined result.
(= (str-concat $fragments) (foldl-atom $fragments "" atom_concat))

;; ---- tree-vstr: candidate Expression -> "(And ( $A $B))" ----
;; Children are wrapped in an inner Expression so the And/Or/Not arity-1
;; clauses bind $args to the whole children list. Operators are renamed
;; via head-vstr; leaf symbols get a `$` prefix so parse mints them as
;; variables. The recursion rides inside map-atom -- no explicit self-call
;; against decons-atom. Called ONCE per candidate.
;; tree-vstr emits And/Or with their children wrapped in an extra
;; Expression so the arity-1 (And $args) / (Or $args) clauses bind
;; the whole list. Not stays unary (no extra wrap).
(= (tree-vstr $t)
   (if (== (get-metatype $t) Expression)
       (let ($h $rest) (decons-atom $t)
            (if (== $h NOT)
                (str-concat ("(Not" (children-vstr $rest) ")"))
                (str-concat ("(" (head-vstr $h) " (" (children-vstr $rest) "))"))))
       (str-concat ("$" $t))))

;; children-vstr: " $c1 $c2 ..." via map-atom + str-concat.
(= (children-vstr $exp)
   (str-concat (map-atom $exp $c (str-concat (" " (tree-vstr $c))))))

;; ---- labels-vstr: cons-tagged labels -> "($A $B $C)". ----
;; Called ONCE per scoreTree.
(= (labels-vstr $labels)
   (str-concat ("(" (str-concat (map-atom $labels $l (str-concat (" $" $l)))) ")")))

;; ---- Per-row entry: thin -- no walks, just str-concat + parse + unify + eval ----
(= (boolEval $labelsStr $row $candStr)
   (let $combined (str-concat ("(" $labelsStr " " $candStr ")"))
        (let ($labelsP $expP) (parse $combined)
             (let $labelsP $row
                  (eval $expP)))))
