;; The probability parameter p in the scoring represents the assumed probability that the model makes an error on any given data point.
;; If p is small (close to 0), it means the model is expected to be very accurate, making mistakes rarely.
;; If p is large (approaching 0.5), it means the model is expected to be less accurate, making mistakes more often (but still better than random guessing).

(: getCscore (-> (ITable $a) (Tree $a) Number Cscore))
(= (getCscore $itable $tree $complexityRatio $scoreSpace)
    (unify $scoreSpace 
            ($tree $score) 
            (let $cached-score (trace! "USED from cache XXXXXXXXXXXXXXXXXXXXXXXXXXX " $score) $cached-score)
            (chain (scoreTree $itable $tree) $bs 
                (if-error $bs ;; return worst possible composite score
                (worstCscore)
                (let* (($bsum (sumBScore $bs))
                    (() (println! (Score: $bsum)))
                    (() (println! ""))
                    ($cpxy (treeComplexity $tree))
                    (() (println! (Complexity: $cpxy)))
                    ($cCoef (getComplexityCoef $complexityRatio))
                    ($res (updatePenalizedScore (mkCscore $bsum $cpxy (* $cpxy $cCoef) 0.0 (* -1 (pow-math 10 308)))  False))
                    (() (add-atom $scoreSpace ($tree $res)))
                    )

                    $res )))))


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
;converts a score to an expression
; (: cScoreToExpr (-> Cscore Expression))
(= (cScoreToExpr (mkCscore $scor $cpxy $complexityPenalty $uniformityPenalty $penalizedScore))
    (let* (
        ($e1 (cons-atom $penalizedScore ()))
        ($e2 (cons-atom $uniformityPenalty $e1))
        ($e3 (cons-atom $complexityPenalty $e2))
        ($e4 (cons-atom $cpxy $e3))
        ($e5 (cons-atom $scor $e4))
    )
        ($e5)
    )
)

; (: exprToCScore (-> Expression Cscore))
(= (exprToCScore $exp)
    (let* (
        ($expr (car-atom $exp))
        (($scor $rest1) (decons-atom $expr))
        (($cpxy $rest2) (decons-atom $rest1))
        (($complexityPenalty $rest3) (decons-atom $rest2))
        (($uniformityPenalty $rest4) (decons-atom $rest3))
        (($penalizedScore $_) (decons-atom $rest4))
    )
        (mkCscore $scor $cpxy $complexityPenalty $uniformityPenalty $penalizedScore)
    )
)


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

;; cScoreExpr< -- composite score less than operator for expressions
;; works directly with expressions using index-atom to extract scores
;; index 4 = penalized score, index 1 = complexity score
(: cScoreExpr< (-> Expression Expression Bool))
(= (cScoreExpr< (($scor $cpxy $complexityPenalty $uniformityPenalty $penalizedScore)) 
                    (($scor2 $cpxy2 $complexityPenalty2 $uniformityPenalty2 $penalizedScore2)))
    
        (if (type-cast (isnan $penalizedScore) Bool &self)
            (not (type-cast (isnan $penalizedScore2) Bool &self))
            (or (< $penalizedScore $penalizedScore2) (and (== $penalizedScore $penalizedScore2) (> $cpxy $cpxy2)))))
            
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

(= (setUniPen (mkCscore $scor $cpxy $complexityPenalty $uniformityPenalty $penalizedScore) $newUniPen)
    (mkCscore $scor $cpxy $complexityPenalty $newUniPen $penalizedScore))
