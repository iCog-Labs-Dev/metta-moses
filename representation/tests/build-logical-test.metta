!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/tree)

!(import! &self ../../scoring/bscore)

!(import! &self ../logical-canonize)
!(import! &self ../knob-representation)
!(import! &self ../lsk)
!(import! &self ../logical-probe)
!(import! &self ../sample-logical-perms)
!(import! &self ../add-logical-knobs)
!(import! &self ../build-logical)

(= (tree1) (mkTree (mkNode AND)
                  (
                    (mkTree (mkNode A) ())
                    (mkTree (mkNode B) ())
                    (mkTree (mkNode OR)
                      (
                        (mkTree (mkNode C) ()))))))

;; buildLogical should materially change the tree and produce many knobs
!(assertEqual (let ($updatedTree $MMap) (buildLogical (tree1) () (A B))
                     (and (== $updatedTree (mkTree (mkNode AND) ((mkTree (mkNode OR) ((mkTree (mkNode AND) ((mkTree (mkNode C) ()) (mkKnob (mkNullVex ((mkTree (mkNode A) ()))) 8) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) 9) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) 10) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) 11))) (mkKnob (mkNullVex ((mkTree (mkNode A) ()))) 4) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) 5) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) 6) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) 7) (mkTree (mkNode AND) ((mkKnob (mkNullVex ((mkTree (mkNode A) ()))) 12) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) 13) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) 14) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) 15))))) (mkKnob (mkTree (mkNode OR) ((mkTree (mkNode A) ()) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) 16) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) 17) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) 18))) 0) (mkKnob (mkTree (mkNode OR) ((mkTree (mkNode B) ()) (mkKnob (mkNullVex ((mkTree (mkNode A) ()))) 19) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) 20) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) 21))) 1) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) 2) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) 3) (mkTree (mkNode OR) ((mkKnob (mkNullVex ((mkTree (mkNode A) ()))) 22) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) 23) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) 24) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) 25))))))
(MultiMap.equals $MMap (((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))))))
True)


;; Simple game strategy tree for testing
(= (simpleGameTree) (mkTree (mkNode PRIORITIZED-OR)
                           (cons (mkTree (mkNode playcenter) ())
                           (cons (mkTree (mkNode playcorner) ()) ()))))

;; Verify buildStrategy creates knobs
!(assertEqual
    (let* (
        (($updatedTree $MMap) (buildStrategy
                                (mkTree (mkNode PRIORITIZED-OR)
                                        (cons (mkTree (mkNode playwin) ()) ()))
                                (mkNodeId (0)) () (playwin playblock)))
        ($mmLength (MultiMap.length $MMap))
        ($hasKnobs (> $mmLength 0))
    )
    $hasKnobs) True)

;; Verify buildStrategy creates correct number of knobs
!(assertEqual (let* (
    (($updatedTree $MMap) (buildStrategy (simpleGameTree) (mkNodeId (0)) () (playcenter playcorner)))
    ($mmLength (MultiMap.length $MMap))
)
(== $mmLength 5)
) True)

;; Verify tree structure is modified correctly
!(assertEqual (let* (
    (($updatedTree $MMap) (buildStrategy
                            (mkTree (mkNode PRIORITIZED-OR)
                                    (cons (mkTree (mkNode playcenter) ())
                                          (cons (mkTree (mkNode playblock) ()) ())))
                            (mkNodeId (0)) () (playcenter playblock)))
    ($treeChanged (not (== $updatedTree (mkTree (mkNode PRIORITIZED-OR)
                                                (cons (mkTree (mkNode playcenter) ())
                                                      (cons (mkTree (mkNode playblock) ()) ()))))))
)
$treeChanged
) True)

;; Verify knob multiplicity is 2 for SSK (not 3 like LSK)
!(assertEqual
    (let* (
        (($updatedTree $MMap) (buildStrategy
                                (mkTree (mkNode PRIORITIZED-OR)
                                        (cons (mkTree (mkNode playcorner) ()) ()))
                                (mkNodeId (0)) () (playcorner play-edge)))
        ($mmLength (MultiMap.length $MMap))
        ($hasCorrectLength (== $mmLength 5))
    )
    $hasCorrectLength) True)

;; Complex strategy tree with nested structure
(= (complexGameTree) (mkTree (mkNode PRIORITIZED-OR)
                            (cons (mkTree (mkNode playcenter) ())
                            (cons (mkTree (mkNode PRIORITIZED-OR)
                                         (cons (mkTree (mkNode playcorner) ())
                                         (cons (mkTree (mkNode playblock) ()) ())))
                            ()))))

!(assertEqual (let* (
    (($updatedTree $MMap) (buildStrategy (complexGameTree) (mkNodeId (0)) () (playcenter playcorner playblock)))
    ($mmLength (MultiMap.length $MMap))
    ($hasMultipleKnobs (> $mmLength 4))
)
$hasMultipleKnobs
) True)
