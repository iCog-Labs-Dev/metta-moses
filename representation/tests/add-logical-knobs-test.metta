!(import! &self ../../utilities/tree)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/general-helpers)
!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/logical-probe)
!(import! &self ../../representation/knob-representation)
!(import! &self ../lsk)
!(import! &self ../../utilities/nodeId)
!(import! &self ../sample-logical-perms) 
!(import! &self ../add-logical-knobs)
!(import! &self ../../utilities/ordered-multimap) 
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../scoring/bscore)

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

!(py-call (random.seed 0))
;; Testcase for the addLogicalKnobs 
!(assertEqual (let* 
(
    (($updatedTree $mm) 
     (addLogicalKnobs (mkTree (mkNode AND)     
        (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode B) Nil) Nil)))
              (mkNodeId (0)) True NilMMap (A B)))
    ($_ (println! $updatedTree))
    ($_ (println! $mm))
    ($mmpsEqual 
     (MultiMap.equals $mm 
     (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (0 2))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (0 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) NilMMap))))))

    ($treesEqual 
     (== $updatedTree
     (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil))))))
    )
)
$mmpsEqual
) True)

;; Testcase for the addLogicalKnobs 
!(assertEqual (let* 
(
    (($updatedTree $mm) 
     (addLogicalKnobs (mkTree (mkNode AND)     
        (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil) Nil)))Nil)))
              (mkNodeId (2)) True NilMMap (A B)))
    ($mmpsEqual 
     (MultiMap.equals $mm 
(ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap))))))
    ($treesEqual 
     (== $updatedTree
     (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))))) Nil))) )
    )
)
(and $mmpsEqual $treesEqual)
) True)

!(assertEqual (let* 
(
    (($updatedTree $mm) 
     (addLogicalKnobs (mkTree (mkNode PRIORITIZED-OR)     
        (Cons (mkTree (mkNode play-center) Nil)
          (Cons (mkTree (mkNode play-corner) Nil) Nil)))
              (mkNodeId (0)) True NilMMap (play-center play-corner)))
    ($mmLength (MultiMap.length $mm))
    ($treeHasNullVex (not (== $updatedTree (mkTree (mkNode PRIORITIZED-OR) (Cons (mkTree (mkNode play-center) Nil) (Cons (mkTree (mkNode play-corner) Nil) Nil))))))
)
(and (== $mmLength 4) $treeHasNullVex)
) True)

;; Test 2: addLogicalKnobs with PRIORITIZED-OR - single move
!(assertEqual (let* 
(
    (($updatedTree $mm) 
     (addLogicalKnobs (mkTree (mkNode PRIORITIZED-OR)     
        (Cons (mkTree (mkNode play-center) Nil) Nil))
              (mkNodeId (0)) True NilMMap (play-center)))
    ($mmLength (MultiMap.length $mm))
    ($treeUnchanged (== $updatedTree (mkTree (mkNode PRIORITIZED-OR) (Cons (mkTree (mkNode play-center) Nil) Nil))))
)
(and (== $mmLength 2) $treeUnchanged)
) True)

;; Test 3: addLogicalKnobs with PRIORITIZED-OR - three moves
!(assertEqual (let* 
(
    (($updatedTree $mm) 
     (addLogicalKnobs (mkTree (mkNode PRIORITIZED-OR)     
        (Cons (mkTree (mkNode play-center) Nil)
          (Cons (mkTree (mkNode play-corner) Nil)
            (Cons (mkTree (mkNode play-block) Nil) Nil))))
              (mkNodeId (0)) True NilMMap (play-center play-corner play-block)))
    ($mmLength (MultiMap.length $mm))
    ($treeHasNullVex (not (== $updatedTree (mkTree (mkNode PRIORITIZED-OR) (Cons (mkTree (mkNode play-center) Nil) (Cons (mkTree (mkNode play-corner) Nil) (Cons (mkTree (mkNode play-block) Nil) Nil)))))))
)
(and (== $mmLength 6) $treeHasNullVex)
) True)

;; Test 4: Verify SSK knobs (multiplicity 2) are created for PRIORITIZED-OR
!(assertEqual 
    (let* (
        (($updatedTree $mm) (addLogicalKnobs 
                               (mkTree (mkNode PRIORITIZED-OR)
                                       (Cons (mkTree (mkNode play-center) Nil) Nil))
                               (mkNodeId (0)) True NilMMap (play-center play-corner)))
        ($firstPair (car-atom (cdr-atom $mm)))
        ($knobWrapper (cdr-atom $firstPair))
        ($firstKnob (car-atom $knobWrapper))
        ($multi (getKnobMultip $firstKnob))
    )
    (== $multi (mkMultip 2))) True)

;; Test 5: Verify different game moves work correctly
!(assertEqual (let* 
(
    (($updatedTree $mm) 
     (addLogicalKnobs (mkTree (mkNode PRIORITIZED-OR)     
        (Cons (mkTree (mkNode play-win) Nil)
          (Cons (mkTree (mkNode play-fork) Nil)
            (Cons (mkTree (mkNode play-block) Nil) Nil))))
              (mkNodeId (0)) True NilMMap (play-win play-fork play-block)))
    ($mmLength (MultiMap.length $mm))
    ($treeHasNullVex (not (== $updatedTree (mkTree (mkNode PRIORITIZED-OR) (Cons (mkTree (mkNode play-win) Nil) (Cons (mkTree (mkNode play-fork) Nil) (Cons (mkTree (mkNode play-block) Nil) Nil)))))))
)
(and (== $mmLength 6) $treeHasNullVex)
) True)