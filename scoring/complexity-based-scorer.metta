
;; Gives an instance a composite score. 
;; Params:
;;   $rep: The representation object
;;   $inst: The instance we want to evaluate
;;   $itable: The input table
;;   $complexityRatio: probability parameter
;; Returns:
;;   cScore: Composite score of the instance                      
; (: complexityBasedScorer (-> Representation Instance (ITable $a) Number Cscore))
(= (complexityBasedScorer $rep $id $inst $itable $complexityRatio)
  (let*
      (
        ;; ($_ (println! (Instance: $inst)))
        ;; ($_ (println! (GetCandidate $rep $id $inst)))
        ($tree (getCandidate $rep $id $inst))
        ;; ($_ (println! (Tree: $tree)))
        ($score (getCscore $itable $tree $complexityRatio &bscoreCache))
        ;; ($_ (println! (Score: $score)))
      )
      $score))
