;; ============================================================================
;; search/hillclimb.metta -- looking for a better instance.
;;
;; The space is far too large to enumerate once conditions can nest, so:
;; start from the instance that reproduces the exemplar, look at every
;; instance one knob-setting away, move to the best of them, repeat until
;; nothing improves.
;;
;; Deliberately the simplest thing that works. No randomness, so every run
;; gives the same answer. Names follow the production tree's
;; optimization/hillclimbing (classic: neighborhood_sampling.h, hill-climbing.cc).
;; ============================================================================

;; classic: field_set::set_raw
(= (changeAt $items $index $value)
   (map-atom (rangeTo (size-atom $items)) $i (if (== $i $index) $value (index-atom $items $i))))

;; every instance that differs from $inst in knob $index alone
(= (varyNKnobs $mults $inst $index)
   (let* (($settings (index-atom $mults $index))
          ($current  (index-atom $inst $index))
          ($others   (filter-atom (rangeTo $settings) $setting (!= $setting $current))))
     (map-atom $others $setting (changeAt $inst $index $setting))))

(= (generateAllInNeighborhood $mults $inst)
   (let $indices (rangeTo (size-atom $inst))
     (foldl-atom $indices () $found $index
       (union-atom $found (varyNKnobs $mults $inst $index)))))

;; the best single move, or where we already are if nothing is better
(= (hillClimbingStep $scorer $rep $mults $inst $score)
   (let $neighbours (generateAllInNeighborhood $mults $inst)
     (foldl-atom $neighbours ($inst $score) $best $neighbour
       (let* ((($bestInst $bestScore) $best)
              ($neighbourScore (scoreInstance $scorer $rep $neighbour)))
         (if (> $neighbourScore $bestScore) ($neighbour $neighbourScore) $best)))))

(= (hillClimbingLoop $scorer $rep $mults $inst $score $fuel)
   (if (<= $fuel 0)
       ($inst $score)
       (let ($nextInst $nextScore) (hillClimbingStep $scorer $rep $mults $inst $score)
         (if (== $nextScore $score)
             ($inst $score)
             (hillClimbingLoop $scorer $rep $mults $nextInst $nextScore (- $fuel 1))))))

(= (searchSteps) 40)

(= (hillClimbing $scorer $rep)
   (let* (($mults (knobMultiplicities $rep))
          ($start (exemplarInst $rep))
          ($startScore (scoreInstance $scorer $rep $start)))
     (hillClimbingLoop $scorer $rep $mults $start $startScore (searchSteps))))
