;; select top features -- based on value of diversity pressure parameter
;;          $ft-set         -- feature set from feature selection algos
;;          $div-pres       -- diversity pressure parameter -- description in rankFtSet below
;;          $div-interaction-- diversity interaction parameter -- description in rankFtSet below
;;          $sim-scorer     -- ja or mi
;;          $ft-sets        -- pop of feature set oreded by raw score
;;NOTe -- this implementation requires the feature sets to come with their MI score
(= (selectTopFts (mkITable $table $labels) $div-pres $div-interaction $multi-diversity $sim-scorer $ft-sets $nDeme)
    (chain (size-atom $ft-sets) $fts-size 
        (chain (min-atom ($fts-size $nDeme)) $res-size 
            (if (> $div-pres 0)
                (let $ranked-set (rankFtSet (mkITable $table $labels) $div-pres $div-interaction $multi-diversity $sim-scorer $ft-sets ())
                    (eval (takeN $res-size $ranked-set)))
                (let $ft-sets-less-score (map-atom $ft-sets $ft-set (eval (second $ft-set))) (eval (takeN $res-size $ft-sets-less-score))))))) ;; strip the scores off the feature sets

;;  rankFtSet -- applies diversity pressure to rank feature sets 
;;          $div-pres           -- diversity pressure parameter higher value means similarity is less tolerated    
;;                              -- on the other hand smaller values means similar feature sets are tolerated -- the smaller the value gets it is the same as comparing feature sets by their raw score, MI value in this case
;;          $div-interaction    -- parameter dictating level of interaction on subset level for calculation MI between sets of features
;;          $multi-diversity    -- bool parameter used in penalized score updating -- if True the current penalized score is muliplied by uniformity penality for the final score
;;                              -- if False -- uniformity penality will be subtracted
;;          $sim-scorer         -- type of the similarity scorer used -- either jaccard index or mutual information between sets
;;          $ft-sets            -- pop of featuresets returned by the feature selection procedure
;;          $acc                -- empty accumulator ()
(= (rankFtSet (mkITable $table $labels) $div-pres $div-interaction $multi-diversity $sim-scorer $ft-sets $acc)
    ;; convert each feature set into composite scoreed set -- 
    (let $csc-ft-set 
        (map-atom $ft-sets $ft-set ((mkCscore (first-from-pair $ft-set) (let $set (second-from-pair $ft-set) (size-atom $set)) 0.0 0.0 (first-from-pair $ft-set)) (second-from-pair $ft-set)))
            (rankIterator (mkITable $table $labels) $div-pres $div-interaction $multi-diversity $sim-scorer $csc-ft-set $acc)))

(= (rankIterator (mkITable $table $labels) $div-pres $div-interaction $multi-diversity $sim-scorer $csc-ft-set $acc)
    (if (== $acc ())
        (rankIterator (mkITable $table $labels) $div-pres $div-interaction $multi-diversity $sim-scorer (cdr-atom $csc-ft-set) ((car-atom $csc-ft-set))) ;; add the first feature -- since this is the one with the best raw score
        (if (== $csc-ft-set ())
            (map-atom $acc $a (eval (second $a)))                                       ;; return only the indices -- drop the score values
            (let* (($current-ft-set (car-atom $csc-ft-set))                             ;; current feature set under consideration (score set) pair
                    ($current-cscore (first-from-pair $current-ft-set))                 ;; the score
                    ($current-ft (second-from-pair $current-ft-set))                    ;; the feature set, tuple of indices
                    ($last-ft-set (car-atom $acc))                                      ;; last added feature set -- ordered by score so the first one in the accumulator
                    ($last-cscore (first-from-pair $last-ft-set))                       ;; score of the last
                    ($last-ft (eval (second $last-ft-set)))                             ;; the feature set
                    ($sim (if (== $sim-scorer ja)                                       ;; assumes either of two similarity scorers jaccard or mi
                                (eval (jaccardIndex $last-ft $current-ft))         
                                (eval (mi $current-ft $last-ft $div-interaction (mkITable $table $labels)))))      ;; calculation of feature set similarity uisng mutual infomration between sets                             
                    ($last-dp (simToPen $sim $div-pres))                                ;; the latest diversity penality
                    ($current-unipen-score (eval (getUniPen $current-cscore)))  
                    ($agg-dp (max-atom ($last-dp $current-unipen-score)))
                    ($updated-uniPen-score (eval (setUniPen $current-cscore $agg-dp)))
                    ($updatd-pen-score (eval (updatePenalizedScore $updated-uniPen-score $multi-diversity)))
                    ($new-acc (eval (insertPair cScore>= ($updatd-pen-score $current-ft) $acc))))                   ;; ordered insertion using the composite score

                (rankIterator (mkITable $table $labels) $div-pres $div-interaction $multi-diversity $sim-scorer (cdr-atom $csc-ft-set) $new-acc)))))


;; simToPen similarity to penality                    
(= (simToPen $sim $div-pres) (* $sim $div-pres))

;; biased randbool
;;          $b -- float [0, 1]
;;          random-float doesnt work in mettalog -- using python binding instead
; ! (bind! randomFloat (py-atom random.random))
(= (biasedRandBool $b)
    (let $rnd (random-float 0 1) (> $b $rnd)))

;; sample_enforced_features -- hence the name XXX for future use
;; takes tuple of pairs containing feaures and probability values of being included in deme creation 
;; sth like this ((A 0.4) (B 0.3) (C 0.73) ...)

(= (sampleEnforcedFts $enforced-fts)
    (collapse (let $enforced-ft (superpose $enforced-fts)
            (let $p (second $enforced-ft) (if (biasedRandBool $p) (first $enforced-ft) (Empty))))))
