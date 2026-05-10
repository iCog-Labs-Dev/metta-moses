;; randomFeatureSelection -- Optimized random feature selection algorithm

;; Purpose: Randomly selects a set of unique feature indices from an input table.
;;          Optimized over the original by replacing 'chain' with 'let' for eager
;;          evaluation of $numFeatures, reducing interpreter overhead and improving
;;          execution stability.
;;
;; How it works:
;;   1. Compute $numFeatures = total columns - 1 (excluding the output column).
;;   2. If $targetSize <= 0, return empty selection (default: no features).
;;   3. If $targetSize >= $numFeatures, return all feature indices (range 0..numFeatures).
;;   4. Otherwise, delegate to randomSelectHelper to randomly pick $targetSize unique indices.
;;
;; Parameters:
;;   $data        → Raw table data (list of rows).
;;   $labels      → Column labels including the output label.
;;   $targetSize  → Number of features to randomly select.
;;
;; Returns: ((0 (idx1 idx2 ...))) — selected indices wrapped in standard scorer format.
;;
;; Example:
;;   Input:  !(randomFeatureSelection (mkITable myTable myLabels) 3)
;;   Output: ((0 (2 0 4)))   ; indices vary due to randomness
;;
;; Optimization note:
;;   Original used 'chain' to bind $numFeatures, which defers evaluation.
;;   This version uses 'let' for strict/eager binding, reducing overhead.
; (: randomFeatureSelection (-> ITable Number Expression))
(= (randomFeatureSelection (mkITable $data $labels) $targetSize)
   (let $numFeatures (- (List.length $labels) 1)   ;; eagerly bind number of input features
     (if (<= $targetSize 0)
         ((0 ()))                                   ;; no features requested → empty selection
         (if (>= $targetSize $numFeatures)
             ((0 (range 0 1 $numFeatures)))         ;; request exceeds available → return all
             ((0 (randomSelectHelper $numFeatures $targetSize ())))  ;; random subset selection
         ))))


;; randomSelectHelper -- Optimized unique random index sampler

;; Purpose: Recursively and randomly selects $count unique indices in [0, $numFeatures-1].
;;          Optimized over the original by:
;;            1. Replacing 'chain' with 'let' for eager evaluation of $randomIdx.
;;            2. Inlining 'cons-atom' directly into the recursive call, eliminating
;;               the intermediate $newSelected binding and its associated 'chain' overhead.
;;
;; How it works:
;;   1. Base case: if $count == 0, return the accumulated $selected indices.
;;   2. Generate a random index $randomIdx in [0, $numFeatures-1] via Python's random.randint.
;;   3. If $randomIdx is already in $selected (duplicate), retry with the same $count.
;;      Note: unlike the C++ reference implementation (opencog/cogutil/random.h), which
;;      decrements $count even on duplicates, this implementation retries to guarantee
;;      exactly $targetSize unique features are selected.
;;      Ref: https://github.com/opencog/cogutil/blob/6b149c457c9cfbf5edccefb166a7a9a1d2d74196/opencog/util/random.h#L72
;;   4. If $randomIdx is unique, prepend it to $selected and recurse with $count - 1.
;;
;; Parameters:
;;   $numFeatures → Total number of available feature indices (max index = $numFeatures - 1).
;;   $count       → Number of unique indices still needed.
;;   $selected    → Accumulator of already selected indices (starts as ()).
;;
;; Returns: (Expression) → Randomly selected unique indices as a MeTTa expression.
;;
;; Example:
;;   Input:  !(randomSelectHelper 5 2 ())
;;   Output: (4 1)   ; order and values vary
;;
;; Optimization note:
;;   Original used nested 'chain' calls to bind $randomIdx and $newSelected separately.
;;   This version uses 'let' for $randomIdx and inlines cons-atom into the recursive call,
;;   eliminating one chain step per iteration — measurably faster on repeated calls.
; (: randomSelectHelper (-> Number Number Expression Expression))
(= (randomSelectHelper $numFeatures $count $selected)
   (if (== $count 0)
       $selected                                              ;; base case: all indices collected
       (let $randomIdx (py-call (random.randint 0 (- $numFeatures 1)))  ;; eagerly pick random index
         (if (is-member $randomIdx $selected)
             (randomSelectHelper $numFeatures $count $selected)          ;; duplicate → retry
             (randomSelectHelper $numFeatures                            ;; unique → add and continue
                                 (- $count 1)
                                 (cons-atom $randomIdx $selected))))))   ;; inline cons, no intermediate binding