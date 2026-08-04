;; ============================================================================
;; knobs/perms.metta -- the candidate subtrees offered at a boolean node.
;;
;; For a node whose operator is $op, over a vocabulary of labels, the
;; candidates are:
;;
;;   * every label on its own                      p,  q
;;   * one pair per label, built with the OPPOSITE operator, one of them
;;     negated                                     (OR (NOT p) q),  (OR q p)
;;
;; That second group is where NESTING comes from. Switch one on inside an AND
;; and you have an OR inside an AND -- structure the search could not
;; otherwise reach, since a knob can only turn a whole candidate on or off.
;; ============================================================================

;; The $i-th ordered pair (a, b) with a /= b, over 0 .. n-1. A plain
;; enumeration -- no randomness, so a run is reproducible.
(= (pairAt $n $i)
   (let* (($d (- $n 1))
          ($a (floor-math (/ $i $d)))
          ($j (% $i $d))
          ($b (if (< $j $a) $j (+ $j 1))))
     ($a $b)))

(= (pairTree $flip $n $i $labels)
   (let* ((($a $b) (pairAt $n $i))
          ($x (leafOf (index-atom $labels $a)))
          ($y (leafOf (index-atom $labels $b))))
     (if (< $b $a)
         (mkTree (mkNode $flip) ($y $x))
         (mkTree (mkNode $flip) ((negated $x) $y)))))

(= (logicalPerms $op $labels)
   (let $n (size-atom $labels)
     (if (<= $n 1)
         (let $a (car-atom $labels) ((leafOf $a) (negated (leafOf $a))))
         (let* (($flip (flipJunctor $op))
                ($idxs (rangeTo $n))
                ($pairs (map-atom $idxs $i (pairTree $flip $n $i $labels)))
                ($lits  (map-atom $labels $l (leafOf $l))))
           (union-atom $lits $pairs)))))
