;; bind python functinalities in metta -- metta functions not working 
;; random-float and random-int both require what is denoted as RandomGenerator
;; which, for now, is not clear what it is

! (bind! rndfloat (py-atom random.random))
! (bind! round (py-atom round))
! (bind! NO_EXEMPLAR "empty metapopulation")
! (bind! COMPXY_TEMP 4)
! (bind! INV_TEMP (mkScoreT (/ 100.0 COMPXY_TEMP)))

;; exemplar  selection
;; if the the metapopulation is empty - throw error and quit
;; if only one exemplar in the metapopulation select that
;; if more than one exemplar in mp - get the max penalized score and 
;; make a roulette selection on those after converting scores into probability values

(: selectExemplar (-> (OS Xmplr) Xmplr))
(= (selectExemplar $xmplrSet)
    (case $xmplrSet
        ((NilOS (Error $xmplrSet NO_EXEMPLAR))
        ((ConsOS $x NilOS) $x)
        ($_ (let* (($probs (getPnScore $xmplrSet))
                ($hstScr (List.max >>= $probs))
                ;; get list of normalized ScoreT values
                ($normalizedProbs (normalizeProbs INV_TEMP $hstScr $probs))
                ($sum (List.sum adder $normalizedProbs)))

                (rouletteSelect $xmplrSet $probs $sum) )))))

;; get penalized scores of all the exemplars as a list of ScoreT's
;;      (ConsOS $x $xs) -- pattern for the list of exemplars constructed by Cons
;;      made use of deconstruction by pattern matching

(: getPnScore (-> (OS Xmplr) (List ScoreT)))
(= (getPnScore NilOS) Nil)
(= (getPnScore (ConsOS $x $xs))
   (let*
        (((mkXmplr $tree (mkDemeId $id) (mkCscore (mkScoreT $s) (mkComplexity $cs) (mkScoreT $cp) (mkScoreT $up)) (mkBscore $bscore)) $x)
        ($p (- (- $s $cp) $up))
        ($c (getPnScore $xs)))

        (Cons (mkScoreT $p) $c)))

;;  a function to normalize the ScoreT values into normalized scores of Boltzman distribution
;; the function is specific to this distribution type
(: normalizeProbs (-> $a $a (List $a) (List $a)))
(= (normalizeProbs (mkScoreT $invTemp) (mkScoreT $best) Nil) Nil)
(= (normalizeProbs (mkScoreT $invTemp) (mkScoreT $best) (Cons (mkScoreT $x) $xs))
    (let*
        (($new (if (isInf $x) (mkScoreT 0) (mkScoreT (pow-math EXP (* (- $x $best) $invTemp)))))
        ($c (normalizeProbs (mkScoreT $invTemp) (mkScoreT $best) $xs)))

        (Cons $new $c)))

;; the main roulette select function
;;      $xmplrSet -- (OS Xmplr) -- list of exemplars
;;      $probs -- (List ScoreT) -- list of prob values as ScoreT types
;;      (mkScoreT $sum) -- sum of penalized score values after normalization using the (pow-math EXP (* (- $val $higestScr) INV_TEMP)) 
;;      to favour the selection of high scoring exemplars -- Boltzman distribution
(: rouletteSelect (-> (OS Xmplr) (List ScoreT) ScoreT Xmplr))
(= (rouletteSelect $xmplrSet $probs (mkScoreT $sum))
    (let* (($rndfloat (rndfloat))
           ($ajstdSum (* $sum $rndfloat))
            ($index (roulette $probs 0 $ajstdSum)))

        (OS.getByIdx $index $xmplrSet)))

;; roulette function to do the roulette selection and return an index -- spin the wheel
;;      $probs -- (List ScoreT) -- list of prob values (Cons (mkScoretT ..) .. Nil)
;;      $sIdx -- start index -- 0
;;      $ajstdsum -- sum of probabilities which has been multiplied with a random with random value in (0 .. 1) range
(: roulette (-> (List ScoreT) Number Number Number))
(= (roulette (Cons ($custor $p) $xs) $sIdx $ajstdsum)
    (if (<= (- $ajstdsum $p) 0)
            $sIdx
            (roulette $xs (+ 1 $sIdx) (- $ajstdsum $p))))
