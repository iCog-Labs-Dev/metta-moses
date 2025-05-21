;; The probability parameter p in the scoring represents the assumed probability that the model makes an error on any given data point.
;; If p is small (close to 0), it means the model is expected to be very accurate, making mistakes rarely.
;; If p is large (approaching 0.5), it means the model is expected to be less accurate, making mistakes more often (but still better than random guessing).

(: getCscore (-> (ITable $a) (Tree $a) Number Cscore))
(= (getCscore $itable $tree $complexityRatio)
    (let $bs (scoreTree $itable $tree)
        (if-error $bs ;; return worst possible composite score
            (worstCscore)
            (let* (($bsum (sumBScore $bs))
                   ($cpxy (treeComplexity $tree))
                   ($cCoef (getComplexityCoef $complexityRatio)))

                   (updatePenalizedScore (mkCscore $bsum $cpxy (* $cpxy $cCoef) 0.0 (pow-math 10 -308))  False)))))         

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
           ($updatedPScore (if $multiplyDiversity (* $temp $uniformityPenalty) (- $temp $uniformityPenalty))))
        
            (mkCscore $scor $cpxy $cpxyPenalty $uniformityPenalty $updatedPScore)))

;; worstCscore
(: worstCscore (-> Cscore))
(= (worstCscore)
    (mkCscore (pow-math 10 -308)  0 0.0 0.0 (pow-math 10 -308)))            
