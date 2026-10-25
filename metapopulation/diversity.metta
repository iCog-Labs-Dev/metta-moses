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

;; Manhattan distance accumulator (p = 1)
(= (pNormManhattan () () $acc) $acc)
(= (pNormManhattan (cons $u $us) (cons $v $vs) $acc)
   (let $diff (abs-math (- $u $v))
      (pNormManhattan $us $vs (+ $acc $diff))))

;; Euclidean distance accumulator (p = 2)
(= (pNormEuclidean () () $acc) (sqrt-math $acc))
(= (pNormEuclidean (cons $u $us) (cons $v $vs) $acc)
   (let* (($diff (- $u $v))
          ($sq (* $diff $diff)))
      (pNormEuclidean $us $vs (+ $acc $sq))))

;; Chebyshev / maximum difference accumulator (p <= 0)
(= (pNormChebyshev () () $maxDiff) (+ 0.0 $maxDiff))
(= (pNormChebyshev (cons $u $us) (cons $v $vs) $maxDiff)
   (let $diff (abs-math (- $u $v))
      (pNormChebyshev $us $vs (if (> $diff $maxDiff) $diff $maxDiff))))

;; General Minkowski distance accumulator (general p > 0)
(= (pNormGeneral () () $p $acc)
   (if (== $acc 0.0)
       0.0
       (pow-math $acc (/ 1.0 $p))))
(= (pNormGeneral (cons $u $us) (cons $v $vs) $p $acc)
   (let* (($diff (abs-math (- $u $v)))
          ($term (if (> $diff 0.0) (pow-math $diff $p) 0.0)))
      (pNormGeneral $us $vs $p (+ $acc $term))))

;; Core Lp distance evaluation on raw coordinate lists
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
(= (pNormDistance (mkBScore $l1) (mkBScore $l2) $p)
   (pNormDistanceList $l1 $l2 $p))
(= (pNormDistance (mkBscore $l1) (mkBscore $l2) $p)
   (pNormDistanceList $l1 $l2 $p))

;; -------- 1b. Tanimoto Distance --------

;; Single-pass accumulator computing dot product (ab) and norms (aa, bb)
(= (vectorProducts () () $ab $aa $bb) ($ab $aa $bb))
(= (vectorProducts (cons $u $us) (cons $v $vs) $ab $aa $bb)
   (vectorProducts $us $vs (+ $ab (* $u $v)) (+ $aa (* $u $u)) (+ $bb (* $v $v))))

;; Core Tanimoto distance evaluation on raw coordinate lists
(= (tanimotoDistanceList $l1 $l2)
   (if (not (== (List.length $l1) (List.length $l2)))
       (Error ($l1 $l2) "Cannot compare unequal-sized behavioral score vectors")
       (if (== (List.length $l1) 0)
           0.0
           (let ($ab $aa $bb) (vectorProducts $l1 $l2 0.0 0.0 0.0)
              (let $denom (- (+ $aa $bb) $ab)
                 (case (>= $denom (pow-math 10 -32))
                    ((True (- 1.0 (/ $ab $denom)))
                     (False 0.0))))))))

;; Tanimoto distance overloads unwrapping behavioral score wrappers
(= (tanimotoDistance (mkBScore $l1) (mkBScore $l2))
   (tanimotoDistanceList $l1 $l2))
(= (tanimotoDistance (mkBscore $l1) (mkBscore $l2))
   (tanimotoDistanceList $l1 $l2))

;; -------- 1c. Angular Distance --------

;; Numerical clamping to [-1.0, 1.0] guarding against floating-point rounding
(= (clamp11 $x)
   (if (> $x 1.0) 1.0 (if (< $x -1.0) -1.0 $x)))

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
(= (angularDistanceList $l1 $l2)
   (angularDistanceList $l1 $l2 True))

(= (angularDistanceList $l1 $l2 $posNNeg)
   (if (not (== (List.length $l1) (List.length $l2)))
       (Error ($l1 $l2) "Cannot compare unequal-sized behavioral score vectors")
       (if (== (List.length $l1) 0)
           0.0
           (let ($ab $aa $bb) (vectorProducts $l1 $l2 0.0 0.0 0.0)
              (let $denom (sqrt-math (* $aa $bb))
                 (case (>= $denom (pow-math 10 -32))
                    ((True (let $alpha (case $posNNeg ((True 1.0) (False 2.0)))
                              (* $alpha (/ (acos-math (clamp11 (/ $ab $denom))) 3.141592653589793))))
                     (False 0.0))))))))

;; Angular distance overloads unwrapping behavioral score wrappers
(= (angularDistance $bs1 $bs2)
   (angularDistance $bs1 $bs2 True))

(= (angularDistance (mkBScore $l1) (mkBScore $l2) $posNNeg)
   (angularDistanceList $l1 $l2 $posNNeg))
(= (angularDistance (mkBscore $l1) (mkBscore $l2) $posNNeg)
   (angularDistanceList $l1 $l2 $posNNeg))

;; -------- 1d. Behavioral Distance Dispatchers --------

;; Explicit dispatch by metric name (p_norm, tanimoto, angular)
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

;; Two-argument dispatcher looking up default metric and p-norm from registry
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
;;     aggregatedDps aggregates penalties across the pool using the
;;     generalized power-mean:
;;       aggregated_dp = ((1/N) * sum(dp_i^exponent))^(1/exponent)
;;     When exponent <= 0, the maximum penalty is used instead:
;;       aggregated_dp = max(dp_1, dp_2, ...)
;; ============================================================

;; Inverse converter: pressure / (1.0 + dst)
(= (dstToPenaltyInverse $dist $pressure)
   (/ $pressure (+ 1.0 $dist)))

;; Complement converter: pressure * (1.0 - dst)
(= (dstToPenaltyComplement $dist $pressure)
   (* $pressure (- 1.0 $dist)))

;; Power converter: dist^pressure
(= (dstToPenaltyPower $dist $pressure)
   (pow-math $dist $pressure))

;; Dispatcher mapping converter symbol to the corresponding formula
(= (convertDstToPenalty $dist $converter $pressure)
   (case $converter
      ((inverse (dstToPenaltyInverse $dist $pressure))
       (complement (dstToPenaltyComplement $dist $pressure))
       (power (dstToPenaltyPower $dist $pressure))
       (pthpower (dstToPenaltyPower $dist $pressure))
       ($else (Error ($converter) "Unknown distance-to-penalty converter")))))

;; Dispatcher using default converter and pressure from registry
(= (convertDstToPenalty $dist)
   (convertDstToPenalty $dist (param diversityDst2dp) (param diversityPressure)))

;; Power-mean aggregation of penalties across pool size N:
;; aggregated_dps(ddp_sum, N) = (ddp_sum / N)^(1 / exponent)
(= (aggregatedDps $ddpSum $n $exponent)
   (if (== $ddpSum 0.0)
       0.0
       (pow-math (/ $ddpSum $n) (/ 1.0 $exponent))))

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

;; Core cached distance with explicit metric and p-norm parameters
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

;; Polymorphic overloads accepting candidate structures (mkExemplar or mkXmplr)
(= (getCachedDistance (mkExemplar $t1 $d1 $cs1 $bs1) (mkExemplar $t2 $d2 $cs2 $bs2))
   (getCachedDistance $t1 $t2 $bs1 $bs2))
(= (getCachedDistance (mkXmplr $t1 $d1 $cs1 $bs1) (mkXmplr $t2 $d2 $cs2 $bs2))
   (getCachedDistance $t1 $t2 $bs1 $bs2))
(= (getCachedDistance (mkExemplar $t1 $d1 $cs1 $bs1) (mkXmplr $t2 $d2 $cs2 $bs2))
   (getCachedDistance $t1 $t2 $bs1 $bs2))
(= (getCachedDistance (mkXmplr $t1 $d1 $cs1 $bs1) (mkExemplar $t2 $d2 $cs2 $bs2))
   (getCachedDistance $t1 $t2 $bs1 $bs2))

(= (getCachedDistance (mkExemplar $t1 $d1 $cs1 $bs1) (mkExemplar $t2 $d2 $cs2 $bs2) $metric $p)
   (getCachedDistance $t1 $t2 $bs1 $bs2 $metric $p))
(= (getCachedDistance (mkXmplr $t1 $d1 $cs1 $bs1) (mkXmplr $t2 $d2 $cs2 $bs2) $metric $p)
   (getCachedDistance $t1 $t2 $bs1 $bs2 $metric $p))
(= (getCachedDistance (mkExemplar $t1 $d1 $cs1 $bs1) (mkXmplr $t2 $d2 $cs2 $bs2) $metric $p)
   (getCachedDistance $t1 $t2 $bs1 $bs2 $metric $p))
(= (getCachedDistance (mkXmplr $t1 $d1 $cs1 $bs1) (mkExemplar $t2 $d2 $cs2 $bs2) $metric $p)
   (getCachedDistance $t1 $t2 $bs1 $bs2 $metric $p))

;; -------- Cache Eviction & Cleanup --------

;; Erases all cache pairs containing a specific tree: (dst $tree * *) and (dst * $tree *)
(= (eraseTreeFromDstCache $tree)
   (let* (($entries1 (collapse (match &dstCache (dst $tree $t $d) (dst $tree $t $d))))
          ($entries2 (collapse (match &dstCache (dst $t $tree $d) (dst $t $tree $d))))
          ($_1 (map-atom $entries1 $e (remove-atom &dstCache $e)))
          ($_2 (map-atom $entries2 $e (remove-atom &dstCache $e))))
      ()))

;; Erases cache pairs for a sequence of trees
(= (eraseTreeSeqFromDstCache ()) ())
(= (eraseTreeSeqFromDstCache (cons $tree $rest))
   (let () (eraseTreeFromDstCache $tree)
      (eraseTreeSeqFromDstCache $rest)))

;; Erases cache pairs for candidate wrappers (mkExemplar / mkXmplr)
(= (eraseCandidateFromDstCache (mkExemplar $tree $d $cs $bs))
   (eraseTreeFromDstCache $tree))
(= (eraseCandidateFromDstCache (mkXmplr $tree $d $cs $bs))
   (eraseTreeFromDstCache $tree))

;; Selective eviction: erases cache entries for a sequence of culled candidates
(= (eraseCandidateSeqFromDstCache ()) ())
(= (eraseCandidateSeqFromDstCache (cons $cand $rest))
   (let () (eraseCandidateFromDstCache $cand)
      (eraseCandidateSeqFromDstCache $rest)))

;; Total cache flush: clears all atoms in &dstCache (useful between independent runs or tests)
(= (clearDstCache)
   (let $entries (collapse (match &dstCache $e $e))
     (map-atom $entries $e (remove-atom &dstCache $e))))

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
;;    3. In each subsequent step, remaining candidates in $tmp are
;;       updated against the last selected exemplar:
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
;;    $cand: An individual candidate exemplar [mkExemplar or mkXmplr].
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
;; Polymorphic accessors extracting fields from mkExemplar and mkXmplr

(= (candTree (mkExemplar $tree $d $cs $bs)) $tree)
(= (candTree (mkXmplr $tree $d $cs $bs)) $tree)

(= (candDemeId (mkExemplar $tree $d $cs $bs)) $d)
(= (candDemeId (mkXmplr $tree $d $cs $bs)) $d)

(= (candCscore (mkExemplar $tree $d $cs $bs)) $cs)
(= (candCscore (mkXmplr $tree $d $cs $bs)) $cs)

(= (candBscore (mkExemplar $tree $d $cs $bs)) $bs)
(= (candBscore (mkXmplr $tree $d $cs $bs)) $bs)

(= (updateCandidateCscore (mkExemplar $tree $d $cs $bs) $newCs)
   (mkExemplar $tree $d $newCs $bs))
(= (updateCandidateCscore (mkXmplr $tree $d $cs $bs) $newCs)
   (mkXmplr $tree $d $newCs $bs))

;; -------- Initialization & Selection --------

;; Initializes the working list ($tmp) with initial uniformity penalty 0.0
(= (initDiversityTmp ()) ())
(= (initDiversityTmp (cons $cand $rest))
   (let* (($cs (candCscore $cand))
          ($zeroUniPenCs (setUniPen $cs 0.0))
          ($initCs (updatePenalizedScore $zeroUniPenCs False))
          ($initCand (updateCandidateCscore $cand $initCs)))
      (cons ($initCand 0.0) (initDiversityTmp $rest))))

;; Selects the candidate with the highest penalized score from $tmp.
;; Returns ($bestEntry $remainingTmp).
(= (selectBestCandidate ()) (() ()))
(= (selectBestCandidate (cons $entry ()))
   ($entry ()))
(= (selectBestCandidate (cons $entry $rest))
   (let* ((($bestOther $remOther) (selectBestCandidate $rest))
          (($cand1 $acc1) $entry)
          (($cand2 $acc2) $bestOther)
          ($cs1 (candCscore $cand1))
          ($cs2 (candCscore $cand2))
          ($isBetter (cScore>= $cs2 $cs1)))
      (if $isBetter
          ($bestOther (cons $entry $remOther))
          ($entry $rest))))

;; Updates uniformity penalties and composite scores of all candidates
;; in $tmp relative to the newly added exemplar ($lastPtr).
(= (updateDiversityTmp () $lastPtr $poolSize $dpMax $dst2dp $pressure $exponent $normalize $metric $p $multiplyDiv)
   ())
(= (updateDiversityTmp (cons ($cand $accDp) $rest) $lastPtr $poolSize $dpMax $dst2dp $pressure $exponent $normalize $metric $p $multiplyDiv)
   (let* (($lastDst (getCachedDistance $cand $lastPtr $metric $p))
          ($lastDp (convertDstToPenalty $lastDst $dst2dp $pressure))
          ($lastDdp (if $dpMax $lastDp (pow-math $lastDp $exponent)))
          ($newAccDp (if $dpMax
                         (if (> $accDp $lastDdp) $accDp $lastDdp)
                         (+ $accDp $lastDdp)))
          ($adp (if $dpMax
                    $newAccDp
                    (let $n (if $normalize $poolSize 1)
                       (aggregatedDps $newAccDp $n $exponent))))
          ($cs (candCscore $cand))
          ($csWithUniPen (setUniPen $cs $adp))
          ($newCs (updatePenalizedScore $csWithUniPen $multiplyDiv))
          ($updatedCand (updateCandidateCscore $cand $newCs))
          ($updatedRest (updateDiversityTmp $rest $lastPtr $poolSize $dpMax $dst2dp $pressure $exponent $normalize $metric $p $multiplyDiv)))
      (cons ($updatedCand $newAccDp) $updatedRest)))

;; Main recursive greedy diversification loop.
;; Iteratively pulls the best candidate from $tmp into the exemplar pool.
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

;; Full-parameter entry point: executes diversification if pressure > 0.0
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

(= (logExemplarDiversity (mkExemplar $tree $demeId $cscore $bscore))
   (let* (($t (preOrder $tree))
          ($s (getScore $cscore))
          ($c (getComp $cscore))
          ($up (getUniPen $cscore))
          ($ps (getPenScore $cscore)))
      (println! ("   -> Tree:" $t "RawScore:" $s "Cpxy:" $c "UniPen:" $up "PenScore:" $ps))))

(= (logTopDiversity () $n) ())
(= (logTopDiversity (cons $cand $rest) $n)
   (if (<= $n 0)
       ()
       (let* (($_1 (logExemplarDiversity $cand)))
          (logTopDiversity $rest (- $n 1)))))
