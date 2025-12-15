!(import! &self ../../reduct/boolean-reduct/rte-helpers)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-or)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-and)
!(import! &self ../../reduct/boolean-reduct/n-ary-propagate-not)
!(import! &self ../../reduct/boolean-reduct/n-ary-gather-junctors)
!(import! &self ../../reduct/boolean-reduct/delete-inconsistent-handle)
!(import! &self ../../reduct/boolean-reduct/zero-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/one-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/promote-common-constraints)
!(import! &self ../../reduct/boolean-reduct/reduce-to-elegance)

!(import! &self ../merge-demes)
!(import! &self ../create-deme)
!(import! &self ../deme-id-creation)
!(import! &self ../score-deme)

!(import! &self ../../scoring/fitness)
!(import! &self ../../scoring/bscore) 
!(import! &self ../../scoring/cscore)
!(import! &self ../../scoring/complexity-based-scorer)

!(import! &self ../../moses/neighborhood-sampling)
!(import! &self ../../representation/representation)
!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/instance)  
!(import! &self ../../representation/lsk)
!(import! &self ../../representation/knob-mapper)
!(import! &self ../../representation/logical-probe) 
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/build-knobs)
!(import! &self ../../representation/sample-logical-perms) 
!(import! &self ../../representation/add-logical-knobs)

!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/ordered-set)
!(import! &self ../../utilities/pair)
!(import! &self ../../utilities/tree)
!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/map)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/ordered-multimap)
; !(import! &self ../../utilities/python-treehelpers)

; ! (import! &self metta-moses:reduct:enf)
!(import! &self ../../metapopulation/exemplar-type)
!(import! &self ../../metapopulation/metapopulation)
; !(import! &self metta-moses:scoring:bscore)

(= (APPEND_CHILD $tree $nodeId $child ) (py_appendChild $tree $nodeId $child))
(= (GetByID $tree $nodeId) (py_getById $tree $nodeId))
(= (INSERT_ABOVE $tree $nodeId $subtree) (py_insertAbove  $tree $nodeId $subtree))
; Helper function for clean tree
; (= (REDUCE $expr) (reduce $expr))

(= (tree1)
        (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil)
                  (Cons (mkNullVex
                          (Cons (mkTree (mkNode D) Nil) Nil)) Nil))))
          (Cons (mkNullVex
                  (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil)))))

(= (lsk1)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (2 3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            ))

(= (lsk2)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              Nil)
            ))

(= (lsk3)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              Nil)
            ))

(= (knobMapObj) (mkKbMap
                      (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap))))
                      (mkDscMp (ConsMMap ((mkDiscSpec 1) lsk1) (ConsMMap ((mkDiscSpec 0) lsk2) (ConsMMap ((mkDiscSpec 1) lsk3) NilMMap))))))

(= (sInstSet) (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) (mkCscore -0.1 2 0.2 0.3 -0.6)))
           (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 (Cons 0 Nil)))) (mkCscore -0.2 1 0.1 0.1 -0.4)))
                 (Cons  (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 (Cons 2 Nil)))) (mkCscore 0 2 1.0 0 -1.0))) Nil)))))

(= (ttable1) (mkITable (Cons (Cons True (Cons False (Cons True Nil)))
                        (Cons (Cons True (Cons True  (Cons True Nil))) Nil)) 
                        (Cons A (Cons B (Cons O Nil)))))
(= (ttable2) (mkITable
                    (Cons (Cons True (Cons True (Cons True (Cons True (Cons True Nil)))))
                    (Cons (Cons True (Cons False (Cons False (Cons False (Cons False Nil)))))
                    (Cons (Cons False (Cons True (Cons False (Cons False (Cons False Nil)))))
                    (Cons (Cons False (Cons False (Cons False (Cons False (Cons False Nil))))) Nil))))
                    (Cons A (Cons B (Cons C (Cons D (Cons output Nil)))))))

(= (metaPop) (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (Cons 0 (Cons 0 Nil))))
                 (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) 
                 NilOS)))

; Testcase-1 for the removeDupInsts
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
 ; 
; Testcase-2 for the removeDupInsts
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
 ; 
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
 ; 
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
 ; 
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
 ; 
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
 ; 
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
 ; 
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
 ; 
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
 ; 
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
                ; 
   (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 0 1 0 0 -0.1))) Nil))
 ; 
 ;; Testcase-2 for trimDownDeme
 !(assertEqual
   (trimDownDeme
     (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))) (mkCscore -0.2 1 0.1 0.1 -0.4))) (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 0 (Cons 0 Nil)))) (mkCscore -0.1 2 0.2 0.3 -0.6))) Nil)) 0 1)
   (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 0 Nil)))) (mkCscore -0.2 1 0.1 0.1 -0.4))) (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 0 (Cons 0 Nil)))) (mkCscore -0.1 2 0.2 0.3 -0.6))) Nil)))
 ; 
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
 
;;  Testcase-1 for demeToTrees
;;  NOTE: All the instances in the deme don't include lsk1 (or they all start with '0') because we are testing it using ttable2. 
;;        ttable2 is a truth table which doesn't have a 'D' column.
 !(assertEqual
  (demeToTrees (mkDeme (mkRep (mkKbMap 
                                  (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap)))) 
                                  (mkDscMp (ConsMMap ((mkDiscSpec 1) (lsk1)) (ConsMMap ((mkDiscSpec 0) (lsk2)) (ConsMMap ((mkDiscSpec 1) (lsk3)) NilMMap))))) 
                              (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) 
                                                      (Cons (mkTree (mkNode OR) 
                                                          (Cons (mkTree (mkNode B) Nil) 
                                                          (Cons (mkTree (mkNode C) Nil) 
                                                      (Cons (mkNullVex (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) 
                                                      (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil)) Nil)) Nil))))) 
                          (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 1 Nil)))) (mkCscore -1 2 1 0 1))) 
                                      (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (mkCscore 0 2 0.5 0 0.8))) Nil))) (mkDemeId "1")) (ttable2))
  
  (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) 
        (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) 
            (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) Nil))) Nil))) 
        (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil)))))) 
  (Cons (mkExemplar (mkTree (mkNode AND) Nil) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8) 
                    (mkBScore (Cons -1 (Cons -1 (Cons -1 (Cons -1 Nil)))))) Nil)))

;; Testcase-2 for demeToTrees
!(assertEqual 
      (demeToTrees (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap)))) (mkDscMp (ConsMMap ((mkDiscSpec 1) (lsk1)) (ConsMMap ((mkDiscSpec 0) (lsk2)) (ConsMMap ((mkDiscSpec 1) (lsk3)) NilMMap))))) 
                  (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) 
                          (Cons (mkNullVex (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)))) 
                  (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 (Cons 2 Nil)))) (mkCscore -1 2 1 0 1))) 
                  (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 0 Nil)))) (mkCscore 0 2 0.5 0 0.8))) Nil))) (mkDemeId "1")) (ttable2))
      
      (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) 
                            (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) 
                            (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) Nil))) Nil))) (mkDemeId "1") (mkCscore -1 2 1 0 1) 
                            (mkBScore (Cons -1 (Cons 0 (Cons -1 (Cons 0 Nil)))))) 
        (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) 
                            (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) Nil))) Nil)) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8) 
                                    (mkBScore (Cons 0 (Cons 0 (Cons -1 (Cons 0 Nil)))))) Nil)))

;; Testcase-1 for getNewCandidates
; ! ("Get new Candidate tests")
!(assertEqual
  (getNewCandidates 
    (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (Cons 0 (Cons 0 Nil)))) (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) Nil)) 
     (metaPop))
  (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (Cons 0 (Cons 0 Nil)))) (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) Nil)))
; 
;; Testcase-2 for getNewCandidates
!(assertEqual
   (getNewCandidates 
    (Cons (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) Nil)) 
     (metaPop))
   (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) Nil))
; 
;; Testcase-1 for dominates
!(assertEqual 
  (dominates (mkBScore (Cons 1 (Cons 5 (Cons 3 Nil)))) (mkBScore (Cons 2 (Cons 2 (Cons 4 Nil)))))
  Indeterminate)
; 
;; Testcase-2 for dominates
!(assertEqual
   (dominates 
      (mkBScore (Cons 5 (Cons 4 (Cons 3 Nil))))
      (mkBScore (Cons 2 (Cons 1 (Cons 0 Nil)))))
   True)
; 
;; Testcase-3 for dominates
!(assertEqual
   (dominates 
      (mkBScore (Cons 1 (Cons 2 (Cons 3 Nil))))
      (mkBScore (Cons 2 (Cons 3 (Cons 3 Nil)))))
   False)
;                          
; Testcase-1 for removeDominated
; ! ("Remove dominated tests")
!(assertEqual
(removeDominated
   (Cons 
     (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (Cons 1 (Cons 5 (Cons 3 Nil))))) 
   (Cons 
     (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8)(mkBScore (Cons 2 (Cons 2 (Cons 4 Nil))))) Nil))
)
(Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (Cons 1 (Cons 5 (Cons 3 Nil))))) (Cons (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8) (mkBScore (Cons 2 (Cons 2 (Cons 4 Nil))))) Nil))
)
; 
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
; 
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
; 
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
; 
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
; 
; Testcase for mergeCandidates
; ! ("Merge candidates tests")
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
      (metaPop))
      (ConsOS (mkExemplar (mkTree (mkNode A) Nil) (mkDemeId "1") (mkCscore -0.1 2 0.1 0.1 -0.3) (mkBScore (Cons 0 (Cons 0 Nil)))) (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (Cons 0 (Cons 0 Nil)))) (ConsOS (mkExemplar (mkTree (mkNode B) Nil) (mkDemeId "1") (mkCscore -0.2 3 0.1 0.1 -0.4) (mkBScore (Cons 0 (Cons 0 Nil)))) (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) NilOS)))))
; 
;; Testcase for mergeDemes
;; NOTE: All the instances in the deme don't include lsk1 (or they all start with '0') because we are testing it using ttable2. 
;;       ttable2 is a truth table which doesn't have a 'D' column.
;; ! ("Merge Demes tests")
!(assertEqual
   (mergeDemes ((mkDeme (mkRep 
                        (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 3) (ConsMap ((mkNodeId (2)) 2) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (4)) 0) NilMap))))) 
                                    (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) 
                                             (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) 
                                             (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) 
                                             (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))))) 
                        (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))))) 
                                                   (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 1 (Cons 1 Nil))))) (mkCscore 0 2 1.0 0.0 -1.0))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) (mkCscore -4 0 0.0 0.0 -4.0))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 2 Nil))))) (mkCscore -3 1 0.5 0.0 -3.5))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 1 Nil))))) (mkCscore -1 1 0.5 0.0 -1.5))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) (mkCscore -4 0 0.0 0.0 -4.0))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 1 Nil))))) (mkCscore -1 1 0.5 0.0 -1.5))) Nil))))))) (mkDemeId "1.1")) 
               (mkDeme (mkRep 
                           (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 3) (ConsMap ((mkNodeId (2)) 2) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (4)) 0) NilMap))))) 
                              (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) 
                                       (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) 
                                       (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) 
                                       (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))))) 
                                       
                           (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) 
                                                (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) 
                                                (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) 
                                                (Cons (mkNullVex (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) Nil)))))) 
                                                (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 1 Nil))))) (mkCscore -1 1 0.5 0.0 -1.5))) (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 1 Nil))))) (mkCscore -1 1 0.5 0.0 -1.5))) 
                                                   (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 0 Nil))))) (mkCscore -4 0 0.0 0.0 -4.0))) 
                                                   (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 1 Nil))))) (mkCscore -1 1 0.5 0.0 -1.5))) 
                                                   (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 0 (Cons 0 (Cons 2 Nil))))) (mkCscore -3 1 0.5 0.0 -3.5))) 
                                                   (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 (Cons 0 (Cons 1 Nil))))) (mkCscore -1 3 1.5 0.0 -2.5))) 
                                                   (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 0 (Cons 0 (Cons 1 Nil))))) (mkCscore -2 3 1.5 0.0 -3.5))) Nil)))))))) (mkDemeId "1.0"))) 
                                                   5 2 0 1 (ttable2) (metaPop) 3 0.004 1000)
                           
               (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) 
                                    (Cons (mkTree (mkNode A) Nil) Nil)) 
                                    (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) 
                                    (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) 
                                    (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) 
                                    (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) 
                                    (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (Cons 0 (Cons 0 Nil)))) 
               (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode OR) 
                                    (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) 
                                    (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) 
                                    (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) 
                                    (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) NilOS))
)