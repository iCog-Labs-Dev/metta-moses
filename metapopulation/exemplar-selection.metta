;; bind python functinalities in metta -- metta functions not working 
;; which, for now, is not clear what it is

!(callPredicate (Predicate (py_add_lib_dir "scripts" first)))

;; removed python binding for compatibility with workflow -- XXX 
;; bind is not supported for constants (as of 13 NOV) in PeTTa -- thus using function style notation
(= (NO_EXEMPLAR) "empty metapopulation")
(= (INV_TEMP) (/ 100.0 (param compxyTemp)))

;; Visited tracking helpers:
;; An exemplar is eligible if its visit count satisfies C++ revisit semantics:
;;   revisit < 0  => always eligible (unbounded)
;;   revisit >= 0 => eligible iff count <= revisit
;;   (so revisit=0 means exactly 1 visit total, matching C++ default)
(= (isExemplarEligible (mkExemplar $tree $demeId $cscore $bscore))
   (== (py-call (visited_tracker.is_eligible (preOrder $tree) (param revisit))) 1))

(= (filterEligibleExemplars ()) ())
(= (filterEligibleExemplars (cons $x $xs))
   (if (isExemplarEligible $x)
       (cons $x (filterEligibleExemplars $xs))
       (filterEligibleExemplars $xs)))

;; roulette selection on a pool of exemplars
(= (rouletteSelectFromPool $pool)
    (case $pool
        ((() (Error $pool (NO_EXEMPLAR)))
        ((cons $x ()) $x)
        ($_ (let* (
                    ($probs (getPnScore $pool))
                    ($hstScr (List.max $probs))
                    ;; get list of normalized ScoreT values
                    ($normalizedProbs (normalizeProbs (INV_TEMP) $hstScr $probs))
                    ;; ($pr (println! (NotNormalized: $probs)))
                    ;; ($pr (println! (Normalized Probs: $normalizedProbs)))
                    ($sum (List.sum $normalizedProbs))
                    ;; ($pr (println! (HstScr: $hstScr Sum: $sum)))
                  )
                  (rouletteSelect $pool $normalizedProbs $sum) )))))

(= (recordExemplarVisit (mkExemplar $tree $demeId $cscore $bscore))
   (py-call (visited_tracker.record_visit (preOrder $tree))))

;; exemplar selection (C++ parity)
;; * Empty metapop              -> NO_EXEMPLAR error
;; * Metapop (1 or N exemplars) -> filter eligible; if empty return NO_EXEMPLAR
;;                                 (matches C++ select_exemplar returning end())
; (: selectExemplar (-> (OS (Exemplar $a)) (Exemplar $a)))
(= (selectExemplar $metaPop)
    (case $metaPop
        ((() (Error $metaPop (NO_EXEMPLAR)))
        ($_ (let* (
                    ($eligible (filterEligibleExemplars $metaPop))
                    ($chosen (if (== $eligible ())
                                 (let* (
                                        ($_ (println! "[VISITED] All exemplars at revisit limit. No eligible exemplar (C++ parity: select_exemplar returns end())."))
                                        ($_ex (py-call (visited_tracker.record_exhaustion)))
                                       )
                                       (Error $metaPop (NO_EXEMPLAR)))
                                 (let* (
                                        ($sel (rouletteSelectFromPool $eligible))
                                        ($_ (recordExemplarVisit $sel))
                                       )
                                       $sel)))
                  )
                  $chosen)))))

;; get penalized scores of all the exemplars as a list of Numbers
;;      (cons $x $xs) -- pattern for the list of exemplars constructed by cons
;;      made use of deconstruction by pattern matching

; (: getPnScore (-> (OS (Exemplar $a)) (List Number)))
(= (getPnScore $xs) (map-atom $xs getExemplarPenScore))

;;  a function to normalize the score values into normalized scores of Boltzman distribution
;; the function is specific to this distribution type
; (: normalizeProbs (-> Number Number (List Number) (List Number)))
;; (= (normalizeProbs $invTemp $best ()) ())
(= (normalizeProbs $invTemp $best $xs) (map-atom $xs $x (if (isinf-math $x) 0 (exp (* (- $x $best) $invTemp)))))

;; the main roulette select function
;;      $metaPop -- (OS (Exemplar $a)) -- list of exemplars
;;      $probs -- (List Number) -- list of prob values as ScoreT types
;;      $sum -- sum of penalized score values after normalization using the (pow-math EXP (* (- $val $higestScr) INV_TEMP)) 
;;      to favour the selection of high scoring exemplars -- Boltzman distribution

; (: rouletteSelect (-> (OS (Exemplar $a)) (List Number) Number (Exemplar $a)))
(= (rouletteSelect $metaPop $probs $sum)
    (let* (

           ($rndfloat (py-call (random.random))) ;;This was (random-float 0 1)
           ($ajstdSum (* $sum $rndfloat))
           ($index (roulette $probs 0 $ajstdSum))
           ;; ($_ (println! (Sum: $sum RandFloat: $rndfloat AjstdSum: $ajstdSum)))
           ;; ($_ (println! (Index: $index)))
          )
        (OS.getByIdx $index $metaPop)))

;; roulette function to do the roulette selection and return an index -- spin the wheel
;;      $probs -- (List Number) -- list of prob values 
;;      $sIdx -- start index -- 0
;;      $ajstdsum -- sum of probabilities which has been multiplied with a random with random value in (0 .. 1) range
; (: roulette (-> (List Number) Number Number Number))
(= (roulette () $sIdx $ajstdsum) (- $sIdx 1))
(= (roulette (cons $p $xs) $sIdx $ajstdsum)
    ;; (trace! (AdjustdSum: (- $ajstdsum $p))
            (if (<= (- $ajstdsum $p) 0)
            $sIdx
            (roulette $xs (+ 1 $sIdx) (- $ajstdsum $p)))
            ;; )
    )
