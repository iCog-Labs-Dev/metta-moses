;; ============================================================================
;; search/hillclimb.metta -- looking for a better instance.
;;
;; The space is far too large to enumerate once conditions can nest, so:
;; start from the instance that reproduces the exemplar, look at every
;; instance one knob-setting away, move to the best of them, repeat until
;; nothing improves.
;;
;; Deliberately the simplest thing that works. No randomness, so every run
;; gives the same answer.
;; ============================================================================

(= (setNth $xs $i $v)
   (let $idxs (rangeTo (size-atom $xs))
     (map-atom $idxs $k (if (== $k $i) $v (index-atom $xs $k)))))

;; every instance that differs from $inst in knob $i alone
(= (neighboursAt $mults $inst $i)
   (let* (($m (index-atom $mults $i))
          ($cur (index-atom $inst $i))
          ($vals (filter-atom (rangeTo $m) $v (!= $v $cur))))
     (map-atom $vals $v (setNth $inst $i $v))))

(= (neighbours $mults $inst)
   (let $idxs (rangeTo (size-atom $inst))
     (foldl-atom $idxs () $acc $i (union-atom $acc (neighboursAt $mults $inst $i)))))

;; the best single move, or where we already are if nothing is better
(= (climbStep $scorer $rep $mults $inst $score)
   (let $ns (neighbours $mults $inst)
     (foldl-atom $ns ($inst $score) $best $n
       (let* ((($bi $bs) $best)
              ($s (scoreInstance $scorer $rep $n)))
         (if (> $s $bs) ($n $s) $best)))))

(= (climb $scorer $rep $mults $inst $score $fuel)
   (if (<= $fuel 0)
       ($inst $score)
       (let ($ni $ns) (climbStep $scorer $rep $mults $inst $score)
         (if (== $ns $score)
             ($inst $score)
             (climb $scorer $rep $mults $ni $ns (- $fuel 1))))))

(= (searchSteps) 40)

(= (searchBest $scorer $rep)
   (let* (($mults (multsOf $rep))
          ($start (defaultInstance $rep))
          ($s0 (scoreInstance $scorer $rep $start)))
     (climb $scorer $rep $mults $start $s0 (searchSteps))))
