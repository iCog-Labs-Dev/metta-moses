;; Gives an instance a composite score. 
;; Params:
;;   $rep: The representation object
;;   $inst: The instance we want to evaluate
;;   $itable: The input table
;;   $complexityRatio: probability parameter
;; Returns:
;;   cScore: Composite score of the instance                      
(: complexityBasedScorer (-> Representation Instance (ITable $a) Number Cscore))
(= (complexityBasedScorer $rep $inst $itable $complexityRatio)
(chain (getCandidate $rep $inst) $tree (getCscore $itable $tree $complexityRatio)))

