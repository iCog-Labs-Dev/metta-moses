;; Native boolean evaluation -- operator clauses + the whole row-eval
;; pipeline. scoreTree (scoring/bscore.metta) only orchestrates:
;;   once per candidate:  (indexLeaves (preOrderExp $tree) $labels)
;;   once per row:        (reduceRow $indexed $row)
;; preOrderExp emits the wrapped eval shape ((Op (kids)) / (NOT child)),
;; indexLeaves maps label symbols to (lbl N) column positions, and
;; reduceRow substitutes the row's values and evaluates bottom-up,
;; dispatching each operator node into its clause below.
;; The var-template path (expToExp/foldTemplate/evalParsed) has no
;; production callers; it is kept as the semantics reference exercised by
;; boolean-ops-test.
;;
;; Quote rule: these clause names double as the data constructors used in
;; candidate trees and reduct expressions. Any bare (NOT $x) or arity-1
;; (AND ...)/(OR ...) tuple in a module loaded after this one compiles as
;; a CALL — wrap such data sites in (quote ...). All constructed terms
;; here use cons-atom or quote so nothing fires at build time.

;; Wrapped-list operators: single arity-1 clause = n-ary. Evaluation is
;; STRICT — a clause always receives fully evaluated children (reduceRow
;; evaluates bottom-up; evalParsed's eval normalizes bottom-up), so
;; new-operator clauses can consume their kids tuple directly.
(= (AND $args) (all $args))
(= (OR  $args) (any $args))
(= (NOT $x)    (not $x))

;; preOrderExp: Tree -> wrapped eval shape, leaves still label symbols.
;; Mirrors utilities/tree's preOrder; every emission is quote-protected.
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
;; passthroughs. Bodies capture nothing, so map-atom's yall copy is safe.
(= (childrenExp $children)
   (filter-atom (map-atom $children $c (preOrderExp $c)) $x (not (== $x ()))))

;; indexLeaves: once per candidate, replace each label symbol with
;; (lbl N), N = its column position (List.index misses return -1 and the
;; symbol passes through — operator heads, unknown symbols).
(= (indexLeaves $expr $labels)
   (if (== (get-metatype $expr) Expression)
       (if (== $expr ())
           ()
           (let ($h $t) (decons-atom $expr)
             (cons-atom (indexLeaves $h $labels) (indexLeaves $t $labels))))
       (if (== (get-metatype $expr) Symbol)
           (let $i (List.index $labels $expr)
             (if (== $i -1) $expr (lbl $i)))
           $expr)))

;; reduceRow: one bottom-up walk per (candidate, row) — (lbl N) leaves
;; become the row's Nth value, children evaluate before their parent, and
;; each arity-1 atom-headed node dispatches its operator clause via a
;; var-headed application. Do NOT "simplify" that dispatch to
;; (reduce $var): stock PeTTa (the CI image) mis-compiles a variable
;; argument to the reduce special form and fails silently; only PeTTaV1
;; accepts it. Terms that are not arity-1 with an atom head (row-bound
;; value tuples, data) pass through unchanged. Child iteration is direct
;; recursion: a map-atom body capturing $row would copy_term the capture
;; per element.
(= (reduceRow $e $row)
   (if (not (== (get-metatype $e) Expression))
       $e
       (if (== $e ())
           ()
           (if (== (car-atom $e) lbl)
               (index-atom $row (car-atom (cdr-atom $e)))
               (let* (
                      ($kids (rowKids $e $row))
                      ($h (car-atom $kids))
                      ($t (cdr-atom $kids))
                     )
                 (if (== (get-metatype $h) Expression)
                     $kids
                     (if (== $t ())
                         $kids
                         (if (== (cdr-atom $t) ())
                             ($h (car-atom $t))
                             $kids))))))))

(= (rowKids $kids $row)
   (if (== $kids ())
       ()
       (let ($k $rest) (decons-atom $kids)
         (cons-atom (reduceRow $k $row) (rowKids $rest $row)))))

;; substExp: replace every leaf occurrence of $target with $repl. Manual
;; recursion, NOT map-atom/foldl-atom — their yall lambdas copy_term
;; captured vars per iteration, which would break $repl's identity.
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

;; foldTemplate: mint one fresh var per label ($v is fresh per recursive
;; call) and substitute it everywhere; returns ($labelsTerm $finalExp)
;; sharing the same vars positionally for row unification.
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

;; evalParsed: per-row core of the template path. sealed (copy_term)
;; freshens only the label vars, row unification binds them, eval fires
;; the clauses; the original template stays unbound for the next row.
(= (evalParsed $template $row)
   (let ($labelsP $expP) $template
        (sealed $labelsP
                (let $labelsP $row
                     (eval $expP)))))

;; expToExp: same shape transform as preOrderExp but from a raw test
;; expression like (AND A B) instead of a Tree.
(= (expToExp $e)
   (if (== (get-metatype $e) Expression)
       (let ($h $rest) (decons-atom $e)
            (if (== $h NOT)
                (let $child (expToExp (car-atom $rest))
                     (let $node (cons-atom NOT (cons-atom $child ())) $node))
                (let $childrenTerm (map-atom $rest $c (expToExp $c))
                     (let $node (cons-atom $h (cons-atom $childrenTerm ())) $node))))
       $e))
