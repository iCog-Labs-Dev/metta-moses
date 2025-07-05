! (register-module! ../../../metta-moses)
! (import! &self metta-moses:deme:merge-demes)
! (import! &self metta-moses:deme:create-deme)
! (import! &self metta-moses:deme:deme-id-creation)
! (import! &self metta-moses:scoring:fitness)
! (import! &self metta-moses:scoring:bscore) 
! (import! &self metta-moses:scoring:cscore) 
! (import! &self metta-moses:representation:representation)
! (import! &self metta-moses:representation:knob-representation)
! (import! &self metta-moses:representation:instance)  
! (import! &self metta-moses:representation:instance)
! (import! &self metta-moses:representation:lsk)
! (import! &self metta-moses:representation:knob-mapper)
! (import! &self metta-moses:representation:logical-probe) 
! (import! &self metta-moses:representation:build-logical)
! (import! &self metta-moses:representation:build-knobs)
! (import! &self metta-moses:representation:sample-logical-perms) 
! (import! &self metta-moses:representation:add-logical-knobs)
! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:ordered-set)
! (import! &self metta-moses:utilities:pair)
! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:utilities:map)
! (import! &self metta-moses:utilities:nodeId)
! (import! &self metta-moses:utilities:ordered-multimap)
! (import! &self metta-moses:utilities:python-treehelpers)
! (import! &self metta-moses:reduct:enf)
! (import! &self metta-moses:metapopulation:exemplar-type)
! (import! &self metta-moses:metapopulation:metapopulation)

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

! (bind! metaPop (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (Cons 0 (Cons 0 Nil))))
                 (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) 
                 NilOS)))

;; Testcase-1 for the removeDupInsts
!(assertEqual
   (removeDupInsts
      (Cons
         (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 0)))
         (Cons
            (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 0)))
            (Cons
               (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 0)))
               Nil)))
      2)
   (Cons
      (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 0)))
      (Cons
         (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 0)))
         Nil)))

;; Testcase-2 for the removeDupInsts
!(assertEqual
   (removeDupInsts
      (Cons
         (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 0)))
         (Cons
            (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 0)))
            (Cons
               (mkSInst (mkPair (mkInst (Cons 5 (Cons 6 Nil))) (mkCscore 0 3 0 0 0)))
               Nil)))
      2)
   (Cons
      (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 0)))
      (Cons
         (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 0)))
         Nil)))

;; Testcase-3 for the removeDupInsts
!(assertEqual
   (removeDupInsts
      (Cons
         (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 0)))
         (Cons
            (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 0)))
            (Cons
               (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 0)))
               (Cons
                  (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 0)))
                  Nil))))
      3)
   (Cons
      (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 0)))
      (Cons
         (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 0)))
         Nil)))

;; Testcase-1 for keepTopUnique
!(assertEqual
   (keepTopUniqueCandidates
      (mkSInstSet
         (Cons
            (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 0)))
            (Cons
               (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 0)))
               (Cons
                  (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 0)))
                  Nil))))
      5
      2)
   (Cons
      (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 0)))
      (Cons
         (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 0)))
         Nil)))

;; Testcase-2 for keepTopUnique   
!(assertEqual
   (keepTopUniqueCandidates
      (mkSInstSet
         (Cons
            (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 0)))
            (Cons
               (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 0)))
               (Cons
                  (mkSInst (mkPair (mkInst (Cons 5 (Cons 6 Nil))) (mkCscore 0 3 0 0 0)))
                  Nil))))
      2
      5)
   (Cons
      (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 0)))
      (Cons
         (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 0)))
         Nil)))

;; Testcase-3 for keepTopUnique
!(assertEqual
   (keepTopUniqueCandidates
      (mkSInstSet
         (Cons
            (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 0)))
            (Cons
               (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 0)))
               (Cons
                  (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 0)))
                  (Cons
                     (mkSInst (mkPair (mkInst (Cons 5 (Cons 6 Nil))) (mkCscore 0 3 0 0 0)))
                     Nil)))))
      5
      3)
   (Cons
      (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 0)))
      (Cons
         (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 0)))
         (Cons
            (mkSInst (mkPair (mkInst (Cons 5 (Cons 6 Nil))) (mkCscore 0 3 0 0 0)))
            Nil))))

;; Testcase-1 for filterDemeByScore
!(assertEqual
   (filterDemeByScore
      (Cons
         (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 -0.1)))
         (Cons
            (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 -0.3)))
            (Cons
               (mkSInst (mkPair (mkInst (Cons 5 (Cons 6 Nil))) (mkCscore 0 3 0 0 -0.5)))
               Nil)))
      2
      -0.4)
   (Cons
      (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 -0.1)))
      (Cons
         (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 -0.3)))
         Nil)))

;; Testcase-2 for filterDemeByScore
!(assertEqual
   (filterDemeByScore
      (Cons
         (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 -0.1)))
         (Cons
            (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 -0.2)))
            (Cons
               (mkSInst (mkPair (mkInst (Cons 5 (Cons 6 Nil))) (mkCscore 0 3 0 0 -0.3)))
               Nil)))
      2
      -0.4)
   (Cons
      (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 -0.1)))
      (Cons
         (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 -0.2)))
         (Cons
            (mkSInst (mkPair (mkInst (Cons 5 (Cons 6 Nil))) (mkCscore 0 3 0 0 -0.3)))
            Nil))))

;; Testcase-3 for filterDemeByScore
!(assertEqual
   (filterDemeByScore
      (Cons
         (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 -0.1)))
         (Cons
            (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 -0.5)))
            (Cons
               (mkSInst (mkPair (mkInst (Cons 5 (Cons 6 Nil))) (mkCscore 0 3 0 0 -0.6)))
               Nil)))
      2
      -0.4)
   (Cons
      (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 -0.1)))
      Nil))

;; Testcase-1 for trimDownDeme
!(assertEqual
  (trimDownDeme
      (Cons
         (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 -0.1)))
         (Cons
            (mkSInst (mkPair (mkInst (Cons 3 (Cons 4 Nil))) (mkCscore 0 2 0 0 -0.3)))
            (Cons
               (mkSInst (mkPair (mkInst (Cons 5 (Cons 6 Nil))) (mkCscore 0 3 0 0 -0.5)))
               Nil))) 2 0.1)
               
  (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 -0.1))) Nil))

;; Testcase-2 for trimDownDeme
!(assertEqual
  (trimDownDeme
    (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))) (mkCscore -0.2 1 0.1 0.1 -0.4))) (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 0 (Cons 0 Nil)))) (mkCscore -0.1 2 0.2 0.3 -0.6))) Nil)) 0 1)
  (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))) (mkCscore -0.2 1 0.1 0.1 -0.4))) (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 0 (Cons 0 Nil)))) (mkCscore -0.1 2 0.2 0.3 -0.6))) Nil)))

;; Testcase-3 for trimDownDeme
!(assertEqual
   (trimDownDeme
      (Cons
         (mkSInst (mkPair (mkInst (Cons 7 (Cons 8 Nil))) (mkCscore -0.1 1 0.2 0.0 -0.15)))
         (Cons
            (mkSInst (mkPair (mkInst (Cons 9 (Cons 10 Nil))) (mkCscore -0.2 2 0.15 0.1 -0.35)))
            (Cons
               (mkSInst (mkPair (mkInst (Cons 11 (Cons 12 Nil))) (mkCscore -0.3 3 0.1 0.2 -0.55)))
               Nil)))
      2
      0.1)
   (Cons (mkSInst (mkPair (mkInst (Cons 7 (Cons 8 Nil))) (mkCscore -0.1 1 0.2 0.0 -0.15))) Nil))

; Testcase-1 for demeToTrees
!(assertEqual
  (demeToTrees (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap)))) (mkDscMp (ConsMMap ((mkDiscSpec 1) lsk1) (ConsMMap ((mkDiscSpec 0) lsk2) (ConsMMap ((mkDiscSpec 1) lsk3) NilMMap))))) (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil))))) (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 0 (Cons 0 Nil)))) (mkCscore -1 2 1 0 1))) (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 0 (Cons 0 Nil)))) (mkCscore 0 2 0.5 0 0.8))) Nil))) (mkDemeId "1")) ttable1)
  ;; (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (Cons 0 (Cons 0 Nil)))) (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8) (mkBScore (Cons 0 (Cons 0 Nil)))) Nil)) ;; TODO: Uncomment when the reduct issue has been resolved.
  (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) (Cons (mkTree (mkNode D) Nil) Nil)))) Nil)) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (Cons -1 (Cons 0 Nil)))) (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8) (mkBScore (Cons -1 (Cons 0 Nil)))) Nil))
)

; Testcase-2 for demeToTrees
 !(assertEqual
    (demeToTrees (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap)))) (mkDscMp (ConsMMap ((mkDiscSpec 1) lsk1) (ConsMMap ((mkDiscSpec 0) lsk2) (ConsMMap ((mkDiscSpec 1) lsk3) NilMMap))))) (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil))))) (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 0 (Cons 0 Nil)))) (mkCscore -1 2 1 0 1))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) (mkCscore 0 2 0.5 0 0.8))) Nil))) (mkDemeId "1")) ttable1)
    ;; (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (Cons 0 (Cons 0 Nil)))) (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) Nil))) Nil)) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8) (mkBScore (Cons 0 (Cons 0 Nil)))) Nil)) ;; TODO: Uncomment when the reduct issue is resolved.
    (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) (Cons (mkTree (mkNode D) Nil) Nil)))) Nil)) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (Cons -1 (Cons 0 Nil)))) (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) Nil))) Nil)) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8) (mkBScore (Cons -1 (Cons 0 Nil)))) Nil))
)

;; Testcase-1 for getNewCandidates
! "Get new Candidate tests"
!(assertEqual
  (getNewCandidates 
    (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (Cons 0 (Cons 0 Nil)))) (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) Nil)) 
     metaPop)
  (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (Cons 0 (Cons 0 Nil)))) (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) Nil)))

;; Testcase-2 for getNewCandidates
!(assertEqual
   (getNewCandidates 
    (Cons (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) Nil)) 
     metaPop)
   (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) Nil))

;; Testcase-1 for dominates
!(assertEqual 
  (dominates (mkBScore (Cons 1 (Cons 5 (Cons 3 Nil)))) (mkBScore (Cons 2 (Cons 2 (Cons 4 Nil)))))
  Indeterminate)

;; Testcase-2 for dominates
!(assertEqual
   (dominates 
      (mkBScore (Cons 5 (Cons 4 (Cons 3 Nil))))
      (mkBScore (Cons 2 (Cons 1 (Cons 0 Nil)))))
   True)

;; Testcase-3 for dominates
!(assertEqual
   (dominates 
      (mkBScore (Cons 1 (Cons 2 (Cons 3 Nil))))
      (mkBScore (Cons 2 (Cons 3 (Cons 3 Nil)))))
   False)

; Testcase-1 for removeDominated

! "Remove dominated tests"
!(assertEqual
(removeDominated
   (Cons 
     (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (Cons 1 (Cons 5 (Cons 3 Nil))))) 
   (Cons 
     (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8)(mkBScore (Cons 2 (Cons 2 (Cons 4 Nil))))) Nil))
)
(Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (Cons 1 (Cons 5 (Cons 3 Nil))))) (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8) (mkBScore (Cons 2 (Cons 2 (Cons 4 Nil))))) Nil))
)

; Testcase-2 for removeDominated
!(assertEqual
  (removeDominated
   (Cons
     (mkExemplar
       (mkTree (mkNode A) Nil)
       (mkDemeId "1")
       (mkCscore -1 2 1 0 1)
       (mkBScore (Cons 1 (Cons 1 Nil))))
     Nil))
   (Cons (mkExemplar (mkTree (mkNode A) Nil) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (Cons 1 (Cons 1 Nil)))) Nil))

; Testcase-3 for removeDominated    
!(assertEqual
   (removeDominated
     (Cons
       (mkExemplar
         (mkTree (mkNode A) Nil)
         (mkDemeId "1")
         (mkCscore -1 2 1 0 1)
         (mkBScore (Cons 1 (Cons 1 Nil))))
       (Cons
         (mkExemplar
           (mkTree (mkNode B) Nil)
           (mkDemeId "1")
           (mkCscore 0 2 0.5 0 0.8)
           (mkBScore (Cons 1 (Cons 0 Nil))))
         Nil)))
   (Cons
     (mkExemplar
       (mkTree (mkNode A) Nil)
       (mkDemeId "1")
       (mkCscore -1 2 1 0 1)
       (mkBScore (Cons 1 (Cons 1 Nil))))
     Nil))

; Testcase-4 for removeDominated
!(assertEqual
   (removeDominated
     (Cons
       (mkExemplar
         (mkTree (mkNode A) Nil)
         (mkDemeId "1")
         (mkCscore -1 2 1 0 1)
         (mkBScore (Cons 1 (Cons 0 Nil))))
       (Cons
         (mkExemplar
           (mkTree (mkNode B) Nil)
           (mkDemeId "1")
           (mkCscore 0 2 0.5 0 0.8)
           (mkBScore (Cons 1 (Cons 1 Nil))))
         Nil)))
   (Cons
     (mkExemplar
       (mkTree (mkNode B) Nil)
       (mkDemeId "1")
       (mkCscore 0 2 0.5 0 0.8)
       (mkBScore (Cons 1 (Cons 1 Nil))))
     Nil))

; Testcase-5 for removeDominated
!(assertEqual
   (removeDominated
     (Cons
       (mkExemplar
         (mkTree (mkNode A) Nil)
         (mkDemeId "1")
         (mkCscore -1 2 1 0 1)
         (mkBScore (Cons 2 (Cons 1 Nil))))
       (Cons
         (mkExemplar
           (mkTree (mkNode B) Nil)
           (mkDemeId "1")
           (mkCscore 0 2 0.5 0 0.8)
           (mkBScore (Cons 1 (Cons 2 Nil))))
         (Cons
           (mkExemplar
             (mkTree (mkNode C) Nil)
             (mkDemeId "1")
             (mkCscore 0 2 0.5 0 0.7)
             (mkBScore (Cons 1 (Cons 0 Nil))))
           Nil))))
   (Cons
     (mkExemplar
       (mkTree (mkNode A) Nil)
       (mkDemeId "1")
       (mkCscore -1 2 1 0 1)
       (mkBScore (Cons 2 (Cons 1 Nil))))
     (Cons
       (mkExemplar
         (mkTree (mkNode B) Nil)
         (mkDemeId "1")
         (mkCscore 0 2 0.5 0 0.8)
         (mkBScore (Cons 1 (Cons 2 Nil))))
       Nil)))

; Testcase for mergeCandidates
! "Merge candidates tests"
!(assertEqual
 (mergeCandidates
      (Cons
         (mkExemplar
            (mkTree (mkNode A) Nil)
            (mkDemeId "1")
            (mkCscore -0.1 2 0.1 0.1 -0.3)
            (mkBScore (Cons 0 (Cons 0 Nil))))
         (Cons
            (mkExemplar
               (mkTree (mkNode B) Nil)
               (mkDemeId "1")
               (mkCscore -0.2 3 0.1 0.1 -0.4)
               (mkBScore (Cons 0 (Cons 0 Nil))))
            Nil))
      metaPop)
      (ConsOS (mkExemplar (mkTree (mkNode A) Nil) (mkDemeId "1") (mkCscore -0.1 2 0.1 0.1 -0.3) (mkBScore (Cons 0 (Cons 0 Nil)))) (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (Cons 0 (Cons 0 Nil)))) (ConsOS (mkExemplar (mkTree (mkNode B) Nil) (mkDemeId "1") (mkCscore -0.2 3 0.1 0.1 -0.4) (mkBScore (Cons 0 (Cons 0 Nil)))) (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) NilOS)))))

;; Testcase for mergeDemes
! "Merge Demes tests"
!(assertEqual
  (mergeDemes (mkDeme (mkRep knobMapObj tree1) sInstSet (mkDemeId "1")) 5 2 0 1 ttable1 metaPop 3 0.004 1000)
  (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (Cons 0 (Cons 0 Nil)))) (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) NilOS)))

