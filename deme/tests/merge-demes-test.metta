! (register-module! ../../../metta-moses)
! (import! &self metta-moses:deme:merge-demes)
! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:representation:instance)
! (import! &self metta-moses:deme:create-deme)
! (import! &self metta-moses:deme:deme-id-creation)
! (import! &self metta-moses:representation:representation)
! (import! &self metta-moses:representation:knob-representation)
! (import! &self metta-moses:utilities:pair)
! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:scoring:fitness)
! (import! &self metta-moses:scoring:bscore) 
! (import! &self metta-moses:scoring:cscore) 
! (import! &self metta-moses:representation:instance) 
! (import! &self metta-moses:metapopulation:exemplar-type) 
! (import! &self metta-moses:representation:lsk)
! (import! &self metta-moses:representation:knob-mapper)

!(import! &self metta-moses:representation:logical-probe) 
! (import! &self metta-moses:representation:build-logical)
! (import! &self metta-moses:representation:build-knobs)
!(import! &self metta-moses:representation:sample-logical-perms) 
!(import! &self metta-moses:representation:add-logical-knobs)

! (import! &self metta-moses:utilities:map)
! (import! &self metta-moses:utilities:nodeId)
! (import! &self metta-moses:utilities:ordered-multimap)
! (import! &self metta-moses:reduct:enf)
! (import! &self metta-moses:utilities:python-treehelpers)

(= (ARGS) args) 
(= (APPEND_CHILD $tree $nodeId $child ) (py_appendChild $tree $nodeId $child))
(= (GetByID $tree $nodeId) (py_getById $tree $nodeId))

(= (INSERT_ABOVE $tree $nodeId $subtree) (py_insertAbove  $tree $nodeId $subtree))

; Helper function for clean tree
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
                      (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap))))
                      (mkDscMp (ConsMMap ((mkDiscSpec 1) lsk1) (ConsMMap ((mkDiscSpec 0) lsk2) (ConsMMap ((mkDiscSpec 1) lsk3) NilMMap))))))

! (bind! sInstSet (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 0 (Cons 0 Nil)))) (mkCscore -0.1 2 0.2 0.3 -0.6)))
           (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))) (mkCscore -0.2 1 0.1 0.1 -0.4)))
                 (Cons  (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 (Cons 0 Nil)))) (mkCscore 0 2 1.0 0 -1.0))) Nil)))))

! (bind! ttable1 (mkITable (Cons (Cons True (Cons False (Cons True Nil)))
                        (Cons (Cons True (Cons True  (Cons True Nil))) Nil)) 
                        (Cons A (Cons B (Cons O Nil)))))
! (bind! ttable2 (mkITable
                    (Cons (Cons True (Cons True (Cons True Nil)))
                    (Cons (Cons True (Cons False (Cons False Nil)))
                    (Cons (Cons False (Cons True (Cons False Nil)))
                    (Cons (Cons False (Cons False (Cons False Nil))) Nil))))
                    (Cons A (Cons B (Cons Output Nil)))))

; ;; Test cases for removeDupInsts
; !(assertEqual
;    (removeDupInsts
;      (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))) 1)) Nil)
;      1)
;    (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))) 1)) Nil))

; !(assertEqual
;    (removeDupInsts
;      (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))) 1)) Nil)
;      0)
;    Nil)

; !(assertEqual
;    (removeDupInsts
;      (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))) 3))
;            (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))) 3))
;                  (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 1 (Cons 1 Nil)))) 1)) Nil)))
;      3)
;    (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))) 3))
;          (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 1 (Cons 1 Nil)))) 1)) Nil)))

; !(assertEqual
;    (removeDupInsts
;      (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))) 3))
;            (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))) 3))
;                  (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 1 (Cons 1 Nil)))) 2))
;                        (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 1 (Cons 1 Nil)))) 2))
;                              (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 1)) Nil)))))
;      3)
;    (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))) 3))
;          (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 1 (Cons 1 Nil)))) 2))
;                (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) 1)) Nil))))

; ;; Test case for keepTopUnique
; !(assertEqual 
;    (keepTopUniqueCandidates (mkDeme (mkRep knobMapObj tree1) sInstSet (mkDemeId "1")) 5 2)
;    (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 0 (Cons 0 Nil)))) (mkCscore -1 2 1 0 1))) (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))) (mkCscore 0 2 0.5 0 -0.5))) Nil)))

; ; Test case for trimDownDeme
; !(trimDownDeme (mkDeme (mkRep knobMapObj tree1) sInstSet (mkDemeId "1")) 0 1)

; !(assertEqual
;   (demeToTrees (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap)))) (mkDscMp (ConsMMap ((mkDiscSpec 1) lsk1) (ConsMMap ((mkDiscSpec 0) lsk2) (ConsMMap ((mkDiscSpec 1) lsk3) NilMMap))))) (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil))))) (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 0 (Cons 0 Nil)))) (mkCscore -1 2 1 0 1))) (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 0 (Cons 0 Nil)))) (mkCscore 0 2 0.5 0 0.8))) Nil))) (mkDemeId "1")))
;   (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore Nil)) (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8) (mkBScore Nil)) Nil))
; )
; !(getNewCandidates (Cons 1 (Cons 2 (Cons 3 Nil))) (Cons 1 (Cons 4 (Cons 5 Nil))))

; !(dominates (mkBScore (Cons 1 (Cons 5 (Cons 3 Nil)))) (mkBScore (Cons 2 (Cons 2 (Cons 4 Nil)))))

; !(assertEqual
; (removeDominated
;    (Cons 
;      (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (Cons 1 (Cons 5 (Cons 3 Nil))))) 
;    (Cons 
;      (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8)(mkBScore (Cons 2 (Cons 2 (Cons 4 Nil))))) Nil))
; )
; (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (Cons 1 (Cons 5 (Cons 3 Nil))))) (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8) (mkBScore (Cons 2 (Cons 2 (Cons 4 Nil))))) Nil))
; )

; !(assertEqual
;    (removeDominated Nil)
;    Nil)

; !(assertEqual
;   (removeDominated
;    (Cons
;      (mkExemplar
;        (mkTree (mkNode A) Nil)
;        (mkDemeId "1")
;        (mkCscore -1 2 1 0 1)
;        (mkBScore (Cons 1 (Cons 1 Nil))))
;      Nil))
;    (Cons (mkExemplar (mkTree (mkNode A) Nil) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (Cons 1 (Cons 1 Nil)))) Nil))
       
; !(assertEqual
;    (removeDominated
;      (Cons
;        (mkExemplar
;          (mkTree (mkNode A) Nil)
;          (mkDemeId "1")
;          (mkCscore -1 2 1 0 1)
;          (mkBScore (Cons 1 (Cons 1 Nil))))
;        (Cons
;          (mkExemplar
;            (mkTree (mkNode B) Nil)
;            (mkDemeId "1")
;            (mkCscore 0 2 0.5 0 0.8)
;            (mkBScore (Cons 1 (Cons 0 Nil))))
;          Nil)))
;    (Cons
;      (mkExemplar
;        (mkTree (mkNode A) Nil)
;        (mkDemeId "1")
;        (mkCscore -1 2 1 0 1)
;        (mkBScore (Cons 1 (Cons 1 Nil))))
;      Nil))

; !(assertEqual
;    (removeDominated
;      (Cons
;        (mkExemplar
;          (mkTree (mkNode A) Nil)
;          (mkDemeId "1")
;          (mkCscore -1 2 1 0 1)
;          (mkBScore (Cons 1 (Cons 0 Nil))))
;        (Cons
;          (mkExemplar
;            (mkTree (mkNode B) Nil)
;            (mkDemeId "1")
;            (mkCscore 0 2 0.5 0 0.8)
;            (mkBScore (Cons 1 (Cons 1 Nil))))
;          Nil)))
;    (Cons
;      (mkExemplar
;        (mkTree (mkNode B) Nil)
;        (mkDemeId "1")
;        (mkCscore 0 2 0.5 0 0.8)
;        (mkBScore (Cons 1 (Cons 1 Nil))))
;      Nil))

; !(assertEqual
;    (removeDominated
;      (Cons
;        (mkExemplar
;          (mkTree (mkNode A) Nil)
;          (mkDemeId "1")
;          (mkCscore -1 2 1 0 1)
;          (mkBScore (Cons 2 (Cons 1 Nil))))
;        (Cons
;          (mkExemplar
;            (mkTree (mkNode B) Nil)
;            (mkDemeId "1")
;            (mkCscore 0 2 0.5 0 0.8)
;            (mkBScore (Cons 1 (Cons 2 Nil))))
;          (Cons
;            (mkExemplar
;              (mkTree (mkNode C) Nil)
;              (mkDemeId "1")
;              (mkCscore 0 2 0.5 0 0.7)
;              (mkBScore (Cons 1 (Cons 0 Nil))))
;            Nil))))
;    (Cons
;      (mkExemplar
;        (mkTree (mkNode A) Nil)
;        (mkDemeId "1")
;        (mkCscore -1 2 1 0 1)
;        (mkBScore (Cons 2 (Cons 1 Nil))))
;      (Cons
;        (mkExemplar
;          (mkTree (mkNode B) Nil)
;          (mkDemeId "1")
;          (mkCscore 0 2 0.5 0 0.8)
;          (mkBScore (Cons 1 (Cons 2 Nil))))
;        Nil)))

;  !(mergeDemes (mkDeme (mkRep knobMapObj tree1) sInstSet (mkDemeId "1")) 5 2 ttable1)

!(get-type )