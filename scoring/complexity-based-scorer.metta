
;; Gives an instance a composite score. 
;; Params:
;;   $rep: The representation object
;;   $id: The deme id (the key of the candidate tree cache)
;;   $inst: The instance we want to evaluate
;;   $itable: The input table
;;   $complexityRatio: The complexity ratio (see getComplexityCoef)
;; Returns:
;;   cScore: Composite score of the instance                      
;; (: complexityBasedScorer (-> Representation DemeId Instance (ITable $a) Number Cscore))
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
