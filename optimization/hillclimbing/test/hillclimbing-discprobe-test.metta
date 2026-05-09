!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../../utilities/list-methods)
!(import! &self ../../../utilities/nodeId)
!(import! &self ../../../utilities/map)
!(import! &self ../../../utilities/ordered-multimap)
!(import! &self ../../../utilities/lazy-random-selector)
!(import! &self ../../../utilities/pair)

!(import! &self ../../../reduct/boolean-reduct/rte-helpers)
!(import! &self ../../../reduct/boolean-reduct/cut-unnecessary-or)
!(import! &self ../../../reduct/boolean-reduct/cut-unnecessary-and)
!(import! &self ../../../reduct/boolean-reduct/n-ary-propagate-not)
!(import! &self ../../../reduct/boolean-reduct/n-ary-gather-junctors)
!(import! &self ../../../reduct/boolean-reduct/delete-inconsistent-handle)
!(import! &self ../../../reduct/boolean-reduct/zero-constraint-subsumption)
!(import! &self ../../../reduct/boolean-reduct/one-constraint-subsumption)
!(import! &self ../../../reduct/boolean-reduct/promote-common-constraints)
!(import! &self ../../../reduct/boolean-reduct/reduce-to-elegance)

!(import! &self ../../../utilities/tree)

!(import! &self ../../../representation/knob-representation)
!(import! &self ../../../representation/lsk)
!(import! &self ../../../representation/disc-probe)
!(import! &self ../../../representation/logical-probe)
!(import! &self ../../../representation/logical-canonize)
!(import! &self ../../../representation/sample-logical-perms)
!(import! &self ../../../representation/add-logical-knobs)
!(import! &self ../../../representation/build-logical)
!(import! &self ../../../representation/build-knobs)
!(import! &self ../../../representation/knob-mapper)
!(import! &self ../../../representation/representation)
!(import! &self ../../../representation/create-representation)
!(import! &self ../../../representation/instance)

!(import! &self ../../../moses/neighborhood-sampling)

!(import! &self ../../../scoring/fitness)
!(import! &self ../../../scoring/bscore)
!(import! &self ../../../scoring/cscore)
!(import! &self ../../../scoring/complexity-based-scorer)

!(import! &self ../../../deme/deme-id-creation)
!(import! &self ../../../deme/create-deme)
!(import! &self ../../../deme/score-deme)
!(import! &self ../../../deme/expand-deme)

!(import! &self ../cross-top-one-helpers)
!(import! &self ../cross-top-one)
!(import! &self ../hill-climbing-helpers)

;; ──────────────────────────────────────────────────────────────
;; Shared helpers
;; ──────────────────────────────────────────────────────────────

;; Extract the disallowed list stored inside an LSK.
(= (getDisallowed $lsk)
   (let (mkDiscKnob $k $m $c $d $dis) (getDiscKnob $lsk) $dis))

;; True when a scored instance has received a real score (not worst).
(= (isScored (mkSInst (mkPair $inst $score))) (~= $score (worstCscore)))

;; ──────────────────────────────────────────────────────────────
;; Test fixtures
;; ──────────────────────────────────────────────────────────────

;; Standard two-knob AND deme (mirrors hill-climbing-helpers-test.metta).
(= (andDeme)
   (mkDeme
     (mkRep
       (mkKbMap
         (mkDscKbMp (cons ((mkNodeId (1)) 0) (cons ((mkNodeId (2)) 1) ())))
         (mkDscMp
           (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
           (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
           ()))))
       (mkTree (mkNode AND)
         (cons (mkNullVex (cons (mkTree (mkNode A) ()) ()))
         (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) ()))))
     (mkSInstSet ())
     (mkDemeId "and-deme")))

;; Truth table for AND(A, B).
(= (andTable)
   (createTruthTableBScore 2
     (mkITable
       (cons (cons False (cons False (cons False ())))
       (cons (cons True  (cons False (cons False ())))
       (cons (cons False (cons True  (cons False ())))
       (cons (cons True  (cons True  (cons True  ()))) ()))))
       (cons A (cons B (cons O ()))))))

;; A two-knob disc map where knob-1 has been disc-probed:
;;   knob-1 → disallowed [1 2] → effective multip 1 (fully pruned)
;;   knob-2 → no disallowed    → effective multip 3
(= (prunedDisc)
   (mkDscMp
     (cons ((mkDiscSpec 3)
            (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0)
                               (cons (mkDiscSpec 1) (cons (mkDiscSpec 2) ())))))
     (cons ((mkDiscSpec 3)
            (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
     ()))))

;; A more-pruned variant:
;;   knob-1 -> disallowed [1 2] -> effective multip 1 (fully pruned)
;;   knob-2 -> disallowed [2]   -> effective multip 2 (one variant left)
(= (morePrunedDisc)
   (mkDscMp
     (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) (cons (mkDiscSpec 1) (cons (mkDiscSpec 2) ())))))
     (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) (cons (mkDiscSpec 2) ()))))
     ()))))

;; Full (no pruning) disc map: both knobs have effective multip 3.
(= (fullDisc)
   (mkDscMp
     (cons ((mkDiscSpec 3)
            (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
     (cons ((mkDiscSpec 3)
            (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
     ()))))

;; Build the same AND deme with an explicit disc map so hillclimbing can be
;; compared before and after disc-probe pruning.
(= (andDemeWithDisc $disc $id)
   (mkDeme
     (mkRep
       (mkKbMap
         (mkDscKbMp (cons ((mkNodeId (1)) 0) (cons ((mkNodeId (2)) 1) ())))
         $disc)
       (mkTree (mkNode AND)
         (cons (mkNullVex (cons (mkTree (mkNode A) ()) ()))
         (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) ()))))
     (mkSInstSet ())
     (mkDemeId $id)))

;; Return the distance-1 search size seen by hillclimbing for a deme:
;;   (estimated-neighborhood actual-exhaustive-neighborhood)
;; `estimateNeighborhood` is the heuristic hillclimbing uses before sampling,
;; while `generateAllInNeighborhoodForDisc` is the exhaustive path used when the
;; requested sample size covers the available neighborhood.
(= (hillClimbingDistanceOneSearchStats $deme)
   (let*
     (($center (mkInst (cons 0 (cons 0 ()))))
      ($disc (getDisk $deme))
      ($estimated (estimateNeighborhood 1 $disc))
      ($actual (List.length (generateAllInNeighborhoodForDisc (mkDscMp $disc) $center 1))))
     ($estimated $actual)))

;; ──────────────────────────────────────────────────────────────
;; Group A  –  discProbe: disallowed-setting classification
;; ──────────────────────────────────────────────────────────────

;; A1  –  Useful knob (B added to AND A) → no settings disallowed.
;; (AND A B) does not simplify, so nothing is pruned.
!(assertEqual
   (let*
     (($ex  (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
      (($t $lsk) (logicalSubtreeKnob $ex (mkNodeId (0)) (mkTree (mkNode B) ())))
      ($pl (discProbe $t (mkNodeId (0)) $lsk)))
     (== (getDisallowed $pl) ()))
   True)

;; A2  –  Redundant knob: (OR A) added to (AND A) → reduces to A.
;; Setting 1 (present) must be in the disallowed list.
!(assertEqual
   (let*
     (($ex  (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
      ($sub (mkTree (mkNode OR)  (cons (mkTree (mkNode A) ()) ())))
      (($t $nid) (appendChild $ex (mkNodeId (0)) (mkNullVex (cons $sub ()))))
      ($lsk (mkLSK (mkDiscKnob (mkKnob $nid) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
      ($pl  (discProbe $t (mkNodeId (0)) $lsk))
      ($_ (println! (Probbed knob settings $pl))))
     (List.contains (mkDiscSpec 1) (getDisallowed $pl)))
   True)

;; A3  –  Conflict: negated setting of A-knob yields (AND A (NOT A)) → False.
;; Setting 2 (negated) must be in the disallowed list.
!(assertEqual
   (let*
     (($ex  (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
      (($t $nid) (appendChild $ex (mkNodeId (0)) (mkNullVex (cons (mkTree (mkNode A) ()) ()))))
      ($lsk (mkLSK (mkDiscKnob (mkKnob $nid) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
      ($pl  (discProbe $t (mkNodeId (0)) $lsk)))
     (List.contains (mkDiscSpec 2) (getDisallowed $pl)))
   True)

;; A4  –  Double-negation (NOT (NOT B)) stays allowed:
;; (AND A B) is no simpler than the probed tree, so setting 1 is NOT disallowed.
!(assertEqual
   (let*
     (($ex  (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
      ($sub (mkTree (mkNode NOT) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode B) ()) ())) ())))
      (($t $nid) (appendChild $ex (mkNodeId (0)) (mkNullVex (cons $sub ()))))
      ($lsk (mkLSK (mkDiscKnob (mkKnob $nid) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
      ($pl  (discProbe $t (mkNodeId (0)) $lsk)))
     (not (List.contains (mkDiscSpec 1) (getDisallowed $pl))))
   True)

;; ──────────────────────────────────────────────────────────────
;; Group B  –  allDisallowed & effective multiplicity
;; ──────────────────────────────────────────────────────────────

;; B1  –  allDisallowed returns True when both non-default settings are pruned.
!(assertEqual
   (let*
     (($lsk (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0)
                               (cons (mkDiscSpec 1) (cons (mkDiscSpec 2) ()))))))
     (allDisallowed $lsk))
   True)

;; B2  –  getKnobMultip reflects disallowed settings: raw 3, disallowed 2 → effective 1.
!(assertEqual
   (let*
     (($lsk (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0)
                               (cons (mkDiscSpec 1) (cons (mkDiscSpec 2) ()))))))
     (== (getKnobMultip $lsk) (mkMultip 1)))
   True)

;; B3  –  allDisallowed returns False when no settings are pruned.
!(assertEqual
   (let*
     (($lsk (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))))
     (allDisallowed $lsk))
   False)

;; ──────────────────────────────────────────────────────────────
;; Group C  –  logicalProbe drops fully-pruned knobs
;; ──────────────────────────────────────────────────────────────

;; C1  –  (OR A) is fully pruned by discProbe inside logicalProbe;
;; the returned knob tuple must equal the empty seed.
;; Pattern mirrors disc-probe-test.metta test 7.
!(assertEqual
   (let*
     (($ex  (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
      ($sub (mkTree (mkNode OR)  (cons (mkTree (mkNode A) ()) ())))
      (($knobs $_) (logicalProbe $ex (mkNodeId (0)) ($sub) True (seed))))
     (== $knobs (seed)))
   True)

;; C2  –  In-exemplar knob: effective setting 0 maps to actual 1.
;; logicalSubtreeKnob for an existing child sets default to 1.
!(assertEqual
   (let*
     (($ex  (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
      (($t $lsk) (logicalSubtreeKnob $ex (mkNodeId (0)) (mkTree (mkNode A) ())))
      ($pl  (discProbe $t (mkNodeId (0)) $lsk)))
     (and (== (mapEffectiveDiscSpec $pl 0) 1)
          (not (List.contains (mkDiscSpec 1) (getDisallowed $pl)))))
   True)

;; ──────────────────────────────────────────────────────────────
;; Group D  –  Neighbourhood generation with disc-probed knobs
;; ──────────────────────────────────────────────────────────────

;; D1  –  Full disc map (two knobs, multip 3 each):
;; distance-1 neighbourhood must have ≥ 4 instances (2 knobs × 2 non-default values).
!(assertEqual
   (let*
     (($center (mkInst (cons 0 (cons 0 ()))))
      ($nbrs   (generateAllInNeighborhoodForDisc (fullDisc) $center 1))
      ($cnt    (List.length $nbrs)))
     (>= $cnt 4))
   True)

;; D2  –  Pruned disc map (knob-1 fully pruned, knob-2 full):
;; distance-1 neighbourhood must be strictly smaller than the full case (≤ 2).
!(assertEqual
   (let*
     (($center (mkInst (cons 0 (cons 0 ()))))
      ($prunedNbrs (generateAllInNeighborhoodForDisc (prunedDisc) $center 1))
      ($fullNbrs   (generateAllInNeighborhoodForDisc (fullDisc)   $center 1))
      ($pc (List.length $prunedNbrs))
      ($fc (List.length $fullNbrs)))
     (< $pc $fc))
   True)

;; ──────────────────────────────────────────────────────────────
;; Group E  –  Hillclimbing integration with disc-probed demes
;; ──────────────────────────────────────────────────────────────

;; E1  –  Standard hillclimbing on the full AND deme terminates and
;; returns a non-empty scored instance set.
;; (Mirrors the baseline test in hillclimbing-helpers-test.metta.)
!(assertEqual
   (let*
     ((($inst (mkDeme $_ (mkSInstSet $instSet) $__) $state)
        (hillClimbing (andDeme) (andTable)
                      (mkInst (cons 0 (cons 0 ())))
                      (mkParams applyComplexityBasedScore ())))
      ($cnt     (List.length $instSet))
      ($anyScored (List.any (List.map isScored $instSet))))
     ((>= $cnt 2) $anyScored))
   (True True))

;; E2  –  Disc probing changes the search space that hillclimbing sees.
;; With both knobs available, distance-1 hillclimbing estimates a larger
;; neighborhood and has four exhaustive variants. When knob-1 is fully pruned
;; by discProbe, the same distance only exposes the two variants from knob-2.
!(assertEqual
   (let*
     ((($fullEstimate $fullActual)
        (hillClimbingDistanceOneSearchStats
          (andDemeWithDisc (fullDisc) "full-hc-step")))
      (($prunedEstimate $prunedActual)
        (hillClimbingDistanceOneSearchStats
          (andDemeWithDisc (prunedDisc) "pruned-hc-step"))))
     ($fullEstimate $fullActual $prunedEstimate $prunedActual
                    (< $prunedEstimate $fullEstimate)
                    (< $prunedActual $fullActual)))
   (12 4 8 2 True True))

;; E3  –  If the second knob is also partially pruned, hillclimbing shrinks
;; the same distance-1 search again. Only one non-default setting remains
;; reachable, so exhaustive variants drop from 2 to 1.
!(assertEqual
   (let*
     ((($prunedEstimate $prunedActual)
        (hillClimbingDistanceOneSearchStats
          (andDemeWithDisc (prunedDisc) "pruned-hc-step")))
      (($morePrunedEstimate $morePrunedActual)
        (hillClimbingDistanceOneSearchStats
          (andDemeWithDisc (morePrunedDisc) "more-pruned-hc-step"))))
     ($prunedEstimate $prunedActual $morePrunedEstimate $morePrunedActual
                     (< $morePrunedEstimate $prunedEstimate)
                     (< $morePrunedActual $prunedActual)))
   (8 2 6 1 True True))
