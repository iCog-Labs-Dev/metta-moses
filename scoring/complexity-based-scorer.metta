
;; Gives an instance a composite score. 
;; Params:
;;   $rep: The representation object
;;   $inst: The instance we want to evaluate
;;   $itable: The input table
;;   $complexityRatio: probability parameter
;; Returns:
;;   cScore: Composite score of the instance                      
;; Var-safe candidate memo. &treeSpace stores the GROUND preOrder form of the
;; reduced candidate ((lbl N) leaves) — Space retrieval copies terms, but a
;; copy of a ground term is identical, so nothing is lost. Hits relink each
;; index back to the original table var via ungroundKey (scoring/bscore.metta).
;; This restores the memoization that had to be removed from getCandidate
;; (whose var-carrying trees came back freshened) without the corruption.
(= (getCandidateCached $rep $id $inst (mkITable $tbl $labels))
   (chain (collapse (match &treeSpace ($id $inst $gt) $gt)) $hits
     (if (== $hits ())
         (let*
           (
             ($tree (getCandidate $rep $id $inst))
             ($ground (groundCacheKey (preOrder $tree) $labels))
             ($_ (add-atom &treeSpace ($id $inst $ground)))
           )
           $tree)
         (buildTree (ungroundKey (car-atom $hits) $labels)))))

; (: complexityBasedScorer (-> Representation Instance (ITable $a) Number Cscore))
(= (complexityBasedScorer $rep $id $inst $itable $complexityRatio)
  (let*
      (
        ;; ($_ (println! (Instance: $inst)))
        ;; ($_ (println! (GetCandidate $rep $id $inst)))
        ($tree (getCandidateCached $rep $id $inst $itable))
        ;; ($_ (println! (Tree: $tree)))
        ($score (getCscore $itable $tree $complexityRatio &bscoreCache))
        ;; ($_ (println! (Score: $score)))
      )
      $score))
