
;; exemplar  selection
;; if the the metapopulation is empty - throw error and quit
;; if only one exemplar in the metapopulation select that
;; if more than one exemplar in mp - get the max penalized score and 
;; make a roulette selection on those after converting scores into probability values


! (bind! NO_EXEMPLAR "empty metapopulation")

(: select-exemplar (-> (OrdSet Xmplr) Xmplr))

(= (select-exemplar $xmplrSet)
    (let $n (size-atom $xmplrSet)
        (case $n
            ((0 (Error $xmplrSet NO_EXEMPLAR))
             (1 (car-atom $xmplrSet))
             ($_ (let* (($probs (mp.getPnzdScr $xmplrSet))
                        ($hstScr (max-atom $probs))
                        ($sum (mp.probSums $probs $hstScr)))

                        (rlt-select $probs $sum $xmplrSet) ))))))

;; helper functions
;; get penalized scores from each exemplar 

; (: mp.getPnzdScr (-> (OrdSet Xmplr) (Exp scoreT)))

(= (mp.getPnzdScr $mp)
    (collapse 
        (let* (($xmplr (superpose $mp))
                (($t $demeID ($s $cs $cp $up) $bscore) $xmplr)) 
     (- (- $s $cp) $up))))

! (bind! COMPXY_TEMP 4)
! (bind! INV_TEMP (/ 100.0 COMPXY_TEMP))

; (: mp.probSums (-> (Exp prob) scoreT Number))

(= (mp.probSums $probs $higestScr) 
    (if (== $probs ())
        0
        (let*((($f $t) (decons-atom $probs))
              ($p (if (isInf $f) 0 (pow-math EXP (* (- $f $higestScr) INV_TEMP))))
              ($c (mp.probSums $t $higestScr)))

            (+ $p $c))))

;; wrapping the inbuilt ininf-math with custom function because the return type is not bool, it is number
;; using the type-cast function

(: isInf (-> Number Bool))
(= (isInf $x) (type-cast (isinf-math $x) Bool &self))


;; the main roulette select function

;; bind python functinalities in metta -- metta functions not working 
;; random-float and random-int both require what is denoted as RandomGenerator
;; which, for now, is not clear what it is

! (bind! rndfloat (py-atom random.random))
! (bind! rndint (py-atom random.randint))

(= (rlt-select $probs $sum $xmplrSet)
    (let* (($rndfloat (rndfloat))
           ($newsum (* $sum $rndfloat))
           (() (println! $newsum))
            ($index (rlt $probs 0 $newsum)))

        (index-atom $xmplrSet $index)))

;; rlt function to do the roulette selection and return an index -- spin the wheel 😁
;;  $probs -- an expression of probability values
;;  $sIdx -- start index -- 0
;;  $ajstdsum -- sum of probabilities which has been deducted with some random value

; (: rlt (-> (Exp prob) Number Number))

(= (rlt $probs $sIdx $ajstdsum)
    (let $p (index-atom $probs $sIdx) 
        (if (<= (- $ajstdsum $p) 0)
            $sIdx
            (rlt $probs (+ 1 $sIdx) (- $ajstdsum $p)))))

            