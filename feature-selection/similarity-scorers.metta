;; mutual information between feature sets -- makes use of the diversity interaction parameter, which dictates the amount of set to set interaction employed to calculate similarity of sets using average mutual inforamtion
;;      $set1 $set2         - the two sets -- set of integer indices 
;;      $div-interaction    -- level of of one two one interaction between subsets of the two sets 
;;                          -- -ve value means all interaction -- so make the calcualtions using the whole set
;;                          -- anything else requires computation of powerset(all possible subsets of a set) and finding the mutual information betweeen all the possible combinations in a nested loop simulated here with nested map-atom

(= (mi $set1 $set2 $div-interaction (mkITable $table $labels))
    (if (< $div-interaction 0)
            (mutualInformationBtwSets $set1 $set2 (mkITable $table $labels))
            (let* (($sss (+ $div-interaction 1))
                    (($ps1 $ps2) (map-atom ($set1 $set2) $set (eval (powerSet $set $sss True))))        ;; powersets of the two feature sets
                    (($ps1-size $ps2-size) ((size-atom $ps1) (size-atom $ps2)))                         ;; size of the power sets
                    ($all-comb-mi (map-atom $ps1 $ps-a (map-atom $ps2 $ps-b (mutualInformationBtwSets $ps-a $ps-b (mkITable $table $labels)))))                  ;; calculation of mutual information between all features sets in the powersets -- all combinations XXX -- i think the labels are not needed in the calculation
                    ($inner-sum (map-atom $all-comb-mi $mi (foldl + $mi 0)))                            ;; folding the resulting tuple of tuples of MI values into one tuple
                    ($total-mi (foldl-atom $inner-sum 0 $acc $x (+ $acc $x))))                          ;; final fold to get the sum MI
                    
                    (/ $total-mi (* $ps1-size $ps2-size)))))                                            ;; the final answer is an average value of the total MI 

;; mutualInformationBtwSets  -- calculates the MI between feature sets by using entropy values        
(= (mutualInformationBtwSets $set1 $set2 (mkITable $table $labels))
    (let* (($union (union-atom $set1 $set2))
            ($len (eval (List.length $table)))                                                                                   ;; total number of rows
            (($set1-zip $set2-zip $union-zip) (map-atom ($set1 $set2 $union) $set (eval (zipColumn $set $table)))) 
            (($zip1-count $zip2-count $union-count) (map-atom ($set1-zip $set2-zip $union-zip) $zip (eval (List.uniqueValuesCount $zip ()))))
            (($e1 $e2 $eu) (map-atom ($zip1-count $zip2-count $union-count) $count (eval (entropy $count $len 0)))))

            (- (+ $e1 $e2) $eu)))

;; jaccard_index 0 ≤ ji ≤ 1 -- simple measure of similarity -- ratio of size of intersection of two sets to that of their union's
; (: jaccardIndex (-> Expression Expression Number))
(= (jaccardIndex $s1 $s2)
	(let* (($comm (intersection-atom $s1 $s2))
			($uni (eval (union-atom-set $s1 $s2))))
		(/ (size-atom $comm) (size-atom $uni)))) 