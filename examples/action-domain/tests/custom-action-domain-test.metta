;; ============================================================================
;; End-to-end regression test for the generic ACTION-domain API.
!(import! &self utilities/general-helpers)
!(import! &self parameters/registry)
!(import! &self parameters/defaults)

!(import! &self utilities/list-methods)
!(import! &self utilities/pair)
!(import! &self utilities/map)
!(import! &self utilities/ordered-multimap)
!(import! &self utilities/ordered-set)
!(import! &self utilities/ordered-multiset)
!(import! &self utilities/nodeId)
!(import! &self utilities/lazy-random-selector)
!(import! &self utilities/lru-cache)

!(import! &self reduct/boolean-reduct/rte-helpers)
!(import! &self reduct/boolean-reduct/cut-unnecessary-or)
!(import! &self reduct/boolean-reduct/cut-unnecessary-and)
!(import! &self reduct/boolean-reduct/n-ary-propagate-not)
!(import! &self reduct/boolean-reduct/n-ary-gather-junctors)
!(import! &self reduct/boolean-reduct/delete-inconsistent-handle)
!(import! &self reduct/boolean-reduct/zero-constraint-subsumption)
!(import! &self reduct/boolean-reduct/one-constraint-subsumption)
!(import! &self reduct/boolean-reduct/promote-common-constraints)
!(import! &self reduct/boolean-reduct/reduce-to-elegance)

!(callPredicate (Predicate (consult "moses/tests/rte-helpers-fast.pl")))

!(import! &self utilities/tree)

!(import! &self scoring/cacheSpace)
!(import! &self scoring/fitness)
!(import! &self scoring/boolean-ops)
!(import! &self scoring/action-registry)
!(import! &self scoring/action-eval)
!(import! &self scoring/action-ops)
!(import! &self scoring/bscore)
!(import! &self scoring/cscore)
!(import! &self scoring/action-score)

!(import! &self feature-selection/feature-selection-helpers)
!(import! &self feature-selection/similarity-scorers)
!(import! &self feature-selection/select-top-features)
!(import! &self feature-selection/simple)
!(import! &self feature-selection/smd)
!(import! &self feature-selection/incremental)
!(import! &self feature-selection/hc)
!(import! &self feature-selection/random-feature-selection)
!(import! &self feature-selection/feature-selection-main)

!(import! &self representation/knob-representation)
!(import! &self representation/lsk)
!(import! &self representation/disc-probe)
!(import! &self representation/logical-probe)
!(import! &self representation/sample-logical-perms)
!(import! &self representation/logical-canonize)
!(import! &self representation/add-logical-knobs)
!(import! &self representation/build-logical)
!(import! &self representation/build-action)
!(import! &self representation/build-knobs)
!(import! &self representation/knob-mapper)
!(import! &self representation/representation)
!(import! &self representation/create-representation)

!(import! &self scoring/complexity-based-scorer)

!(import! &self optimization/hillclimbing/crossover-helpers)
!(import! &self optimization/hillclimbing/crossover)
!(import! &self optimization/hillclimbing/hill-climbing-helpers)

!(import! &self deme/create-deme)
!(import! &self moses/neighborhood-sampling)

!(import! &self metapopulation/exemplar-type)
!(import! &self metapopulation/exemplar-selection)
!(import! &self metapopulation/metapopulation)

!(import! &self representation/instance)

!(import! &self deme/deme-id-creation)
!(import! &self deme/score-deme)
!(import! &self deme/merge-demes)
!(import! &self deme/expand-deme)

!(import! &self moses/action-domain-api)
!(import! &self moses/demo-problems)
!(import! &self moses/action-domain-runner)


;; ============================================================================
;; ANT DOMAIN
;; ============================================================================


(= (antWrap $i $n) (if (< $i 0) (+ $i $n) (if (>= $i $n) (- $i $n) $i)))

(= (antCellAt $grid (mkPair $x $y)) (index-atom (index-atom $grid $y) $x))

(= (antSetCell $grid (mkPair $x $y) $v)
   (let* (($row (index-atom $grid $y)) ($newRow (List.replaceAt $row $x $v)))
     (List.replaceAt $grid $y $newRow)))

(= (antAheadPos $grid $pos $dir)
   (let* (($w (size-atom (index-atom $grid 0))) ($h (size-atom $grid))
          ($x (Pair.first $pos)) ($y (Pair.second $pos)))
     (case $dir
       ((E (mkPair (antWrap (+ $x 1) $w) $y))
        (W (mkPair (antWrap (- $x 1) $w) $y))
        (S (mkPair $x (antWrap (+ $y 1) $h)))
        (N (mkPair $x (antWrap (- $y 1) $h)))))))

(= (antLeftOf $dir) (case $dir ((N W) (W S) (S E) (E N))))

(= (antRightOf $dir) (case $dir ((N E) (E S) (S W) (W N))))


;; ===========================================================================
;; ACTIONS
;; ============================================================================
(= (antMoveForward $params (mkAntWorld $grid $pos $dir $eaten $fuel))
   (if (<= $fuel 0)
       (mkARes False (mkAntWorld $grid $pos $dir $eaten $fuel))
       (let* (($ahead (antAheadPos $grid $pos $dir))
              ($target (antCellAt $grid $ahead))
              ($moved (antSetCell (antSetCell $grid $pos E) $ahead A)))
         (if (== $target F)
             (mkARes True (mkAntWorld $moved $ahead $dir (+ $eaten 1) (- $fuel 1)))
             (mkARes True (mkAntWorld $moved $ahead $dir $eaten (- $fuel 1)))))))



(= (antTurnLeft $params (mkAntWorld $grid $pos $dir $eaten $fuel))
   (if (<= $fuel 0)
       (mkARes False (mkAntWorld $grid $pos $dir $eaten $fuel))
       (mkARes True (mkAntWorld $grid $pos (antLeftOf $dir) $eaten (- $fuel 1)))))



(= (antTurnRight $params (mkAntWorld $grid $pos $dir $eaten $fuel))
   (if (<= $fuel 0)
       (mkARes False (mkAntWorld $grid $pos $dir $eaten $fuel))
       (mkARes True (mkAntWorld $grid $pos (antRightOf $dir) $eaten (- $fuel 1)))))


;; ============================================================================
;; PERCEPTIONS
;; ============================================================================
(= (antFoodAhead $params (mkAntWorld $grid $pos $dir $eaten $fuel))
   (let $ahead (antAheadPos $grid $pos $dir)
        (mkARes (== (antCellAt $grid $ahead) F)
                (mkAntWorld $grid $pos $dir $eaten $fuel))))


;; ============================================================================
;; DOMAIN-LEVEL EVALUATION TESTS
;; ============================================================================
(= (antTestWorld)
   (mkAntWorld ((A F E E E E E E) (E E E E E E E E) (E E E E E E E E))
               (mkPair 0 0) E 0 9))


;; Move onto food.
!(assertEqual
   (evalAction (quote (antMoveForward ())) (antTestWorld))
   (mkARes True (mkAntWorld ((E A E E E E E E) (E E E E E E E E) (E E E E E E E E))
                             (mkPair 1 0) E 1 8)))


;; Turn right, then move.
!(assertEqual
   (evalAction (quote (and_seq ((antTurnRight ()) (antMoveForward ())))) (antTestWorld))
   (mkARes True (mkAntWorld ((E F E E E E E E) (A E E E E E E E) (E E E E E E E E))
                             (mkPair 0 1) S 0 7)))


;; Perception is free.
!(assertEqual
   (evalAction (quote (antFoodAhead ())) (antTestWorld))
   (mkARes True (antTestWorld)))


;; Conditional action.
!(assertEqual
   (evalAction (quote (action_bool_if ((antFoodAhead ()) (antMoveForward ()) (antTurnRight ()))))
               (antTestWorld))
   (mkARes True (mkAntWorld ((E A E E E E E E) (E E E E E E E E) (E E E E E E E E))
                             (mkPair 1 0) E 1 8)))


;; Toroidal wrapping.
!(assertEqual
   (evalAction (quote (and_seq ((antTurnLeft ()) (antTurnLeft ()) (antMoveForward ()))))
               (antTestWorld))
   (mkARes True (mkAntWorld ((E F E E E E E A) (E E E E E E E E) (E E E E E E E E))
                             (mkPair 7 0) W 0 6)))


;; Budget exhaustion.
!(assertEqual
   (evalAction (quote (and_seq ((antMoveForward ()) (antMoveForward ()))))
               (mkAntWorld ((A F E E E E E E)) (mkPair 0 0) E 0 1))
   (mkARes False (mkAntWorld ((E A E E E E E E)) (mkPair 1 0) E 1 0)))


;; ============================================================================
;; FITNESS
;; ============================================================================
(= (antTrailStraight)
   ((A F F F F F E E) (E E E E E E E E) (E E E E E E E E)))

(= (antTrailCorner)
   ((A F F F E E E E) (E E E F E E E E) (E E E F E E E E)
    (E E E E E E E E) (E E E E E E E E)))

(= (antFuelBudget) 20)


;; Run one episode.
(= (antRunEpisode $exp $world)
   (let (mkAntWorld $g $p $d $eaten $fuel) $world
     (if (<= $fuel 0)
         $eaten
         (let (mkARes $v (mkAntWorld $g2 $p2 $d2 $e2 $f2)) (evalAction $exp $world)
           (if (== $f2 $fuel)
               $e2
               (antRunEpisode $exp (mkAntWorld $g2 $p2 $d2 $e2 $f2)))))))


;; Domain fitness.
(= (antFitness $exp $i)
   (antRunEpisode $exp
                  (mkAntWorld (if (isEven $i) (antTrailStraight) (antTrailCorner))
                              (mkPair 0 0) E 0 (antFuelBudget))))

(= (antBestScore $n) (* 5 $n))


;; Register fitness.
!(set-param fitness antFitness)
!(set-param bestScore antBestScore)

;; ============================================================================
;; ACTION DOMAIN
;; The domain definition is the only place where the domain exposes its
;; primitives and scoring functions to the generic ACTION-domain pipeline.
;; ============================================================================
(= (antActionDomain)
   (mkActionDomain
      (mkActionSpace (quote (antMoveForward antTurnLeft antTurnRight))
                     (quote (antFoodAhead))
                     antFitness
                     antBestScore)
      ()))

;; ===========================================
;; GENERIC CONFIGURATION
;; ===========================================
!(set-param seed 0)
!(set-param maxGen 2)
!(set-param nDeme 1)
!(set-param complexityRatio 3.5)
!(set-param nTrials 4)
!(set-param maxCandOutput 3)
!(set-param hcMaxEvals 60)


;; PUBLIC ACTION-DOMAIN API.
!(runActionDomain (antActionDomain))