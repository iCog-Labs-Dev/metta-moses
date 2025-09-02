;; the main feature selector procedure
;;      preprocess the exemplar 
;;                          -- gets column indices of features used in the exemplar
;;                          -- checks two parameteres
;;                                  1. increase target size of the feature selection by number of features in the examplar -- or just use exemplar features as seed
;;                                  2. or ignore the features in exemplar in the feature selection process
;;                          $targetSize -- the number of features sets to be returned
;;                          $increaseTargetSize -- bool -- to increase number of features in a feature set by the number of features already in the exemplar

; (: featureSelector (-> 
;                         Symbol
;                         (ITable $a)
;                         Number
;                         (Tree $a)
;                         Number
;                         Number
;                         Bool
;                         Expression
;                         Bool
;                         Number
;                         Bool
;                         Symbol
;                         Number
;                         Expression))
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
)
        (let* (($exemplar-fts (treeFtsIndices $exemplar $labels))       
                ($exemplar-fts-size (size-atom $exemplar-fts)) 
                ($init-ft-indices (map-atom $init-fts $ft (List.index $labels $ft)))                  ;; initial ft names changed into index values

                ($ft-set-pop (if $init-xmplr-fts                                                      ;; if the featue selection is to be initialized with exemplar features
                                (let* (($updated-init-fts (union-atom $init-fts $exemplar-fts))       ;; include exemplar featues in the init features list(tuple)
                                        ($updated-target-size (+ $target-size $exemplar-fts-size))    ;; target size also should be updated
                                        ($updated-init-fts (union-atom $init-ft-indices $exemplar-fts))) 

                                        (featureSelection $algo (mkITable $table $labels) $th $updated-target-size $updated-init-fts))     ;; do the feature selection using the new target-size
                
                                        (if $ignore-xmplr-fts                                                        ;; on the other hand, if we elect to ignore exemplar features 
                                            (let* ((mkITable $filtered-rows $filtered-labels) (filterTable $exemplar-fts (mkITable $table $labels))   ;; filter the table and pass only labels that don't include exemplar features
                                                   ($selected-ft-set (featureSelection $algo (mkITable $filtered-rows $filtered-labels) $th $target-size $init-ft-indices)))
                                                        (readjustIndices $selected-ft-set $filtered-labels $labels)) ;; here the returned index values refere to column indices in the filtetered table so some adjstment is needed to make up for any removed columns
                                            (featureSelection $algo (mkITable $table $labels) $th $target-size $init-ft-indices))))
                ($ft-set-pop-size (size-atom $ft-set-pop))                     
                ($capped-ft-set-pop (if (and (> $diversity-cap 0) (< $diversity-cap $ft-set-pop-size))                  ;; limmit the size of feature set pop to diversity cap value
                                        (takeN $diversity-cap $ft-set-pop)
                                        $ft-set-pop)))
                ;; -1 a default value divesity interaction used here meaning just use the top level sets without needing to calculate the powersets
                ;; 2 for divesity pressure -- just for testing good values should be verfied by more tests with larger data sets
                (selectTopFts (mkITable $table $labels) $div-pres -1 $multi-diversity $sim-scorer $capped-ft-set-pop $nDeme)))                   ;; select top features out of set of selected features after applying uniformity penality 

(= (featureSelection            ;; for sake of clarity I chose to list the parameteres top-down style
            $algo
            (mkITable $table $labels)
            $th                 ;; threshold for simle, smd ..
            $target-size        ;; desired number of features in a set   
            $init-fts           ;; indices of initial features -- ne
            ) 
	(case $algo
		((hc (hillclimbing ))
		 (rd (randomFeatureSelection (mkITable $table $labels) $num-desired))                                       
		 (sim (simpleFeatureSelector $th $target-size False (mkITable $table $labels) ()))                           ;; False -- default value for using exp distribution for selection of top N features -- and start with empty feature list as initial features -- th here refers to the minimum score required for feature set to be selected
		 (inc (incrementatl .. ))
		 (smd (if (== $init-fts ())
                (stochasticMaxDependency $th 3 $target-size (mkITable $table $labels) mi ())
                (let* (($len (List.length $labels))
                        ($oc (Table.getColumn (- $len 1) $table))      ;; output column to calculate MI for initial ft set
                        ($init-ft-zip (zipColumn $init-fts $table))     ;; 
                        ($mi (mutualInformation $init-ft-zip $oc)))
                        
                        (stochasticMaxDependency $th $target-size 3 (mkITable $table $labels) mi (($mi $init-fts))))))          ;; this `th` is a vlue used to check marginal score improvements as a features are added to the set. feature-count refers to the number of features in a single feature set
		))) 

