;; the main feature selector procedure
;;      preprocess the exemplar 
;;                          -- gets column indices of features used in the exemplar
;;                          -- checks two parameteres
;;                                  1. increase target size of the feature selection by number of features in the examplar -- or just use exemplar features as seed
;;                                  2. or ignore the features in exemplar in the feature selection process
;;                          $targetSize -- the number of features sets to be returned
;;                          $increaseTargetSize -- bool -- to increase number of features in a feature set by the number of features already in the exemplar

;; (: featureSelector (->  Symbol (ITable $a) Number (Tree $a) Number Number Bool Expression Bool Number Bool Symbol Number Symbol Expression))
(= (featureSelector 
            $algo               ;; feature selection algo one of the following symbols hc, rnd, sim, inc, smd for hillclimbing, random, simple, incremental and stochasticMaxDependency selection algos
            (mkITable $table $labels)   ;; the table
            $th                 ;; score threshold (MI for instance)
            $exemplar           ;; the exemplar tree
            $diversity-cap      ;; cap on population of feature sets
            $target-size        ;; number of features in a feature set
            $init-xmplr-fts     ;; bool to determine to use exemplar features as initial features or not
            $init-fts           ;; initial features specified list of symbols -- column labels
            $ignore-xmplr-fts   ;; bool dictating whether to/not ignore exemplar features in feature selection
            $div-pres           ;; diversity pressure -- XXX more explanation 
            $multi-diversity    ;; multiply diversity -- used when updating the penalized score
            $sim-scorer         ;; feature set similarity scorer either mi or ja for jaccard
            $nDeme              ;; number of demes to spawn
            $scorerType         ;; Type of score needed for hillClimbing feature selection it might be mutualInformation or precision_bscore
)
        (let* (
                ;; ($_ (println! (debug Inside Feature Selection Main)))
                ($exemplar-fts (treeFtsIndices $exemplar $labels))       
                ;; ($_ (println! (after treeFtsIndices)))

                 ($exemplar-fts-size (size-atom $exemplar-fts)) 
                 ($init-ft-indices (map-atom $init-fts $ft (List.index $labels $ft)))                  ;; initial ft names changed into index values

                 ($ft-set-pop (if $init-xmplr-fts                                                      ;; if the featue selection is to be initialized with exemplar features
                                (let* (
                                        ($updated-target-size (+ $target-size $exemplar-fts-size))    ;; target size also should be updated
                                        ($updated-init-fts (union-atom $init-ft-indices $exemplar-fts))
                                      )

                                      (featureSelection $algo (mkITable $table $labels) $th $updated-target-size $updated-init-fts $scorerType)
                                )     ;; do the feature selection using the new target-size

                                (if $ignore-xmplr-fts                                                        ;; on the other hand, if we elect to ignore exemplar features 
                                    (let* (
                                            ((mkITable $filtered-rows $filtered-labels) (filterTable $exemplar-fts (mkITable $table $labels)))   ;; filter the table and pass only labels that don't include exemplar features
                                            ($selected-ft-set (featureSelection $algo (mkITable $filtered-rows $filtered-labels) $th $target-size $init-ft-indices $scorerType))
                                          )
                                          (readjustIndices $selected-ft-set $filtered-labels $labels)
                                    ) ;; here the returned index values refere to column indices in the filtetered table so some adjstment is needed to make up for any removed columns
                                    (featureSelection $algo (mkITable $table $labels) $th $target-size $init-ft-indices $scorerType))))

                ($ft-set-pop-size (size-atom $ft-set-pop))                     
                ($capped-ft-set-pop (if (and (> $diversity-cap 0) (< $diversity-cap $ft-set-pop-size))                  ;; limmit the size of feature set pop to diversity cap value
                                        (takeN $diversity-cap $ft-set-pop)
                                        $ft-set-pop))
                ; ($_ (println! (Selected features set pop $capped-ft-set-pop)))
                ;; ($_ (println! (quote (selectTopFts (mkITable $table $labels) $div-pres -1 $multi-diversity $sim-scorer $capped-ft-set-pop $nDeme))))
                )
                (selectTopFts (mkITable $table $labels) $div-pres -1 $multi-diversity $sim-scorer $capped-ft-set-pop $nDeme)
        )
)                                                              
                                                                                                                                
(= (featureSelection            ;; for sake of clarity I chose to list the parameteres top-down style
            $algo
            (mkITable $table $labels)
            $th                 ;; threshold for simle, smd ..
            $target-size        ;; desired number of features in a set   
            $init-fts           ;; indices of initial features -- ne
            $scorerType         ;; can MI or precision_bscore
            ) 
	(case $algo
		((hc (let $init-instance (indicesToBits $init-fts (- (List.length $labels) 1))     ;; seed the search with the initial features, all zeros when none are given
		                      (hcFtSetPop (mkITable $table $labels) $init-instance $scorerType (defaultFsHyperparams))))

		 (rd (randomFeatureSelection (mkITable $table $labels) $target-size))                                       
		 (sim (simpleFeatureSelector $th $target-size False (mkITable $table $labels) ()))                           ;; False -- default value for using exp distribution for selection of top N features -- and start with empty feature list as initial features -- th here refers to the minimum score required for feature set to be selected
		 (inc (incremental-feature-selection (mkITable $table $labels) $th $target-size -1 1 0.01))                                 
		 (smd (smd-feature-selection (mkITable $table $labels) $target-size $th 3 $init-fts)))))                   ;; 3 -- as a default for count of top feature sets
