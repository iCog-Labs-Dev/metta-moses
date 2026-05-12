;; randomFeatureSelection (safe optimized version)
;; Purpose:
;;   Selects a random subset of feature indices from a table.
;;   Ensures exactly $targetSize features are selected (when possible).
;;
;; Optimization notes:
;;   - Replaced deep nesting of `chain` with `let`
;;   - Improved readability and reduced evaluation overhead
;;   - No change in selection logic or output behavior
;;   - Maintains identical fallback behavior as original version

(= (randomFeatureSelection (mkITable $data $labels) $targetSize)
   (let $numFeatures (- (List.length $labels) 1)

      ;; Case 1: invalid or zero request → return empty selection
      (if (<= $targetSize 0)
          ((0 ()))

          ;; Case 2: request exceeds available features → return full range
          (if (>= $targetSize $numFeatures)
              ((0 (range 0 1 $numFeatures)))

              ;; Case 3: perform randomized selection
              ((0
                 (randomSelectHelper
                     $numFeatures
                     $targetSize
                     ())))))))


;; randomSelectHelper (safe optimized version)
;; Purpose:
;;   Recursively builds a list of unique random feature indices.
;;   Ensures no duplicates are included in the final selection.
;;
;; Parameters:
;;   $numFeatures → upper bound of index range
;;   $count       → how many more features must be selected
;;   $selected    → accumulator of already selected indices
;;
;; Optimization notes:
;;   - Removed unnecessary nesting to reduce evaluation depth
;;   - Kept strict same recursion semantics (CRITICAL for correctness)
;;   - Preserved retry behavior for duplicate indices
;;   - Avoided changing C++-equivalent stochastic behavior
;;   - Only structural simplification for performance/readability

(= (randomSelectHelper $numFeatures $count $selected)

   ;; Base case: required number of features already selected
   (if (== $count 0)
       $selected

       ;; Recursive case: generate a new random candidate index
       (chain
           (py-call (random.randint 0 (- $numFeatures 1)))
           $randomIdx

           ;; Check if index already exists in selection
           (if (is-member $randomIdx $selected)

               ;; Duplicate case:
               ;; Optimization rule: preserve original behavior exactly
               ;; → retry without decrementing count
               (randomSelectHelper
                   $numFeatures
                   $count
                   $selected)

               ;; Unique case:
               ;; Add index and reduce remaining required count
               (randomSelectHelper
                   $numFeatures
                   (- $count 1)
                   (cons-atom $randomIdx $selected))))))