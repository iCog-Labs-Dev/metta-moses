; !(register-module! ../../metta-moses)

; !(import! &self metta-moses:moses:neighborhood-sampling)
; !(import! &self metta-moses:representation:instance)
; !(import! &self metta-moses:representation:knob-representation)

; ! (import! &self metta-moses:utilities:tree)
; ! (import! &self metta-moses:utilities:nodeId)
; ! (import! &self metta-moses:utilities:list-methods)
; ! (import! &self metta-moses:utilities:python-helpers)
; ! (import! &self metta-moses:utilities:general-helpers)
; ! (import! &self metta-moses:utilities:ordered-multimap)
; ! (import! &self metta-moses:utilities:lazy-random-selector)
; ! (import! &self metta-moses:optimization:hillclimbing:hill-climbing-helpers)
; ! (import! &self metta-moses:deme:create-deme)


; (= (pyExprToList $expr) (py_exprToList $expr))


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
                      (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap))))
                      (mkDscMp (ConsMMap ((mkDiscSpec 1) lsk1) (ConsMMap ((mkDiscSpec 0) lsk2) (ConsMMap ((mkDiscSpec 1) lsk3) NilMMap))))))



; ;; At distance 2 should generate total of 32 neighbors
; !(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 2) ((List.length $a) (get-type $a))) (32 (List Instance)))

; ;; At distance 3 should generate total of 64 neighbors
; !(assertEqual (let $a (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 3) ((List.length $a) (get-type $a))) (64 (List Instance)))

; ;; Generated neighbors should be 32 in length and center shouldn't be member.
; ;;    Distance 0 indicates a center node being present.
; !(assertEqual
;    (let $distList
;         (List.map ((curry distance) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil)))))) 
;                   (generateAllInNeighborhood (mkMultip 3) (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) 2))
;         ((List.length $distList) (List.contains 0 $distList))) 
;    (32 False))
(= (isMember $list $x) (let $y (superpose $list) (if (== $x $y) True Empty)))

!(== Empty Empty)