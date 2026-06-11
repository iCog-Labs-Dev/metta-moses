!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/nodeId)

!(import! &self ../../reduct/boolean-reduct/rte-helpers)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-or)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-and)
!(import! &self ../../reduct/boolean-reduct/n-ary-propagate-not)
!(import! &self ../../reduct/boolean-reduct/n-ary-gather-junctors)
!(import! &self ../../reduct/boolean-reduct/delete-inconsistent-handle)
!(import! &self ../../reduct/boolean-reduct/zero-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/one-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/promote-common-constraints)
!(import! &self ../../reduct/boolean-reduct/reduce-to-elegance)

!(import! &self ../../utilities/tree)

!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/lsk)
!(import! &self ../../representation/disc-probe)
!(import! &self ../../representation/logical-probe)
!(import! &self ../../representation/logical-canonize)
!(import! &self ../../representation/sample-logical-perms)
!(import! &self ../../representation/add-logical-knobs)
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/build-knobs)

(= (getDisallowed $lsk)
   (let (mkDiscKnob $m $c $d $dis) (getDiscKnob $lsk) $dis))

;; Useful knobs stay unpruned.
!(assertEqual
    (let*
      (
        ($exemplar (mkTree (mkNode AND) ((mkTree (mkNode A) ()))))
        (($controlled $lsk) (logicalSubtreeKnob $exemplar (mkTree (mkNode B) ())))
        (($probeTree $targetId) (appendChild $exemplar (mkNodeId (0)) $controlled))
        ($probedLsk (discProbe $probeTree (mkNodeId (0)) $targetId $lsk))
      )
      (== (getDisallowed $probedLsk) ()))
    True)

;; Redundant present setting is disallowed: (AND A (OR A)) reduces.
!(assertEqual
    (let*
      (
        ($exemplar (mkTree (mkNode AND) ((mkTree (mkNode A) ()))))
        ($subtree (mkTree (mkNode OR) ((mkTree (mkNode A) ()))))
        (($controlled $lsk) (logicalSubtreeKnob $exemplar $subtree))
        (($probeTree $targetId) (appendChild $exemplar (mkNodeId (0)) $controlled))
        ($probedLsk (discProbe $probeTree (mkNodeId (0)) $targetId $lsk))
      )
      (List.contains (mkDiscSpec 1) (getDisallowed $probedLsk)))
    True)

;; Redundant negated setting is disallowed: (AND A (NOT A)) reduces.
!(assertEqual
    (let*
      (
        ($exemplar (mkTree (mkNode AND) ((mkTree (mkNode A) ()))))
        ($controlled (mkNullVex ((mkTree (mkNode A) ()))))
        ($lsk (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))
        (($probeTree $targetId) (appendChild $exemplar (mkNodeId (0)) $controlled))
        ($probedLsk (discProbe $probeTree (mkNodeId (0)) $targetId $lsk))
      )
      (List.contains (mkDiscSpec 2) (getDisallowed $probedLsk)))
    True)

;; Default logicalProbe/buildKnobs behavior keeps disc probing disabled.
!(assertEqual
    (let*
      (
        ($exemplar (mkTree (mkNode AND) ((mkTree (mkNode A) ()))))
        (($knobs $updatedTree) (logicalProbe $exemplar ((mkTree (mkNode OR) ((mkTree (mkNode A) ())))) True))
        ($firstKnob (car-atom $knobs))
      )
      (== (getDisallowed $firstKnob) ()))
    True)

!(resetState &knobCount)

;; Passing disable-discprobe=False enables pruning and drops fully pruned knobs.
!(assertEqual
    (let*
      (
        ($exemplar (mkTree (mkNode AND) ((mkTree (mkNode A) ()))))
        (($knobs $updatedTree)
            (logicalProbe $exemplar (mkNodeId (0)) (mkNodeId (0))
                          ((mkTree (mkNode OR) ((mkTree (mkNode A) ()))))
                          True False))
      )
      (== $knobs ()))
    True)

!(resetState &knobCount)

;; mapEffectiveDiscSpec skips disallowed holes: effective 1 maps to actual 2.
!(assertEqual
    (let*
      (
        ($lsk (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ((mkDiscSpec 1)))))
      )
      (== (mapEffectiveDiscSpec $lsk 1) 2))
    True)

;; Opting buildKnobs into disc probing reduces knob count for redundant knobs.
!(assertEqual
    (let*
      (
        ($exemplar (mkTree (mkNode AND) ((mkTree (mkNode A) ()))))
        (($unprobedTree $unprobedMap) (buildKnobs $exemplar () (A B) True))
        ($_ (resetState &knobCount))
        (($probedTree $probedMap) (buildKnobs $exemplar () (A B) False))
      )
      (< (MultiMap.length $probedMap) (MultiMap.length $unprobedMap)))
    True)
