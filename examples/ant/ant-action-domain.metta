;; ============================================================================
;; ant-action-domain.metta -- the classic Santa Fe ant as a GENERAL action
;; domain, on the shared action path (the fitness-params contract).
;;
;; This is the ant analog of examples/tic-tac-toe/ttt-action-registration.metta:
;; the file DEFINES the domain -- world, actions, perception, fitness, best
;; score -- and binds NO params, so merely loading it never turns a (moses)
;; run into an action run. To RUN the classic demo:
;;
;;   --problem=ant          (self-contained: binds the four params itself)
;;   or         !(moses) with the four params bound, e.g.:
;;   !(set-param fitness antFitness)
;;   !(set-param bestScore antBestScore)
;;   !(set-param actions (quote (antMoveForward antTurnLeft antTurnRight)))
;;   !(set-param perceptions (quote (antFoodAhead)))
;;
;; or --fitness=antFitness --bestScore=antBestScore on the CLI (the tuple
;; params still have to be set in-script).
;;
;; NOTHING in the shared pipeline (deme/, optimization/, scoring/) knows an
;; ant exists: the evaluator (scoring/action-eval), the scorer
;; (scoring/action-score), and the deme lifecycle dispatch on nothing more
;; than the four params and the tagged (mkActionCtx ...) context. The
;; experiment-specific world, trails, and episode loop below are PRIVATE to
;; this file; the framework only hands the fitness an episode ordinal.
;;
;; LOAD ORDER: no imports here -- this file must load AFTER
;; scoring/action-eval (evalAction) and utilities/ (isEven, index-atom,
;; size-atom, List.replaceAt), exactly as moses.metta places it. The classic
;; reference (OpenCog/Moses/examples/example-ant/) uses a 32x32 toroidal
;; Santa Fe trail, 600-step budget, optimum 89; the scaled trails below make
;; every trace readable (see examples/tests/ant-action-test.metta for the
;; scaled + classic-scale + literal Santa Fe runs).
;; ============================================================================

;; ---- grid helpers (domain-local, plain data plumbing) ----------------------
(= (antWrap $i $n) (if (< $i 0) (+ $i $n) (if (>= $i $n) (- $i $n) $i)))

(= (antCellAt $grid (mkPair $x $y))
   (index-atom (index-atom $grid $y) $x))

;; cell replacement = List.replaceAt (positions are toroidally wrapped, so
;; indices are always in range).
(= (antSetCell $grid (mkPair $x $y) $v)
   (let* (
          ($row (index-atom $grid $y))
          ($newRow (List.replaceAt $row $x $v)))
     (List.replaceAt $grid $y $newRow)))

;; position ahead of the ant, toroidal wrap (classic: (x+1) % ANT_X etc.)
(= (antAheadPos $grid $pos $dir)
   (let* (
          ($w (size-atom (index-atom $grid 0)))
          ($h (size-atom $grid))
          ($x (Pair.first $pos))
          ($y (Pair.second $pos)))
     (case $dir
       ((E (mkPair (antWrap (+ $x 1) $w) $y))
        (W (mkPair (antWrap (- $x 1) $w) $y))
        (S (mkPair $x (antWrap (+ $y 1) $h)))
        (N (mkPair $x (antWrap (- $y 1) $h)))))))

(= (antLeftOf $dir)  (case $dir ((N W) (W S) (S E) (E N))))
(= (antRightOf $dir) (case $dir ((N E) (E S) (S W) (W N))))

;; ---- ACTIONS (cost 1 fuel; fail only when the budget is spent) -------------

;; antMoveForward: step onto the cell ahead; eat if it holds food. Classic
;; move_forward always "succeeds"; eating is a side effect. Placing the A marker
;; on the target cell consumes any food there, and the vacated cell becomes E --
;; marker and (mkPair $x $y) move together.
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

;; ---- PERCEPTION (free, read-only -- classic is_food_ahead) -----------------
(= (antFoodAhead $params (mkAntWorld $grid $pos $dir $eaten $fuel))
   (let $ahead (antAheadPos $grid $pos $dir)
        (mkARes (== (antCellAt $grid $ahead) F) (mkAntWorld $grid $pos $dir $eaten $fuel))))

;; ---- TRAILS: which world an episode runs on is PRIVATE to the fitness ------
;; Two 5-pellet trails, ant at (0 0), fuel 20. antFitness alternates the
;; trails by episode-ordinal parity, so a candidate is rewarded for following
;; trails IN GENERAL, not for memorizing one map.
(= (antTrailStraight) ((A F F F F F E E)
                       (E E E E E E E E)
                       (E E E E E E E E)))

(= (antTrailCorner) ((A F F F E E E E)
                     (E E E F E E E E)
                     (E E E F E E E E)
                     (E E E E E E E E)
                     (E E E E E E E E)))

(= (antFuelBudget) 20)

;; One episode: classic's operator() do-while -- re-run the whole program on the
;; world it produced, stop when fuel is spent or a pass makes no progress
;; (ant_scoring.cc:55-62: `if (at_time == tmp) break;`). Score = pellets.
(= (antRunEpisode $exp $world)
   (let (mkAntWorld $g $p $d $eaten $fuel) $world
        (if (<= $fuel 0)
            $eaten
            (let (mkARes $v (mkAntWorld $g2 $p2 $d2 $e2 $f2)) (evalAction $exp $world)
                 (if (== $f2 $fuel)
                     $e2                                   ;; zero-progress pass -> stop
                     (antRunEpisode $exp (mkAntWorld $g2 $p2 $d2 $e2 $f2)))))))

;; ---- THE FITNESS BINDING (the whole shared contract) ------------------------
;; ($fn $exp $i) -> Number: even ordinals run the straight trail, odd ones the
;; corner trail. Every trail holds 5 pellets, so the best over $n episodes is 5
;; each (antBestScore, the termination target).
(= (antFitness $exp $i)
   (antRunEpisode $exp
     (mkAntWorld (if (isEven $i) (antTrailStraight) (antTrailCorner))
                 (mkPair 0 0) E 0 (antFuelBudget))))
(= (antBestScore $n) (* 5 $n))

;; The seed exemplar for evolution: the empty and_seq (the action analog of
;; the boolean `true` tree).
(= (ant-exemplar) (mkTree (mkNode and_seq) ()))