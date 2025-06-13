;; bind python functinalities in metta -- metta functions not working 
;; random-float and random-int both require what is denoted as RandomGenerator
;; which, for now, is not clear what it is

! (bind! rndfloat (py-atom random.random))
! (bind! round (py-atom round))
! (bind! NO_EXEMPLAR "empty metapopulation")
! (bind! COMPXY_TEMP 4)
! (bind! INV_TEMP (/ 100.0 COMPXY_TEMP))

;; exemplar  selection
;; if the the metapopulation is empty - throw error and quit
;; if only one exemplar in the metapopulation select that
;; if more than one exemplar in mp - get the max penalized score and 
;; make a roulette selection on those after converting scores into probability values
(: selectExemplar (-> (OS (Exemplar $a)) (Exemplar $a)))
(= (selectExemplar $metaPop)
    (case $metaPop
        ((NilOS (Error $metaPop NO_EXEMPLAR))
        ((ConsOS $x NilOS) $x)
        ($_ (let* (($probs (getPnScore $metaPop))
                ($hstScr (List.max >= $probs))
                ;; get list of normalized ScoreT values
                ($normalizedProbs (normalizeProbs INV_TEMP $hstScr $probs))
                ($sum (List.sum $normalizedProbs)))
                (rouletteSelect $metaPop $probs $sum) )))))

;; get penalized scores of all the exemplars as a list of Numbers
;;      (ConsOS $x $xs) -- pattern for the list of exemplars constructed by Cons
;;      made use of deconstruction by pattern matching

(: getPnScore (-> (OS (Exemplar $a)) (List Number)))
(= (getPnScore NilOS) Nil)
(= (getPnScore (ConsOS $x $xs))
   (let (mkExemplar $tree1 $demeId1 (mkCscore $scrr $cpxy $cpxyPen $uniPen $penScr) $bscr1) $x
        (Cons $penScr (getPnScore $xs))))

;;  a function to normalize the score values into normalized scores of Boltzman distribution
;; the function is specific to this distribution type
(: normalizeProbs (-> Number Number (List Number) (List Number)))
(= (normalizeProbs $invTemp $best Nil) Nil)
(= (normalizeProbs $invTemp $best (Cons $x $xs))
    (let*
        (($new (if (isInf $x) 0 (pow-math EXP (* (- $x $best) $invTemp))))
        ($c (normalizeProbs $invTemp $best $xs)))

        (Cons $new $c)))

;; the main roulette select function
;;      $metaPop -- (OS (Exemplar $a)) -- list of exemplars
;;      $probs -- (List Number) -- list of prob values as ScoreT types
;;      $sum -- sum of penalized score values after normalization using the (pow-math EXP (* (- $val $higestScr) INV_TEMP)) 
;;      to favour the selection of high scoring exemplars -- Boltzman distribution

(: rouletteSelect (-> (OS (Exemplar $a)) (List Number) Number (Exemplar $a)))
(= (rouletteSelect $metaPop $probs $sum)
    (let* (($rndfloat (rndfloat))
           ($ajstdSum (* $sum $rndfloat))
            ($index (roulette $probs 0 $ajstdSum)))
        (OS.getByIdx $index $metaPop)))

;; roulette function to do the roulette selection and return an index -- spin the wheel
;;      $probs -- (List Number) -- list of prob values 
;;      $sIdx -- start index -- 0
;;      $ajstdsum -- sum of probabilities which has been multiplied with a random with random value in (0 .. 1) range
(: roulette (-> (List Number) Number Number Number))
(= (roulette Nil $sIdx $ajstdsum) (- $sIdx 1))
(= (roulette (Cons $p $xs) $sIdx $ajstdsum)
    (if (<= (- $ajstdsum $p) 0)
            $sIdx
            (roulette $xs (+ 1 $sIdx) (- $ajstdsum $p))))