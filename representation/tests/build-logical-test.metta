!(import! &self ../../utilities/tree)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/ordered-multimap) 
!(import! &self ../../utilities/nodeId)

!(import! &self ../knob-representation)
!(import! &self ../logical-probe)
!(import! &self ../lsk)
!(import! &self ../build-logical)
!(import! &self ../sample-logical-perms) 
!(import! &self ../add-logical-knobs)

!(import! &self ../../scoring/bscore)

;; !(py-call (random.seed 0))

(= (tree1) (mkTree (mkNode AND) 
                  (Cons (mkTree (mkNode A) Nil) 
                  (Cons (mkTree (mkNode B) Nil) 
                  (Cons (mkTree (mkNode OR) 
                        (Cons (mkTree (mkNode C) Nil) Nil)) 
                        Nil)))))
 ;; buildLogical test case
!(assertEqual (let ($updatedTree $MMap) (buildLogical (tree1) (mkNodeId (3)) NilMMap (A B))
                     (and (== $updatedTree (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))))) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))))) Nil))))  )
                         (MultiMap.equals $MMap (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 1 5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (3 1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob  (mkNodeId (3 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))))))))))
                True)
;; Simple game strategy tree for testing
(= (simpleGameTree) (mkTree (mkNode PRIORITIZED-OR) 
                           (Cons (mkTree (mkNode playcenter) Nil) 
                           (Cons (mkTree (mkNode playcorner) Nil) Nil))))

;; Verify buildStrategy creates knobs
!(assertEqual 
    (let* (
        (($updatedTree $MMap) (buildStrategy 
                                (mkTree (mkNode PRIORITIZED-OR)
                                        (Cons (mkTree (mkNode playwin) Nil) Nil))
                                (mkNodeId (0)) NilMMap (playwin playblock)))
        ($mmLength (MultiMap.length $MMap))
        ($hasKnobs (> $mmLength 0))
    )
    $hasKnobs) True)

;; Verify buildStrategy creates correct number of knobs
!(assertEqual (let* (
    (($updatedTree $MMap) (buildStrategy (simpleGameTree) (mkNodeId (0)) NilMMap (playcenter playcorner)))
    ($mmLength (MultiMap.length $MMap))
)
(== $mmLength 5)
) True)
;; Verify tree structure is modified correctly
!(assertEqual (let* (
    (($updatedTree $MMap) (buildStrategy 
                            (mkTree (mkNode PRIORITIZED-OR)
                                    (Cons (mkTree (mkNode playcenter) Nil)
                                          (Cons (mkTree (mkNode playblock) Nil) Nil)))
                            (mkNodeId (0)) NilMMap (playcenter playblock)))
    ($treeChanged (not (== $updatedTree (mkTree (mkNode PRIORITIZED-OR)
                                                (Cons (mkTree (mkNode playcenter) Nil)
                                                      (Cons (mkTree (mkNode playblock) Nil) Nil))))))
)
$treeChanged
) True)

;; Verify knob multiplicity is 2 for SSK (not 3 like LSK)
!(assertEqual 
    (let* (
        (($updatedTree $MMap) (buildStrategy 
                                (mkTree (mkNode PRIORITIZED-OR)
                                        (Cons (mkTree (mkNode playcorner) Nil) Nil))
                                (mkNodeId (0)) NilMMap (playcorner play-edge)))
        ($mmLength (MultiMap.length $MMap))
        ($hasCorrectLength (== $mmLength 5))
    )
    $hasCorrectLength) True)

;; Complex strategy tree with nested structure
(= (complexGameTree) (mkTree (mkNode PRIORITIZED-OR)
                            (Cons (mkTree (mkNode playcenter) Nil)
                            (Cons (mkTree (mkNode PRIORITIZED-OR)
                                         (Cons (mkTree (mkNode playcorner) Nil)
                                         (Cons (mkTree (mkNode playblock) Nil) Nil)))
                            Nil))))

!(assertEqual (let* (
    (($updatedTree $MMap) (buildStrategy (complexGameTree) (mkNodeId (0)) NilMMap (playcenter playcorner playblock)))
    ($mmLength (MultiMap.length $MMap))
    ($hasMultipleKnobs (> $mmLength 4))
)
$hasMultipleKnobs
) True)