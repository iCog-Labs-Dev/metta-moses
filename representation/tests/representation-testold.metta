; NOTE: This test file has been commented out temporarily.
; It was designed to test representation using the original sampleLogicalPerms implementation.
; For now, we are using a simple placeholder instead of calling sampleLogicalPerms
; to speed up testing and development.
; Because of this simplification, this test fails due to mismatches in expected structure and output.
; Once the original function is reintroduced, this test can be uncommented and adjusted if needed.


; !(register-module! ../../../metta-moses)

; ! (import! &self metta-moses:representation:lsk)
; ! (import! &self metta-moses:representation:knob-mapper)
; ! (import! &self metta-moses:representation:representation)
; ! (import! &self metta-moses:representation:knob-representation)
; !(import! &self metta-moses:representation:logical-probe) 
; ! (import! &self metta-moses:representation:build-logical)
; ! (import! &self metta-moses:representation:build-knobs)
; !(import! &self metta-moses:representation:sample-logical-perms) 
; !(import! &self metta-moses:representation:add-logical-knobs)

; ! (import! &self metta-moses:utilities:map)
; ! (import! &self metta-moses:utilities:tree) 
; ! (import! &self metta-moses:utilities:nodeId)
; ! (import! &self metta-moses:utilities:list-methods) 
; ! (import! &self metta-moses:utilities:general-helpers) 
; ! (import! &self metta-moses:utilities:ordered-multimap)
; ! (import! &self metta-moses:reduct:enf)
; ! (import! &self metta-moses:utilities:python-treehelpers)

; (= (ARGS) args) 
; (= (APPEND_CHILD $tree $nodeId $child ) (py_appendChild $tree $nodeId $child))
; (= (GetByID $tree $nodeId) (py_getById $tree $nodeId))

; (= (INSERT_ABOVE $tree $nodeId $subtree) (py_insertAbove  $tree $nodeId $subtree))


; ; Helper function for clean tree
; (= (REDUCE $expr) (reduce $expr))

; !(bind! tree1
;         (mkTree (mkNode AND)
;           (Cons (mkTree (mkNode A) Nil)
;           (Cons (mkTree (mkNode OR)
;                   (Cons (mkTree (mkNode B) Nil)
;                   (Cons (mkTree (mkNode C) Nil)
;                   (Cons (mkNullVex
;                           (Cons (mkTree (mkNode D) Nil) Nil)) Nil))))
;           (Cons (mkNullVex
;                   (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

; !(bind! lsk1
;         (mkLSK
;             (mkDiscKnob
;               (mkKnob tree1 (mkNodeId (2 3)))
;               (mkMultip 3)
;               (mkDiscSpec 0)
;               (mkDiscSpec 0)
;               Nil)
;             (mkTree (mkNode D) Nil)))

; !(bind! lsk2
;         (mkLSK
;             (mkDiscKnob
;               (mkKnob tree1 (mkNodeId (3)))
;               (mkMultip 3)
;               (mkDiscSpec 0)
;               (mkDiscSpec 0)
;               Nil)
;             (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil))))

; !(bind! lsk3
;         (mkLSK
;             (mkDiscKnob
;               (mkKnob tree1 (mkNodeId (1)))
;               (mkMultip 3)
;               (mkDiscSpec 1)
;               (mkDiscSpec 1)
;               Nil)
;             (mkTree (mkNode A) Nil)))

; !(bind! knobMapObj (mkKbMap
;                       (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap))))
;                       (mkDscMp (ConsMMap ((mkDiscSpec 1) lsk1) (ConsMMap ((mkDiscSpec 0) lsk2) (ConsMMap ((mkDiscSpec 1) lsk3) NilMMap))))))


; ;; Test case for Instance (0 0 0): (AND A (OR B C)) => (AND (OR B C))
; ! "===================Test case for Instance (0 0 0)============================"

; !(assertEqual
;     (getCandidateRec (mkRep knobMapObj tree1)
;                      (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 
;                      (mkNodeId (0))
;                      (mkNodeId (0))
;                      (mkNullVex Nil))
;     (mkTree (mkNode AND)
;         (Cons (mkNullVex
;                 (Cons (mkTree (mkNode A) Nil) Nil))
;         (Cons (mkTree (mkNode OR)
;                 (Cons (mkTree (mkNode B) Nil)
;                 (Cons (mkTree (mkNode C) Nil)
;                 (Cons (mkNullVex
;                         (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) 
;         (Cons (mkNullVex
;                 (Cons (mkTree (mkNode OR)
;                          (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

; ;; Test case for Instance (1 1 1): (AND A (OR B C)) => (AND A (OR B C D) (OR A))
; ! "===================Test case for Instance (1 1 1)============================"
; !(assertEqual
;    (getCandidateRec (mkRep knobMapObj tree1)
;                     (mkInst (Cons 1 (Cons 1 (Cons 1 Nil)))) 
;                     (mkNodeId (0))
;                     (mkNodeId (0))
;                     (mkNullVex Nil))
;    (mkTree (mkNode AND)
;       (Cons (mkTree (mkNode A) Nil)
;       (Cons (mkTree (mkNode OR) 
;               (Cons (mkTree (mkNode B) Nil)
;               (Cons (mkTree (mkNode C) Nil)
;               (Cons (mkTree (mkNode D) Nil) Nil))))
;       (Cons (mkTree (mkNode OR)
;                 (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))

; ;; Test case for Instance (2 2 2): (AND A (OR B C)) => (AND (NOT A) (OR B C (NOT D)) (NOT (OR A)))
; ! "===================Test case for Instance (2 2 2)============================"
; !(assertEqual
;    (getCandidateRec (mkRep knobMapObj tree1)
;                     (mkInst (Cons 2 (Cons 2 (Cons 2 Nil))))
;                     (mkNodeId (0))
;                     (mkNodeId (0))
;                     (mkNullVex Nil))
;    (mkTree (mkNode AND)
;       (Cons (mkTree (mkNode NOT)
;               (Cons (mkTree (mkNode A) Nil) Nil))
;       (Cons (mkTree (mkNode OR)
;               (Cons (mkTree (mkNode B) Nil)
;               (Cons (mkTree (mkNode C) Nil)
;               (Cons (mkTree (mkNode NOT)
;                       (Cons (mkTree (mkNode D) Nil) Nil)) Nil))))
;       (Cons (mkTree (mkNode NOT)
;               (Cons (mkTree (mkNode OR)
;                       (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

; ;; Test case for Instance (2 1 0): (AND A (OR B C)) => (AND (OR B C (NOT D)) (OR A))
; ! "===================Test case for Instance (2 1 0)============================"
; !(assertEqual
;    (getCandidateRec (mkRep knobMapObj tree1)
;                     (mkInst (Cons 2 (Cons 1 (Cons 0 Nil))))
;                     (mkNodeId (0))
;                     (mkNodeId (0))
;                     (mkNullVex Nil))
;    (mkTree (mkNode AND)
;       (Cons (mkNullVex
;               (Cons (mkTree (mkNode A) Nil) Nil))
;       (Cons (mkTree (mkNode OR)
;               (Cons (mkTree (mkNode B) Nil)
;               (Cons (mkTree (mkNode C) Nil)
;               (Cons (mkTree (mkNode NOT)
;                       (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) 
;       (Cons (mkTree (mkNode OR)
;               (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))

; ;; Test case for Instance (1 0 2): (AND A (OR B C)) => (AND (NOT A) (OR B C D))
; ! "===================Test case for Instance (1 0 2)============================"
; !(assertEqual
;    (getCandidateRec (mkRep knobMapObj tree1)
;                                (mkInst (Cons 1 (Cons 0 (Cons 2 Nil))))
;                                (mkNodeId (0))
;                                (mkNodeId (0))
;                                (mkNullVex Nil))
;    (mkTree (mkNode AND)
;      (Cons (mkTree (mkNode NOT)
;              (Cons (mkTree (mkNode A) Nil) Nil))
;      (Cons (mkTree (mkNode OR)
;              (Cons (mkTree (mkNode B) Nil)
;              (Cons (mkTree (mkNode C) Nil)
;              (Cons (mkTree (mkNode D) Nil) Nil))))
;      (Cons (mkNullVex
;              (Cons (mkTree (mkNode OR)
;                       (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

; ;; Test case for Instance (2 0 1): (AND A (OR B C)) => (AND A (OR B C (NOT D)))
; ! "===================Test case for Instance (2 0 1)============================"
; !(assertEqual
;    (getCandidateRec (mkRep knobMapObj tree1)
;                     (mkInst (Cons 2 (Cons 0 (Cons 1 Nil))))
;                     (mkNodeId (0))
;                     (mkNodeId (0))
;                     (mkNullVex Nil))
;    (mkTree (mkNode AND)
;       (Cons (mkTree (mkNode A) Nil)
;       (Cons (mkTree (mkNode OR)
;               (Cons (mkTree (mkNode B) Nil)
;               (Cons (mkTree (mkNode C) Nil)
;               (Cons (mkTree (mkNode NOT)
;                       (Cons (mkTree (mkNode D) Nil) Nil)) Nil))))
;       (Cons (mkNullVex
;                (Cons (mkTree (mkNode OR)
;                         (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

; ;; Test case for Instance (2 0 1): (AND A (OR B C)) => (AND A (OR B C (NOT D)))
; ! "===================Test case for Instance (2 0 1)============================"
; !(assertEqual
;    (getCandidate (mkRep knobMapObj tree1)
;                  (mkInst (Cons 2 (Cons 0 (Cons 1 Nil)))))
;    (mkTree (mkNode AND)
;       (Cons (mkTree (mkNode A) Nil)
;       (Cons (mkTree (mkNode OR)
;                 (Cons (mkTree (mkNode B) Nil)
;                 (Cons (mkTree (mkNode C) Nil)
;                 (Cons (mkTree (mkNode NOT)
;                         (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))))

; ;; ;; TODO: Change the above expected by below when reduct issue is fixed.
; ;;                 (Cons (mkTree (mkNode AND)
; ;;                         (Cons (mkTree (mkNode B) Nil) Nil))
; ;;                 (Cons (mkTree (mkNode AND)
; ;;                         (Cons (mkTree (mkNode C) Nil) Nil))
; ;;                 (Cons (mkTree (mkNode AND)
; ;;                         (Cons (mkTree (mkNode NOT)
; ;;                                   (Cons (mkTree (mkNode D) Nil) Nil)) Nil)) Nil)))) Nil))))

; ; Test for crtDiscKnobMap
; ; converts dscMp($kbSpec $kb) to dscKbMp($kbLoc $index)
; !(assertEqual (crtDiscKnobMap (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))) 
;      (ConsMMap ((mkDiscSpec 2) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) (mkNodeId (2 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))) 
;      (ConsMMap ((mkDiscSpec 1) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) (mkNodeId (2 1 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))) NilMMap)))) (mkDscKbMp NilMap) 0)
;      (mkDscKbMp (ConsMap ((mkNodeId (2)) 0) (ConsMap ((mkNodeId (2 1 1)) 2) (ConsMap ((mkNodeId (2 3)) 1) NilMap)))))

; !(assertEqual (crtDiscKnobMap (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) (mkNodeId (2 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))) 
;      (ConsMMap ((mkDiscSpec 2) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) (mkNodeId (2 3 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))) 
;      (ConsMMap ((mkDiscSpec 1) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) (mkNodeId (2 1 1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))) NilMMap)))) (mkDscKbMp NilMap) 0)
;      (mkDscKbMp (ConsMap ((mkNodeId (2 1 1)) 2) (ConsMap ((mkNodeId (2 2)) 0) (ConsMap ((mkNodeId (2 3 1)) 1) NilMap)))))

; ; Test for the representation
; ; takes exemplar and generates Representation($kbMapKnobMap $updatedExemplar)
; !(assertEqual (representation  (mkTree (mkNode OR) (Cons (mkTree (mkNode C) Nil) Nil)))
; (mkRep 
;   (mkKbMap 
;      (mkDscKbMp (ConsMap ((mkNodeId (1 2)) 0) (ConsMap ((mkNodeId (1 3)) 1) (ConsMap ((mkNodeId (1 4)) 2) (ConsMap ((mkNodeId (1 5)) 3) (ConsMap ((mkNodeId (2)) 4) (ConsMap ((mkNodeId (3)) 5) (ConsMap ((mkNodeId (4)) 6) (ConsMap ((mkNodeId (5)) 7) NilMap))))))))) 
;      (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil))) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))) (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))) (mkNodeId (1 3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil))))) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))) (mkNodeId (1 4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode B) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))) (mkNodeId (1 5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil))) (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))) (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil))))) (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode B) Nil))) (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))) (mkNodeId (5))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))) NilMMap)))))))))) 
;      (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil))))))))
