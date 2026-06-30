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
!(import! &self ../../scoring/bscore)


!(py-call (random.seed 0))
;; Testcase for the addLogicalKnobs 

!(assertEqual (let* 
(
    (($updatedTree $mm)
     (addLogicalKnobs (mkTree (mkNode AND)
        ((mkTree (mkNode A) ()) (mkTree (mkNode B) ())))
        True () (A B)))
    ($mmpsEqual
     (MultiMap.equals $mm
     (((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))))))

    ($treesEqual
     (== $updatedTree
     (mkTree (mkNode AND) ((mkKnob (mkTree (mkNode A) ()) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())) 0) (mkKnob (mkTree (mkNode B) ()) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())) 1) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 2) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 3))))
    )
)
(and $mmpsEqual $treesEqual)
) True)

!(resetState &knobCount)

;; Testcase for the addLogicalKnobs 
!(assertEqual (let* 
(
    (($updatedTree $mm)
     (addLogicalKnobs 
       (mkTree (mkNode AND)
        (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ()) ())))())))
       True () (A B)))
    ($_ (println! (Tree: $updatedTree)))
    ($mmpsEqual 
     (MultiMap.equals $mm
                      (((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))))))

    ($treesEqual 
     (== $updatedTree
     (mkTree (mkNode AND) ((mkTree (mkNode OR) ((mkTree (mkNode B) ()) (mkTree (mkNode C) ()))) (mkKnob (mkTree (mkNode A) ()) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())) 0) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 1) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 2) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 3))) )
    )
)
(and $mmpsEqual $treesEqual)
) True)

!(resetState &knobCount)

!(assertEqual (let* 
(
    (($updatedTree $mm) 
     (addLogicalKnobs (mkTree (mkNode PRIORITIZED-OR)     
        (cons (mkTree (mkNode playcenter) ())
          (cons (mkTree (mkNode playcorner) ()) ())))
              (mkNodeId (0)) True () (playcenter playcorner)))
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
              (mkNodeId (0)) True () (playcenter)))
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
              (mkNodeId (0)) True () (playcenter playcorner playblock)))
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
                               (mkNodeId (0)) True () (playcenter playcorner)))
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
              (mkNodeId (0)) True () (playwin playfork playblock)))
    ($mmLength (MultiMap.length $mm))
    ($treeHasNullVex (not (== $updatedTree (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playwin) ()) (cons (mkTree (mkNode playfork) ()) (cons (mkTree (mkNode playblock) ()) ())))))))
)
(and (== $mmLength 5) $treeHasNullVex)
) True)
