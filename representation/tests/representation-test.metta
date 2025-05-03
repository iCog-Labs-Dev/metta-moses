!(register-module! ../../../metta-moses)

! (import! &self metta-moses:representation:lsk)
! (import! &self metta-moses:representation:knob-mapper)
! (import! &self metta-moses:representation:representation)
! (import! &self metta-moses:representation:knob-representation)

! (import! &self metta-moses:utilities:map)
! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:utilities:nodeId)
! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:utilities:ordered-multimap)

! (import! &self metta-moses:reduct:enf)

;; Helper function for clean tree
(= (REDUCE $expr) (reduce $expr))

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
              (mkKnob tree1 (mkNodeId (2 3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            (mkTree (mkNode D) Nil)))

!(bind! lsk2
        (mkLSK
            (mkDiscKnob
              (mkKnob tree1 (mkNodeId (3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil))))

!(bind! lsk3
        (mkLSK
            (mkDiscKnob
              (mkKnob tree1 (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              Nil)
            (mkTree (mkNode A) Nil)))

!(bind! knobMapObj (mkKbMap
                      (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap)))
                      (ConsMMap ((mkDiscSpec 1) lsk1) (ConsMMap ((mkDiscSpec 0) lsk2) (ConsMMap ((mkDiscSpec 1) lsk3) NilMMap)))))


;; Test case for Instance (0 0 0): (AND A (OR B C)) => (AND (OR B C))
! "===================Test case for Instance (0 0 0)============================"

!(assertEqual
    (getCandidateRec (mkRep knobMapObj tree1)
                     (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 
                     (mkNodeId (0))
                     (mkNodeId (0))
                     (mkNullVex Nil))
    (mkTree (mkNode AND)
        (Cons (mkNullVex
                (Cons (mkTree (mkNode A) Nil) Nil))
        (Cons (mkTree (mkNode OR)
                (Cons (mkTree (mkNode B) Nil)
                (Cons (mkTree (mkNode C) Nil)
                (Cons (mkNullVex
                        (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) 
        (Cons (mkNullVex
                (Cons (mkTree (mkNode OR)
                         (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

;; Test case for Instance (1 1 1): (AND A (OR B C)) => (AND A (OR B C D) (OR A))
! "===================Test case for Instance (1 1 1)============================"
!(assertEqual
   (getCandidateRec (mkRep knobMapObj tree1)
                    (mkInst (Cons 1 (Cons 1 (Cons 1 Nil)))) 
                    (mkNodeId (0))
                    (mkNodeId (0))
                    (mkNullVex Nil))
   (mkTree (mkNode AND)
      (Cons (mkTree (mkNode A) Nil)
      (Cons (mkTree (mkNode OR) 
              (Cons (mkTree (mkNode B) Nil)
              (Cons (mkTree (mkNode C) Nil)
              (Cons (mkTree (mkNode D) Nil) Nil))))
      (Cons (mkTree (mkNode OR)
                (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))

;; Test case for Instance (2 2 2): (AND A (OR B C)) => (AND (NOT A) (OR B C (NOT D)) (NOT (OR A)))
! "===================Test case for Instance (2 2 2)============================"
!(assertEqual
   (getCandidateRec (mkRep knobMapObj tree1)
                    (mkInst (Cons 2 (Cons 2 (Cons 2 Nil))))
                    (mkNodeId (0))
                    (mkNodeId (0))
                    (mkNullVex Nil))
   (mkTree (mkNode AND)
      (Cons (mkTree (mkNode NOT)
              (Cons (mkTree (mkNode A) Nil) Nil))
      (Cons (mkTree (mkNode OR)
              (Cons (mkTree (mkNode B) Nil)
              (Cons (mkTree (mkNode C) Nil)
              (Cons (mkTree (mkNode NOT)
                      (Cons (mkTree (mkNode D) Nil) Nil)) Nil))))
      (Cons (mkTree (mkNode NOT)
              (Cons (mkTree (mkNode OR)
                      (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

;; Test case for Instance (2 1 0): (AND A (OR B C)) => (AND (OR B C (NOT D)) (OR A))
! "===================Test case for Instance (2 1 0)============================"
!(assertEqual
   (getCandidateRec (mkRep knobMapObj tree1)
                    (mkInst (Cons 2 (Cons 1 (Cons 0 Nil))))
                    (mkNodeId (0))
                    (mkNodeId (0))
                    (mkNullVex Nil))
   (mkTree (mkNode AND)
      (Cons (mkNullVex
              (Cons (mkTree (mkNode A) Nil) Nil))
      (Cons (mkTree (mkNode OR)
              (Cons (mkTree (mkNode B) Nil)
              (Cons (mkTree (mkNode C) Nil)
              (Cons (mkTree (mkNode NOT)
                      (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) 
      (Cons (mkTree (mkNode OR)
              (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))))

;; Test case for Instance (1 0 2): (AND A (OR B C)) => (AND (NOT A) (OR B C D))
! "===================Test case for Instance (1 0 2)============================"
!(assertEqual
   (getCandidateRec (mkRep knobMapObj tree1)
                               (mkInst (Cons 1 (Cons 0 (Cons 2 Nil))))
                               (mkNodeId (0))
                               (mkNodeId (0))
                               (mkNullVex Nil))
   (mkTree (mkNode AND)
     (Cons (mkTree (mkNode NOT)
             (Cons (mkTree (mkNode A) Nil) Nil))
     (Cons (mkTree (mkNode OR)
             (Cons (mkTree (mkNode B) Nil)
             (Cons (mkTree (mkNode C) Nil)
             (Cons (mkTree (mkNode D) Nil) Nil))))
     (Cons (mkNullVex
             (Cons (mkTree (mkNode OR)
                      (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

;; Test case for Instance (2 0 1): (AND A (OR B C)) => (AND A (OR B C (NOT D)))
! "===================Test case for Instance (2 0 1)============================"
!(assertEqual
   (getCandidateRec (mkRep knobMapObj tree1)
                    (mkInst (Cons 2 (Cons 0 (Cons 1 Nil))))
                    (mkNodeId (0))
                    (mkNodeId (0))
                    (mkNullVex Nil))
   (mkTree (mkNode AND)
      (Cons (mkTree (mkNode A) Nil)
      (Cons (mkTree (mkNode OR)
              (Cons (mkTree (mkNode B) Nil)
              (Cons (mkTree (mkNode C) Nil)
              (Cons (mkTree (mkNode NOT)
                      (Cons (mkTree (mkNode D) Nil) Nil)) Nil))))
      (Cons (mkNullVex
               (Cons (mkTree (mkNode OR)
                        (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

;; Test case for Instance (2 0 1): (AND A (OR B C)) => (AND A (OR B C (NOT D)))
! "===================Test case for Instance (2 0 1)============================"
!(assertEqual
   (getCandidate (mkRep knobMapObj tree1)
                 (mkInst (Cons 2 (Cons 0 (Cons 1 Nil)))))
   (mkTree (mkNode AND)
      (Cons (mkTree (mkNode A) Nil)
      (Cons (mkTree (mkNode OR)
                (Cons (mkTree (mkNode AND)
                        (Cons (mkTree (mkNode B) Nil) Nil))
                (Cons (mkTree (mkNode AND)
                        (Cons (mkTree (mkNode C) Nil) Nil))
                (Cons (mkTree (mkNode AND)
                        (Cons (mkTree (mkNode NOT)
                                  (Cons (mkTree (mkNode D) Nil) Nil)) Nil)) Nil)))) Nil))))
