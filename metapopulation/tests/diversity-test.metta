;; ============================================================
;;  diversity-test.metta
;;  Comprehensive Test Suite for Metapopulation Diversity
;;
;;  Verifies all core components of the diversity subsystem:
;;    1. Behavioral Distance Metrics (Lp, Tanimoto, Angular)
;;    2. Distance-to-Penalty Converters & Aggregation
;;    3. Symmetric Pairwise Distance Cache & Selective Eviction
;;    4. Greedy Diversification Engine & Metapopulation Pipeline
;;    5. Diversity Pressure Autoscaling
;; ============================================================

!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/tree)
!(import! &self ../../utilities/ordered-set)
!(import! &self ../../parameters/defaults)
!(import! &self ../../parameters/registry)
!(import! &self ../../scoring/bscore)
!(import! &self ../../scoring/cscore)
!(import! &self ../../scoring/fitness)
!(import! &self ../../scoring/boolean-ops)
!(import! &self ../../deme/deme-id-creation)
!(import! &self ../diversity)
!(import! &self ../metapopulation)

;; ============================================================
;;  1. Behavioral Distance Metrics
;; ============================================================

;; ---- 1a. Lp Norm Distance ----

;; Manhattan distance (p = 1):
;; u = [1, 2, 3], v = [4, 6, 1]
;; Hand calculation: |1-4| + |2-6| + |3-1| = 3 + 4 + 2 = 9.0
!(assertEqual
    (pNormDistance (mkBScore (cons 1 (cons 2 (cons 3 ()))))
                   (mkBScore (cons 4 (cons 6 (cons 1 ())))) 1)
    9.0)

;; Euclidean distance (p = 2):
;; u = [1, 2], v = [4, 6]
;; Hand calculation: sqrt((1-4)^2 + (2-6)^2) = sqrt(9 + 16) = 5.0
!(assertEqual
    (pNormDistance (mkBScore (cons 1 (cons 2 ())))
                   (mkBScore (cons 4 (cons 6 ()))) 2)
    5.0)

;; Chebyshev distance (p <= 0):
;; u = [1, 2, 10], v = [2, 5, 3]
;; Hand calculation: max(|1-2|, |2-5|, |10-3|) = max(1, 3, 7) = 7.0
!(assertEqual
    (pNormDistance (mkBScore (cons 1 (cons 2 (cons 10 ()))))
                   (mkBScore (cons 2 (cons 5 (cons 3 ())))) 0)
    7.0)

;; General Minkowski distance (p = 3):
;; u = [1, 0], v = [0, 2]
;; Hand calculation: (|1-0|^3 + |0-2|^3)^(1/3) = (1 + 8)^(1/3) = 9^(1/3)
!(assertEqual
    (isApproxEq
        (pNormDistance (mkBScore (cons 1 (cons 0 ())))
                       (mkBScore (cons 0 (cons 2 ()))) 3)
        (pow-math 9.0 (/ 1.0 3.0)))
    True)

;; Zero distance for identical vectors
!(assertEqual
    (pNormDistance (mkBScore (cons 1 (cons -1 ())))
                   (mkBScore (cons 1 (cons -1 ()))) 2)
    0.0)

;; Error guard on mismatched vector lengths
!(assertEqual
    (pNormDistance (mkBScore (cons 1 (cons 2 ())))
                   (mkBScore (cons 1 (cons 2 (cons 3 ())))) 2)
    (Error ((cons 1 (cons 2 ())) (cons 1 (cons 2 (cons 3 ()))))
           "Cannot compare unequal-sized behavioral score vectors"))

;; ---- 1b. Tanimoto Distance ----

;; Orthogonal vectors: u = [1, 0], v = [0, 2]
;; Hand calculation: u.v = 0, ||u||^2 = 1, ||v||^2 = 4
;; dist = 1 - 0 / (1 + 4 - 0) = 1.0
!(assertEqual
    (tanimotoDistance (mkBScore (cons 1 (cons 0 ())))
                      (mkBScore (cons 0 (cons 2 ()))))
    1.0)

;; Overlapping vectors: u = [1, 0, 1], v = [0, 1, 1]
;; Hand calculation: u.v = 1, ||u||^2 = 2, ||v||^2 = 2
;; dist = 1 - 1 / (2 + 2 - 1) = 1 - 1/3 = 2/3 ≈ 0.6666667
!(assertEqual
    (isApproxEq
        (tanimotoDistance (mkBScore (cons 1 (cons 0 (cons 1 ()))))
                          (mkBScore (cons 0 (cons 1 (cons 1 ())))))
        (/ 2.0 3.0))
    True)

;; Identical vectors -> 0.0
!(assertEqual
    (tanimotoDistance (mkBScore (cons 1 (cons 2 ())))
                      (mkBScore (cons 1 (cons 2 ()))))
    0.0)

;; ---- 1c. Angular Distance ----

;; Orthogonal vectors with mixed-sign mode (posNNeg = True, alpha = 1.0):
;; u = [1, 0], v = [0, 1] -> cos(theta) = 0 -> theta = pi / 2
;; Hand calculation: dist = 1.0 * (pi/2) / pi = 0.5
!(assertEqual
    (angularDistance (mkBScore (cons 1 (cons 0 ())))
                     (mkBScore (cons 0 (cons 1 ()))))
    0.5)

;; Orthogonal vectors with non-negative mode (posNNeg = False, alpha = 2.0):
;; Hand calculation: dist = 2.0 * (pi/2) / pi = 1.0
!(assertEqual
    (angularDistance (mkBScore (cons 1 (cons 0 ())))
                     (mkBScore (cons 0 (cons 1 ()))) False)
    1.0)

;; Diametrically opposite vectors: u = [1, 0], v = [-1, 0]
;; cos(theta) = -1 -> theta = pi
;; Hand calculation: dist = 1.0 * pi / pi = 1.0
!(assertEqual
    (angularDistance (mkBScore (cons 1 (cons 0 ())))
                     (mkBScore (cons -1 (cons 0 ()))))
    1.0)

;; ============================================================
;;  2. Distance-to-Penalty Converters & Aggregation
;; ============================================================

;; ---- 2a. Converters ----

;; Inverse: pressure / (1.0 + dst)
;; Hand calculation: 2.0 / (1.0 + 1.0) = 1.0; 2.0 / (1.0 + 3.0) = 0.5
!(assertEqual (dstToPenaltyInverse 1.0 2.0) 1.0)
!(assertEqual (dstToPenaltyInverse 3.0 2.0) 0.5)

;; Complement: pressure * (1.0 - dst)
;; Hand calculation: 2.0 * (1.0 - 0.25) = 1.5; 2.0 * (1.0 - 1.0) = 0.0
!(assertEqual (dstToPenaltyComplement 0.25 2.0) 1.5)
!(assertEqual (dstToPenaltyComplement 1.0 2.0) 0.0)

;; Power: dst^pressure
;; Hand calculation: 2.0^3.0 = 8.0; 0.5^2.0 = 0.25
!(assertEqual (dstToPenaltyPower 2.0 3.0) 8.0)
!(assertEqual (dstToPenaltyPower 0.5 2.0) 0.25)

;; Dispatcher error on invalid converter
!(assertEqual
    (convertDstToPenalty 1.0 unknown_conv 2.0)
    (Error (unknown_conv) "Unknown distance-to-penalty converter"))

;; ---- 2b. Power-Mean Aggregation (aggregatedDps) ----

;; Arithmetic mean (exponent = 1.0): (1.5 / 3)^1.0 = 0.5
!(assertEqual (aggregatedDps 1.5 3 1.0) 0.5)

;; Root mean cube (exponent = 3.0): (8.0 / 1)^(1/3) = 2.0
!(assertEqual
    (isApproxEq (aggregatedDps 8.0 1 3.0) 2.0)
    True)

;; Root mean square (exponent = 2.0): sqrt(0.93 / 3) = sqrt(0.31) ≈ 0.5567764
!(assertEqual
    (isApproxEq (aggregatedDps 0.93 3 2.0) 0.556776436283)
    True)

;; ============================================================
;;  3. Symmetric Pairwise Distance Cache & Selective Eviction
;; ============================================================

;; Tree fixtures
(= (cacheTreeA) (mkTree (mkNode A) ()))
(= (cacheTreeB) (mkTree (mkNode B) ()))
(= (cacheTreeC) (mkTree (mkNode C) ()))

;; Candidate fixtures
(= (cacheCandA)
   (mkExemplar (cacheTreeA) (mkDemeId "1")
               (mkCscore 10.0 1.0 0.0 0.0 10.0)
               (mkBScore (cons 1 (cons 2 ())))))

(= (cacheCandB)
   (mkExemplar (cacheTreeB) (mkDemeId "2")
               (mkCscore 8.0 1.0 0.0 0.0 8.0)
               (mkBScore (cons 4 (cons 6 ())))))

(= (cacheCandC)
   (mkExemplar (cacheTreeC) (mkDemeId "3")
               (mkCscore 7.0 1.0 0.0 0.0 7.0)
               (mkBScore (cons 1 (cons 2 ())))))

;; Clean cache before testing
!(clearDstCache)

;; Distance to self returns 0.0 without querying cache
!(assertEqual (getCachedDistance (cacheCandA) (cacheCandA)) 0.0)

;; First calculation: Euclidean distance = sqrt((1-4)^2 + (2-6)^2) = 5.0
!(assertEqual (getCachedDistance (cacheCandA) (cacheCandB)) 5.0)

;; Verify symmetric insertion: both (A B 5.0) and (B A 5.0) exist in &dstCache
!(assertEqual
    (let* (($tA (cacheTreeA)) ($tB (cacheTreeB)))
       (collapse (match &dstCache (dst $tA $tB $d) $d)))
    (5.0))
!(assertEqual
    (let* (($tA (cacheTreeA)) ($tB (cacheTreeB)))
       (collapse (match &dstCache (dst $tB $tA $d) $d)))
    (5.0))

;; Reverse query uses cached value directly
!(assertEqual (getCachedDistance (cacheCandB) (cacheCandA)) 5.0)

;; Compute distance between B and C (Manhattan: |4-1| + |6-2| = 7.0)
!(assertEqual (getCachedDistance (cacheCandB) (cacheCandC) p_norm 1) 7.0)

;; Selective eviction: evicting candidate B removes all pairs involving B,
;; while preserving pairs that do not involve B
!(eraseCandidateSeqFromDstCache (cons (cacheCandB) ()))

;; Pairs with B are gone
!(assertEqual
    (let* (($tA (cacheTreeA)) ($tB (cacheTreeB)))
       (collapse (match &dstCache (dst $tA $tB $d) $d)))
    ())
!(assertEqual
    (let* (($tB (cacheTreeB)) ($tC (cacheTreeC)))
       (collapse (match &dstCache (dst $tB $tC $d) $d)))
    ())

;; ============================================================
;;  4. Greedy Diversification Engine & Metapopulation Pipeline
;;
;;  Tests candidate re-ranking and clone demotion on a 4-candidate
;;  population:
;;    - candA (anchor): raw 10.0, behavior [1, 1, 0, 0]
;;    - candB (clone of A): raw 9.8, behavior [1, 1, 0, 0] (dist to A = 0.0)
;;    - candC (semi-diverse): raw 9.5, behavior [1, 0, 1, 0] (dist to A = 2.0)
;;    - candD (fully diverse): raw 9.0, behavior [0, 0, 1, 1] (dist to A = 4.0)
;;
;;  Hand calculations with pressure = 2.0, inverse converter, Manhattan:
;;    1. Anchor: candA selected first (PenScore = 10.0).
;;    2. Re-ranking remaining candidates against candA:
;;       - candB: dist = 0.0 -> penalty = 2.0 / (1 + 0) = 2.0
;;                PenScore = 9.8 - 2.0 = 7.800
;;       - candC: dist = 2.0 -> penalty = 2.0 / (1 + 2) = 0.667
;;                PenScore = 9.5 - 0.667 = 8.833
;;       - candD: dist = 4.0 -> penalty = 2.0 / (1 + 4) = 0.400
;;                PenScore = 9.0 - 0.400 = 8.600
;;    3. New ranking: candA (10.0) > candC (8.833) > candD (8.600) > candB (7.800).
;;       The behavioral clone candB is demoted from 2nd to last place!
;; ============================================================

(= (pipeTreeA) (mkTree (mkNode A) ()))
(= (pipeTreeB) (mkTree (mkNode B) ()))
(= (pipeTreeC) (mkTree (mkNode C) ()))
(= (pipeTreeD) (mkTree (mkNode D) ()))

(= (pipeCandA)
   (mkExemplar (pipeTreeA) (mkDemeId "1")
               (mkCscore 10.0 2 0.0 0.0 10.0)
               (mkBScore (cons 1.0 (cons 1.0 (cons 0.0 (cons 0.0 ())))))))

(= (pipeCandB)
   (mkExemplar (pipeTreeB) (mkDemeId "2")
               (mkCscore 9.8 2 0.0 0.0 9.8)
               (mkBScore (cons 1.0 (cons 1.0 (cons 0.0 (cons 0.0 ())))))))

(= (pipeCandC)
   (mkExemplar (pipeTreeC) (mkDemeId "3")
               (mkCscore 9.5 2 0.0 0.0 9.5)
               (mkBScore (cons 1.0 (cons 0.0 (cons 1.0 (cons 0.0 ())))))))

(= (pipeCandD)
   (mkExemplar (pipeTreeD) (mkDemeId "4")
               (mkCscore 9.0 2 0.0 0.0 9.0)
               (mkBScore (cons 0.0 (cons 0.0 (cons 1.0 (cons 1.0 ())))))))

;; ---- 4a. Zero Diversity Pressure (Pass-Through) ----
;; When pressure = 0.0, candidates retain original score ordering: [A, B, C, D]
!(set-param diversityPressure 0.0)
!(assertEqual
    (let $res (setDiversity (cons (pipeCandA) (cons (pipeCandB) (cons (pipeCandC) (cons (pipeCandD) ())))))
       (cons (getExemplarTree (car-atom $res))
       (cons (getExemplarTree (car-atom (cdr-atom $res)))
       (cons (getExemplarTree (car-atom (cdr-atom (cdr-atom $res))))
       (cons (getExemplarTree (car-atom (cdr-atom (cdr-atom (cdr-atom $res))))) ())))))
    (cons (pipeTreeA) (cons (pipeTreeB) (cons (pipeTreeC) (cons (pipeTreeD) ())))))

;; ---- 4b. Active Diversification & Clone Demotion ----
;; With pressure = 2.0, diversity re-ranks to [A, C, D, B]
!(clearDstCache)
!(set-param diversityPressure 2.0)
!(set-param diversityDst2dp inverse)
!(set-param diversityExponent -1.0)
!(set-param diversityNormalize True)
!(set-param diversityDst p_norm)
!(set-param diversityPNorm 1.0)

!(assertEqual
    (let $res (setDiversity (cons (pipeCandA) (cons (pipeCandB) (cons (pipeCandC) (cons (pipeCandD) ())))))
       (cons (getExemplarTree (car-atom $res))
       (cons (getExemplarTree (car-atom (cdr-atom $res)))
       (cons (getExemplarTree (car-atom (cdr-atom (cdr-atom $res))))
       (cons (getExemplarTree (car-atom (cdr-atom (cdr-atom (cdr-atom $res))))) ())))))
    (cons (pipeTreeA) (cons (pipeTreeC) (cons (pipeTreeD) (cons (pipeTreeB) ())))))

;; ---- 4c. Integration with Metapopulation Resizing & Cache Eviction ----
;; resizeMetapop prunes candidates falling below topScore - usefulScoreRange.
;; With compTemp = 6.0 -> usefulScoreRange = 6.0 * 30 / 100 = 1.8
;; worstScore = 10.0 - 1.8 = 8.2
;; Surviving candidates: A (10.0), C (8.833), D (8.333)
;; Culled candidate: B (7.800 < 8.2)
;; resizeMetapop prunes B and automatically evicts B from &dstCache!
!(set-param minPoolSize 2)
!(set-param capCoef 0.01)
!(set-param genCount 100)
!(set-param complexityTemperature 6.0)
!(set-param nToKeep 3)

(= (diversifiedPop)
   (setDiversity (cons (pipeCandA) (cons (pipeCandB) (cons (pipeCandC) (cons (pipeCandD) ()))))))

(= (survivingPop)
   (resizeMetapop (diversifiedPop)))

;; 3 candidates survive (A, C, D)
!(assertEqual (OS.length (survivingPop)) 3)

;; Assert surviving candidates are A, C, D
!(assertEqual (getExemplarTree (car-atom (survivingPop))) (pipeTreeA))
!(assertEqual (getExemplarTree (car-atom (cdr-atom (survivingPop)))) (pipeTreeC))
!(assertEqual (getExemplarTree (car-atom (cdr-atom (cdr-atom (survivingPop))))) (pipeTreeD))

;; Verify cache synchronization:
;; Culled candidate B must be evicted from &dstCache
!(assertEqual
    (let* (($tA (pipeTreeA)) ($tB (pipeTreeB)))
       (collapse (match &dstCache (dst $tA $tB $d) $d)))
    ())

;; Surviving candidate pair (A C) must remain in &dstCache
!(assertEqual
    (let* (($tA (pipeTreeA)) ($tC (pipeTreeC)))
       (== (collapse (match &dstCache (dst $tA $tC $d) $d)) ()))
    False)

;; ============================================================
;;  5. Diversity Pressure Autoscaling
;; ============================================================

;; Disabled autoscale leaves pressure untouched
!(set-param diversityPressure 0.5)
!(set-param diversityAutoscale False)
!(assertEqual (autoscaleDiversity 0.0 -8.0) 0.5)
!(assertEqual (param diversityPressure) 0.5)

;; Zero diversity pressure ignores autoscale
!(set-param diversityPressure 0.0)
!(set-param diversityAutoscale True)
!(assertEqual (autoscaleDiversity 0.0 -8.0) 0.0)
!(assertEqual (param diversityPressure) 0.0)

;; Active autoscale on 3-bit parity:
;; best = 0.0, worst = -8.0 -> magnitude = 0.0 - (-8.0) = 8.0
;; Hand calculation: pressure = 0.5 * 8.0 = 4.0
!(set-param diversityPressure 0.5)
!(set-param diversityAutoscale True)
!(assertEqual (autoscaleDiversity 0.0 -8.0) 4.0)
!(assertEqual (param diversityPressure) 4.0)

;; Active autoscale on 5-bit parity (32 truth-table rows):
;; best = 0.0, worst = -32.0 -> magnitude = 32.0
;; Hand calculation: pressure = 0.01 * 32.0 = 0.32
!(set-param diversityPressure 0.01)
!(set-param diversityAutoscale True)
!(assertEqual (autoscaleDiversity 0.0 -32.0) 0.32)
!(assertEqual (param diversityPressure) 0.32)

;; Restore default parameters at end of test
!(set-param diversityPressure 0.0)
!(set-param diversityAutoscale False)
