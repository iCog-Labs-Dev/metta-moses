;; this is implementation of stochastic max dependency feature selection algorithm
;; How it works
;;  0 --> vector<feature_set> tops = empty set
;;  1 --> For each feature_set fs in tops:
;;  2 -->     Add one feature, compute new score. Repeat 1
;;  3 --> Discard all but top_size of highest scorers
;;  4 --> tops = the highest scorers.
;;  5 --> If score hasn't improved by threshold,
;;    --> then skip next step.
;;  6 --> Repeat, until tops holds feature_sets of at most
;;    --> 'num_features' features.
;;  7 --> return highest scorer from tops.

;;  Parameters           
;;                  --   $th    minimum values improvement (in this case MI)                                                  
;;                  --   $numFeatures    desired number of features in the featuresets                                             
;;                  --   $scorer    scorer of importance, MI, Correlation ...?                                            
;;                  --   $acc    an accumulator for feature sets                                          
;; Steps
;;  get set of labels, or indices
;;  start from an empty feature set ()
;;  score each feature using mutual information and add them to the accumulator as (($feature) $score)
;;  keep only features that score above a certain threshold -- can be done non-deterministicly
;;  keep the feature set shuffled -- or pick from the labels with randomness 
;;  label indices will be used to form the set of features ... the final output will be tuple of tuples containing indices of columns selected

(= (stochasticMaxDependency $th $numFeatures $topsCount (mkITable $table $labels) $scorer $acc)
    (chain (List.length $labels) $len
    (chain (Table.getColumn (- $len 1) $table ) $oc ;; output column
    (chain (range 0 1 (- $len 1)) $indices          ;; input feature indices    
        (if (> $numFeatures (- $len 1))             ;; makes sure the desire number of features is not more than what is available
            (smdIterator $th (- $len 1) $topsCount $len $oc $indices (mkITable $table $labels) $scorer $acc)
            (smdIterator $th $numFeatures $topsCount $len $oc $indices (mkITable $table $labels) $scorer $acc))))))

(= (smdIterator $th $numFeatures $topsCount $len $oc $indices (mkITable $table $labels) $scorer $acc)
    (if (== $acc ())
        (chain 
            (collapse 
                (chain (superpose $indices) $i
                    (chain (mutualInformation (Table.getColumn $i $table) $oc) $mi
                                (chain (calculateConfidence (size-atom $indices) (ITable.rowCount $table) 50.0) $confi
                                        ((* $mi $confi) ($i))  
                                )
                    )
                )
             ) $indexMiPair
                        (if (== $indexMiPair ())
                            (Error $indexMiPair "No relevant feature found ... Exiting")              ;; No feature selected -- low MI values
                            ;; get each feature and and calculate MI against output feature
                            (chain (sortPairs pairMax $indexMiPair $topsCount ()) $topNSeed 
                                (smdIterator $th $numFeatures $topsCount $len $oc $indices (mkITable $table $labels) $scorer $topNSeed))))        
        (chain (second (car-atom $acc)) $sampleTuple 
            (if (== (size-atom $sampleTuple) $numFeatures)
                $acc                                 ;; return the score and feature indices pair
                (chain (first (car-atom $acc)) $prevHighestScore
                (chain 
                    (inputPairMiCalculator $table $oc $indices $acc) $res                                                       ;; collapsed result of pairing scoring
                    (chain (shuffle $res ()) $shuffledPairs 
                    (chain (sortPairs pairMax $shuffledPairs $topsCount ()) $topN
                    (chain (first (car-atom $topN)) $topScore                               ;; $topScore                  ;; shuffling to give pairs with equal scores better chance of being selected for variety
                    (if (< (- $topScore $prevHighestScore) $th)                           ;; terminate the loop if there is no significant improvement
                        $acc
                        (smdIterator $th $numFeatures $topsCount $len $oc $indices (mkITable $table $labels) $scorer $topN)))))))))))

(= (inputPairMiCalculator $table $oc $indices $acc) ;; adds a feature to the previous pair thus growing the index size and calculates the mutual information for that pair, triplet ... of input features
    (collapse 
        (chain (superpose $acc) $pair
            (chain (second $pair) $usedIndices
                    (chain (subtraction-atom $indices $usedIndices) $candidateIndices                   ;; removed used indices from index list
                        (chain (union-atom $usedIndices ((superpose $candidateIndices))) $newIndices   ;; form a union of used indices tuple and one unused index for each such an index
                            (chain (zipColumn $newIndices $table) $zippedInputFeature                  ;; form a zipped pair, triplet .. of input feature values from the table
                                (chain (mutualInformation $zippedInputFeature $oc) $mi
                                    (chain (calculateConfidence (size-atom $newIndices) (ITable.rowCount $table) 50.0) $confi
                                        ((* $mi $confi) $newIndices)    
                                    )
                                )
                            )
                        ))))))
