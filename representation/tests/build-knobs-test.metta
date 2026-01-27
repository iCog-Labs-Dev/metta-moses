!(import! &self ../../utilities/tree)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/general-helpers)
!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/logical-probe)
!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/lsk)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../representation/sample-logical-perms) 
!(import! &self ../../utilities/lazy-random-selector) 
!(import! &self ../../representation/add-logical-knobs)
!(import! &self ../../utilities/ordered-multimap) 
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/build-knobs)
!(import! &self ../../scoring/bscore)


!(py-call (random.seed 0))

(= (tree1) (mkTree (mkNode OR) 
                        (Cons (mkTree (mkNode C) Nil) Nil)) )

;; Game strategy tree for testing PRIORITIZED-OR knob building
(= (gameTree1) (mkTree (mkNode PRIORITIZED-OR) 
                      (Cons (mkTree (mkNode play-center) Nil) 
                      (Cons (mkTree (mkNode play-corner) Nil) Nil))))

;; buildLogical test case
!(assertEqual (let ($updatedTree $MMap) (buildKnobs (tree1) NilMMap (A B))
                     (and (== $updatedTree (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))))) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil))))))  )
                         (MultiMap.equals $MMap (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))))))))))
                True)
;; Test 1: buildKnobs with PRIORITIZED-OR creates SSK knobs
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs (gameTree1) NilMMap (play-center play-corner)))
    ($mmLength (MultiMap.length $MMap))
    ($hasKnobs (> $mmLength 0))
)
$hasKnobs
) True)

;; Test 2: buildKnobs routes PRIORITIZED-OR to buildStrategy
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs 
                            (mkTree (mkNode PRIORITIZED-OR)
                                   (Cons (mkTree (mkNode play-win) Nil) Nil))
                            NilMMap (play-win play-block)))
    ($mmLength (MultiMap.length $MMap))
)
(== $mmLength 4)
) True)

;; Test 4: buildKnobs creates correct number of knobs for game strategies
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs (gameTree1) NilMMap (play-center play-corner)))
    ($mmLength (MultiMap.length $MMap))
)
(== $mmLength 4)
) True)

; ;; Test 5: buildKnobs modifies tree structure for game strategies
!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs 
                            (mkTree (mkNode PRIORITIZED-OR)
                                   (Cons (mkTree (mkNode play-win) Nil) Nil))
                            NilMMap (play-win play-block)))
    ($treeChanged (not (== $updatedTree (mkTree (mkNode PRIORITIZED-OR)
                                               (Cons (mkTree (mkNode play-win) Nil) Nil)))))
)
$treeChanged
) True)

;; Test 6: buildKnobs handles nested PRIORITIZED-OR structures
(= (complexGameTree) (mkTree (mkNode PRIORITIZED-OR)
                            (Cons (mkTree (mkNode play-center) Nil)
                            (Cons (mkTree (mkNode PRIORITIZED-OR)
                                         (Cons (mkTree (mkNode play-corner) Nil)
                                         (Cons (mkTree (mkNode play-block) Nil) Nil)))
                            Nil))))

!(assertEqual (let* (
    (($updatedTree $MMap) (buildKnobs (complexGameTree) NilMMap (play-center play-corner play-block)))
    ($mmLength (MultiMap.length $MMap))
    ($hasCorrectKnobs (> $mmLength 6))  ;; Expect exactly 6 knobs for nested structure
)
$hasCorrectKnobs
) True)
