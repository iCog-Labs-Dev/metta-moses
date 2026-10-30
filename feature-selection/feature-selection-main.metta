;; the main feature selector procedure
;;      preprocess the exemplar 
;;                          -- gets column indices of features used in the exemplar
;;                          -- checks two parameters
;;                                  1. increase target size of the feature selection by number of features in the exemplar -- or just use exemplar features as seed
;;                                  2. or ignore the features in exemplar in the feature selection process
;;                          $targetSize -- the number of features sets to be returned
;;                          $increaseTargetSize -- bool -- to increase number of features in a feature set by the number of features already in the exemplar

;; (: featureSelector (->  Symbol (ITable $a) Number (Tree $a) Number Number Bool Expression Bool Number Bool Symbol Number Symbol Expression))
(= (featureSelector 
            $algo               ;; feature selection algo one of the following symbols hc, rnd, sim, inc, smd for hillclimbing, random, simple, incremental and stochasticMaxDependency selection algos
            (mkITable $table $labels)   ;; the table
            $th                 ;; score threshold (MI for instance)
            $exemplar           ;; the exemplar tree
            $diversityCap      ;; cap on population of feature sets
            $targetSize        ;; number of features in a feature set
            $initXmplrFts     ;; bool to determine to use exemplar features as initial features or not
            $initFts           ;; initial features specified list of symbols -- column labels
            $ignoreXmplrFts   ;; bool dictating whether to/not ignore exemplar features in feature selection
            $divPres           ;; diversity pressure -- see rankFtSet
            $multiDiversity    ;; multiply diversity -- used when updating the penalized score
            $simScorer         ;; feature set similarity scorer either mi or ja for jaccard
            $nDeme              ;; number of demes to spawn
            $scorerType         ;; Type of score needed for hillClimbing feature selection it might be mutualInformation or precision_bscore
)
        (let* (
                ;; ($_ (println! (debug Inside Feature Selection Main)))
                ($exemplarFts (treeFtsIndices $exemplar $labels))       
                ;; ($_ (println! (after treeFtsIndices)))

                 ($exemplarFtsSize (size-atom $exemplarFts)) 
                 ($initFtIndices (map-atom $initFts $ft (List.index $labels $ft)))                  ;; initial ft names changed into index values

                 ($ftSetPop (if $initXmplrFts                                                      ;; if the feature selection is to be initialized with exemplar features
                                (let* (
                                        ($updatedTargetSize (+ $targetSize $exemplarFtsSize))    ;; target size also should be updated
                                        ($updatedInitFts (union-atom $initFtIndices $exemplarFts))
                                      )

                                      (featureSelection $algo (mkITable $table $labels) $th $updatedTargetSize $updatedInitFts $scorerType)
                                )     ;; do the feature selection using the new target-size

                                (if $ignoreXmplrFts                                                        ;; on the other hand, if we elect to ignore exemplar features 
                                    (let* (
                                            ((mkITable $filteredRows $filteredLabels) (filterTable $exemplarFts (mkITable $table $labels)))   ;; filter the table and pass only labels that don't include exemplar features
                                            ($selectedFtSet (featureSelection $algo (mkITable $filteredRows $filteredLabels) $th $targetSize $initFtIndices $scorerType))
                                          )
                                          (readjustIndices $selectedFtSet $filteredLabels $labels)
                                    ) ;; here the returned index values refer to column indices in the filtered table so some adjustment is needed to make up for any removed columns
                                    (featureSelection $algo (mkITable $table $labels) $th $targetSize $initFtIndices $scorerType))))

                ($ftSetPopSize (size-atom $ftSetPop))                     
                ($cappedFtSetPop (if (and (> $diversityCap 0) (< $diversityCap $ftSetPopSize))                  ;; limit the size of feature set pop to diversity cap value
                                        (List.takeN $diversityCap $ftSetPop)
                                        $ftSetPop))
                ;; ($_ (println! (Selected features set pop $cappedFtSetPop)))
                ;; ($_ (println! (quote (selectTopFts (mkITable $table $labels) $divPres -1 $multiDiversity $simScorer $cappedFtSetPop $nDeme))))
                )
                (selectTopFts (mkITable $table $labels) $divPres -1 $multiDiversity $simScorer $cappedFtSetPop $nDeme)
        )
)                                                              
                                                                                                                                
(= (featureSelection
            $algo
            (mkITable $table $labels)
            $th                 ;; threshold for simple, smd ..
            $targetSize        ;; desired number of features in a set   
            $initFts           ;; indices of initial features
            $scorerType         ;; can be MI or precision_bscore
            ) 
	(case $algo
		((hc (let $initInstance (indicesToBits $initFts (- (List.length $labels) 1))     ;; seed the search with the initial features, all zeros when none are given
		                      (hcFtSetPop (mkITable $table $labels) $initInstance $scorerType (defaultFsHyperparams))))

		 (rd (randomFeatureSelection (mkITable $table $labels) $targetSize))                                       
		 (sim (simpleFeatureSelector $th $targetSize False (mkITable $table $labels) ()))                           ;; False -- default value for using exp distribution for selection of top N features -- and start with empty feature list as initial features -- th here refers to the minimum score required for feature set to be selected
		 (inc (incremental-feature-selection (mkITable $table $labels) $th $targetSize -1 1 0.01))                                 
		 (smd (smd-feature-selection (mkITable $table $labels) $targetSize $th 3 $initFts)))))                   ;; 3 -- as a default for count of top feature sets
