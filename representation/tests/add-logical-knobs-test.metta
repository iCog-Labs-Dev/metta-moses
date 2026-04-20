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
!(import! &self ../lsk)
!(import! &self ../../representation/logical-canonize)
!(import! &self ../../representation/logical-probe)
!(import! &self ../sample-logical-perms) 
!(import! &self ../add-logical-knobs)
!(import! &self ../../representation/knob-representation)
!(import! &self ../../scoring/bscore)


!(py-call (random.seed 0))
;; Testcase for the addLogicalKnobs 
!(assertEqual (let* 
(
    (($updatedTree $mm) 
     (addLogicalKnobs (mkTree (mkNode AND)     
        (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode B) ()) ())))
              (mkNodeId (0)) True NilMMap (A B)))
    ($_ (println! $updatedTree))
    ($_ (println! $mm))
    ($mmpsEqual 
     (MultiMap.equals $mm 
     (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) NilMMap))))))

    ($treesEqual 
     (== $updatedTree
     (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) ()))))))
    )
)
$mmpsEqual
) True)

;; Testcase for the addLogicalKnobs 
!(assertEqual (let* 
(
    (($updatedTree $mm) 
     (addLogicalKnobs (mkTree (mkNode AND)     
        (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ()) ())))())))
              (mkNodeId (2)) True NilMMap (A B)))
    ($mmpsEqual 
     (MultiMap.equals $mm 
(ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) NilMMap))))))
    ($treesEqual 
     (== $updatedTree
     (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ()) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) ())))))) ()))) )
    )
)
(and $mmpsEqual $treesEqual)
) True)

!(assertEqual (let* 
(
    (($updatedTree $mm) 
     (addLogicalKnobs (mkTree (mkNode PRIORITIZED-OR)     
        (cons (mkTree (mkNode playcenter) ())
          (cons (mkTree (mkNode playcorner) ()) ())))
              (mkNodeId (0)) True NilMMap (playcenter playcorner)))
    ($mmLength (MultiMap.length $mm))
    ($treeHasNullVex (!= $updatedTree (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playcenter) ()) (cons (mkTree (mkNode playcorner) ()) ())))))
)
(and (== $mmLength 5) $treeHasNullVex)
) True)

;; addLogicalKnobs with PRIORITIZED-OR - single move
!(assertEqual (let* 
(
    (($updatedTree $mm) 
     (addLogicalKnobs (mkTree (mkNode PRIORITIZED-OR)     
        (cons (mkTree (mkNode playcenter) ()) ()))
              (mkNodeId (0)) True NilMMap (playcenter)))
    ($mmLength (MultiMap.length $mm))
    ($treeHasNullVex (!= $updatedTree (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playcenter) ()) ()))))
)
(and (== $mmLength 5) $treeHasNullVex)
) True)

;; addLogicalKnobs with PRIORITIZED-OR - three moves
!(assertEqual (let* 
(
    (($updatedTree $mm) 
     (addLogicalKnobs (mkTree (mkNode PRIORITIZED-OR)     
        (cons (mkTree (mkNode playcenter) ())
          (cons (mkTree (mkNode playcorner) ())
            (cons (mkTree (mkNode playblock) ()) ()))))
              (mkNodeId (0)) True NilMMap (playcenter playcorner playblock)))
    ($mmLength (MultiMap.length $mm))
    ($treeHasNullVex (!= $updatedTree (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playcenter) ()) (cons (mkTree (mkNode playcorner) ()) (cons (mkTree (mkNode playblock) ()) ()))))))
)
(and (== $mmLength 5) $treeHasNullVex)
) True)

;; Verify SSK knobs (multiplicity 2) are created for PRIORITIZED-OR
!(assertEqual 
    (let* (
        (($updatedTree $mm) (addLogicalKnobs 
                               (mkTree (mkNode PRIORITIZED-OR)
                                       (cons (mkTree (mkNode playcenter) ()) ()))
                               (mkNodeId (0)) True NilMMap (playcenter playcorner)))
        ($firstPair (car-atom (cdr-atom $mm)))
        ($knobWrapper (cdr-atom $firstPair))
        ($firstKnob (car-atom $knobWrapper))
        ($multi (getKnobMultip $firstKnob))
    )
    (== $multi (mkMultip 2))) True)

;; Verify different game moves work correctly
!(assertEqual (let* 
(
    (($updatedTree $mm) 
     (addLogicalKnobs (mkTree (mkNode PRIORITIZED-OR)     
        (cons (mkTree (mkNode playwin) ())
          (cons (mkTree (mkNode playfork) ())
            (cons (mkTree (mkNode playblock) ()) ()))))
              (mkNodeId (0)) True NilMMap (playwin playfork playblock)))
    ($mmLength (MultiMap.length $mm))
    ($treeHasNullVex (not (== $updatedTree (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playwin) ()) (cons (mkTree (mkNode playfork) ()) (cons (mkTree (mkNode playblock) ()) ())))))))
)
(and (== $mmLength 5) $treeHasNullVex)
) True)
