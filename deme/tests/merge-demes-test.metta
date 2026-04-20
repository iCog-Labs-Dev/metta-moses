!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/map)
!(import! &self ../../utilities/ordered-set)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/pair)
!(import! &self ../../utilities/nodeId)

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

!(import! &self ../../utilities/tree)

!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/lsk)
!(import! &self ../../representation/logical-probe) 
!(import! &self ../../representation/logical-canonize)
!(import! &self ../../representation/sample-logical-perms) 
!(import! &self ../../representation/add-logical-knobs)
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/build-knobs)
!(import! &self ../../representation/knob-mapper)
!(import! &self ../../representation/representation)


!(import! &self ../../moses/neighborhood-sampling)

!(import! &self ../../examples/tic-tac-toe/tic-tac-toe-helpers)
!(import! &self ../../examples/tic-tac-toe/random-player)
!(import! &self ../../examples/tic-tac-toe/strategy-scoring)
!(import! &self ../../examples/tic-tac-toe/minimax-player)
!(import! &self ../../examples/tic-tac-toe/game-engine)
!(import! &self ../../examples/tic-tac-toe/moves)
!(import! &self ../../examples/tic-tac-toe/moses-player)

!(import! &self ../../scoring/fitness)
!(import! &self ../../scoring/bscore) 
!(import! &self ../../scoring/cscore)
!(import! &self ../../scoring/complexity-based-scorer)
!(import! &self ../../scoring/strategy-score-cache)

!(import! &self ../../metapopulation/exemplar-type)
!(import! &self ../../metapopulation/metapopulation)
!(import! &self ../../optimization/hillclimbing/hill-climbing-helpers)

!(import! &self ../../representation/instance)  

!(import! &self ../deme-id-creation)
!(import! &self ../create-deme)
!(import! &self ../score-deme)
!(import! &self ../merge-demes)

(= (tree1)
        (mkTree (mkNode AND)
          (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ())
                  (cons (mkNullVex
                          (cons (mkTree (mkNode D) ()) ())) ()))))
          (cons (mkNullVex
                  (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())) ())) ())))))

(= (lsk1)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (2 3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              ())
            ))

(= (lsk2)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (3)))
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              ())
            ))

(= (lsk3)
        (mkLSK
            (mkDiscKnob
              (mkKnob (mkNodeId (1)))
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              ())
            ))

(= (knobMapObj) (mkKbMap
                      (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap))))
                      (mkDscMp (ConsMMap ((mkDiscSpec 1) lsk1) (ConsMMap ((mkDiscSpec 0) lsk2) (ConsMMap ((mkDiscSpec 1) lsk3) NilMMap))))))

(= (sInstSet) (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 ())))) (mkCscore -0.1 2 0.2 0.3 -0.6)))
           (cons (mkSInst (mkPair (mkInst (cons 0 (cons 2 (cons 0 ())))) (mkCscore -0.2 1 0.1 0.1 -0.4)))
                 (cons  (mkSInst (mkPair (mkInst (cons 0 (cons 2 (cons 2 ())))) (mkCscore 0 2 1.0 0 -1.0))) ())))))

(= (ttable1) (mkITable (cons (cons True (cons False (cons True ())))
                        (cons (cons True (cons True  (cons True ()))) ())) 
                        (cons A (cons B (cons O ())))))
(= (ttable2) (mkITable
                    (cons (cons True (cons True (cons True (cons True (cons True ())))))
                    (cons (cons True (cons False (cons False (cons False (cons False ())))))
                    (cons (cons False (cons True (cons False (cons False (cons False ())))))
                    (cons (cons False (cons False (cons False (cons False (cons False ()))))) ()))))
                    (cons A (cons B (cons C (cons D (cons output ())))))))

(= (metaPop) (ConsOS (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (cons 0 (cons 0 ()))))
                 (ConsOS (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ())))) 
                 NilOS)))
(mkDeme  
                          (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1))) 
                                      (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8))) ()))) (mkDemeId "1"))
(= (rep) (mkRep (mkKbMap 
                  (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap)))) 
                  (mkDscMp (ConsMMap ((mkDiscSpec 1) (lsk1)) (ConsMMap ((mkDiscSpec 0) (lsk2)) (ConsMMap ((mkDiscSpec 1) (lsk3)) NilMMap))))) 
                  (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) 
                     (cons (mkTree (mkNode OR) 
                              (cons (mkTree (mkNode B) ()) 
                              (cons (mkTree (mkNode C) ()) 
                              (cons (mkNullVex (cons (mkTree (mkNode D) ()) ())) ()))))
                     (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())) ())) ()))))))
;; Testcase-1 for the removeDupInsts
!(assertEqual
   (removeDupInsts
      (rep)
      (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1))) 
      (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
      (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8)))  ())))
      2)
   (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
   (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8))) ())))

;; Testcase-2 for the removeDupInsts
 !(assertEqual
    (removeDupInsts
       (rep)
       (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
       (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
       (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8))) ())))

       2)
       (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
       (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8))) ())))

 ;; Testcase-3 for the removeDupInsts
 !(assertEqual
    (removeDupInsts
       (rep)
       (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
       (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
       (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8)))
       (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8))) ()))))

       3)

       (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
       (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8))) ())))
 ; 
 ;; Testcase-1 for keepTopUnique
 !(assertEqual
    (keepTopUniqueCandidates
       (rep)
       (mkSInstSet
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1))) 
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8)))  ()))))
       5
       2)
    (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
    (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8))) ())))

 ;; Testcase-2 for keepTopUnique   
 !(assertEqual
    (keepTopUniqueCandidates
       (rep)
       (mkSInstSet
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1))) 
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8)))  ()))))
       2
       5)
    (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
    (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8))) ())))
 ; 
 ;; Testcase-3 for keepTopUnique
 !(assertEqual
    (keepTopUniqueCandidates
       (rep)
       (mkSInstSet
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8)))
          (cons (mkSInst (mkPair (mkInst (cons 1 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8))) ())))))
       5
       3)
    (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
    (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8))) ())))

 ;; Testcase-1 for filterDemeByScore
 !(assertEqual
    (filterDemeByScore
       (cons
          (mkSInst (mkPair (mkInst (cons 1 (cons 2 ()))) (mkCscore 0 1 0 0 -0.1)))
          (cons
             (mkSInst (mkPair (mkInst (cons 3 (cons 4 ()))) (mkCscore 0 2 0 0 -0.3)))
             (cons
                (mkSInst (mkPair (mkInst (cons 5 (cons 6 ()))) (mkCscore 0 3 0 0 -0.5)))
                ())))
       2
       -0.4)
    (cons
       (mkSInst (mkPair (mkInst (cons 1 (cons 2 ()))) (mkCscore 0 1 0 0 -0.1)))
       (cons
          (mkSInst (mkPair (mkInst (cons 3 (cons 4 ()))) (mkCscore 0 2 0 0 -0.3)))
          ())))
 ; 
 ;; Testcase-2 for filterDemeByScore
 !(assertEqual
    (filterDemeByScore
       (cons
          (mkSInst (mkPair (mkInst (cons 1 (cons 2 ()))) (mkCscore 0 1 0 0 -0.1)))
          (cons
             (mkSInst (mkPair (mkInst (cons 3 (cons 4 ()))) (mkCscore 0 2 0 0 -0.2)))
             (cons
                (mkSInst (mkPair (mkInst (cons 5 (cons 6 ()))) (mkCscore 0 3 0 0 -0.3)))
                ())))
       2
       -0.4)
    (cons
       (mkSInst (mkPair (mkInst (cons 1 (cons 2 ()))) (mkCscore 0 1 0 0 -0.1)))
       (cons
          (mkSInst (mkPair (mkInst (cons 3 (cons 4 ()))) (mkCscore 0 2 0 0 -0.2)))
          (cons
             (mkSInst (mkPair (mkInst (cons 5 (cons 6 ()))) (mkCscore 0 3 0 0 -0.3)))
             ()))))
 ; 
 ;; Testcase-3 for filterDemeByScore
 !(assertEqual
    (filterDemeByScore
       (cons
          (mkSInst (mkPair (mkInst (cons 1 (cons 2 ()))) (mkCscore 0 1 0 0 -0.1)))
          (cons
             (mkSInst (mkPair (mkInst (cons 3 (cons 4 ()))) (mkCscore 0 2 0 0 -0.5)))
             (cons
                (mkSInst (mkPair (mkInst (cons 5 (cons 6 ()))) (mkCscore 0 3 0 0 -0.6)))
                ())))
       2
       -0.4)
    (cons
       (mkSInst (mkPair (mkInst (cons 1 (cons 2 ()))) (mkCscore 0 1 0 0 -0.1)))
       ()))
 ; 
 ;; Testcase-1 for trimDownDeme
 !(assertEqual
   (trimDownDeme
       (cons
          (mkSInst (mkPair (mkInst (cons 1 (cons 2 ()))) (mkCscore 0 1 0 0 -0.1)))
          (cons
             (mkSInst (mkPair (mkInst (cons 3 (cons 4 ()))) (mkCscore 0 2 0 0 -0.3)))
             (cons
                (mkSInst (mkPair (mkInst (cons 5 (cons 6 ()))) (mkCscore 0 3 0 0 -0.5)))
                ()))) 2 0.1)
                ; 
   (cons (mkSInst (mkPair (mkInst (cons 1 (cons 2 ()))) (mkCscore 0 1 0 0 -0.1))) ()))
 ; 
 ;; Testcase-2 for trimDownDeme
 !(assertEqual
   (trimDownDeme
     (cons (mkSInst (mkPair (mkInst (cons 1 (cons 2 (cons 0 ())))) (mkCscore -0.2 1 0.1 0.1 -0.4))) (cons (mkSInst (mkPair (mkInst (cons 1 (cons 0 (cons 0 ())))) (mkCscore -0.1 2 0.2 0.3 -0.6))) ())) 0 1)
   (cons (mkSInst (mkPair (mkInst (cons 1 (cons 2 (cons 0 ())))) (mkCscore -0.2 1 0.1 0.1 -0.4))) (cons (mkSInst (mkPair (mkInst (cons 1 (cons 0 (cons 0 ())))) (mkCscore -0.1 2 0.2 0.3 -0.6))) ())))
 ; 
 ;; Testcase-3 for trimDownDeme
 !(assertEqual
    (trimDownDeme
       (cons
          (mkSInst (mkPair (mkInst (cons 7 (cons 8 ()))) (mkCscore -0.1 1 0.2 0.0 -0.15)))
          (cons
             (mkSInst (mkPair (mkInst (cons 9 (cons 10 ()))) (mkCscore -0.2 2 0.15 0.1 -0.35)))
             (cons
                (mkSInst (mkPair (mkInst (cons 11 (cons 12 ()))) (mkCscore -0.3 3 0.1 0.2 -0.55)))
                ())))
       2
       0.1)
    (cons (mkSInst (mkPair (mkInst (cons 7 (cons 8 ()))) (mkCscore -0.1 1 0.2 0.0 -0.15))) ()))

;;  Testcase-1 for demeToTrees
;;  NOTE: All the instances in the deme don't include lsk1 (or they all start with '0') because we are testing it using ttable2. 
;;        ttable2 is a truth table which doesn't have a 'D' column.
!(assertEqual
  (demeToTrees (mkDeme (mkRep (mkKbMap 
                                  (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap)))) 
                                  (mkDscMp (ConsMMap ((mkDiscSpec 1) (lsk1)) (ConsMMap ((mkDiscSpec 0) (lsk2)) (ConsMMap ((mkDiscSpec 1) (lsk3)) NilMMap))))) 
                              (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) 
                                                      (cons (mkTree (mkNode OR) 
                                                          (cons (mkTree (mkNode B) ()) 
                                                          (cons (mkTree (mkNode C) ()) 
                                                      (cons (mkNullVex (cons (mkTree (mkNode D) ()) ())) ())))) 
                                                      (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())) ())) ()))))) 
                          (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1))) 
                                      (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8))) ()))) (mkDemeId "1")) (ttable2))

  (cons (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ()) ()))) ()))) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (cons 0 (cons 0 (cons 0 (cons 0 ())))))) (cons (mkExemplar (mkTree (mkNode AND) ()) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8) (mkBScore (cons -1 (cons -1 (cons -1 (cons -1 ())))))) ())))

;; Testcase-2 for demeToTrees
!(assertEqual 
      (demeToTrees (mkDeme (mkRep (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (2 3)) 0) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (1)) 2) NilMap)))) (mkDscMp (ConsMMap ((mkDiscSpec 1) (lsk1)) (ConsMMap ((mkDiscSpec 0) (lsk2)) (ConsMMap ((mkDiscSpec 1) (lsk3)) NilMMap))))) 
                  (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ()) 
                          (cons (mkNullVex (cons (mkTree (mkNode D) ()) ())) ())))) ())))) 
                  (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 2 (cons 2 ())))) (mkCscore -1 2 1 0 1))) 
                  (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 ())))) (mkCscore 0 2 0.5 0 0.8))) ()))) (mkDemeId "1")) (ttable2))

      (cons (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ()) ()))) ()))) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (cons -1 (cons 0 (cons -1 (cons 0 ())))))) (cons (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ()) ()))) ())) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8) (mkBScore (cons 0 (cons 0 (cons -1 (cons 0 ())))))) ())))

;; Testcase-1 for getNewCandidates
; ! ("Get new Candidate tests")
!(assertEqual
  (getNewCandidates 
    (cons (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (cons 0 (cons 0 ())))) (cons (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ())))) ())) 
     (metaPop))
  (cons (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (cons 0 (cons 0 ())))) (cons (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ())))) ())))
; 
;; Testcase-2 for getNewCandidates
!(assertEqual
   (getNewCandidates 
    (cons (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ())))) (cons (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ())))) ())) 
     (metaPop))
   (cons (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ())))) ()))
; 
;; Testcase-1 for dominates
!(assertEqual 
  (dominates (mkBScore (cons 1 (cons 5 (cons 3 ())))) (mkBScore (cons 2 (cons 2 (cons 4 ())))))
  Indeterminate)
; 
;; Testcase-2 for dominates
!(assertEqual
   (dominates 
      (mkBScore (cons 5 (cons 4 (cons 3 ()))))
      (mkBScore (cons 2 (cons 1 (cons 0 ())))))
   True)
; 
;; Testcase-3 for dominates
!(assertEqual
   (dominates 
      (mkBScore (cons 1 (cons 2 (cons 3 ()))))
      (mkBScore (cons 2 (cons 3 (cons 3 ())))))
   False)
;                          
; Testcase-1 for removeDominated
; ! ("Remove dominated tests")
!(assertEqual
(removeDominated
   (cons 
     (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (cons 1 (cons 5 (cons 3 ()))))) 
   (cons 
     (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode D) ()) ())) ())) ())))) ())) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8)(mkBScore (cons 2 (cons 2 (cons 4 ()))))) ()))
)
(cons (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (cons 1 (cons 5 (cons 3 ()))))) (cons (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode D) ()) ())) ())) ())))) ())) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8) (mkBScore (cons 2 (cons 2 (cons 4 ()))))) ()))
)
; 
; Testcase-2 for removeDominated
!(assertEqual
  (removeDominated
   (cons
     (mkExemplar
       (mkTree (mkNode A) ())
       (mkDemeId "1")
       (mkCscore -1 2 1 0 1)
       (mkBScore (cons 1 (cons 1 ()))))
     ()))
   (cons (mkExemplar (mkTree (mkNode A) ()) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (cons 1 (cons 1 ())))) ()))
; 
; Testcase-3 for removeDominated    
!(assertEqual
   (removeDominated
     (cons
       (mkExemplar
         (mkTree (mkNode A) ())
         (mkDemeId "1")
         (mkCscore -1 2 1 0 1)
         (mkBScore (cons 1 (cons 1 ()))))
       (cons
         (mkExemplar
           (mkTree (mkNode B) ())
           (mkDemeId "1")
           (mkCscore 0 2 0.5 0 0.8)
           (mkBScore (cons 1 (cons 0 ()))))
         ())))
   (cons
     (mkExemplar
       (mkTree (mkNode A) ())
       (mkDemeId "1")
       (mkCscore -1 2 1 0 1)
       (mkBScore (cons 1 (cons 1 ()))))
     ()))
; 
; Testcase-4 for removeDominated
!(assertEqual
   (removeDominated
     (cons
       (mkExemplar
         (mkTree (mkNode A) ())
         (mkDemeId "1")
         (mkCscore -1 2 1 0 1)
         (mkBScore (cons 1 (cons 0 ()))))
       (cons
         (mkExemplar
           (mkTree (mkNode B) ())
           (mkDemeId "1")
           (mkCscore 0 2 0.5 0 0.8)
           (mkBScore (cons 1 (cons 1 ()))))
         ())))
   (cons
     (mkExemplar
       (mkTree (mkNode B) ())
       (mkDemeId "1")
       (mkCscore 0 2 0.5 0 0.8)
       (mkBScore (cons 1 (cons 1 ()))))
     ()))
; 
; Testcase-5 for removeDominated
!(assertEqual
   (removeDominated
     (cons
       (mkExemplar
         (mkTree (mkNode A) ())
         (mkDemeId "1")
         (mkCscore -1 2 1 0 1)
         (mkBScore (cons 2 (cons 1 ()))))
       (cons
         (mkExemplar
           (mkTree (mkNode B) ())
           (mkDemeId "1")
           (mkCscore 0 2 0.5 0 0.8)
           (mkBScore (cons 1 (cons 2 ()))))
         (cons
           (mkExemplar
             (mkTree (mkNode C) ())
             (mkDemeId "1")
             (mkCscore 0 2 0.5 0 0.7)
             (mkBScore (cons 1 (cons 0 ()))))
           ()))))
   (cons
     (mkExemplar
       (mkTree (mkNode A) ())
       (mkDemeId "1")
       (mkCscore -1 2 1 0 1)
       (mkBScore (cons 2 (cons 1 ()))))
     (cons
       (mkExemplar
         (mkTree (mkNode B) ())
         (mkDemeId "1")
         (mkCscore 0 2 0.5 0 0.8)
         (mkBScore (cons 1 (cons 2 ()))))
       ())))
; 
; Testcase for mergeCandidates
; ! ("Merge candidates tests")
!(assertEqual
 (mergeCandidates
      (cons
         (mkExemplar
            (mkTree (mkNode A) ())
            (mkDemeId "1")
            (mkCscore -0.1 2 0.1 0.1 -0.3)
            (mkBScore (cons 0 (cons 0 ()))))
         (cons
            (mkExemplar
               (mkTree (mkNode B) ())
               (mkDemeId "1")
               (mkCscore -0.2 3 0.1 0.1 -0.4)
               (mkBScore (cons 0 (cons 0 ()))))
            ()))
      (metaPop))
      (ConsOS (mkExemplar (mkTree (mkNode A) ()) (mkDemeId "1") (mkCscore -0.1 2 0.1 0.1 -0.3) (mkBScore (cons 0 (cons 0 ())))) (ConsOS (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (cons 0 (cons 0 ())))) (ConsOS (mkExemplar (mkTree (mkNode B) ()) (mkDemeId "1") (mkCscore -0.2 3 0.1 0.1 -0.4) (mkBScore (cons 0 (cons 0 ())))) (ConsOS (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ())))) NilOS)))))
; 
;; Testcase for mergeDemes
;; NOTE: All the instances in the deme don't include lsk1 (or they all start with '0') because we are testing it using ttable2. 
;;       ttable2 is a truth table which doesn't have a 'D' column.
;; ! ("Merge Demes tests")

!(assertEqual
   (mergeDemes ((mkDeme (mkRep 
                        (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 3) (ConsMap ((mkNodeId (2)) 2) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (4)) 0) NilMap))))) 
                                    (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) 
                                             (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) 
                                             (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) 
                                             (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) NilMMap)))))) 
                        (mkTree (mkNode AND) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) ())))))) 
                                                   (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 (cons 1 ()))))) (mkCscore 0 2 1.0 0.0 -1.0))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) (mkCscore -4 0 0.0 0.0 -4.0))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 2 ()))))) (mkCscore -3 1 0.5 0.0 -3.5))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 1 ()))))) (mkCscore -1 1 0.5 0.0 -1.5))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) (mkCscore -4 0 0.0 0.0 -4.0))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 1 ()))))) (mkCscore -1 1 0.5 0.0 -1.5))) ()))))))) (mkDemeId "1.1")) 
               (mkDeme (mkRep 
                           (mkKbMap (mkDscKbMp (ConsMap ((mkNodeId (1)) 3) (ConsMap ((mkNodeId (2)) 2) (ConsMap ((mkNodeId (3)) 1) (ConsMap ((mkNodeId (4)) 0) NilMap))))) 
                              (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) 
                                       (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) 
                                       (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) 
                                       (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) NilMMap)))))) 

                           (mkTree (mkNode AND) (cons (mkNullVex (cons (mkTree (mkNode A) ()) ())) 
                                                (cons (mkNullVex (cons (mkTree (mkNode B) ()) ())) 
                                                (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) 
                                                (cons (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) ())))))) 
                                                (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 1 ()))))) (mkCscore -1 1 0.5 0.0 -1.5))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 1 ()))))) (mkCscore -1 1 0.5 0.0 -1.5))) 
                                                   (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) (mkCscore -4 0 0.0 0.0 -4.0))) 
                                                   (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 1 ()))))) (mkCscore -1 1 0.5 0.0 -1.5))) 
                                                   (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 2 ()))))) (mkCscore -3 1 0.5 0.0 -3.5))) 
                                                   (cons (mkSInst (mkPair (mkInst (cons 0 (cons 2 (cons 0 (cons 1 ()))))) (mkCscore -1 3 1.5 0.0 -2.5))) 
                                                   (cons (mkSInst (mkPair (mkInst (cons 2 (cons 0 (cons 0 (cons 1 ()))))) (mkCscore -2 3 1.5 0.0 -3.5))) ())))))))) (mkDemeId "1.0"))) 
                                                   5 2 0 1 (ttable2) (metaPop) 3 0.004 1000)

               (ConsOS (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) 
                                    (cons (mkTree (mkNode A) ()) ())) 
                                    (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) 
                                    (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) 
                                    (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) 
                                    (cons (mkTree (mkNode D) ()) ())) ())))) ()))) 
                                    (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (cons 0 (cons 0 ())))) 
               (ConsOS (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) 
                                    (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) 
                                    (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) 
                                    (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) 
                                    (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ())))) NilOS))
)
(= (testStrategyDeme)
   (mkDeme 
     (mkRep 
       (mkKbMap 
         (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap)))
         (mkDscMp 
           (ConsMMap ((mkDiscSpec 2) 
             (mkSSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ()))) 
           (ConsMMap ((mkDiscSpec 2) 
             (mkSSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ()))) 
           NilMMap))))
       (mkTree (mkNode PRIORITIZED-OR) 
         (cons (mkTree (mkNode playwin) ()) 
               (cons (mkTree (mkNode playblock) ()) ()))))
     (mkSInstSet 
       (cons (mkSInst (mkPair (mkInst (cons 1 (cons 1 ()))) (mkCscore 5.0 2 0.571 0.0 4.429))) ()))
     (mkDemeId "1")))

(= (testStrategyDeme2)
   (mkDeme 
     (mkRep 
       (mkKbMap 
         (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap)))
         (mkDscMp 
           (ConsMMap ((mkDiscSpec 2) 
             (mkSSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ()))) 
           (ConsMMap ((mkDiscSpec 2) 
             (mkSSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ()))) 
           NilMMap))))
       (mkTree (mkNode PRIORITIZED-OR) 
         (cons (mkTree (mkNode playcenter) ()) 
               (cons (mkTree (mkNode playside) ()) ()))))
     (mkSInstSet 
       (cons (mkSInst (mkPair (mkInst (cons 1 (cons 1 ()))) (mkCscore 6.0 2 0.571 0.0 5.429))) ()))
     (mkDemeId "2")))
!(assertEqual (demeToTrees (testStrategyDeme) (1 random-player)) 
              (cons (mkExemplar (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playwin) ()) (cons (mkTree (mkNode playblock) ()) ()))) (mkDemeId "1") (mkCscore 5.0 2 0.571 0.0 4.429) (mkBScore (cons -1.0 ()))) ()))

!(assertEqual (mergeDemes ((testStrategyDeme) (testStrategyDeme2)) 5 2 0 1 
                  (1 random-player) NilOS 3 0.004 1000) 
                  (ConsOS (mkExemplar (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playcenter) ()) (cons (mkTree (mkNode playside) ()) ()))) (mkDemeId "2") (mkCscore 6.0 2 0.571 0.0 5.429) (mkBScore (cons -1.0 ()))) NilOS))
