;; this is implementation of stochastic max dependency feature selection algorithm
;; How it works
;  0 --> vector<feature_set> tops = empty set
;  1 --> For each feature_set fs in tops:
;  2 -->     Add one feature, compute new score. Repeat 1
;  3 --> Discard all but top_size of highest scorers
;  4 --> tops = the highest scorers.
;  5 --> If score hasn't improved by threshold,
;    --> then skip next step.
;  6 --> Repeat, until tops holds feature_sets of at most
;    --> 'num_features' features.
;  7 --> return highest scorer from tops.
;; it appears as though this is built on top of the simple algorithm? .... doesnt it? 

;;  Prametres           
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
    (chain (eval (List.length $labels)) $len
    (chain (eval (Table.getColumn (- $len 1) $table )) $oc ;; output column
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
                                (chain (calculateConfidence (size-atom $indices) (eval (List.length $table)) 50.0) $confi 
                                        ((* $mi $confi) ($i))  
                                )
                    )
                )
             ) $index-mi-pair
                        (if (== $index-mi-pair ())
                            (Error $index-mi-pair "No relevant feature found ... Exiting")              ;; No feature selected -- low MI values
                            ;; get each feature and and calculate MI against output feature
                            (chain (sortPairs pairMax $index-mi-pair $topsCount ()) $topNSeed 
                                (smdIterator $th $numFeatures $topsCount $len $oc $indices (mkITable $table $labels) $scorer $topNSeed))))        
        (chain (eval (second (car-atom $acc))) $sample-tuple 
            (if (== (size-atom $sample-tuple) $numFeatures)
                $acc                                 ;; return the score and feature indices pair
                (chain (eval (first (car-atom $acc))) $prev-highest-score
                (chain 
                    (inputPairMiCalculator $table $oc $indices $acc) $res                                                       ;; collapsed result of pairing scoring
                    (chain (shuffle $res ()) $shuffled-pairs 
                    (chain (sortPairs pairMax $shuffled-pairs $topsCount ()) $topN
                    (chain (eval (first (car-atom $topN))) $topScore                               ;; $topScore                  ;; shuffling to give pairs with equal scores better chance of being selected for variety
                    (if (< (- $topScore $prev-highest-score) $th)                           ;; terminate the loop if there is no significant improvement
                        $acc
                        (smdIterator $th $numFeatures $topsCount $len $oc $indices (mkITable $table $labels) $scorer $topN)))))))))))

(= (inputPairMiCalculator $table $oc $indices $acc) ;; adds a feature to the previous pair thus growing the index size and calculates the mutual information for that pair, triplet ... of input features
    (collapse 
        (chain (superpose $acc) $pair
            (chain (eval (second $pair)) $used-indices
                    (chain (subtraction-atom $indices $used-indices) $candidate-indices                   ;; removed used indices from index list
                        (chain (union-atom $used-indices ((superpose $candidate-indices))) $new-indices   ;; form a union of used indices tuple and one unused index for each such an index
                            (chain (zipColumn $new-indices $table) $zipped-input-feature                  ;; form a zipped pair, triplet .. of input feature values from the table
                                (chain (mutualInformation $zipped-input-feature $oc) $mi
                                    (chain (calculateConfidence (size-atom $new-indices) (eval (List.length $table)) 50.0) $confi 
                                        ((* $mi $confi) $new-indices)    
                                    )
                                )
                            )
                        ))))))
