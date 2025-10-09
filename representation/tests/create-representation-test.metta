; NOTE: This test file is temporarily commented out because set-seed is 
; not functioning correctly in the current mettalog version. 
; The tests will be re-enabled after fixing Python binding in the workflow.

!(register-module! ../../../metta-moses)

! (import! &self metta-moses:reduct/boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct/boolean-reduct:cut-unnecessary-or)
! (import! &self metta-moses:reduct/boolean-reduct:cut-unnecessary-and)
! (import! &self metta-moses:reduct/boolean-reduct:n-ary-propagate-not)
! (import! &self metta-moses:reduct/boolean-reduct:n-ary-gather-junctors)
! (import! &self metta-moses:reduct/boolean-reduct:delete-inconsistent-handle)
! (import! &self metta-moses:reduct/boolean-reduct:zero-constraint-subsumption)
! (import! &self metta-moses:reduct/boolean-reduct:one-constraint-subsumption)
! (import! &self metta-moses:reduct/boolean-reduct:promote-common-constraints)
! (import! &self metta-moses:reduct/boolean-reduct:reduce-to-elegance)

! (import! &self metta-moses:representation:lsk)
! (import! &self metta-moses:representation:knob-mapper)
! (import! &self metta-moses:representation:representation)
! (import! &self metta-moses:representation:create-representation)
! (import! &self metta-moses:representation:knob-representation)
! (import! &self metta-moses:representation:logical-probe) 
! (import! &self metta-moses:representation:build-logical)
! (import! &self metta-moses:representation:build-knobs)
! (import! &self metta-moses:representation:sample-logical-perms) 
! (import! &self metta-moses:representation:add-logical-knobs)

! (import! &self metta-moses:utilities:lazy-random-selector)
! (import! &self metta-moses:utilities:map)
! (import! &self metta-moses:utilities:tree) 
! (import! &self metta-moses:utilities:nodeId)
! (import! &self metta-moses:utilities:list-methods) 
! (import! &self metta-moses:utilities:general-helpers) 
! (import! &self metta-moses:utilities:ordered-multimap)
! (import! &self metta-moses:utilities:ordered-set)
! (import! &self metta-moses:utilities:python-treehelpers)

!(import! &self metta-moses:scoring:bscore)
!(import! &self metta-moses:scoring:cscore)

!(import! &self metta-moses:feature-selection:feature-selection-helpers)
!(import! &self metta-moses:feature-selection:feature-selection-main)
!(import! &self metta-moses:feature-selection:select-top-features)
!(import! &self metta-moses:feature-selection:similarity-scorers)
!(import! &self metta-moses:feature-selection:simple)

(= (APPEND_CHILD $tree $nodeId $child ) (py_appendChild $tree $nodeId $child))
(= (GetByID $tree $nodeId) (py_getById $tree $nodeId))

(= (INSERT_ABOVE $tree $nodeId $subtree) (py_insertAbove  $tree $nodeId $subtree))

!(bind! ttable 
    (mkITable 
        (Cons (Cons False (Cons False (Cons True (Cons True (Cons True Nil)))))
        (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
        (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
        (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil))))
        (Cons A (Cons B (Cons C (Cons D (Cons Output Nil)))))))


;; Test for the create representation
;; The test case is the same as the representation test case
;;      if create representation supports feature selection and ignore op it will be different
;; takes exemplar and generates Representation($kbMapKnobMap $updatedExemplar)
; !(assertEqual (createRepresentation (mkTree (mkNode OR) (Cons (mkTree (mkNode C) Nil) Nil)) (A B))
; (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1 2)) 3) (ConsMap ((mkNodeId (1 3)) 2) (ConsMap ((mkNodeId (1 4)) 1) (ConsMap ((mkNodeId (1 5)) 0) (ConsMap ((mkNodeId (2)) 7) (ConsMap ((mkNodeId (3)) 6) (ConsMap ((mkNodeId (4)) 5) (ConsMap ((mkNodeId (5)) 4) NilMap))))))))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))))))))) 
; (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))))) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil))))))))
;; New test based on improved representation building
! (assertEqual 
    (createRepresentation 
        2
        (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) Nil)) 
        ttable 
        sim 
        False
        ; ((E 0.4) (F 0.3) (G 0.73))
        ()
        )
        ((mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 3) (ConsMap ((mkNodeId (1 1)) 1) (ConsMap ((mkNodeId (1 2)) 0) (ConsMap ((mkNodeId (2)) 2) NilMap))))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) NilMMap)))))) (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil))) (Cons (mkNullVex (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))) (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 6) (ConsMap ((mkNodeId (1 1)) 2) (ConsMap ((mkNodeId (1 2)) 3) (ConsMap ((mkNodeId (1 3)) 1) (ConsMap ((mkNodeId (1 4)) 0) (ConsMap ((mkNodeId (2)) 7) (ConsMap ((mkNodeId (3)) 5) (ConsMap ((mkNodeId (4)) 4) NilMap))))))))) (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))))))))) (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode A) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode A) Nil) Nil))) Nil)) Nil))))) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode A) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode A) Nil) Nil))) Nil)) Nil)))))))
    ) 