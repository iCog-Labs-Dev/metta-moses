;; bind python functinalities in metta -- metta functions not working 
;; random-float and random-int both require what is denoted as RandomGenerator
;; which, for now, is not clear what it is

! (bind! rndfloat (py-atom random.random))
; ! (bind! rndint (py-atom random.randint))
! (bind! round (py-atom round))
! (bind! NO_EXEMPLAR "empty metapopulation")
! (bind! COMPXY_TEMP 4)
! (bind! INV_TEMP (/ 100.0 COMPXY_TEMP))

;; exemplar  selection
;; if the the metapopulation is empty - throw error and quit
;; if only one exemplar in the metapopulation select that
;; if more than one exemplar in mp - get the max penalized score and 
;; make a roulette selection on those after converting scores into probability values

(: select-exemplar (-> (OS Xmplr) Xmplr))
(= (select-exemplar $xmplrSet)
    (case $xmplrSet
        ((NilOS (Error $xmplrSet NO_EXEMPLAR))
        ((ConsOS $x NilOS) $x)
        ($_ (let* (($probs (getPnScore $xmplrSet))
                ($hstScr (listMax max $probs))
                ($sum (probSum $probs $hstScr)))

                (rlt-select $xmplrSet $probs $sum) )))))

;; get penalized scores of all the exemplars as a list of ScoreT's
;;      (ConsOS $x $xs) -- pattern for the list of exemplars constructed by Cons
;;      made use of deconstruction by pattern matching

(: getPnScore (-> (OS Xmplr) (List scoreT)))
(= (getPnScore NilOS) Nil)
(= (getPnScore (ConsOS $x $xs))
   (let*
        (((mkXmplr $tree (mkDemeId $id) (mkCscore (mkScoreT $s) (mkComplexity $cs) (mkScoreT $cp) (mkScoreT $up)) (mkBscore $bscore)) $x)
        ($p (- (- $s $cp) $up))
        ($c (getPnScore $xs)))

        (Cons (mkScoreT $p) $c)))

;; probSum -- 
(: probSum (-> (List ScoreT) Number Number))
(= (probSum Nil $h) 0)
(= (probSum (Cons $x $xs) $higestScr)
    (let* ((($custor $val) $x)
            ($p (if (isInf $val) 0 (pow-math EXP (* (- $val $higestScr) INV_TEMP))))
            ($c (probSum $xs $higestScr)))

            (+ $p $c)))

;; wrapping the built-in ininf-math with custom function because the return type is not bool, it is number
;; using the type-cast function
(: isInf (-> Number Bool))
(= (isInf $x) (type-cast (isinf-math $x) Bool &self))

;; the main roulette select function
;;      $xmplrSet -- (OS Xmplr) -- list of exemplars
;;      $probs -- (List ScoreT) -- list of prob values as ScoreT types
;;      $sum -- sum of penalized score values after normalization using the (pow-math EXP (* (- $val $higestScr) INV_TEMP)) 
;;      to favour the selection of high scoring exemplars -- Boltzman distribution
(: rlt-select (-> (OS Xmplr) (List ScoreT) Number Xmplr))
(= (rlt-select $xmplrSet $probs $sum)
    (let* (($rndfloat (rndfloat))
           ($ajstdSum (* $sum $rndfloat))
        ;    (() (println! $ajstdSum))
            ($index (rlt $probs 0 $ajstdSum)))

        (OS.getByIdx $index $xmplrSet)))

;; rlt function to do the roulette selection and return an index -- spin the wheel 😁
;;      $probs -- (List ScoreT) -- list of prob values (Cons (mkScoretT ..) .. Nil)
;;      $sIdx -- start index -- 0
;;      $ajstdsum -- sum of probabilities which has been multiplied with a random with random value in (0 .. 1) range
(: rlt (-> (List ScoreT) Number Number Number))
(= (rlt (Cons $x $xs) $sIdx $ajstdsum)
    (let ($custor $p) $x
        (if (<= (- $ajstdsum $p) 0)
            $sIdx
            (rlt $xs (+ 1 $sIdx) (- $ajstdsum $p)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Helper function max num value in (List $a)  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; max between two numbers
;;      (-> $a $b ..) just a trick to enable comparison of Nil with numbers 
(: max (-> $a $b $a))
(= (max $x $y)
    (case $y
        ((Nil $x)
        ($_ (if (>= $x $y) $x $y)))))

;; listMax -- finding maximum of (List $a)
;;      $max -- function comparing two numerical values
;;      (Cons $x $xs) -- list pattern
;;      ($ctor $val) -- used to deconstruct the value wrapped in some type constructor
(: listMax (-> (-> $t $u $t) (List $a) $a))
(= (listMax $max Nil) Nil)
(= (listMax $max (Cons $x $xs))
    (let*
        ((($ctor $val) $x)
        ($c (listMax $max $xs)))
        
        ($max $val $c) )) 
    

! (bind! inf (py-atom "float('inf')"))