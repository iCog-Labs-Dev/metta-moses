;; ============================================================================
;; core/prelude.metta -- small helpers. Nothing here knows about MOSES.
;; ============================================================================

;; Is $x a tuple (as opposed to a bare symbol or a number)?
(= (isExpr $x) (== (get-metatype $x) Expression))

;; 0, 1, ... n-1.  ASCENDING -- several things below rebuild lists by mapping
;; over these indices, and a descending range would silently reverse them.
(= (rangeFrom $i $n) (if (>= $i $n) () (cons-atom $i (rangeFrom (+ $i 1) $n))))
(= (rangeTo $n) (rangeFrom 0 $n))

(= (lastOf $xs) (index-atom $xs (- (size-atom $xs) 1)))

;; Position of $x in $xs, or -1.
;; $idxs is LET-BOUND on purpose: `superpose` does not evaluate its argument,
;; so (superpose (rangeTo ...)) would superpose over the literal two-element
;; term `(rangeTo ...)` and quietly produce nothing.
(= (idxOfIn $xs $x)
   (let* (($idxs (rangeTo (size-atom $xs)))
          ($hits (collapse (let $i (superpose $idxs)
                                (if (== (index-atom $xs $i) $x) $i (empty))))))
     (if (== $hits ()) -1 (car-atom $hits))))

(= (containsIn $xs $x) (!= (idxOfIn $xs $x) -1))

;; Every element of $xs except those in $ys.
(= (without $xs $ys) (filter-atom $xs $x (not (containsIn $ys $x))))

(= (maxOf $xs) (foldl-atom $xs -1000000 $a $x (if (> $x $a) $x $a)))


;; ---------------------------------------------------------------------------
;; Trees.  A program is a tree:
;;
;;     (mkTree (mkNode <symbol>) <tuple of child trees>)
;;
;; Two extra shapes appear once knobs are involved:
;;     (mkKnob <controlled subtree> <knob> <index>)   a knobbed position
;;     (mkNullVex (<subtree>))                        a position that is empty
;;                                                    unless its knob turns on
;; ---------------------------------------------------------------------------

(= (leafOf $s) (mkTree (mkNode $s) ()))
(= (nodeSymOf (mkTree (mkNode $s) $kids)) $s)
(= (kidsOf (mkTree (mkNode $s) $kids)) $kids)
(= (isNullVex $x) (== (car-atom $x) mkNullVex))

;; Wrap $t in a negation node.
(= (negated $t) (mkTree (mkNode NOT) ($t)))


;; ---------------------------------------------------------------------------
;; showTree -- compact printing.  (mkTree (mkNode a) ((mkTree (mkNode b) ())))
;; prints as (a (b)), which is what makes the demo readable.
;; Knobs print as (KNOB <index> <kind> <multiplicity> <default> <subtree>).
;; ---------------------------------------------------------------------------
(= (showTree (mkNullVex ()))  EMPTY)
(= (showTree (mkNullVex ($t))) (let $in (showTree $t) (quote (OFF $in))))
(= (showTree (mkTree (mkNode $s) ())) $s)
(= (showTree (mkTree (mkNode $s) (cons $x $xs)))
   (let $kids (map-atom (cons $x $xs) $c (showTree $c)) (quote ($s $kids))))
(= (showTree (mkKnob $sub (mkLSK $m $d) $i))
   (let $in (showTree $sub) (quote (KNOB $i LSK $m $d $in))))
(= (showTree (mkKnob $sub (mkASK $m $d $p) $i))
   (let $in (showTree $sub) (quote (KNOB $i ASK $m $d $in))))
