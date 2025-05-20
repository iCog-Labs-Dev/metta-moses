;; The probability parameter p in the scoring represents the assumed probability that the model makes an error on any given data point.
;; If p is small (close to 0), it means the model is expected to be very accurate, making mistakes rarely.
;; If p is large (approaching 0.5), it means the model is expected to be less accurate, making mistakes more often (but still better than random guessing).

(: getCscore (-> (ITable $a) (Tree $a) Number Cscore))
(= (getCscore $itable $tree $p)
    (let $bs (scoreTree $itable $tree)
        (if-error $bs ;; return worst possible composite score
            (mkCscore (mkScoreT (pow-math 10 -308) (mkComplexity 0) (mkScoreT 0.0) (mkScoreT 0.0) (mkScoreT (pow-math 10 -308))))
            (let* (($bsum (sumBScore $bs))
                   ($cpxy (treeComplexity $tree))
                   ((mkScoreT $cCoef) (getComplexityCoef $tree $p)))

                   (updatePenalizedScore (mkCscore (mkScoreT $bsum) (mkComplexity $cpxy) (mkScoreT (* $cpxy $cCoef)) (mkScoreT 0.0) (mkScoreT (pow-math 10 -308)))  False)))))         

;; getComplexityCoef -- calcualtes the complexity coeffient of a tree                
(: getComplexityCoef (-> (Tree $a) Number ScoreT))
(= (getComplexityCoef $tree $p)
    (let $f (float (alphabetSize $tree))
        (mkScoreT (round (if (and (> $p 0) (< $p 0.5))
                                (* -1 (/ (log-math EXP $f) (log-math EXP (/ $p (- 1 $p)))))
                                0) 4))))            

;; updatePenalizedScore            
;; by default the worst possible score is set as the penalized score for a tree
;; there is a bool multiply_diversity parameter if set to true the penalized score has to be multiplied with the uniform penalty
;; if not the uniformity penalty is instead subtracted
;; the default thing is to set the parameter to False

(: updatePenalizedScore (-> Cscore Bool Cscore))
(= (updatePenalizedScore (mkCscore (mkScoreT $scor) (mkComplexity $cpxy) (mkScoreT $cpxyPenalty) (mkScoreT $uniformityPenalty) (mkScoreT $penalizedScore)) $multiplyDiversity)
    (let* (($temp (- $scor $cpxyPenalty))
           ($updatedPScore (if $multiplyDiversity (* $temp $uniformityPenalty) (- $temp $uniformityPenalty))))
        
            (mkCscore (mkScoreT $scor) (mkComplexity $cpxy) (mkScoreT $cpxyPenalty) (mkScoreT $uniformityPenalty) (mkScoreT $updatedPScore))))