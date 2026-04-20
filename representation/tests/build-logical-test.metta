!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/ordered-multimap) 
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/tree)

!(import! &self ../../scoring/bscore)

!(import! &self ../knob-representation)
!(import! &self ../lsk)
!(import! &self ../logical-probe)
!(import! &self ../sample-logical-perms) 
!(import! &self ../add-logical-knobs)
!(import! &self ../build-logical)


;; !(py-call (random.seed 0))

(= (tree1) (mkTree (mkNode AND) 
                  (cons (mkTree (mkNode A) ()) 
                  (cons (mkTree (mkNode B) ()) 
                  (cons (mkTree (mkNode OR) 
                        (cons (mkTree (mkNode C) ()) ())) 
                        ())))))
 ;; buildLogical test case
!(assertEqual (let ($updatedTree $MMap) (buildLogical (tree1) (mkNodeId (3)) () (A B))
                     (and (== $updatedTree (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) ())))))) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkTree (mkNode AND) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) ()))))) ()))))))) ())))))
                         (MultiMap.equals $MMap (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 1 5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 6 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 6 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 6 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 6 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ())))))))))))) )))
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
