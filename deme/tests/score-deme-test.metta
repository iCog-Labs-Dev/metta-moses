! (register-module! ../../../metta-moses)

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

! (import! &self metta-moses:deme:score-deme)
! (import! &self metta-moses:scoring:complexity-based-scorer)
! (import! &self metta-moses:scoring:cscore)
! (import! &self metta-moses:scoring:bscore)
! (import! &self metta-moses:scoring:fitness)

! (import! &self metta-moses:moses:neighborhood-sampling)
! (import! &self metta-moses:representation:lsk)
! (import! &self metta-moses:representation:knob-mapper)
! (import! &self metta-moses:representation:instance)
! (import! &self metta-moses:representation:representation)
! (import! &self metta-moses:representation:knob-representation)

! (import! &self metta-moses:utilities:map)
! (import! &self metta-moses:utilities:tree) 
! (import! &self metta-moses:utilities:nodeId)
! (import! &self metta-moses:utilities:list-methods) 
! (import! &self metta-moses:utilities:general-helpers) 
! (import! &self metta-moses:utilities:ordered-multimap)
! (import! &self metta-moses:utilities:python-treehelpers)
! (import! &self metta-moses:feature-selection:feature-selection-helpers)

!(import! &self metta-moses:scoring:precision-bscore)

;; TODO: Add REDUCE Function here when it's edge case if fixed.
; (= (APPEND_CHILD $tree $nodeId $child ) (py_appendChild $tree $nodeId $child))

!(bind! tree1
        (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil)
                  (Cons (mkNullVex
                          (Cons (mkTree (mkNode D) Nil) Nil)) Nil))))
          (Cons (mkNullVex
                  (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

!(bind! lsk1
        (mkLSK
            (mkDiscKnob
              (mkKnob  (mkNodeId (2 3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            ))

!(bind! lsk2
        (mkLSK
            (mkDiscKnob
              (mkKnob  (mkNodeId (3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            ))

!(bind! lsk3
        (mkLSK
            (mkDiscKnob
              (mkKnob  (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              Nil)
            ))

! (bind! knobMapObj (mkKbMap
                      (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap))))
               
                      (mkDscMp (ConsMMap ((mkDiscSpec 1) lsk1) (ConsMMap ((mkDiscSpec 0) lsk2) (ConsMMap ((mkDiscSpec 1) lsk3) NilMMap))))))
! (bind! ttable1 (mkITable (Cons (Cons True (Cons False (Cons True Nil)))
                        (Cons (Cons True (Cons True  (Cons True Nil))) Nil)) 
                        (Cons A (Cons B (Cons O Nil)))))
! (bind! ttable2 (mkITable
                    (Cons (Cons True (Cons True (Cons True (Cons True Nil))))
                    (Cons (Cons True (Cons False (Cons False (Cons False Nil))))
                    (Cons (Cons False (Cons True (Cons False (Cons False Nil))))
                    (Cons (Cons False (Cons False (Cons False (Cons False Nil)))) Nil))))
                    (Cons A (Cons B (Cons C (Cons output Nil))))))
;; NOTE: All the instances in the deme don't include lsk1 (or they all start with '0') because we are testing it using ttable2. 
;;       ttable2 is a truth table which doesn't have a 'D' column.
; Testcases for applyComplexityBasedScore
!(assertEqual 
   (applyComplexityBasedScore 
      (mkRep knobMapObj tree1)
      (Cons (mkInst (Cons 0 (Cons 0 (Cons 2 Nil)))) (Cons (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) (Cons (mkInst (Cons 0 (Cons 2 (Cons 2 Nil)))) Nil)))
      ttable2
      2.0
      Nil)
   (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 (Cons 2 Nil)))) (mkCscore -2 4 2.0 0.0 -4.0))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) (mkCscore 0 3 1.5 0.0 -1.5))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 2 Nil)))) (mkCscore -2 3 1.5 0.0 -3.5))) Nil))))

!(assertEqual
   (applyComplexityBasedScore 
      (mkRep knobMapObj tree1)
      (Cons (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (Cons (mkInst (Cons 0 (Cons 2 (Cons 1 Nil)))) Nil))
      ttable2
      2.0
      Nil)
      (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 (Cons 1 Nil)))) (mkCscore -4 0 0.0 0.0 -4.0))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (mkCscore -4 0 0.0 0.0 -4.0))) Nil)))
;; (  (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 (Cons 1 Nil)))) (mkCscore -1 4 2.0 0.0 -3.0))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (mkCscore -1 4 2.0 0.0 -3.0))) Nil)))

; Testcases for transform
!(assertEqual
   (transform
   (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 2 Nil)))) -1.0000000000000001e308)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) -1.0000000000000001e308)) Nil)))
   (mkRep knobMapObj tree1)
   ttable2
   2.0)
   (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) (mkCscore 0 3 1.5 0.0 -1.5))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 2 Nil)))) (mkCscore -2 3 1.5 0.0 -3.5))) Nil))))

!(assertEqual
   (transform
   (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) -1.0000000000000001e308)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 1 Nil)))) -1.0000000000000001e308)) Nil)))
   (mkRep knobMapObj tree1)
   ttable2
   1)
   (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 1 Nil)))) (mkCscore 0 3 1.5 0.0 -1.5))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (mkCscore -4 0 0.0 0.0 -4.0))) Nil))))

;;( (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 1 Nil)))) (mkCscore 0 4 4.0 0.0 -4.0))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (mkCscore -1 4 4.0 0.0 -5.0))) Nil))))

;; Testcase for the bitsToIndices
!(assertEqual (bitsToIndices (Cons 1 (Cons 0 (Cons 1 (Cons 0 Nil)))) 0 ()) (0 2))

;; Testcase for applyMutualInformationBasedScore
!(assertEqual
  (applyMutualInformationBasedScore 
      (Cons (mkInst (Cons 0 (Cons 0 (Cons 2 Nil)))) (Cons (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) (Cons (mkInst (Cons 0 (Cons 2 (Cons 2 Nil)))) Nil)))
      ttable2
      100.0  ;; confidence parameter
      Nil)
  (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 (Cons 2 Nil)))) 0)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) 0.811)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 2 Nil)))) 0)) Nil))))

;; Test for applyPrecisionBasedScore
! (assertEqual
   (applyPrecisionBasedScore 
      (Cons (mkInst (Cons 0 (Cons 0 (Cons 2 Nil)))) (Cons (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) (Cons (mkInst (Cons 0 (Cons 2 (Cons 2 Nil)))) Nil)))
      ttable2
      100.0 1.0 0.5 1.0 True
      Nil)
   (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 (Cons 2 Nil)))) 0.0)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) 0.306780946956833)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 2 Nil)))) 0.0)) Nil)))
      )
;; Testcase for transformFs
!(assertEqual
   (transformFs
   (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 1 Nil)))) 0)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 0 Nil)))) 0)) Nil)))
   ttable2
   100.0 1.0 0.5 1.0 True mi
   )
   (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 0 Nil)))) 0.311)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 1 Nil)))) 0.811)) Nil))))

! (assertEqual
   (transformFs
      (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 1 Nil)))) 0)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 0 Nil)))) 0)) Nil)))
      ttable2
      100.0 1.0 0.5 1.0 True pre
      )
   (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 0 Nil)))) 0.5)) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 1 Nil)))) 0.33333333333333337)) Nil)))
   )
