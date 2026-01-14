;; Purpose: Randomly selects a set of unique feature indices from an input table.
;; Parameters:
;;   $itable (ITable)      → Input table containing data and labels.
;;   $targetSize (Number)  → Number of features to select.
;; Returns: (Expression)   → Expression containing the selected indices in the form (idx1 idx2 ...).
;; Example:
;;   Input:  !(randomFeatureSelection table1 3)
;;   Output: (2 0 1)   ; Selected indices may vary due to randomness.
; (: randomFeatureSelection (-> ITable Number Expression))
(= (randomFeatureSelection (mkITable $data $labels) $targetSize)
       (chain (- (eval (List.length $labels)) 1) $numFeatures
           (if (<= $targetSize 0)
               ((0 ()))
               (if (>= $targetSize $numFeatures)
                   ((0 (eval (range 0 1 $numFeatures))))
                   ((0 (randomSelectHelper $numFeatures $targetSize ())))
               )
           )
       )
)


;; Purpose: Randomly selects $count unique indices between 0 and $numFeatures-1.
;; Parameters:
;;   $numFeatures (Number) → Total number of available features.
;;   $count (Number)       → Number of features to select.
;;   $selected (Expression)→ Accumulator of already selected indices.
;; Returns: (Expression)   → Expression containing randomly selected indices.
;; Example:
;;   Input:  !(randomSelectHelper 5 2 ())
;;   Output: (4 1) ; Order and values will vary.
; (: randomSelectHelper (-> Number Number Expression Expression))
(= (randomSelectHelper $numFeatures $count $selected)
   (if (== $count 0)
       $selected
       (chain (py-call  (random.randint 0 (- $numFeatures 1))) $randomIdx
        ; the above is referred from opencog/cogutil/random.h -> https://github.com/opencog/cogutil/blob/6b149c457c9cfbf5edccefb166a7a9a1d2d74196/opencog/util/random.h#L72C1-L72C6
         (if (is-member $randomIdx $selected)
             (randomSelectHelper $numFeatures $count $selected)
             ;  this implementation actually slightly changes the the c++ implementation 
            ; In the C++ Implementation if a duplicate feature is selected, the function ignores it but still decrements the $count. 
            ; In our Implementation inorder to match the target size we will recursively call it with the same count
             (chain (cons-atom $randomIdx $selected) $newSelected
               (randomSelectHelper $numFeatures (- $count 1) $newSelected))
         )
       )
   )
)

