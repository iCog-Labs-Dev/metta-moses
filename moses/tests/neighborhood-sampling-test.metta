!(register-module! ../../../metta-moses)

!(import! &self metta-moses:moses:neighborhood-sampling)
!(import! &self metta-moses:representation:instance)
!(import! &self metta-moses:representation:knob-representation)

! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:utilities:nodeId)
! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:python-helpers)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:utilities:ordered-multimap)
! (import! &self metta-moses:utilities:lazy-random-selector)


(= (pyExprToList $expr) (py_exprToList $expr))

;; Test the distance function
;; Hamming distance on expressions
!(assertEqual (distance (0 0 0 1) (0 1 0 0)) 2)
!(assertEqual (distance (0 0 0 0) (0 1 0 0)) 1)
!(assertEqual (distance (1 2 0 0) (0 1 0 0)) 2)
!(assertEqual (distance (1 2 1 0) (0 1 0 0)) 3)

;; Hamming distance on instance
!(assertEqual (distance (mkInst (Cons 1 (Cons 2 (Cons 0 (Cons 0 Nil))))) (mkInst (Cons 0 (Cons 1 (Cons 0 (Cons 0 Nil)))))) 2)
!(assertEqual (distance (mkInst (Cons 1 (Cons 2 (Cons 1 (Cons 0 Nil))))) (mkInst (Cons 0 (Cons 1 (Cons 0 (Cons 0 Nil)))))) 3)


;; ;; Test case to check valid reduction of vary1Knobs
!(assertEqualToResult (vary1Knobs (2 1) (0 0 0 0)) ((0 0 0 2) (0 0 0 1) (0 0 2 0) (0 0 0 2) (0 0 0 1) (0 0 1 0) (0 2 0 0) (0 0 0 2) (0 0 0 1) (0 0 2 0) (0 0 0 2) (0 0 0 1) (0 0 1 0) (0 1 0 0) (2 0 0 0) (0 0 0 2) (0 0 0 1) (0 0 2 0) (0 0 0 2) (0 0 0 1) (0 0 1 0) (0 2 0 0) (0 0 0 2) (0 0 0 1) (0 0 2 0) (0 0 0 2) (0 0 0 1) (0 0 1 0) (0 1 0 0) (1 0 0 0)))
;; Test case to make sure it varyNKnobs reduce
!(assertEqualToResult (let $a (varyNKnobs (2 1) (0 0 0 1) 2) (if (== (distance $a (0 0 0 1)) 0) (empty) $a)) ((1 0 0 2) (1 0 0 0) (1 0 2 1) (1 0 1 1) (1 2 0 1) (1 1 0 1) (2 0 0 1) (2 0 0 2) (2 0 0 0) (2 0 2 1) (2 0 1 1) (2 2 0 1) (2 1 0 1) (1 0 0 1) (0 1 0 2) (0 1 0 0) (0 1 2 1) (0 1 1 1) (0 2 0 1) (2 1 0 1) (1 1 0 1) (0 2 0 2) (0 2 0 0) (0 2 2 1) (0 2 1 1) (0 1 0 1) (2 2 0 1) (1 2 0 1) (0 0 1 2) (0 0 1 0) (0 0 2 1) (0 2 1 1) (0 1 1 1) (2 0 1 1) (1 0 1 1) (0 0 2 2) (0 0 2 0) (0 0 1 1) (0 2 2 1) (0 1 2 1) (2 0 2 1) (1 0 2 1) (0 0 0 2) (0 0 2 0) (0 0 1 0) (0 2 0 0) (0 1 0 0) (2 0 0 0) (1 0 0 0) (0 0 0 0) (0 0 2 2) (0 0 1 2) (0 2 0 2) (0 1 0 2) (2 0 0 2) (1 0 0 2)))

;; At distance 2 should generate total of 32 neighbors
!(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 2) ((List.length $a) (get-type $a))) (32 (List Instance)))

;; At distance 3 should generate total of 64 neighbors
!(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 3) ((List.length $a) (get-type $a))) (64 (List Instance)))

;; Generated neighbors should be 32 in length and center shouldn't be member.
;;    Distance 0 indicates a center node being present.
!(assertEqual
   (let $distList
        (List.map ((curry distance) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil)))))) 
                  (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 2))
        ((List.length $distList) (List.contains 0 $distList))) 
   (32 False))

! (bind! tree1
        (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil)
                  (Cons (mkNullVex
                          (Cons (mkTree (mkNode D) Nil) Nil)) Nil))))
          (Cons (mkNullVex
                  (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

! (bind! lsk1
        (mkLSK
            (mkDiscKnob
              (mkKnob tree1 (mkNodeId (2 3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            (mkTree (mkNode D) Nil)))

! (bind! lsk2
        (mkLSK
            (mkDiscKnob
              (mkKnob tree1 (mkNodeId (3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil))))

! (bind! lsk3
        (mkLSK
            (mkDiscKnob
              (mkKnob tree1 (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              Nil)
            (mkTree (mkNode A) Nil)))

! (bind! knobMapObj (mkKbMap
                      (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap)))
                      (ConsMMap ((mkDiscSpec 1) lsk1) (ConsMMap ((mkDiscSpec 0) lsk2) (ConsMMap ((mkDiscSpec 1) lsk3) NilMMap)))))

;; Test case for sampleFromNeighborhood function
;; Function should returned two instances at the specified distance
! (assertEqual
     (let $returned (sampleFromNeighborhood 2 2 knobMapObj (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))))
       (List.map ((curry distance') (mkInst (Cons 1 (Cons 2 (Cons 0 Nil))))) $returned))
     (Cons 2 (Cons 2 Nil)))
! (assertEqual
     (let $returned (sampleFromNeighborhood 2 3 knobMapObj (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))))
       (List.map ((curry distance') (mkInst (Cons 1 (Cons 2 (Cons 0 Nil))))) $returned))
     (Cons 3 (Cons 3 Nil)))
! (assertEqual
     (let $returned (sampleFromNeighborhood 2 1 knobMapObj (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))))
       (List.map ((curry distance') (mkInst (Cons 1 (Cons 2 (Cons 0 Nil))))) $returned))
     (Cons 1 (Cons 1 Nil)))

;; Invalid knobMapObj or instance
! (assertEqual
     (let $returned
       (sampleFromNeighborhood 1 2  knobMapObj (mkInst Nil)) (List.length $returned))
     (Error (3 0) "Not Equal"))
