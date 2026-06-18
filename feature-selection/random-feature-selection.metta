;; randomFeatureSelection (safe optimized version)
;; Purpose:
;;   Selects a random subset of feature indices from a table.
;;   Ensures exactly $targetSize features are selected (when possible).

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

(= (randomSelectHelper $numFeatures $count $selected)

   ;; Base case: required number of features already selected
   (if (== $count 0)
       $selected

       (chain
           (py-call (random.randint 0 (- $numFeatures 1)))
           $randomIdx
;; The above is referred from opencog/cogutil/random.h -> https://github.com/opencog/cogutil/blob/6b149c457c9cfbf5edccefb166a7a9a1d2d74196/opencog/util/random.h#L72C1-L72C6
           (if (once (is-member $randomIdx $selected))

               ;; Duplicate case: → retry without decrementing count
               (randomSelectHelper
                   $numFeatures
                   $count
                   $selected)
        ;;  this implementation actually slightly changes the the c++ implementation 
        ;; In the C++ Implementation if a duplicate feature is selected, the function ignores it but still decrements the $count. 
        ;; In our Implementation inorder to match the target size we will recursively call it with the same count
               ;; Unique case
               (randomSelectHelper
                   $numFeatures
                   (- $count 1)
                   (cons-atom $randomIdx $selected))))))
