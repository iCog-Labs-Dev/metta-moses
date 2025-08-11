; NOTE: This test file is temporarily commented out because set-seed is 
; not functioning correctly in the current mettalog version. 
; The tests will be re-enabled after fixing Python binding in the workflow.

!(register-module! ../../../metta-moses)

! (import! &self metta-moses:representation:lsk)
! (import! &self metta-moses:representation:knob-mapper)
! (import! &self metta-moses:representation:representation)
! (import! &self metta-moses:representation:create-representation)
! (import! &self metta-moses:representation:knob-representation)
!(import! &self metta-moses:representation:logical-probe) 
! (import! &self metta-moses:representation:build-logical)
! (import! &self metta-moses:representation:build-knobs)
!(import! &self metta-moses:representation:sample-logical-perms) 
! (import! &self metta-moses:utilities:lazy-random-selector)
!(import! &self metta-moses:representation:add-logical-knobs)

! (import! &self metta-moses:utilities:map)
! (import! &self metta-moses:utilities:tree) 
! (import! &self metta-moses:utilities:nodeId)
! (import! &self metta-moses:utilities:list-methods) 
! (import! &self metta-moses:utilities:general-helpers) 
! (import! &self metta-moses:utilities:ordered-multimap)
! (import! &self metta-moses:reduct:enf)
! (import! &self metta-moses:utilities:python-treehelpers)

(= (ARGS) args) 
(= (APPEND_CHILD $tree $nodeId $child ) (py_appendChild $tree $nodeId $child))
(= (GetByID $tree $nodeId) (py_getById $tree $nodeId))

(= (INSERT_ABOVE $tree $nodeId $subtree) (py_insertAbove  $tree $nodeId $subtree))


;; Test for the create representation
;; The test case is the same as the representation test case
;;      if create representation supports feature selection and ignore op it will be different
;; takes exemplar and generates Representation($kbMapKnobMap $updatedExemplar)
!(assertEqual (createRepresentation (mkTree (mkNode OR) (Cons (mkTree (mkNode C) Nil) Nil)))
(mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1 2)) 3) (ConsMap ((mkNodeId (1 3)) 2) (ConsMap ((mkNodeId (1 4)) 1) (ConsMap ((mkNodeId (1 5)) 0) (ConsMap ((mkNodeId (2)) 7) (ConsMap ((mkNodeId (3)) 6) (ConsMap ((mkNodeId (4)) 5) (ConsMap ((mkNodeId (5)) 4) NilMap))))))))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))))))))) 
(mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))))) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil))))))))