;; Native boolean evaluation -- operator clauses + the unification-based
;; row evaluator. scoreTree (scoring/bscore.metta) orchestrates:
;;   once per candidate:  (candTemplate $labels $tree)
;;   once per row:        (evalParsed $template $row)
;; candTemplate walks the Tree once (preOrderExp) into the wrapped eval
;; shape ((Op (kids)) / (NOT child)) with label leaves, then folds over the
;; labels replacing each with a fresh MeTTa variable, yielding a template
;; ($labelsTerm $expTerm) whose labels-term and expression share those
;; vars positionally. Per row, evalParsed seals the vars, UNIFIES the
;; labels-term against the row (binding every leaf var to that row's value
;; in one step), and lets MeTTa's own `eval` reduce the boolean expression
;; natively through the AND/OR/NOT clauses below. This is the native-MeTTa
;; evaluation the scorer is built around: real variables, real
;; unification, real eval — not a hand-rolled interpreter.
;;
;; DEPENDS ON utilities/general-helpers (all/any, is-member) — entry files
;; must import it before this module.
;;
;; Quote rule: these clause names double as the data constructors used in
;; candidate trees and reduct expressions. Any bare (NOT $x) or arity-1
;; (AND ...)/(OR ...) tuple in a module loaded after this one compiles as
;; a CALL — wrap such data sites in (quote ...); a callee that
;; destructures its argument in the clause head needs the quoted value
;; let-bound first (see boolean-ops-test). All constructed terms here use
;; cons-atom or quote so nothing fires at build time.

;; Wrapped-list operators: single arity-1 clause = n-ary. eval reduces the
;; template bottom-up, so each clause receives fully evaluated children.
(= (AND $args) (all $args))
(= (OR  $args) (any $args))
(= (NOT $x)    (not $x))

;; preOrderExp: Tree -> wrapped eval shape, label leaves kept as symbols
;; (candTemplate later replaces them with fresh vars). Mirrors
;; utilities/tree's preOrder; every emission is quote-protected so the
;; clauses cannot fire at template-build time.
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

;; childrenExp: map preOrderExp over child Trees, dropping empty knob
;; passthroughs.
(= (childrenExp $children)
   (filter-atom (map-atom $children $c (preOrderExp $c)) $x (!= $x ())))

;; substExp: replace every leaf occurrence of $target with $repl. The
;; var-safe (map $f $a $b ...) threads $target/$repl through call/1, so the
;; single fresh $repl var is shared across every occurrence (map-atom would
;; copy_term it per element and break that identity).
(= (substExp $target $repl $exp)
   (if (== (get-metatype $exp) Expression)
       (map substExp $target $repl $exp)
       (if (== $exp $target) $repl $exp)))

;; foldTemplateStep: fold accumulator step — mint a fresh $v for one label,
;; substitute it for that label in the running expression, and cons it onto
;; the labels-term (a bare `cons` list so it unifies positionally against
;; the cons-list rows). $v is shared between the labels-term slot and every
;; occurrence substExp plants.
(= (foldTemplateStep $label $acc)
   (let ($labelsAcc $expAcc) $acc
        ((cons $v $labelsAcc) (substExp $label $v $expAcc))))

;; candTemplate: build a candidate's row-evaluation template ONCE —
;; preOrderExp into the wrapped eval shape, then foldr foldTemplateStep to
;; replace each label with a fresh var. Returns (labelsTerm expTerm)
;; sharing those vars positionally; foldr's right-to-left order keeps the
;; labels-term in $labels order without a reversal.
(= (candTemplate $labels $tree)
   (let $exp (preOrderExp $tree)
        (foldr foldTemplateStep (() $exp) $labels)))

;; reduceExp: reduce a (row-bound) template expression bottom-up — reduce
;; every child (map reduceExp), then apply `reduce` to the node so it
;; dispatches the operator clause (or the quote wrapper). `reduce` is
;; single-step and doesn't pre-evaluate its args, so children go first.
;; $kids MUST be let-bound: (reduce (map ...)) would dispatch the literal
;; `map` call instead of its result. A reduced child-value tuple like
;; (True False) has no callable head, so `reduce` returns it unchanged.
(= (reduceExp $e)
   (if (!= (get-metatype $e) Expression)
       $e
       (if (== $e ())
           ()
           (let $kids (map reduceExp $e)
             (reduce $kids)))))

;; evalParsed: per-row core. sealed (copy_term) freshens only the label
;; vars, row unification binds them, reduceExp reduces the bound
;; expression through the clauses; the original template stays unbound for
;; the next row.
(= (evalParsed $template $row)
   (let ($labelsP $expP) $template
        (sealed $labelsP
                (let $labelsP $row
                     (reduceExp $expP)))))
