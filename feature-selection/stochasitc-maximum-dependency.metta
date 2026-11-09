;; --- Stochastic Maximum Dependency Feature Selection Algorithm ---
;; a feature selection method designed to find a set of features that maximizes the joint dependency (typically Mutual Information) with a target variable.
;; 1. Initialization
;;                Starting Point: The algorithm begins with an initial set of candidate feature sets (optionally provided by the user).
;;                Stochasticity: It shuffles the entire list of available features to explore different paths when multiple features offer similar information gains, preventing it from getting stuck in a single local optimum.
;; 2. The Iterative Expansion 
;;                The algorithm proceeds in steps, where each step increases the size of the feature sets by one:

;;                Expansion: For every feature set currently in the beam (the "tops"), the algorithm tries adding each available feature (one at a time) to create new candidate sets.
;;                Scoring: Each new candidate set is scored using a dependency metric (usually Mutual Information).
;;                Pruning (The Beam): All newly generated candidate sets are ranked by their scores. Only the top N sets (defined by the top-size parameter) are kept for the next iteration. This is the "beam" that carries forward.
;; 3. Termination Criteria
;;                The algorithm continues adding features until one of these conditions is met:

;;                Target Size Reached: The feature sets have reached the maximum number of features requested by the user.
;;                Diminishing Returns: The improvement in the highest score from the previous step is less than a specified threshold. If adding another feature doesn't significantly help, the search stops.
;;                Exhaustion: There are no more features left to add.
;; 4. Results
;;                The algorithm returns a population of ranked feature sets (the final beam). The first element is the highest-scoring set found, but the other sets in the population provide diverse alternatives that also have high dependency with the target.

;; --- Random Shuffling ---
;; random shuffling using random weight -- assign random weights to features and by sorting these random weights effectively shuffling feature order
(= (insert-weight $w $h ()) (cons (cons $w (cons $h ())) ()))
(= (insert-weight $w $h (cons $hwHead $t))
   (let (cons $hw $rest) $hwHead
        (if (< $w $hw)
            (cons (cons $w (cons $h ())) (cons $hwHead $t))
            (cons $hwHead (insert-weight $w $h $t)))))

(= (shuffle-with-weights ()) ())
(= (shuffle-with-weights (cons $h $t))
   (insert-weight (py-call (random.random)) $h (shuffle-with-weights $t)))

(= (strip-weights ()) ())
(= (strip-weights (cons $hwHead $t))
   (let (cons $w (cons $h ())) $hwHead
        (cons $h (strip-weights $t))))

(= (shuffle-list $list)
   (strip-weights (shuffle-with-weights $list)))

;; insert pair (score feature-set) into sorted ranks list up to max-size
(= (insert-rank-bounded $pair () $maxSize)
   (if (> $maxSize 0) (cons $pair ()) ()))
(= (insert-rank-bounded $pair (cons $headPair $t) $maxSize)
   (if (<= $maxSize 0)
       ()
       (let* (((cons $score (cons $fs ())) $pair)
              ((cons $hScore (cons $hFs ())) $headPair))
                 (if (== $fs $hFs)
                     (cons $headPair $t)
                     (if (> $score $hScore)
                         (let $nextMax (- $maxSize 1)
                              (cons $pair (take $nextMax (cons $headPair $t))))
                         (let $nextMax (- $maxSize 1)
                              (cons $headPair (insert-rank-bounded $pair $t $nextMax))))))))

(= (get-top-n () $ranks $n) $ranks)
(= (get-top-n (cons $pair $rest) $ranks $n)
    (get-top-n $rest (insert-rank-bounded $pair $ranks $n) $n))

;; insert feature into sorted list (keeps set sorted and unique)
(= (add-feature $f ()) (cons $f ()))
(= (add-feature $f (cons $h $t))
   (if (< $f $h)
       (cons $f (cons $h $t))
       (if (== $f $h)
           (cons $h $t)
           (cons $h (add-feature $f $t)))))

(= (expand-tops $Table $allFeatures $tops)
   (collapse (let* (((cons $score (cons $fs ())) (superpose $tops))
                    ($f (superpose $allFeatures)))
                 (if (List.contains $f $fs)
                     (empty)
                     (let* (($newFs (add-feature $f $fs))
                            ($newScore (cached-mi-score $Table $newFs)))
                       (cons $newScore (cons $newFs ())))))))
                                     
(= (smd-step $Table $allFeatures $numFeatures $threshold $topSize $currentI $previousHighScore $tops)
   (if (> $currentI $numFeatures)
       $tops
       (let* (($newCandidates (expand-tops $Table $allFeatures $tops))
              ($newTops (get-top-n $newCandidates () $topSize)))
             (if (== $newTops ())
                 $tops
                 (let* ((($highScore $ftre) (List.getByIdx $newTops 0))
                        ($improvement (- $highScore $previousHighScore)))
                           (if (< $improvement $threshold)
                               $newTops
                               (let $nextI (+ $currentI 1)
                                    (smd-step $Table $allFeatures $numFeatures $threshold $topSize $nextI $highScore $newTops))))))))


(= (smd-feature-selection $Table $targetSize $threshold $topSize $initFeatures)
   (if (<= $targetSize 0)
       (let $allFeatures (range 0 (get-target-col $Table))
            (cons (cons (mi-score $Table $allFeatures) (cons $allFeatures ())) ()))
       (let* (($allFeatures (range 0 (get-target-col $Table)))
              ($shuffledFeatures (shuffle-list $allFeatures))
              ($actualNumFeatures (min $targetSize (List.length $allFeatures)))
              ($initScore (cached-mi-score $Table $initFeatures))
              ($initTops (cons (cons $initScore (cons $initFeatures ())) ())))
             (if (<= $actualNumFeatures 0)
                 $initTops
                 (smd-step $Table $shuffledFeatures $actualNumFeatures $threshold $topSize (+ (size-atom $initFeatures) 1) $initScore $initTops)))))