;; simpleFeatureSelector    -- simple feature selection algo
;;                          -- producse singletone of sets selected using MI as the scorer
;; parameters 
;;          $numDesired                         -- number of desired features
;;          (mkITable $table $labels)           -- table as a tuple of list of data rows ($table) and labels ($labels)
;;          $th                                 -- minimum MI threshold value considered for selection
;;          $expDist                            -- bool value indicating wehter exponential distn is preferred instead of sharp cut off selection
;;          $acc                                -- accumulator for selected features

(= (simpleFeatureSelector $th $numDesired $expDist (mkITable $table $labels) $acc)
    (if (== $numDesired 0)
        ((0 (List.listToExpr (inputLables $labels))))                                                  ;; return all features by default
        (chain (List.length $labels) $colNum
            (chain (List.length $table) $rowNum
                (chain (Table.getColumn (- $colNum 1) $table) $oc                                  ;; get the output column
                    (chain (selectorIterator $th $rowNum $oc $labels $table 0 $acc) $selected-features  ;; the output format might need to change into sth like ((1) (2) (3) (4))
                        (chain (if $expDist                                                                        ;; this is the actual selection after the scoring
                                    (chain (- 1 (/ 1 (+ $numDesired 1))) $mean                                      ;; if exponential distn is preferred 
                                        (exponentialSelection $mean $numDesired $selected-features 1 ()))
                                    (takeN $numDesired $selected-features)) $final ((0 (map-atom $final ($mi-score ($feature)) $feature))))))))))


;; selectorIterator
;;      $th                         -- threshold
;;      $rowNum                     -- total data rows count
;;      $oc                         -- output column
;;      $dataRows                   -- data rows
;;      (cons $label $labels)       -- list of lables (cons A (cons B ..))
;;      $counter                    -- feature index counter

(= (selectorIterator $th $rowNum $oc (cons $label $labels) $dataRows $counter $acc)
    (if (= (cons $label $labels) (cons $label ()))                                     ;; this means we are at the output label
        $acc                                                                        ;; result -- pair of score and column index for consistent formatting across different feature selection algorithms
        (chain (Table.getColumn 0 $dataRows) $if
        (chain (Table.pop 0 $dataRows) $rem-table                            ;; remove the first column -- better than carrying around the whole table
        (chain (mutualInformation $if $oc) $mi      
            (chain (calculateConfidence (size-atom $if) (List.length $dataRows) 50.0) $confidence
                (chain (* $mi $confidence) $actualScore
                    (if (>= $actualScore $th)
                        (chain (insertPair > ($actualScore ($counter)) $acc) $new-acc
                            (selectorIterator $th $rowNum $oc $labels $rem-table (+ $counter 1) $new-acc))
                        (selectorIterator $th $rowNum $oc $labels $rem-table (+ $counter 1) $acc)
                        ))))))))
