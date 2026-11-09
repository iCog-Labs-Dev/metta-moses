;; select top features -- based on value of diversity pressure parameter
;;          $ftSet         -- feature set from feature selection algos
;;          $divPres       -- diversity pressure parameter -- description in rankFtSet below
;;          $divInteraction -- diversity interaction parameter -- description in rankFtSet below
;;          $simScorer     -- ja or mi
;;          $ftSets        -- pop of feature set ordered by raw score
;; Note -- this implementation requires the feature sets to come with their MI score
(= (selectTopFts (mkITable $table $labels) $divPres $divInteraction $multiDiversity $simScorer $ftSets $nDeme)
    (let* 
       (
         ($ftsSize (size-atom $ftSets))
         ($resSize (min-atom ($ftsSize $nDeme)))
         ($seed (py-call (random.randint 0 2147483647))) ;; As per the OpenCog classic this is how we sample a random seed for introducing randomness into lexicographic ordering of feature sets with the same score.
       )
       (if (> $divPres 0)
                (let $rankedSet (rankFtSet $seed (mkITable $table $labels) $divPres $divInteraction $multiDiversity $simScorer $ftSets ())
                    (List.takeN $resSize $rankedSet))
                (let $ftSetsLessScore (map-atom $ftSets $ftSet (second $ftSet)) (List.takeN $resSize $ftSetsLessScore))))   ;; strip the scores off the feature sets
)

;;  rankFtSet -- applies diversity pressure to rank feature sets 
;;          $seed               -- Random seed to use for the lexicographic ordering of numbers
;;          $divPres           -- diversity pressure parameter higher value means similarity is less tolerated    
;;                              -- on the other hand smaller values means similar feature sets are tolerated -- the smaller the value gets it is the same as comparing feature sets by their raw score, MI value in this case
;;          $divInteraction    -- parameter dictating level of interaction on subset level for calculation MI between sets of features
;;          $multiDiversity    -- bool parameter used in penalized score updating -- if True the current penalized score is multiplied by the uniformity penalty for the final score
;;                              -- if False -- the uniformity penalty will be subtracted
;;          $simScorer         -- type of the similarity scorer used -- either jaccard index or mutual information between sets
;;          $ftSets            -- pop of featuresets returned by the feature selection procedure
;;          $acc                -- empty accumulator ()
(= (rankFtSet $seed (mkITable $table $labels) $divPres $divInteraction $multiDiversity $simScorer $ftSets $acc)
    ;; convert each feature set into a composite scored set
    (let $cscFtSet 
        (map-atom $ftSets $ftSet
                  (let* ((($score $set) $ftSet)
                         ($size (size-atom $set)))
                    ((mkCscore $score $size 0.0 0.0 $score) $set)))
            (rankIterator $seed (mkITable $table $labels) $divPres $divInteraction $multiDiversity $simScorer $cscFtSet $acc)))

(= (rankIterator $seed (mkITable $table $labels) $divPres $divInteraction $multiDiversity $simScorer $cscFtSet $acc)
    (if (== $acc ())
        (rankIterator $seed (mkITable $table $labels) $divPres $divInteraction $multiDiversity $simScorer (cdr-atom $cscFtSet) ((car-atom $cscFtSet))) ;; add the first feature -- since this is the one with the best raw score
        (if (== $cscFtSet ())
            (map-atom $acc $a (second $a))                                       ;; return only the indices -- drop the score values
            (let* ( 
                    ;; current (score feature-set) pair under consideration
                    (($currentCscore $currentFt) (car-atom $cscFtSet))
                    ;; last added pair -- ordered by score so the first one in the accumulator
                    (($lastCscore $lastFt) (car-atom $acc))
                    ($sim (if (== $simScorer ja)                                       ;; assumes either of two similarity scorers jaccard or mi
                                (jaccardIndex $lastFt $currentFt)         
                                (mi $currentFt $lastFt $divInteraction (mkITable $table $labels))))      ;; feature set similarity using mutual information between sets                             

                    ($lastDp (simToPen $sim $divPres))                                ;; the latest diversity penalty
                    ($currentUnipenScore (getUniPen $currentCscore))  
                    ($aggDp (max-atom ($lastDp $currentUnipenScore)))
                    ($updatedUniPenScore (setUniPen $currentCscore $aggDp))
                    ($updatedPenScore (updatePenalizedScore $updatedUniPenScore $multiDiversity))
                    ($newAcc (eval (insertPair cScore>= (featureSet< $seed) ($updatedPenScore $currentFt) $acc)))
                    ) ;; ordered insertion using the composite score. The featureSet< function is curried with $seed

                (rankIterator $seed (mkITable $table $labels) $divPres $divInteraction $multiDiversity $simScorer (cdr-atom $cscFtSet) $newAcc)))))


;; simToPen similarity to penalty                    
(= (simToPen $sim $divPres) (* $sim $divPres))

;; biased randbool
;;          $b -- float [0, 1]
(= (biasedRandBool $b)
    (let $rnd (py-call (random.random))  (> $b $rnd)))

;; sample_enforced_features -- hence the name XXX for future use
;; takes tuple of pairs containing features and probability values of being included in deme creation 
;; sth like this ((A 0.4) (B 0.3) (C 0.73) ...)

(= (sampleEnforcedFts $enforcedFts)
    (collapse (let* (($enforcedFt (superpose $enforcedFts))
                     ($p (second $enforcedFt)))
                (if (biasedRandBool $p) (first $enforcedFt) (Empty)))))
