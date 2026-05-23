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
          ($lsk (mkLSK (mkDiscKnob (mkKnob $nullId) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
          ($probedLsk (discProbe $treeWithNull (mkNodeId (0)) $lsk))
         )
         (List.contains (mkDiscSpec 1) (getDisallowed $probedLsk)))
    True)

;; Redundant negated setting is disallowed: (AND A (NOT A)) reduces.
!(assertEqual
    (let* (
          ($exemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
          (($treeWithNull $nullId) (appendChild $exemplar (mkNodeId (0)) (mkNullVex (cons (mkTree (mkNode A) ()) ()))))
          ($lsk (mkLSK (mkDiscKnob (mkKnob $nullId) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
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
          (($knobs $updatedTree) (logicalProbe $exemplar (mkNodeId (0)) ((mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ()))) True (seed) False))
         )
         (== $knobs (seed)))
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
        ($disallowedKnobs (filter-atom (MultiMap.values $disc1) $knob (not (== (getDisallowedSpecs $knob) ()))))
      )
      (and (and (== (cdr-atom $repPop) ())
                (< (MultiMap.length $disc1) 29))
           (not (== $disallowedKnobs ()))))
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