;; bind python functinalities in metta -- metta functions not working 
;; which, for now, is not clear what it is

;; removed python binding for compatibility with workflow -- XXX 
;; bind is not supported for constants (as of 13 NOV) in PeTTa -- thus using function style notation
(= (NO_EXEMPLAR) "empty metapopulation")
(= (INV_TEMP) (/ 100.0 (param compxyTemp)))

;; exemplar  selection
;; if the the metapopulation is empty - throw error and quit
;; if only one exemplar in the metapopulation select that
;; if more than one exemplar in mp - get the max penalized score and 
;; make a roulette selection on those after converting scores into probability values
; (: selectExemplar (-> (OS (Exemplar $a)) (Exemplar $a)))
(= (selectExemplar $metaPop)
    (case $metaPop
        ((() (Error $metaPop (NO_EXEMPLAR)))
        ((cons $x ()) $x)
        ($_ (let* (
                    ($probs (getPnScore $metaPop))
                    ($hstScr (List.max $probs))
                    ;; get list of normalized ScoreT values
                    ($normalizedProbs (normalizeProbs (INV_TEMP) $hstScr $probs))
                    ;; ($pr (println! (NotNormalized: $probs)))
                    ;; ($pr (println! (Normalized Probs: $normalizedProbs)))
                    ($sum (List.sum $normalizedProbs))
                    ;; ($pr (println! (HstScr: $hstScr Sum: $sum)))
                  )
                  (rouletteSelect $metaPop $normalizedProbs $sum) )))))

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
