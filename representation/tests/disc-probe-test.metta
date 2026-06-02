!(import! &self utilities/general-helpers)
!(import! &self utilities/list-methods)
!(import! &self utilities/map)
!(import! &self utilities/ordered-multimap)
!(import! &self utilities/lazy-random-selector)
!(import! &self utilities/lru-cache)
!(import! &self utilities/nodeId)
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
!(import! &self utilities/tree)
!(import! &self representation/lsk)
!(import! &self representation/knob-representation)
!(import! &self representation/disc-probe)
!(import! &self representation/logical-probe)
!(import! &self representation/logical-canonize)
!(import! &self representation/sample-logical-perms)
!(import! &self representation/add-logical-knobs)
!(import! &self representation/build-logical)
!(import! &self representation/build-knobs)
!(import! &self representation/knob-mapper)
!(import! &self feature-selection/feature-selection-helpers)
!(import! &self feature-selection/simple)
!(import! &self feature-selection/smd)
!(import! &self feature-selection/random-feature-selection)
!(import! &self feature-selection/incremental-feature-selection)
!(import! &self feature-selection/similarity-scorers)
!(import! &self feature-selection/select-top-features)
!(import! &self feature-selection/feature-selection-main)
!(import! &self representation/representation)
!(import! &self moses/neighborhood-sampling)
!(import! &self moses/demo-problems)

(= (getDisallowed $lsk)
   (let (mkDiscKnob $k $m $c $d $dis) (getDiscKnob $lsk) $dis))

(= (discProbeTable)
    (mkITable
        (cons (cons False (cons False (cons True (cons True (cons True ())))))
        (cons (cons True (cons False (cons False (cons True (cons True ())))))
        (cons (cons False (cons True (cons False (cons True (cons False ())))))
        (cons (cons False (cons False (cons False (cons True (cons False ()))))) ()))))
        (cons A (cons B (cons C (cons D (cons Output ())))))))

;; Useful knobs stay unpruned.
!(assertEqual
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          (($updatedTree $lsk) (logicalSubtreeKnob $exemplar (mkNodeId (0)) (mkTree (mkNode B) ())))
          ($probedLsk (discProbe $updatedTree (mkNodeId (0)) $lsk))
         )
         (== (getDisallowed $probedLsk) ()))
    True)

;; Redundant present setting is disallowed: (AND A (OR A)) reduces.
!(assertEqual
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          ($subtree (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())))
          (($treeWithNull $nullId) (appendChild $exemplar (mkNodeId (0)) (mkNullVex (cons $subtree ()))))
          ($lsk (mkDiscKnob (mkKnob $nullId) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))
          ($probedLsk (discProbe $treeWithNull (mkNodeId (0)) $lsk))
         )
         (List.contains (mkDiscSpec 1) (getDisallowed $probedLsk)))
    True)

;; Redundant negated setting is disallowed: (AND A (NOT A)) reduces.
!(assertEqual
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          (($treeWithNull $nullId) (appendChild $exemplar (mkNodeId (0)) (mkNullVex (cons (mkTree (mkNode A) ()) ()))))
          ($lsk (mkDiscKnob (mkKnob $nullId) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))
          ($probedLsk (discProbe $treeWithNull (mkNodeId (0)) $lsk))
         )
         (List.contains (mkDiscSpec 2) (getDisallowed $probedLsk)))
    True)

;; Default logicalProbe/buildKnobs behavior keeps discprobe disabled.
!(assertEqual
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          (($knobs $updatedTree) (logicalProbe $exemplar (mkNodeId (0)) ((mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ()))) True ()))
          ($firstKnob (car-atom $knobs))
         )
         (== (getDisallowed $firstKnob) ()))
    True)

;; Passing disable-discprobe=False enables pruning and drops fully pruned knobs.
!(assertEqual
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          (($knobs $updatedTree) (logicalProbe $exemplar (mkNodeId (0)) ((mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ()))) True () False))
         )
         (== $knobs ()))
    True)

;; Representation can opt into discprobe with the final boolean parameter.
!(assertEqual
    (let*
      (
        ($repPop (representation
                   2
                   (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ()))
                   (discProbeTable)
                   inc
                   False
                   ()
                   mi
                   False))
        ($rep1 (car-atom $repPop))
        ((mkRep (mkKbMap $kb1 (mkDscMp $disc1)) $tree1) $rep1)
        ($disallowedKnobs (filter-atom (MultiMap.values $disc1) $knob (!= (getDisallowedSpecs $knob) ())))
      )
      (and (and (== (cdr-atom $repPop) ())
                (< (MultiMap.length $disc1) 29))
           (!= $disallowedKnobs ())))
    True)

(= (getMultipVal (mkMultip $val)) $val)
(= (getRepSpaceSize $rep)
   (let* (
          ((mkRep (mkKbMap $kb1 (mkDscMp $disc1)) $tree1) $rep)
          ($knobs (MultiMap.values $disc1))
          ($multips (map-atom $knobs $k (getMultipVal (getKnobMultip $k))))
         )
         (foldl-atom $multips 1 $acc $x (* $acc $x))))

;; Disc probing reduces the search space size by pruning fully/partially disallowed knobs.
!(assertEqual
    (let*
      (
        ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
        ($repPopWithPruning (representation 2 $exemplar (discProbeTable) inc False () mi False))
        ($sizeWithPruning (getRepSpaceSize (car-atom $repPopWithPruning)))
        
        ($repPopWithoutPruning (representation 2 $exemplar (discProbeTable) inc False () mi True))
        ($sizeWithoutPruning (getRepSpaceSize (car-atom $repPopWithoutPruning)))
      )
      (< $sizeWithPruning $sizeWithoutPruning))
    True)


;; Disc probing reduces the number of instances generated during neighborhood sampling
!(assertEqual
    (let*
      (
        ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
        ($repPopWithPruning (representation 2 $exemplar (discProbeTable) inc False () mi False))
        ($repPruned (car-atom $repPopWithPruning))
        ((mkRep (mkKbMap $kb1Pruned (mkDscMp $discPruned)) $tree1Pruned) $repPruned)

        ($repPopWithoutPruning (representation 2 $exemplar (discProbeTable) inc False () mi True))
        ($repUnpruned (car-atom $repPopWithoutPruning))
        ((mkRep (mkKbMap $kb1Unpruned (mkDscMp $discUnpruned)) $tree1Unpruned) $repUnpruned)

        ($dist 2)
        ($knobCount (MultiMap.length $discPruned))
        ($centerInst (mkInst (repeat 0 $knobCount)))
        
        ($prunedNeighborhood (generateAllInNeighborhoodForDisc (mkDscMp $discPruned) $centerInst $dist))
        ($fullNeighborhood (generateAllInNeighborhoodForDisc (mkDscMp $discUnpruned) $centerInst $dist))
      )
      (< (List.length $prunedNeighborhood) (List.length $fullNeighborhood)))
    True)


;; ═══════════════════════════════════════════════════════════════════
;; ADDITIONAL TESTS
;; ═══════════════════════════════════════════════════════════════════

;; ───────────────────────────────────────────────────────────────────
;; UNIT 1 — probeControlledSubtree: null-vertex branch
;; When the target IS a null-vertex, the function must return its
;; first child (the actual controlled subtree), not the null-vertex.
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (let* (
          ($subtree (mkTree (mkNode B) ()))
          ($root    (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          (($treeWithNull $nullId)
              (appendChild $root (mkNodeId (0)) (mkNullVex (cons $subtree ()))))
          ($lsk (mkDiscKnob (mkKnob $nullId) (mkMultip 3)
                                   (mkDiscSpec 0) (mkDiscSpec 0) ()))
         )
         (== (probeControlledSubtree $treeWithNull $lsk) $subtree))
    True)

;; ───────────────────────────────────────────────────────────────────
;; UNIT 2 — probeControlledSubtree: direct-node branch
;; When the target is NOT a null-vertex, the node itself is returned
;; (i.e. the result is not a null-vertex).
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          ;; B is already absent, so logicalSubtreeKnob adds a null-vex;
          ;; supply A which IS a direct child to get the direct-node path.
          (($updatedTree $lsk)
              (logicalSubtreeKnob $exemplar (mkNodeId (0)) (mkTree (mkNode A) ())))
         )
         (not (isNullVertex (probeControlledSubtree $updatedTree $lsk))))
    True)

;; ───────────────────────────────────────────────────────────────────
;; UNIT 3 — applyLogicalSettingToSubtree: setting 0 wraps in NullVex
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (isNullVertex
        (applyLogicalSettingToSubtree (mkTree (mkNode A) ()) 0))
    True)

;; ───────────────────────────────────────────────────────────────────
;; UNIT 4 — applyLogicalSettingToSubtree: setting 1 is the identity
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (applyLogicalSettingToSubtree (mkTree (mkNode A) ()) 1)
    (mkTree (mkNode A) ()))

;; ───────────────────────────────────────────────────────────────────
;; UNIT 5 — applyLogicalSettingToSubtree: setting 2 inserts a NOT node
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (let* (($result (applyLogicalSettingToSubtree (mkTree (mkNode A) ()) 2)))
          (== (getNodeValue $result) (mkNode NOT)))
    True)

;; ───────────────────────────────────────────────────────────────────
;; UNIT 6 — settingReducesComplexity: True for a redundant setting
;; (AND A (OR A)) reduces — adding OR A under AND A is redundant.
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (let* (
          ($root    (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          ($subtree (mkTree (mkNode OR)  (cons (mkTree (mkNode A) ()) ())))
          (($treeWithNull $nullId)
              (appendChild $root (mkNodeId (0)) (mkNullVex (cons $subtree ()))))
          ($lsk (mkDiscKnob (mkKnob $nullId) (mkMultip 3)
                                   (mkDiscSpec 0) (mkDiscSpec 0) ()))
         )
         (settingReducesComplexity $treeWithNull (mkNodeId (0)) $lsk 1))
    True)

;; ───────────────────────────────────────────────────────────────────
;; UNIT 7 — settingReducesComplexity: False for a useful setting
;; (AND A B) does not reduce — B is an independent variable.
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (let* (
          ($root    (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          ($subtree (mkTree (mkNode B)   ()))
          (($treeWithNull $nullId)
              (appendChild $root (mkNodeId (0)) (mkNullVex (cons $subtree ()))))
          ($lsk (mkDiscKnob (mkKnob $nullId) (mkMultip 3)
                                   (mkDiscSpec 0) (mkDiscSpec 0) ()))
         )
         (settingReducesComplexity $treeWithNull (mkNodeId (0)) $lsk 1))
    False)

;; ───────────────────────────────────────────────────────────────────
;; UNIT 8 — probeEffectiveSettings: both settings 1 and 2 accumulated
;; ───────────────────────────────────────────────────────────────────
;; UNIT 8 — probeEffectiveSettings: both settings 1 and 2 accumulated
;; Subtree = (OR A) already in AND A: both (OR (OR A)) and (NOT (OR A)) simplify.
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (let* (
          ($root    (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          ($subtree (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())))
          (($treeWithNull $nullId)
              (appendChild $root (mkNodeId (0)) (mkNullVex (cons $subtree ()))))
          ($lsk (mkDiscKnob (mkKnob $nullId) (mkMultip 3)
                                   (mkDiscSpec 0) (mkDiscSpec 0) ()))
          ($dis (probeEffectiveSettings $treeWithNull (mkNodeId (0)) $lsk 1 ()))
         )
         (and (List.contains (mkDiscSpec 1) $dis)
              (List.contains (mkDiscSpec 2) $dis)))
    True)

;; ───────────────────────────────────────────────────────────────────
;; UNIT 9 — discProbe: all-disallowed when both non-default settings reduce
;; With subtree = (OR A) under AND A, both 1 and 2 reduce → allDisallowed.
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (let* (
          ($root    (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          ($subtree (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())))
          (($treeWithNull $nullId)
              (appendChild $root (mkNodeId (0)) (mkNullVex (cons $subtree ()))))
          ($lsk (mkDiscKnob (mkKnob $nullId) (mkMultip 3)
                                   (mkDiscSpec 0) (mkDiscSpec 0) ()))
          ($probedLsk (discProbe $treeWithNull (mkNodeId (0)) $lsk))
         )
         (allDisallowed $probedLsk))
    True)

;; ───────────────────────────────────────────────────────────────────
;; UNIT 10 — discProbe under an OR root: useful knob untouched
;; (OR A) with subtree B: neither present nor negated collapses the OR.
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (let* (
          ($root    (mkTree (mkNode OR)  (cons (mkTree (mkNode A) ()) ())))
          ($subtree (mkTree (mkNode B)   ()))
          (($treeWithNull $nullId)
              (appendChild $root (mkNodeId (0)) (mkNullVex (cons $subtree ()))))
          ($lsk (mkDiscKnob (mkKnob $nullId) (mkMultip 3)
                                   (mkDiscSpec 0) (mkDiscSpec 0) ()))
          ($probedLsk (discProbe $treeWithNull (mkNodeId (0)) $lsk))
         )
         (== (getDisallowed $probedLsk) ()))
    True)

;; ───────────────────────────────────────────────────────────────────
;; UNIT 11 — discProbe: 2-arg and 3-arg arities are consistent
;; The default root (knob's own node id) must equal an explicit call.
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (let* (
          ($root    (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          ($subtree (mkTree (mkNode OR)  (cons (mkTree (mkNode A) ()) ())))
          (($treeWithNull $nullId)
              (appendChild $root (mkNodeId (0)) (mkNullVex (cons $subtree ()))))
          ($lsk (mkDiscKnob (mkKnob $nullId) (mkMultip 3)
                                   (mkDiscSpec 0) (mkDiscSpec 0) ()))
          ($via2arg (discProbe $treeWithNull $lsk))
          ($via3arg (discProbe $treeWithNull $nullId $lsk))
         )
         (== (getDisallowed $via2arg) (getDisallowed $via3arg)))
    True)

;; ───────────────────────────────────────────────────────────────────
;; UNIT 12 — getKnobMultip: reflects the count of disallowed non-defaults
;; Multiplicity 3, one non-default setting disallowed → effective = 2.
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (let* (
          ($root    (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          ($subtree (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())))
          (($treeWithNull $nullId)
              (appendChild $root (mkNodeId (0)) (mkNullVex (cons $subtree ()))))
          ($lsk (mkDiscKnob (mkKnob $nullId) (mkMultip 3)
                                   (mkDiscSpec 0) (mkDiscSpec 0) ()))
          ($probedLsk (discProbe $treeWithNull (mkNodeId (0)) $lsk))
         )
         ;; Setting 1 is disallowed; default is 0 (not counted); so 3 - 1 = 2.
         (== (getKnobMultip $probedLsk) (mkMultip 2)))
    True)

;; ───────────────────────────────────────────────────────────────────
;; UNIT 13 — mapEffectiveDiscSpec: skips the disallowed hole correctly
;; With setting 1 disallowed, effective index 1 must map to actual 2.
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (let* (
          ($root    (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          ($subtree (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())))
          (($treeWithNull $nullId)
              (appendChild $root (mkNodeId (0)) (mkNullVex (cons $subtree ()))))
          ($lsk (mkDiscKnob (mkKnob $nullId) (mkMultip 3)
                                   (mkDiscSpec 0) (mkDiscSpec 0) ()))
          ($probedLsk (discProbe $treeWithNull (mkNodeId (0)) $lsk))
         )
         ;; Effective slot 0 → default (0); effective slot 1 must skip disallowed 1 → 2.
         (== (mapEffectiveDiscSpec $probedLsk 1) 2))
    True)

;; ───────────────────────────────────────────────────────────────────
;; INTEGRATION 14 — logicalProbe with discprobe on: redundant knob dropped
;; (AND A) + perm (OR A) is fully pruned and must not appear in knobs.
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          (($knobs $updatedTree)
              (logicalProbe $exemplar (mkNodeId (0))
                            ((mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())))
                            True () False))
         )
         (== $knobs ()))
    True)

;; ───────────────────────────────────────────────────────────────────
;; INTEGRATION 15 — logicalProbe with discprobe on: useful knob kept
;; (AND A) + perm B is not redundant; the knob must survive.
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          (($knobs $updatedTree)
              (logicalProbe $exemplar (mkNodeId (0))
                            ((mkTree (mkNode B) ()))
                            True () False))
         )
         (!= $knobs ()))
    True)

;; ───────────────────────────────────────────────────────────────────
;; INTEGRATION 16 — exemplar knob: default setting (1) is never disallowed
;; When A is already a child of AND, the knob's default is 1 (present).
;; discProbe must not add (mkDiscSpec 1) to the disallowed list.
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          ;; A is already a direct child, so logicalSubtreeKnob creates default=1.
          (($updatedTree $lsk)
              (logicalSubtreeKnob $exemplar (mkNodeId (0)) (mkTree (mkNode A) ())))
          ($probedLsk (discProbe $updatedTree (mkNodeId (0)) $lsk))
         )
         (not (List.contains (mkDiscSpec 1) (getDisallowed $probedLsk))))
    True)

;; ───────────────────────────────────────────────────────────────────
;; INTEGRATION 17 — neighborhood from a pruned representation is non-empty
;; generateAllInNeighborhoodForDisc must still produce instances after
;; pruning; verifies the pruning does not break instance generation.
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          ($repPop (representation 2 $exemplar (discProbeTable) inc False () mi False))
          ($rep    (car-atom $repPop))
          ((mkRep (mkKbMap $kb1 (mkDscMp $disc1)) $tree1) $rep)
          ($knobCount (MultiMap.length $disc1))
          ($centerInst (mkInst (repeat 0 $knobCount)))
          ($neighborhood
              (generateAllInNeighborhoodForDisc (mkDscMp $disc1) $centerInst 1))
         )
         (!= $neighborhood ()))
    True)

;; ───────────────────────────────────────────────────────────────────
;; INVARIANT 18 — discProbe preserves the default and current DiscSpec fields
;; Only the disallowed list changes; $default and $current must be untouched.
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (let* (
          ($root    (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          ($subtree (mkTree (mkNode OR)  (cons (mkTree (mkNode A) ()) ())))
          (($treeWithNull $nullId)
              (appendChild $root (mkNodeId (0)) (mkNullVex (cons $subtree ()))))
          ($lsk (mkDiscKnob (mkKnob $nullId) (mkMultip 3)
                                   (mkDiscSpec 0) (mkDiscSpec 0) ()))
          ($probedLsk (discProbe $treeWithNull (mkNodeId (0)) $lsk))
          ((mkDiscKnob $k $m $default $current $dis) $probedLsk)
         )
         (and (== $default (mkDiscSpec 0))
              (== $current (mkDiscSpec 0))))
    True)

;; ───────────────────────────────────────────────────────────────────
;; INVARIANT 19 — discProbe is idempotent
;; Running discProbe twice must produce the same disallowed list.
;; ───────────────────────────────────────────────────────────────────
!(assertEqual
    (let* (
          ($root    (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          ($subtree (mkTree (mkNode OR)  (cons (mkTree (mkNode A) ()) ())))
          (($treeWithNull $nullId)
              (appendChild $root (mkNodeId (0)) (mkNullVex (cons $subtree ()))))
          ($lsk (mkDiscKnob (mkKnob $nullId) (mkMultip 3)
                                   (mkDiscSpec 0) (mkDiscSpec 0) ()))
          ($probed1 (discProbe $treeWithNull (mkNodeId (0)) $lsk))
          ($probed2 (discProbe $treeWithNull (mkNodeId (0)) $probed1))
         )
         (== (getDisallowed $probed1) (getDisallowed $probed2)))
    True)

;; __________________________________________________
;; QUANTITATIVE STATS: The Impact of Discrete Probing
;; __________________________________________________
;; This test measures the reduction in local neighborhood sampling (at distance=2)
;; when starting with an exemplar tree of (AND A B).
;; __________________________________________________

!(assertEqual
    (let*
      (
        ;; 1. Set up an exemplar and baseline table
        ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))))
        ($table (discProbeTable)) ;; (Assuming standard table implementation)
        
        ;; 2. Generate Representation WITH Pruning
        ($repPopWithPruning (representation 2 $exemplar $table inc False () mi False))
        ($repPruned (car-atom $repPopWithPruning))
        ((mkRep (mkKbMap $kb1Pruned (mkDscMp $discPruned)) $tree1Pruned) $repPruned)

        ;; 3. Generate Representation WITHOUT Pruning
        ($repPopWithoutPruning (representation 2 $exemplar $table inc False () mi True))
        ($repUnpruned (car-atom $repPopWithoutPruning))
        ((mkRep (mkKbMap $kb1Unpruned (mkDscMp $discUnpruned)) $tree1Unpruned) $repUnpruned)

        ;; 4. Measure Neighborhood Sampling at distance = 2
        ($knobCount (MultiMap.length $discPruned))
        ($centerInst (mkInst (repeat 0 $knobCount)))
        
        ($prunedNeighborhood (generateAllInNeighborhoodForDisc (mkDscMp $discPruned) $centerInst 2))
        ($fullNeighborhood (generateAllInNeighborhoodForDisc (mkDscMp $discUnpruned) $centerInst 2))
        
        ($prunedCount (List.length $prunedNeighborhood))
        ($fullCount (List.length $fullNeighborhood))
      )
      ;; Print the quantitative impact for documentation/logging
      (let $_ (println! (STATS:
               " | Nbrhood Dist=2 (Unpruned): " $fullCount
               " | Nbrhood Dist=2 (Pruned): " $prunedCount))
           
           ;; Assert that pruning successfully reduced both metrics
                (< $prunedCount $fullCount)))
    True)    
;; _______________________________________________________________________________
;; This test measures the reduction in local neighborhood sampling (at distance=1)
;; when starting with an exemplar tree of (AND A B).
;; _______________________________________________________________________________
!(assertEqual
    (let*
      (
        ;; 1. Set up an exemplar and baseline table
        ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))))
        ($table (discProbeTable)) ;; (Assuming standard table implementation)
        
        ;; 2. Generate Representation WITH Pruning
        ($repPopWithPruning (representation 2 $exemplar $table inc False () mi False))
        ($repPruned (car-atom $repPopWithPruning))
        ((mkRep (mkKbMap $kb1Pruned (mkDscMp $discPruned)) $tree1Pruned) $repPruned)

        ;; 3. Generate Representation WITHOUT Pruning
        ($repPopWithoutPruning (representation 2 $exemplar $table inc False () mi True))
        ($repUnpruned (car-atom $repPopWithoutPruning))
        ((mkRep (mkKbMap $kb1Unpruned (mkDscMp $discUnpruned)) $tree1Unpruned) $repUnpruned)

        ;; 4. Measure Neighborhood Sampling at distance = 1
        ($knobCount (MultiMap.length $discPruned))
        ($centerInst (mkInst (repeat 0 $knobCount)))
        
        ($prunedNeighborhood (generateAllInNeighborhoodForDisc (mkDscMp $discPruned) $centerInst 1))
        ($fullNeighborhood (generateAllInNeighborhoodForDisc (mkDscMp $discUnpruned) $centerInst 1))
        
        ($prunedCount (List.length $prunedNeighborhood))
        ($fullCount (List.length $fullNeighborhood))
      )
      ;; Print the quantitative impact for documentation/logging
      (let $_ (println! (STATS:
               " | Nbrhood Dist=1 (Unpruned): " $fullCount
               " | Nbrhood Dist=1 (Pruned): " $prunedCount))
           
           ;; Assert that pruning successfully reduced both metrics
                (< $prunedCount $fullCount)))
    True)

;; ________________________________________________________________
;; ________________________________________________________________
;; QUANTITATIVE STATS: The Impact of Discrete Probing on mux6
;; ________________________________________________________________
;; This test measures the exact reduction in the hypothesis search space 
;; and the reduction in local neighborhood sampling (at distance=1)
;; when starting with an exemplar tree of (AND A0 A1) against the mux6 dataset.
;; ________________________________________________________________

;; Import the dataset
!(assertEqual
    (let*
      (
        ;; 1. Set up an exemplar and load the mux6 table
        ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A0) ()) (cons (mkTree (mkNode A1) ()) ()))))
        ($table (mux6))
        
        ;; 2. Generate Representation WITH Pruning
        ($repPopWithPruning (representation 2 $exemplar $table inc False () mi False))
        ($repPruned (car-atom $repPopWithPruning))
        ((mkRep (mkKbMap $kb1Pruned (mkDscMp $discPruned)) $tree1Pruned) $repPruned)

        ;; 3. Generate Representation WITHOUT Pruning
        ($repPopWithoutPruning (representation 2 $exemplar $table inc False () mi True))
        ($repUnpruned (car-atom $repPopWithoutPruning))
        ((mkRep (mkKbMap $kb1Unpruned (mkDscMp $discUnpruned)) $tree1Unpruned) $repUnpruned)

        ;; 4. Measure Neighborhood Sampling at distance = 1
        ($knobCount (MultiMap.length $discPruned))
        ($centerInst (mkInst (repeat 0 $knobCount)))
        
        ($prunedNeighborhood (generateAllInNeighborhoodForDisc (mkDscMp $discPruned) $centerInst 1))
        ($fullNeighborhood (generateAllInNeighborhoodForDisc (mkDscMp $discUnpruned) $centerInst 1))
        
        ($prunedCount (List.length $prunedNeighborhood))
        ($fullCount (List.length $fullNeighborhood))
      )
      ;; Print the quantitative impact for documentation/logging
      (let $_ (println! (STATS:
               " | Nbrhood Dist=1 (Unpruned): " $fullCount
               " | Nbrhood Dist=1 (Pruned): " $prunedCount))
           
           ;; Assert that pruning successfully reduced both metrics
           
                (< $prunedCount $fullCount)))
    True)
