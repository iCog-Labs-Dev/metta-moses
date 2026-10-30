;; simpleFeatureSelector    -- simple feature selection algo
;;                          -- produces a singleton of sets selected using MI as the scorer
;; parameters 
;;          $numDesired                         -- number of desired features
;;          (mkITable $table $labels)           -- table as a tuple of list of data rows ($table) and labels ($labels)
;;          $th                                 -- minimum MI threshold value considered for selection
;;          $expDist                            -- bool value indicating whether exponential distn is preferred instead of sharp cut off selection
;;          $acc                                -- accumulator for selected features

(= (simpleFeatureSelector $th $numDesired $expDist (mkITable $table $labels) $acc)
    (if (== $numDesired 0)
        ((0 (List.listToExpr (inputLabels $labels))))                                                  ;; return all features by default

        (chain (py-call (random.randint 0 2147483647)) $seed                                        ;; random seed to break ties between equally-scored features
        (chain (List.length $labels) $colNum
            (chain (ITable.rowCount $table) $rowNum
                (chain (Table.getColumn (- $colNum 1) $table) $oc                                  ;; get the output column
                    (chain (selectorIterator $th $rowNum $oc $labels $table 0 $seed $acc) $selectedFeatures
                        (chain (if $expDist                                                                        ;; this is the actual selection after the scoring
                                    (chain (- 1 (/ 1 (+ $numDesired 1))) $mean                                      ;; if exponential distn is preferred 
                                        (exponentialSelection $mean $numDesired $selectedFeatures 1 ()))
                                    (takeN $numDesired $selectedFeatures)) $final ((0 (map-atom $final ($miScore ($feature)) $feature)))))))))))


;; selectorIterator
;;      $th                         -- threshold
;;      $rowNum                     -- total data rows count
;;      $oc                         -- output column
;;      $dataRows                   -- data rows
;;      (cons $label $labels)       -- list of labels (cons A (cons B ..))
;;      $counter                    -- feature index counter

(= (selectorIterator $th $rowNum $oc (cons $label $labels) $dataRows $counter $seed $acc)
    (if (= (cons $label $labels) (cons $label ()))                                     ;; this means we are at the output label
        $acc                                                                        ;; result -- pair of score and column index for consistent formatting across different feature selection algorithms
        (chain (Table.getColumn 0 $dataRows) $inputColumn
        (chain (Table.pop 0 $dataRows) $remTable                            ;; remove the first column -- better than carrying around the whole table
        (chain (mutualInformation $inputColumn $oc) $mi
            (chain (calculateConfidence (size-atom $inputColumn) $rowNum 50.0) $confidence
                (chain (* $mi $confidence) $actualScore
                    (if (>= $actualScore $th)
                        (chain (eval (insertPair > (featureSet< $seed) ($actualScore ($counter)) $acc)) $newAcc   ;; seeded tie-break for equal scores (matches selectTopFts / OpenCog)
                            (selectorIterator $th $rowNum $oc $labels $remTable (+ $counter 1) $seed $newAcc))
                        (selectorIterator $th $rowNum $oc $labels $remTable (+ $counter 1) $seed $acc)
                        ))))))))
