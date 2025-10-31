; NOTE: This test file is temporarily commented out because set-seed is 
; not functioning correctly in the current mettalog version. 
;The tests will be re-enabled after fixing Python binding in the workflow.

!(register-module! ../../../metta-moses)
!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:representation:logical-probe)
!(import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:representation:lsk)
!(import! &self metta-moses:utilities:nodeId)
!(import! &self metta-moses:representation:sample-logical-perms) 
!(import! &self metta-moses:utilities:lazy-random-selector) 
!(import! &self metta-moses:representation:add-logical-knobs)
!(import! &self metta-moses:utilities:ordered-multimap) 
!(import! &self metta-moses:representation:build-logical)
!(import! &self metta-moses:representation:build-knobs)
! (import! &self metta-moses:utilities:python-treehelpers)
!(import! &self metta-moses:scoring:bscore)

(= (APPEND_CHILD $tree $nodeId $child ) (py_appendChild $tree $nodeId $child))
(= (GetByID $tree $nodeId) (py_getById $tree $nodeId))

(= (INSERT_ABOVE $tree $nodeId $subtree) (py_insertAbove  $tree $nodeId $subtree))


!(bind! tree1 (mkTree (mkNode OR) 
                        (Cons (mkTree (mkNode C) Nil) Nil)) )

;; buildLogical test case
! (assertEqual (let ($updatedTree $MMap) (buildKnobs tree1 NilMMap (A B))
                     (and (== $updatedTree (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))))) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil))))))  )
                         (MultiMap.equals $MMap (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))))))))))
                True)