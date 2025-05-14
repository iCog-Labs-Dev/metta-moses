!(register-module! ../../../metta-moses)

!(import! &self metta-moses:moses:neighborhood-sampling)
!(import! &self metta-moses:representation:instance)
!(import! &self metta-moses:representation:knob-representation)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:python-helpers)

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
