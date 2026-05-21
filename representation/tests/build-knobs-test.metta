!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/tree)

!(import! &self ../../scoring/bscore)

!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/lsk)
!(import! &self ../../representation/logical-probe)
!(import! &self ../../representation/logical-canonize)
!(import! &self ../../representation/sample-logical-perms)
!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/add-logical-knobs)
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/build-knobs)

!(py-call (random.seed 0))

(= (tree1) (mkTree (mkNode OR)
                        (cons (mkTree (mkNode C) ()) ())))

;; Game strategy tree for testing PRIORITIZED-OR knob building
(= (gameTree1) (mkTree (mkNode PRIORITIZED-OR)
                      (cons (mkTree (mkNode playcenter) ())
                      (cons (mkTree (mkNode playcorner) ()) ()))))

;; buildKnobs should materially change the tree and produce many knobs
!(assertEqual (let ($updatedTree $MMap) (buildKnobs (tree1) () (A B))
                     (and (== $updatedTree 
                              (mkTree (mkNode AND) ((mkTree (mkNode OR) ((mkTree (mkNode AND) ((mkTree (mkNode C) ()) (mkKnob (mkNullVex ((mkTree (mkNode A) ()))) 8) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) 9) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) 10) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) 11))) (mkKnob (mkNullVex ((mkTree (mkNode A) ()))) 4) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) 5) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) 6) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) 7) (mkTree (mkNode AND) ((mkKnob (mkNullVex ((mkTree (mkNode A) ()))) 12) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) 13) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) 14) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) 15))))) (mkKnob (mkNullVex ((mkTree (mkNode A) ()))) 0) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) 1) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) 2) (mkKnob (mkNullVex ((mkTree (mkNode OR) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) 3) (mkTree (mkNode OR) ((mkKnob (mkNullVex ((mkTree (mkNode A) ()))) 16) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) 17) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode NOT) ((mkTree (mkNode A) ()))) (mkTree (mkNode B) ()))))) 18) (mkKnob (mkNullVex ((mkTree (mkNode AND) ((mkTree (mkNode A) ()) (mkTree (mkNode B) ()))))) 19))))))

                         (MultiMap.equals $MMap (((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())))))))
                True)

;; buildKnobs creates correct number of knobs for single-child PRIORITIZED-OR
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs
                            (mkTree (mkNode PRIORITIZED-OR)
                                   (cons (mkTree (mkNode playwin) ()) ()))
                            () (playwin playblock)))
    ($mmLength (MultiMap.length $MMap))
)
(== $mmLength 5)
) True)

;; buildKnobs creates correct number of knobs for game strategies
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs (gameTree1) () (playcenter playcorner)))
    ($mmLength (MultiMap.length $MMap))
)
(== $mmLength 5)
) True)

;; buildKnobs modifies tree structure for game strategies
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs
                            (mkTree (mkNode PRIORITIZED-OR)
                                   (cons (mkTree (mkNode playwin) ()) ()))
                            () (playwin playblock)))
    ($treeChanged (not (== $updatedTree (mkTree (mkNode PRIORITIZED-OR)
                                               (cons (mkTree (mkNode playwin) ()) ())))))
)
$treeChanged
) True)

;; buildKnobs handles nested PRIORITIZED-OR structures
(= (complexGameTree) (mkTree (mkNode PRIORITIZED-OR)
                            (cons (mkTree (mkNode playcenter) ())
                            (cons (mkTree (mkNode PRIORITIZED-OR)
                                         (cons (mkTree (mkNode playcorner) ())
                                         (cons (mkTree (mkNode playblock) ()) ())))
                            ()))))

;; buildKnobs creates multiple knobs for nested PRIORITIZED-OR structures
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs (complexGameTree) () (playcenter playcorner playblock)))
    ($mmLength (MultiMap.length $MMap))
    ($hasCorrectKnobs (>= $mmLength 10)) ;; Expect more than 10 knobs for nested structure (10 per PRIORITIZED-OR)
)
$hasCorrectKnobs
) True)
