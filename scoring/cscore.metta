;; The probability parameter p in the scoring represents the assumed probability that the model makes an error on any given data point.
;; If p is small (close to 0), it means the model is expected to be very accurate, making mistakes rarely.
;; If p is large (approaching 0.5), it means the model is expected to be less accurate, making mistakes more often (but still better than random guessing).

(: getCscore (-> (ITable $a) (Tree $a) Number Cscore))
(= (getCscore $itable $tree $complexityRatio)
    (let $bs (scoreTree $itable $tree)
        (if-error $bs ;; return worst possible composite score
            (worstCscore)
            (let* (($bsum (sumBScore $bs))
                   (() (println! (Score: $bsum)))
                   (() (println! ""))
                   ($cpxy (treeComplexity $tree))
                   (() (println! (Complexity: $cpxy)))
                   ($cCoef (getComplexityCoef $complexityRatio)))

                   (updatePenalizedScore (mkCscore $bsum $cpxy (* $cpxy $cCoef) 0.0 (* -1 (pow-math 10 308)))  False)))))

;; getComplexityCoef -- calcualtes the complexity coeffient of a tree   
;; takes complexity ratio as input and returns complexity coefficient
;; complexity ratio, unless set by the user, has 3.5 for a default value

(: getComplexityCoef (-> Number Number))
(= (getComplexityCoef $complexityRatio)
    (if (> $complexityRatio 0)
        (/ 1.0 $complexityRatio)
        0.0))           

;; updatePenalizedScore            
;; by default the worst possible score is set as the penalized score for a tree
;; there is a bool multiply_diversity parameter if set to true the penalized score has to be multiplied with the uniform penalty
;; if not the uniformity penalty is instead subtracted
;; the default thing is to set the parameter to False

(: Cscore Type)
(: mkCscore (-> Number Number Number Number Number Cscore))

(: updatePenalizedScore (-> Cscore Bool Cscore))
(= (updatePenalizedScore (mkCscore $scor $cpxy $cpxyPenalty $uniformityPenalty $penalizedScore) $multiplyDiversity)
    (let* (($temp (- $scor $cpxyPenalty))
           ($updatedPScore (if $multiplyDiversity (* $temp $uniformityPenalty) (- $temp $uniformityPenalty)))
           (() (println! (PenalizedScore: $updatedPScore))))
        
            (mkCscore $scor $cpxy $cpxyPenalty $uniformityPenalty $updatedPScore)))

;; worstCscore
(: worstCscore (-> Cscore))
(= (worstCscore)
    (mkCscore (* -1 (pow-math 10 308)) 0 0.0 0.0 (* -1 (pow-math 10 308))))

;; score getters
(: getPenScore (-> Cscore Number))
(= (getPenScore (mkCscore $scor $cpxy $complexityPenalty $uniformityPenalty $penalizedScore)) $penalizedScore)

(: getScore (-> Cscore Number))
(= (getScore (mkCscore $scor $cpxy $complexityPenalty $uniformityPenalty $penalizedScore)) $scor)

(: getComp (-> Cscore Number))
(= (getComp (mkCscore $scor $cpxy $complexityPenalty $uniformityPenalty $penalizedScore)) $cpxy)

(: getCompPen (-> Cscore Number))
(= (getCompPen (mkCscore $scor $cpxy $complexityPenalty $uniformityPenalty $penalizedScore)) $complexityPenalty)

(: getUniPen (-> Cscore Number))
(= (getUniPen (mkCscore $scor $cpxy $complexityPenalty $uniformityPenalty $penalizedScore)) $uniformityPenalty)

;; comparing composite scores
;; cScore< -- composite score less than operator
;; uses penalized scores to compare and complexity score to break ties in the penalized score
;; $cs1 -- composite score of the left side instance ..
;; $cs2 -- composite score of the right side instance or whatever
;; isnan -- python binding for checking NaN values -- MeTTa's isnan-math passes the type check but doenst reduce 
! (bind! isnan (py-atom "math.isnan"))
(: cScore< (-> Cscore Cscore Bool)) 
(= (cScore< $cs1 $cs2)
    (let ($pl $pr $cl $cr) ((getPenScore $cs1) (getPenScore $cs2) (getComp $cs1) (getComp $cs2))
        (if (isnan $pl)
            (not (isnan $pr))
            (or (< $pl $pr) (and (== $pl $pr) (> $cl $cr))))))
            
;; Check for equality, to within floating-point error, EPSILON
(: cScore== (-> Cscore Cscore Bool))
(= (cScore== $cs1 $cs2)
    (let ($sL $cL $cpL $upL $pL $sR $cR $cpR $upR $pR) 
            ((getScore $cs1) (getComp $cs1) (getCompPen $cs1) (getUniPen $cs1) (getPenScore $cs1)
            (getScore $cs2) (getComp $cs2) (getCompPen $cs2) (getUniPen $cs2) (getPenScore $cs2)) 
        
            (and (isApproxEq $sL $sR) 
                (and (isApproxEq $cL $cR) 
                    (and (isApproxEq $cpL $cpR) 
                        (and (isApproxEq $upL $upR) (isApproxEq $pL $pR)))))))

(: cScore>= (-> Cscore Cscore Bool)) 
(= (cScore>= $cs1 $cs2)
    (let ($pl $pr $cl $cr) ((getPenScore $cs1) (getPenScore $cs2) (getComp $cs1) (getComp $cs2))
        (if (isnan $pl)
            False
            (or (> $pl $pr) (and (== $pl $pr) (< $cl $cr))))))
