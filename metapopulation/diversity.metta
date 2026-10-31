;; ============================================================
;;  metta-moses Diversity & Uniformity Penalty Module
;;
;;  This module implements behavioral diversity preservation in
;;  the MOSES metapopulation pipeline. By penalizing candidates
;;  whose evaluation behavior is redundant with already selected
;;  exemplars, it maintains distinct behavioral niches, prevents
;;  premature convergence on single local optima, and ensures that
;;  parallel evolutionary lineages explore varied solution spaces.
;;
;;  Organization:
;;    1. Behavioral Distance Metrics [Lp, Tanimoto, Angular]
;;    2. Distance-to-Penalty Converters & Aggregation
;;    3. Diversity Pressure Autoscaling
;;    4. Symmetric Pairwise Distance Cache & Selective Eviction
;;    5. Greedy Diversification Engine
;;    6. Runtime Inspection & Logging
;; ============================================================

;; ============================================================
;;  1. Behavioral Distance Metrics
;;
;;  Note: The specific vector distance implementations below
;;  [p-norm, Tanimoto, and angular distance] are ported from
;;  OpenCog's utility library [numeric.h], which is referenced
;;  and utilized by the official C++ MOSES repository:
;;  https://github.com/opencog/cogutil/blob/master/opencog/util/numeric.h
;;
;;  MOSES supports three distinct behavioral distance metrics.
;;  Each captures similarity from a different biological and
;;  geometric perspective:
;;
;;  1. Lp Norm [p_norm]:
;;     Measures coordinate-wise distance across behavioral vectors.
;;     Applicable to standard regression or classification error
;;     vectors where direct pointwise differences matter.
;;     - p = 1 [Manhattan]: sum of absolute differences.
;;     - p = 2 [Euclidean]: root of sum of squared differences.
;;     - p <= 0 [Chebyshev]: maximum absolute difference.
;;     - general p > 0: Minkowski p-norm.
;;
;;  2. Tanimoto Distance [tanimoto]:
;;     Measures the ratio of shared feature overlap to the total
;;     feature union.
;;     Applicable to high-dimensional, sparse, or binary boolean
;;     profiles where the mutual presence of activations is more
;;     informative than Euclidean distances.
;;
;;  3. Angular Distance [angular]:
;;     Measures directional similarity via the cosine angle.
;;     Applicable when the relative pattern or profile shape matters
;;     more than absolute magnitude. Two behaviors pointing in the
;;     same direction have 0 angular distance even if their scales
;;     differ significantly.
;; ============================================================

;; -------- 1a. Lp Norm Distance --------

;; Manhattan distance accumulator (p = 1): L1 = sum(|u_i - v_i|)
;; Inputs: Vectors $u, $v (List Number), Accumulator $acc (Number)
;; Output: Number (L1 distance)
(= (pNormManhattan () () $acc) $acc)
(= (pNormManhattan (cons $u $us) (cons $v $vs) $acc)
   (let $diff (abs-math (- $u $v))
      (pNormManhattan $us $vs (+ $acc $diff))))

;; Euclidean distance accumulator (p = 2): L2 = sqrt(sum((u_i - v_i)^2))
;; Inputs: Vectors $u, $v (List Number), Accumulator $acc (Number)
;; Output: Number (L2 distance)
(= (pNormEuclidean () () $acc) (sqrt-math $acc))
(= (pNormEuclidean (cons $u $us) (cons $v $vs) $acc)
   (let* (($diff (- $u $v))
          ($sq (* $diff $diff)))
      (pNormEuclidean $us $vs (+ $acc $sq))))

;; Chebyshev / maximum difference accumulator (p <= 0): L_infinity = max(|u_i - v_i|)
;; Inputs: Vectors $u, $v (List Number), Current max difference $maxDiff (Number)
;; Output: Number (L_infinity distance)
(= (pNormChebyshev () () $maxDiff) (+ 0.0 $maxDiff))
(= (pNormChebyshev (cons $u $us) (cons $v $vs) $maxDiff)
   (let $diff (abs-math (- $u $v))
      (pNormChebyshev $us $vs (if (> $diff $maxDiff) $diff $maxDiff))))

;; General Minkowski distance accumulator (p > 0): Lp = (sum(|u_i - v_i|^p))^(1/p)
;; Inputs: Vectors $u, $v (List Number), Degree $p (Number > 0), Accumulator $acc (Number)
;; Output: Number (Lp distance)
(= (pNormGeneral () () $p $acc)
   (if (== $acc 0.0)
       0.0
       (pow-math $acc (/ 1.0 $p))))
(= (pNormGeneral (cons $u $us) (cons $v $vs) $p $acc)
   (let* (($diff (abs-math (- $u $v)))
          ($term (if (> $diff 0.0) (pow-math $diff $p) 0.0)))
      (pNormGeneral $us $vs $p (+ $acc $term))))

;; Core Lp distance evaluation on raw coordinate lists
;; Inputs: Coordinate lists $l1, $l2 (List Number), Degree $p (Number)
;; Output: Number (distance) or Error
(= (pNormDistanceList $l1 $l2 $p)
   (if (not (== (List.length $l1) (List.length $l2)))
       (Error ($l1 $l2) "Cannot compare unequal-sized behavioral score vectors")
       (if (== (List.length $l1) 0)
           0.0
           (case $p
              ((1 (pNormManhattan $l1 $l2 0.0))
               (2 (pNormEuclidean $l1 $l2 0.0))
               ($else (if (<= $else 0.0) (pNormChebyshev $l1 $l2 0.0) (pNormGeneral $l1 $l2 $p 0.0)))
              )))))

;; Lp distance overloads unwrapping behavioral score wrappers
;; Inputs: Behavioral scores $bs1, $bs2 ((mkBScore $l) or (mkBscore $l)), Degree $p (Number)
;; Output: Number (distance)
(= (pNormDistance (mkBScore $l1) (mkBScore $l2) $p)
   (pNormDistanceList $l1 $l2 $p))
(= (pNormDistance (mkBscore $l1) (mkBscore $l2) $p)
   (pNormDistanceList $l1 $l2 $p))

;; -------- 1b. Tanimoto Distance --------

;; Single-pass accumulator computing dot product (ab) and squared norms (aa, bb)
;; Inputs: Vectors $u, $v (List Number), Accumulators $ab, $aa, $bb (Number)
;; Output: 3-element tuple ($ab $aa $bb) where ab = (u . v), aa = ||u||^2, bb = ||v||^2
(= (vectorProducts () () $ab $aa $bb) ($ab $aa $bb))
(= (vectorProducts (cons $u $us) (cons $v $vs) $ab $aa $bb)
   (vectorProducts $us $vs (+ $ab (* $u $v)) (+ $aa (* $u $u)) (+ $bb (* $v $v))))

;; Core Tanimoto distance evaluation on raw coordinate lists
;; Inputs: Coordinate lists $l1, $l2 (List Number)
;; Output: Number in [0.0, 1.0] (Tanimoto distance) or Error
;; Formula:
;;   Similarity: T(u, v) = (u . v) / (||u||^2 + ||v||^2 - (u . v)) = ab / (aa + bb - ab)
;;   Distance:   D(u, v) = 1.0 - T(u, v) = 1.0 - (ab / denom)
(= (tanimotoDistanceList $l1 $l2)
   (if (not (== (List.length $l1) (List.length $l2)))
       (Error ($l1 $l2) "Cannot compare unequal-sized behavioral score vectors")
       (if (== (List.length $l1) 0)
           0.0
           (let ($ab $aa $bb) (vectorProducts $l1 $l2 0.0 0.0 0.0)
              ;; denom = ||u||^2 + ||v||^2 - (u . v) = aa + bb - ab
              (let $denom (- (+ $aa $bb) $ab)
                 ;; Guard against division by zero when both vectors are zero vectors (denom ~ 0)
                 (case (>= $denom (pow-math 10 -32))
                    ;; Distance = 1.0 - similarity = 1.0 - (ab / denom)
                    ((True (- 1.0 (/ $ab $denom)))
                     ;; If both vectors have zero magnitude, distance is 0.0 (identical empty behavior)
                     (False 0.0))))))))

;; Tanimoto distance overloads unwrapping behavioral score wrappers
;; Inputs: Behavioral scores $bs1, $bs2 ((mkBScore $l) or (mkBscore $l))
;; Output: Number in [0.0, 1.0]
(= (tanimotoDistance (mkBScore $l1) (mkBScore $l2))
   (tanimotoDistanceList $l1 $l2))
(= (tanimotoDistance (mkBscore $l1) (mkBscore $l2))
   (tanimotoDistanceList $l1 $l2))

;; -------- 1c. Angular Distance --------

;; Clamps input to [-1.0, 1.0] guarding against domain errors in acos from float rounding
;; Inputs: Number $x
;; Output: Number clamped to [-1.0, 1.0]
(= (clamp11 $x)
   (max-atom (-1.0 (min-atom (1.0 $x)))))

;; Core Angular distance evaluation on raw coordinate lists:
;;   cos_theta = (u . v) / (||u|| * ||v||)
;;   theta = acos(clamp(cos_theta, -1.0, 1.0))
;;   angular_distance = alpha * (theta / pi)
;;
;; Math behind alpha [1.0 vs 2.0 normalization factor]:
;;   - When posNNeg = True [vectors can have both positive and negative values]:
;;     Vectors can point in diametrically opposite directions [angle theta = pi radians, 180 deg].
;;     Dividing theta by pi scales the maximum angle [pi] to 1.0, so alpha = 1.0.
;;   - When posNNeg = False [vectors are strictly non-negative, confined to the first orthant]:
;;     Vectors can never be opposite [dot product is always >= 0].
;;     The maximum separation angle occurs between orthogonal vectors [theta = pi/2 radians, 90 deg].
;;     Dividing theta by pi would only reach 0.5 for orthogonal vectors.
;;     To normalize the maximum separation [pi/2] to 1.0, we multiply by alpha = 2.0:
;;     dist = 2.0 * (theta / pi) = theta / (pi / 2).
;; Inputs: Coordinate lists $l1, $l2 (List Number), optional $posNNeg (Bool, default True)
;; Output: Number in [0.0, 1.0] (Angular distance) or Error
(= (angularDistanceList $l1 $l2)
   (angularDistanceList $l1 $l2 True))

(= (angularDistanceList $l1 $l2 $posNNeg)
   (if (not (== (List.length $l1) (List.length $l2)))
       (Error ($l1 $l2) "Cannot compare unequal-sized behavioral score vectors")
       (if (== (List.length $l1) 0)
           0.0
           (let ($ab $aa $bb) (vectorProducts $l1 $l2 0.0 0.0 0.0)
              ;; denom = ||u|| * ||v|| = sqrt(aa * bb)
              (let $denom (sqrt-math (* $aa $bb))
                 ;; Guard against division by zero if either vector has zero magnitude (denom ~ 0)
                 (case (>= $denom (pow-math 10 -32))
                    ;; cos_theta = clamp(ab / denom, -1.0, 1.0)
                    ;; dist = alpha * (acos(cos_theta) / pi)
                    ((True (let $alpha (case $posNNeg ((True 1.0) (False 2.0)))
                              (* $alpha (/ (acos-math (clamp11 (/ $ab $denom))) 3.141592653589793))))
                     ;; If either vector has zero magnitude, directional distance defaults to 0.0
                     (False 0.0))))))))

;; Angular distance overloads unwrapping behavioral score wrappers
;; Inputs: Behavioral scores $bs1, $bs2 ((mkBScore $l) or (mkBscore $l)), optional $posNNeg (Bool)
;; Output: Number in [0.0, 1.0]
(= (angularDistance $bs1 $bs2)
   (angularDistance $bs1 $bs2 True))

(= (angularDistance (mkBScore $l1) (mkBScore $l2) $posNNeg)
   (angularDistanceList $l1 $l2 $posNNeg))
(= (angularDistance (mkBscore $l1) (mkBscore $l2) $posNNeg)
   (angularDistanceList $l1 $l2 $posNNeg))

;; -------- 1d. Behavioral Distance Dispatchers --------

;; Explicit dispatch by metric name (p_norm, tanimoto, angular)
;; Inputs: Behavioral scores $bs1, $bs2, Metric symbol $metric, Degree $p (Number), optional $posNNeg (Bool)
;; Output: Number (distance) or Error
(= (calculateBScoreDistance $bs1 $bs2 $metric $p)
   (case $metric
      ((p_norm (pNormDistance $bs1 $bs2 $p))
       (tanimoto (tanimotoDistance $bs1 $bs2))
       (angular (angularDistance $bs1 $bs2 True))
       ($else (Error ($metric) "Unknown distance metric")))))

;; Dispatch with posNNeg option for angular distance
(= (calculateBScoreDistance $bs1 $bs2 $metric $p $posNNeg)
   (case $metric
      ((p_norm (pNormDistance $bs1 $bs2 $p))
       (tanimoto (tanimotoDistance $bs1 $bs2))
       (angular (angularDistance $bs1 $bs2 $posNNeg))
       ($else (Error ($metric) "Unknown distance metric")))))

;; Two-argument dispatcher querying default metric and p-norm from registry
;; Inputs: Behavioral scores $bs1, $bs2
;; Output: Number (distance)
(= (calculateBScoreDistance $bs1 $bs2)
   (calculateBScoreDistance $bs1 $bs2 (param diversityDst) (param diversityPNorm)))

;; ============================================================
;;  2. Distance-to-Penalty Converters & Aggregation
;;
;;  Converts a pairwise behavioral distance into a uniformity
;;  penalty. Different converters reflect different penalization
;;  semantics:
;;
;;  1. inverse:
;;     Formula: dp = pressure / [1.0 + dst]
;;     Unbounded mapping that smoothly decays toward 0 as distance
;;     increases. At dist = 0 [identical behavior], the penalty
;;     equals full pressure. Default for unbounded metrics like Lp.
;;
;;  2. complement:
;;     Formula: dp = pressure * [1.0 - dst]
;;     Bounded linear mapping for normalized metrics where dst in [0, 1]
;;     such as Tanimoto and Angular. Linearly penalizes candidates closer
;;     than 1.0, reaching 0 penalty at dist = 1.0.
;;
;;  3. power and pthpower:
;;     Formula: dp = dst^pressure
;;     Multiplicative / probability-like conversion. When selected,
;;     the penalty acts as a multiplier in the composite score
;;     rather than an additive subtraction.
;;
;;  Aggregation:
;;     aggregatedDps applies generalized power-mean aggregation across the pool:
;;       aggregated_dp = ((1/N) * sum(dp_i^exponent))^(1/exponent)
;;     (or max(dp_1, dp_2, ...) when exponent <= 0).
;;     Optimization: To avoid allocating and re-traversing lists of historical
;;     penalties, updateDiversityTmp maintains the sum incrementally ($accDp).
;;     aggregatedDps then only evaluates the final outer scaling: (ddpSum / N)^(1/exponent).
;; ============================================================

;; Inverse converter: dp = pressure / (1.0 + dst)
;; Inputs: Distance $dist (Number >= 0), Pressure $pressure (Number)
;; Output: Number (uniformity penalty)
;; Behavior: Smoothly decays toward 0 as distance increases; equals full pressure at dist = 0.
(= (dstToPenaltyInverse $dist $pressure)
   (/ $pressure (+ 1.0 $dist)))

;; Complement converter: dp = pressure * (1.0 - dst)
;; Inputs: Distance $dist (Number in [0.0, 1.0]), Pressure $pressure (Number)
;; Output: Number (uniformity penalty)
;; Behavior: Linearly penalizes candidates closer than 1.0; reaches 0 penalty at dist = 1.0.
(= (dstToPenaltyComplement $dist $pressure)
   (* $pressure (- 1.0 $dist)))

;; Power converter: dp = dist^pressure
;; Inputs: Distance $dist (Number), Pressure $pressure (Number)
;; Output: Number (penalty multiplier)
;; Behavior: Exponential multiplier for multiplicative composite scoring.
(= (dstToPenaltyPower $dist $pressure)
   (pow-math $dist $pressure))

;; Dispatches distance to the selected converter (inverse, complement, power/pthpower)
;; Inputs: Distance $dist (Number), Converter symbol $converter (Symbol), Pressure $pressure (Number)
;; Output: Number (penalty) or Error
(= (convertDstToPenalty $dist $converter $pressure)
   (case $converter
      ((inverse (dstToPenaltyInverse $dist $pressure))
       (complement (dstToPenaltyComplement $dist $pressure))
       (power (dstToPenaltyPower $dist $pressure))
       (pthpower (dstToPenaltyPower $dist $pressure))
       ($else (Error ($converter) "Unknown distance-to-penalty converter")))))

;; Dispatcher querying default converter and pressure from registry
;; Inputs: Distance $dist (Number)
;; Output: Number (penalty)
(= (convertDstToPenalty $dist)
   (convertDstToPenalty $dist (param diversityDst2dp) (param diversityPressure)))

;; Power-mean aggregation: aggregated_dp = (ddpSum / n)^(1 / exponent)
;; Note: $ddpSum is streamed incrementally by updateDiversityTmp (sum of dp_i^exponent)
;;       to avoid storing and re-summing historical penalty lists.
;; Inputs: Incremental penalty sum $ddpSum (Number), Pool count $n (Number), Exponent $exponent (Number)
;; Output: Number (aggregated uniformity penalty, 0.0 if ddpSum is 0.0)
(= (aggregatedDps $ddpSum $n $exponent)
   (if (== $ddpSum 0.0)
       0.0
       (pow-math (/ $ddpSum $n) (/ 1.0 $exponent))))

;; Power-mean aggregation using default exponent from registry
;; Inputs: Transformed penalty sum $ddpSum (Number), Pool count $n (Number)
;; Output: Number (aggregated uniformity penalty)
(= (aggregatedDps $ddpSum $n)
   (aggregatedDps $ddpSum $n (param diversityExponent)))

;; ============================================================
;;  3. Diversity Pressure Autoscaling
;;
;;  Normalizes diversity pressure to match the dynamic range of
;;  the problem's scoring function:
;;      magnitude = best_possible_score - worst_possible_score
;;      pressure *= magnitude
;;
;;  When enabled, users can supply a scale-invariant base pressure
;;  (e.g. 0.01 to 0.05) that automatically scales with problem size.
;;  Executed once at run initialization before generational search.
;; ============================================================

;; Rescales diversity pressure to problem score range: new_pressure = old_pressure * (bestScore - worstScore)
;; Inputs: Best score $bestScore (Number), Worst score $worstScore (Number)
;; Output: Number (effective diversity pressure)
(= (autoscaleDiversity $bestScore $worstScore)
   (if (and (> (param diversityPressure) 0.0) (== (param diversityAutoscale) True))
       (let*
         (
           ($magnitude (- $bestScore $worstScore))
           ($oldPressure (param diversityPressure))
           ($newPressure (* $oldPressure $magnitude))
           ($_1 (set-param diversityPressure $newPressure))
           ($_2 (println! ("Diversity pressure has been rescaled from" $oldPressure "to" $newPressure "(magnitude:" $magnitude ")")))
         )
         $newPressure
       )
       (param diversityPressure)))

;; ============================================================
;;  4. Symmetric Pairwise Distance Cache & Selective Eviction
;;
;;  Computing behavioral distances across all candidate pairs can
;;  be computationally intensive. The distance cache memoizes
;;  distances symmetrically in &dstCache as (dst $t1 $t2 $dist)
;;  and (dst $t2 $t1 $dist).
;;
;;  When the metapopulation is resized, candidates culled from
;;  the population are pruned from the cache via selective eviction
;;  (eraseCandidateSeqFromDstCache), preserving all surviving pairs.
;; ============================================================

;; Dedicated atomspace for memoizing pairwise candidate distances
!(bind! &dstCache (new-space))

;; Core cached distance with default parameters:
;; 1. Identical trees return distance 0.0 immediately without querying the cache.
;; 2. On cache hit, returns the memoized distance.
;; 3. On cache miss, computes distance, inserts symmetric pairs, and returns distance.
;; Inputs: Tree structures $t1, $t2 (Tree), Behavioral score wrappers $bs1, $bs2
;; Output: Number (pairwise distance)
(= (getCachedDistance $t1 $t2 $bs1 $bs2)
   (if (== $t1 $t2)
       0.0
       (let $cached (collapse (match &dstCache (dst $t1 $t2 $d) $d))
          (if (== $cached ())
              (let* (($dst (calculateBScoreDistance $bs1 $bs2))
                     ($_1 (add-atom &dstCache (dst $t1 $t2 $dst)))
                     ($_2 (add-atom &dstCache (dst $t2 $t1 $dst))))
                 $dst)
              (car-atom $cached)))))

;; Cached distance with explicit metric and p-norm parameters
;; Inputs: Trees $t1, $t2 (Tree), Behavioral scores $bs1, $bs2, Metric $metric, Degree $p (Number)
;; Output: Number (pairwise distance)
(= (getCachedDistance $t1 $t2 $bs1 $bs2 $metric $p)
   (if (== $t1 $t2)
       0.0
       (let $cached (collapse (match &dstCache (dst $t1 $t2 $d) $d))
          (if (== $cached ())
              (let* (($dst (calculateBScoreDistance $bs1 $bs2 $metric $p))
                     ($_1 (add-atom &dstCache (dst $t1 $t2 $dst)))
                     ($_2 (add-atom &dstCache (dst $t2 $t1 $dst))))
                 $dst)
              (car-atom $cached)))))

;; Unwraps candidate exemplar records to compute/retrieve cached distance
;; Inputs: Candidates (mkExemplar $t $d $cs $bs), optional $metric, $p
;; Output: Number (pairwise distance)
(= (getCachedDistance (mkExemplar $t1 $d1 $cs1 $bs1) (mkExemplar $t2 $d2 $cs2 $bs2))
   (getCachedDistance $t1 $t2 $bs1 $bs2))

(= (getCachedDistance (mkExemplar $t1 $d1 $cs1 $bs1) (mkExemplar $t2 $d2 $cs2 $bs2) $metric $p)
   (getCachedDistance $t1 $t2 $bs1 $bs2 $metric $p))

;; -------- Cache Eviction & Cleanup --------

;; Erases all cache pairs containing a specific tree: (dst $tree * *) and (dst * $tree *)
;; Inputs: Tree structure $tree (Tree)
;; Output: ()
(= (eraseTreeFromDstCache $tree)
   (let* (($_1 (collapse (match &dstCache (dst $tree $t $d) (remove-atom &dstCache (dst $tree $t $d)))))
          ($_2 (collapse (match &dstCache (dst $t $tree $d) (remove-atom &dstCache (dst $t $tree $d))))))
      ()))

;; Erases cache pairs for a sequence of trees
;; Inputs: Sequence of trees (List Tree)
;; Output: ()
(= (eraseTreeSeqFromDstCache $trees)
   (let $_ (map-atom $trees $tree (eraseTreeFromDstCache $tree))
      ()))

;; Erases cache pairs for a candidate exemplar by unwrapping its tree
;; Inputs: Candidate exemplar $cand (mkExemplar $tree $d $cs $bs)
;; Output: ()
(= (eraseCandidateFromDstCache (mkExemplar $tree $d $cs $bs))
   (eraseTreeFromDstCache $tree))

;; Selective eviction: erases cache entries for a sequence of culled candidates
;; Inputs: Sequence of culled candidates (List Candidate)
;; Output: ()
(= (eraseCandidateSeqFromDstCache $cands)
   (let $_ (map-atom $cands $cand (eraseCandidateFromDstCache $cand))
      ()))

;; Total cache flush: clears all atoms in &dstCache
;; Inputs: None
;; Output: ()
(= (clearDstCache)
   (let $_ (collapse (match &dstCache $e (remove-atom &dstCache $e)))
      ()))

;; ============================================================
;;  5. Greedy Diversification Engine
;;
;;  Implements greedy exemplar selection and uniformity penalty
;;  re-ranking.
;;
;;  Process Overview:
;;    1. Candidates are initialized in a temporary working list
;;       [$tmp] as [$candidate, $accDp] pairs, with initial
;;       uniformity penalty set to 0.0.
;;    2. In the first step [$poolSize = 0], the candidate with
;;       the highest penalized score is chosen as the anchor
;;       exemplar [penalty remains 0.0].
;;    3. In subsequent steps, the score of each remaining candidate
;;       in $tmp is updated against the last selected exemplar:
;;         - Cached behavioral distance is retrieved.
;;         - Distance is converted to penalty [$lastDp].
;;         - Accumulated penalty [$newAccDp] is updated.
;;         - Candidate's composite score is re-ranked with the new
;;           uniformity penalty [$adp].
;;    4. The best candidate from the updated $tmp is selected,
;;       added to the surviving pool, and the process repeats.
;;
;;  Variables & Parameters:
;;    $candidates: The merged metapopulation candidate pool [newly
;;       optimized candidates from demes merged with existing
;;       exemplars via mergeCandidates].
;;    $cand: An individual candidate exemplar [mkExemplar].
;;    $tmp: Working list of [$cand, $accDp] pairs being diversified.
;;    $accDp: Accumulated raw diversity penalty for a candidate against
;;       all exemplars currently chosen into the pool.
;;    $lastPtr: The candidate most recently added to the pool [used as
;;       the reference point for distance calculations in the current step].
;;    $poolSize: Current count of exemplars in the surviving pool.
;;    $dpMax: Boolean flag [True if exponent <= 0], selecting max penalty
;;       across the pool instead of power-mean aggregation.
;;    $dst2dp: Selected converter algorithm [inverse, complement, power].
;;    $pressure: Diversity pressure scaling coefficient.
;;    $exponent: Power-mean aggregation exponent across the pool.
;;    $normalize: Boolean flag; when True, divides accumulated penalty by
;;       pool size N, otherwise leaves sum unnormalized.
;;    $metric & $p: Distance metric [p_norm, tanimoto, angular] and Lp p-norm.
;;    $multiplyDiv: Boolean flag; True if penalty is multiplicative [power mode],
;;       False if subtractive [inverse / complement].
;;    $adp: Aggregated Diversity Penalty computed and stored in Cscore.
;;    $bestCand: Top-ranked candidate in $tmp selected as next exemplar.
;; ============================================================

;; -------- Candidate Accessors & Modifiers --------
;; Accessor functions extracting individual fields from candidate exemplar records
;; Inputs: Candidate exemplar (mkExemplar $tree $d $cs $bs)
;; Output: Corresponding field ($tree, $d, $cs, or $bs)

(= (candTree (mkExemplar $tree $d $cs $bs)) $tree)

(= (candDemeId (mkExemplar $tree $d $cs $bs)) $d)

(= (candCscore (mkExemplar $tree $d $cs $bs)) $cs)

(= (candBscore (mkExemplar $tree $d $cs $bs)) $bs)

;; Reconstructs a candidate exemplar with an updated composite score
;; Inputs: Candidate $cand (mkExemplar $tree $d $cs $bs), New composite score $newCs (CompositeScore)
;; Output: Updated candidate exemplar
(= (updateCandidateCscore (mkExemplar $tree $d $cs $bs) $newCs)
   (mkExemplar $tree $d $newCs $bs))

;; -------- Initialization & Selection --------

;; Initializes working list ($tmp) with zeroed uniformity penalties
;; Inputs: Candidate list $cands (List Candidate)
;; Output: Working list of pairs ($cand 0.0)
(= (initDiversityTmp $cands)
   (map-atom $cands $cand
      (let* (($cs (candCscore $cand))
             ($zeroUniPenCs (setUniPen $cs 0.0))
             ($initCs (updatePenalizedScore $zeroUniPenCs False))
             ($initCand (updateCandidateCscore $cand $initCs)))
         ($initCand 0.0))))

;; Helper: folds forward across $rest with accumulator ($champion $remaining)
;; Inputs: Remaining list $rest, Current champion ($bestCand $bestPen), Remaining accumulated list $rem
;; Output: 2-tuple (($bestCand $bestPen) $remaining)
(= (selectBestHelper () $champ $rem) ($champ $rem))
(= (selectBestHelper (cons ($cand $pen) $rest) ($bestCand $bestPen) $rem)
   (if (cScore>= (candCscore $cand) (candCscore $bestCand) (candTree $cand) (candTree $bestCand))
       (selectBestHelper $rest ($cand $pen) (cons ($bestCand $bestPen) $rem))
       (selectBestHelper $rest ($bestCand $bestPen) (cons ($cand $pen) $rem))))

;; Selects candidate with highest penalized score from $tmp via forward fold
;; Inputs: Working list $tmp (List of ($cand $accDp) pairs)
;; Output: 2-tuple ($bestEntry $remainingTmp)
(= (selectBestCandidate ()) (() ()))
(= (selectBestCandidate (cons $entry $rest))
   (selectBestHelper $rest $entry ()))

;; Updates uniformity penalties and composite scores of candidates in $tmp relative to $lastPtr:
;;   1. Retrieves cached distance to $lastPtr and converts to penalty ($lastDp).
;;   2. Updates accumulated penalty: max($accDp, $lastDp) if $dpMax, else $accDp + $lastDp^exponent.
;;   3. Computes aggregated penalty $adp (power-mean over pool size N if $normalize).
;;   4. Stores $adp in Cscore and updates penalized score.
;; Inputs: Working list $tmp, Last added exemplar $lastPtr, Current pool size $poolSize, and diversity parameters
;; Output: Updated working list $tmp
(= (updateDiversityTmp () $lastPtr $poolSize $dpMax $dst2dp $pressure $exponent $normalize $metric $p $multiplyDiv)
   ())
(= (updateDiversityTmp (cons ($cand $accDp) $rest) $lastPtr $poolSize $dpMax $dst2dp $pressure $exponent $normalize $metric $p $multiplyDiv)
   (let* (($lastDst (getCachedDistance $cand $lastPtr $metric $p))
          ($lastDp (convertDstToPenalty $lastDst $dst2dp $pressure))
          (($newAccDp $adp)
           (if $dpMax
               (let $m (max-atom ($accDp $lastDp)) ($m $m))
               (let* (($newSum (+ $accDp (pow-math $lastDp $exponent)))
                      ($n (if $normalize $poolSize 1))
                      ($agg (aggregatedDps $newSum $n $exponent)))
                  ($newSum $agg))))
          ($cs (candCscore $cand))
          ($csWithUniPen (setUniPen $cs $adp))
          ($newCs (updatePenalizedScore $csWithUniPen $multiplyDiv))
          ($updatedCand (updateCandidateCscore $cand $newCs))
          ($updatedRest (updateDiversityTmp $rest $lastPtr $poolSize $dpMax $dst2dp $pressure $exponent $normalize $metric $p $multiplyDiv)))
      (cons ($updatedCand $newAccDp) $updatedRest)))

;; Main greedy diversification loop: iteratively selects the best-scoring candidate from $tmp,
;; re-ranks remaining candidates against it via updateDiversityTmp, and recurses until $tmp is empty.
;; Inputs:
;;   $tmp: Working list of candidate pairs ($cand $accDp)
;;   $poolSize: Current count of exemplars selected into the surviving pool (starts at 0)
;;   $lastPtr: Candidate exemplar most recently added to the pool, used as distance reference point
;;   Remaining arguments: Diversity configuration flags ($dpMax, $dst2dp, $pressure, $exponent, $normalize, $metric, $p, $multiplyDiv)
;; Output: Ordered list of diversified candidate exemplars (List (mkExemplar ...))
(= (diversityGreedyLoop () $poolSize $lastPtr $dpMax $dst2dp $pressure $exponent $normalize $metric $p $multiplyDiv)
   ())
(= (diversityGreedyLoop $tmp $poolSize $lastPtr $dpMax $dst2dp $pressure $exponent $normalize $metric $p $multiplyDiv)
   (let* (($currentTmp (if (== $poolSize 0)
                           $tmp
                           (updateDiversityTmp $tmp $lastPtr $poolSize $dpMax $dst2dp $pressure $exponent $normalize $metric $p $multiplyDiv)))
          ((($bestCand $bestAccDp) $remTmp) (selectBestCandidate $currentTmp))
          ($restPool (diversityGreedyLoop $remTmp (+ $poolSize 1) $bestCand $dpMax $dst2dp $pressure $exponent $normalize $metric $p $multiplyDiv)))
      (cons $bestCand $restPool)))

;; -------- Public Diversification Entry Points --------

;; Primary pipeline entry point: executes greedy diversification and uniformity penalty re-ranking
;; on the candidate pool if diversity pressure > 0.0; returns original candidates unchanged if pressure <= 0.0.
;; Inputs:
;;   $candidates: Merged metapopulation candidate pool (List (mkExemplar ...))
;;   $pressure: Diversity pressure scaling factor (Number)
;;   Optional: $dst2dp (converter algorithm), $exponent (power-mean exponent), $normalize (pool size normalization flag),
;;             $metric (distance metric: p_norm, tanimoto, angular), $p (Lp p-norm degree)
;; Output: Ordered list of diversified candidate exemplars (List (mkExemplar ...))
(= (setDiversity $candidates $pressure $dst2dp $exponent $normalize $metric $p)
   (if (or (<= $pressure 0.0) (== $candidates ()))
       $candidates
       (let* (($dpMax (<= $exponent 0.0))
              ($multiplyDiv (or (== $dst2dp power) (== $dst2dp pthpower)))
              ($tmp (initDiversityTmp $candidates)))
          (diversityGreedyLoop $tmp 0 () $dpMax $dst2dp $pressure $exponent $normalize $metric $p $multiplyDiv))))

;; Overload with explicit pressure, defaulting remaining parameters from registry
(= (setDiversity $candidates $pressure)
   (setDiversity $candidates
                 $pressure
                 (param diversityDst2dp)
                 (param diversityExponent)
                 (param diversityNormalize)
                 (param diversityDst)
                 (param diversityPNorm)))

;; Default entry point querying all diversity parameters from registry
(= (setDiversity $candidates)
   (setDiversity $candidates (param diversityPressure)))

;; ============================================================
;;  6. Runtime Inspection & Logging
;;
;;  Compact logging helpers for runtime diagnostic monitoring.
;;  Emits tree structure, raw fitness score, complexity, uniformity
;;  penalty, and final penalized composite score.
;; ============================================================

;; Formats and prints diagnostic metrics (tree, raw score, complexity, uniformity penalty, penalized score)
;; Inputs: Candidate exemplar (mkExemplar $tree $demeId $cscore $bscore)
;; Output: ()
(= (logExemplarDiversity (mkExemplar $tree $demeId $cscore $bscore))
   (let* (($t (preOrder $tree))
          ($s (getScore $cscore))
          ($c (getComp $cscore))
          ($up (getUniPen $cscore))
          ($ps (getPenScore $cscore)))
      (println! ("   -> Tree:" $t "RawScore:" $s "Cpxy:" $c "UniPen:" $up "PenScore:" $ps))))

;; Recursively logs diagnostic metrics for the top N exemplars in a candidate list
;; Inputs: Candidate list $cands (List Candidate), Count $n (Number)
;; Output: ()
(= (logTopDiversity () $n) ())
(= (logTopDiversity (cons $cand $rest) $n)
   (if (<= $n 0)
       ()
       (let* (($_1 (logExemplarDiversity $cand)))
          (logTopDiversity $rest (- $n 1)))))
