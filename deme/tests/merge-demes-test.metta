!(import! &self ../../utilities/general-helpers)
!(import! &self ../../parameters/registry)
!(import! &self ../../parameters/defaults)
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

!(import! &self ../../scoring/action-registry)
!(import! &self ../../scoring/action-eval)
!(import! &self ../../scoring/action-ops)
!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/lsk)
!(import! &self ../../representation/logical-probe) 
!(import! &self ../../representation/logical-canonize)
!(import! &self ../../representation/sample-logical-perms) 
!(import! &self ../../representation/add-logical-knobs)
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/build-knobs)
!(import! &self ../../representation/candidate)
!(import! &self ../../representation/representation)


!(import! &self ../../moses/neighborhood-sampling)

!(import! &self ../../examples/tic-tac-toe/tic-tac-toe-helpers)
!(import! &self ../../examples/tic-tac-toe/random-player)
!(import! &self ../../examples/tic-tac-toe/minimax-player)
!(import! &self ../../examples/tic-tac-toe/moves)
!(import! &self ../../examples/tic-tac-toe/ttt-action-world)
!(import! &self ../../examples/tic-tac-toe/ttt-action-primitives)
!(import! &self ../../examples/tic-tac-toe/ttt-action-episode)
!(import! &self ../../examples/tic-tac-toe/ttt-action-registration)

!(import! &self ../../scoring/fitness)
!(import! &self ../../scoring/boolean-ops)
!(import! &self ../../scoring/bscore)
!(import! &self ../../scoring/cscore)
!(import! &self ../../scoring/action-score)
!(import! &self ../../scoring/complexity-based-scorer)
!(import! &self ../../scoring/cacheSpace)

!(import! &self ../../metapopulation/exemplar-type)
!(import! &self ../../metapopulation/diversity)
!(import! &self ../../metapopulation/metapopulation)
!(import! &self ../../optimization/hillclimbing/hill-climbing-helpers)

!(import! &self ../../representation/instance)  

!(import! &self ../deme-id-creation)
!(import! &self ../create-deme)
!(import! &self ../score-deme)
!(import! &self ../merge-demes)
!(import! &self ../../moses/demo-problems)

(= (tree1)
        (mkTree (mkNode AND)
          (cons (mkKnob (mkTree (mkNode A) ()) (lsk3) 2)
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ())
                  (cons (mkKnob (mkNullVex
                          (cons (mkTree (mkNode D) ()) ())) (lsk1) 0) ()))))
          (cons (mkKnob (mkNullVex
                  (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())) ())) (lsk2) 1) ())))))

(= (lsk1)
        (mkLSK
            (mkDiscKnob
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              ())
            ))

(= (lsk2)
        (mkLSK
            (mkDiscKnob
              (mkMultip 3)
              (mkDiscSpec 0)
              (mkDiscSpec 0)
              ())
            ))

(= (lsk3)
        (mkLSK
            (mkDiscKnob
              (mkMultip 3)
              (mkDiscSpec 1)
              (mkDiscSpec 1)
              ())
            ))

(= (knobMapObj) (mkKbMap (mkDscMp (((mkDiscSpec 1) (lsk1)) ((mkDiscSpec 0) (lsk2)) ((mkDiscSpec 1) (lsk3))))))

(= (sInstSet) (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 ())))) (mkCscore -0.1 2 0.2 0.3 -0.6)))
           (cons (mkSInst (mkPair (mkInst (cons 0 (cons 2 (cons 0 ())))) (mkCscore -0.2 1 0.1 0.1 -0.4)))
                 (cons  (mkSInst (mkPair (mkInst (cons 0 (cons 2 (cons 2 ())))) (mkCscore 0 2 1.0 0 -1.0))) ())))))

;; Raw-best tracking is independent of penalized ordering.  Lower complexity
;; breaks a raw-score tie and an exact raw/complexity tie keeps the first row.
(= (rawBestInstances)
   (mkSInstSet
     ((mkSInst (mkPair (mkInst (1)) (mkCscore -3 4 0 0 -1)))
      (mkSInst (mkPair (mkInst (2)) (mkCscore -3 2 0 0 -20)))
      (mkSInst (mkPair (mkInst (3)) (mkCscore -3 2 0 0 0)))
      (mkSInst (mkPair (mkInst (4)) (mkCscore -4 0 0 0 0))))))

!(assertEqual
  (bestRawScoredInstance (rawBestInstances))
  (mkSInst (mkPair (mkInst (2)) (mkCscore -3 2 0 0 -20))))

!(assertEqual (bestRawScoredInstance (mkSInstSet ())) ())

;; Dominance retention is shared by Boolean and action problems.  Every
;; problem keeps the dominated C stepping stone by default; the opt-in policy
;; applies the same dominance filter independently of scoring context.
(= (dominanceCandidates)
   ((mkExemplar (mkTree (mkNode A) ()) (mkDemeId "candidate-a")
      (mkCscore -1 1 1 0 -2) (mkBScore (2 1)))
    (mkExemplar (mkTree (mkNode B) ()) (mkDemeId "candidate-b")
      (mkCscore -1 1 1 0 -2) (mkBScore (1 2)))
    (mkExemplar (mkTree (mkNode C) ()) (mkDemeId "candidate-c")
      (mkCscore -2 1 1 0 -3) (mkBScore (1 0)))))

!(assertEqual
  (let* (
         ($_ (set-param discardDominated False))
         ($kept (List.length
                  (candidatesAfterDominance (dominanceCandidates))))
         ($_ (set-param discardDominated True))
         ($filtered (List.length
                      (candidatesAfterDominance (dominanceCandidates))))
         ($_ (set-param discardDominated False))
        )
    ($kept $filtered))
  (3 2))

(= (ttable1) (mkITable (cons (cons True (cons True ()))
                       (cons (cons False (cons True ()))
                       (cons (cons True (cons True ())) ())))
                        (cons A (cons B (cons O ())))))
(= (ttable2) (mkITable
                    (cons (cons True (cons True (cons False (cons False ()))))
                    (cons (cons True (cons False (cons True (cons False ()))))
                    (cons (cons True (cons False (cons False (cons False ()))))
                    (cons (cons True (cons False (cons False (cons False ()))))
                    (cons (cons True (cons False (cons False (cons False ())))) ())))))
                    (cons A (cons B (cons C (cons D (cons output ())))))))

(= (metaPop) (cons (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (cons 0 (cons 0 ()))))
                 (cons (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ()))))
                 ())))
(= (rep) (mkRep (mkKbMap 
                  (mkDscMp (((mkDiscSpec 1) (lsk1)) ((mkDiscSpec 0) (lsk2)) ((mkDiscSpec 1) (lsk3)))))
                  (mkTree (mkNode AND)
                      (cons (mkKnob (mkTree (mkNode A) ()) (lsk3) 2)
                      (cons (mkTree (mkNode OR)
                              (cons (mkTree (mkNode B) ())
                              (cons (mkTree (mkNode C) ())
                              (cons (mkKnob (mkNullVex
                                      (cons (mkTree (mkNode D) ()) ())) (lsk1) 0) ()))))
                      (cons (mkKnob (mkNullVex
                              (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())) ())) (lsk2) 1) ()))))))
;; Testcase-1 for the removeDupInsts
!(assertEqual
   (removeDupInsts
      (rep)
      (mkDemeId "1")
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
       (mkDemeId "1")
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
       (mkDemeId "1")
       (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
       (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
       (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8)))
       (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8))) ()))))

       3)

       (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
       (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8))) ())))
 ;
 ;; Testcase-1 for keepTopUnique  (was: nEval=5, maxCandPerDeme=2)
 !(set-param nEval 5)
 !(set-param maxCandPerDeme 2)
 !(assertEqual
    (keepTopUniqueCandidates
       (rep)
       (mkDemeId "1")
       (mkSInstSet
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8)))  ())))))
    (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
    (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8))) ())))

 ;; Testcase-2 for keepTopUnique  (was: nEval=2, maxCandPerDeme=5)
 !(set-param nEval 2)
 !(set-param maxCandPerDeme 5)
 !(assertEqual
    (keepTopUniqueCandidates
       (rep)
       (mkDemeId "1")
       (mkSInstSet
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8)))  ())))))
    (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
    (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8))) ())))
 ;
 ;; Testcase-3 for keepTopUnique  (was: nEval=5, maxCandPerDeme=3)
 !(set-param nEval 5)
 !(set-param maxCandPerDeme 3)
 !(assertEqual
    (keepTopUniqueCandidates
       (rep)
       (mkDemeId "1")
       (mkSInstSet
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
          (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8)))
          (cons (mkSInst (mkPair (mkInst (cons 1 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8))) ()))))))
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
 ;; Testcase-1 for trimDownDeme  (was: minPoolSize=2, complexityTemperature=0.1)
 !(set-param minPoolSize 2)
 !(set-param complexityTemperature 0.1)
 !(assertEqual
   (trimDownDeme
       (cons
          (mkSInst (mkPair (mkInst (cons 1 (cons 2 ()))) (mkCscore 0 1 0 0 -0.1)))
          (cons
             (mkSInst (mkPair (mkInst (cons 3 (cons 4 ()))) (mkCscore 0 2 0 0 -0.3)))
             (cons
                (mkSInst (mkPair (mkInst (cons 5 (cons 6 ()))) (mkCscore 0 3 0 0 -0.5)))
                ()))))
                ;
   (cons (mkSInst (mkPair (mkInst (cons 1 (cons 2 ()))) (mkCscore 0 1 0 0 -0.1))) ()))
 ;
 ;; Testcase-2 for trimDownDeme  (was: minPoolSize=0, complexityTemperature=1)
 !(set-param minPoolSize 0)
 !(set-param complexityTemperature 1)
 !(assertEqual
   (trimDownDeme
     (cons (mkSInst (mkPair (mkInst (cons 1 (cons 2 (cons 0 ())))) (mkCscore -0.2 1 0.1 0.1 -0.4))) (cons (mkSInst (mkPair (mkInst (cons 1 (cons 0 (cons 0 ())))) (mkCscore -0.1 2 0.2 0.3 -0.6))) ())))
   (cons (mkSInst (mkPair (mkInst (cons 1 (cons 2 (cons 0 ())))) (mkCscore -0.2 1 0.1 0.1 -0.4))) (cons (mkSInst (mkPair (mkInst (cons 1 (cons 0 (cons 0 ())))) (mkCscore -0.1 2 0.2 0.3 -0.6))) ())))
 ;
 ;; Testcase-3 for trimDownDeme  (was: minPoolSize=2, complexityTemperature=0.1)
 !(set-param minPoolSize 2)
 !(set-param complexityTemperature 0.1)
 !(assertEqual
    (trimDownDeme
       (cons
          (mkSInst (mkPair (mkInst (cons 7 (cons 8 ()))) (mkCscore -0.1 1 0.2 0.0 -0.15)))
          (cons
             (mkSInst (mkPair (mkInst (cons 9 (cons 10 ()))) (mkCscore -0.2 2 0.15 0.1 -0.35)))
             (cons
                (mkSInst (mkPair (mkInst (cons 11 (cons 12 ()))) (mkCscore -0.3 3 0.1 0.2 -0.55)))
                ()))))
    (cons (mkSInst (mkPair (mkInst (cons 7 (cons 8 ()))) (mkCscore -0.1 1 0.2 0.0 -0.15))) ()))

;;  Testcase-1 for demeToTrees
;;  NOTE: All the instances in the deme don't include lsk1 (or they all start with '0') because we are testing it using ttable2. 
;;        ttable2 is a truth table which doesn't have a 'D' column.
;;  Instance (0 1 2) reduces to a contradiction, so its tree is the constant FALSE.
!(assertEqual
  (demeToTrees (mkRep (mkKbMap
                                  (mkDscKbMp (cons ((mkNodeId (2 3)) 0) (cons ((mkNodeId (3)) 1) (cons ((mkNodeId (1)) 2) ())))) 
                                  (mkDscMp (cons ((mkDiscSpec 1) (lsk1)) (cons ((mkDiscSpec 0) (lsk2)) (cons ((mkDiscSpec 1) (lsk3)) ()))))) 
                              (mkTree (mkNode AND) (cons (mkKnob (mkTree (mkNode A) ()) (lsk3) 2)
                                                      (cons (mkTree (mkNode OR) 
                                                          (cons (mkTree (mkNode B) ()) 
                                                          (cons (mkTree (mkNode C) ()) 
                                                      (cons (mkKnob (mkNullVex (cons (mkTree (mkNode D) ()) ())) (lsk1) 0) ()))))
                                                      (cons (mkKnob (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())) ())) (lsk2) 1) ())))))
                (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 ())))) (mkCscore -1 2 1 0 1)))
                                      (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 (cons 2 ())))) (mkCscore 0 2 0.5 0 0.8))) ())))
                (mkDemeId "1")
                (ttable2))

  (cons (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ()) ()))) ()))) (mkDemeId "1") (mkCscore -1 2 1 0 1) (mkBScore (cons 0 (cons 0 (cons 0 (cons 0 ())))))) (cons (mkExemplar (mkTree (mkNode FALSE) ()) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8) (mkBScore (cons -1 (cons 0 (cons 0 (cons 0 ())))))) ())))

;; Testcase-2 for demeToTrees
!(assertEqual
      (demeToTrees (mkRep (mkKbMap (mkDscKbMp (cons ((mkNodeId (2 3)) 0) (cons ((mkNodeId (3)) 1) (cons ((mkNodeId (1)) 2) ())))) (mkDscMp (cons ((mkDiscSpec 1) (lsk1)) (cons ((mkDiscSpec 0) (lsk2)) (cons ((mkDiscSpec 1) (lsk3)) ())))))
                  (mkTree (mkNode AND) (cons (mkKnob (mkTree (mkNode A) ()) (lsk3) 2) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ())
                          (cons (mkKnob (mkNullVex (cons (mkTree (mkNode D) ()) ())) (lsk1) 0) ())))) ()))))
                   (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 2 (cons 2 ())))) (mkCscore -1 2 1 0 1)))
                  (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 ())))) (mkCscore 0 2 0.5 0 0.8))) ())))
                  (mkDemeId "1")
                  (ttable2))

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
     (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode D) ()) ())) ())) ())))) ())) (mkDemeId "1") (mkCscore 0 2 0.5 0 0.8) (mkBScore (cons 2 (cons 2 (cons 4 ()))))) ()))
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
      (cons (mkExemplar (mkTree (mkNode A) ()) (mkDemeId "1") (mkCscore -0.1 2 0.1 0.1 -0.3) (mkBScore (cons 0 (cons 0 ())))) (cons (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (cons 0 (cons 0 ())))) (cons (mkExemplar (mkTree (mkNode B) ()) (mkDemeId "1") (mkCscore -0.2 3 0.1 0.1 -0.4) (mkBScore (cons 0 (cons 0 ())))) (cons (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ())))) ())))))
; 
;; Testcase for mergeDemes
;; NOTE: All the instances in the deme don't include lsk1 (or they all start with '0') because we are testing it using ttable2.
;;       ttable2 is a truth table which doesn't have a 'D' column.
;; ! ("Merge Demes tests")

(= (getCandUniPen (mkExemplar $tree $demeId $cscore $bscore)) (getUniPen $cscore))
(= (getCandPenScore (mkExemplar $tree $demeId $cscore $bscore)) (getPenScore $cscore))
(= (getCandidateHelper $inst (mkNullVex (cons $child $rest))) (getCandidateHelper $inst $child))

;; The original test passed: 5 2 0 1 (ttable2) (metaPop) 3 0.004 1000.
!(set-param nEval 5)
!(set-param maxCandPerDeme 2)
!(set-param minPoolSize 0)
!(set-param complexityTemperature 1)
!(set-param nToKeep 3)
!(set-param capCoef 0.004)
!(set-param genCount 1000)

!(bind! &deme3 (new-space))
!(bind! &deme4 (new-space))
!(let $deme3Rep (mkRep
                        (mkKbMap (mkDscKbMp (cons ((mkNodeId (1)) 3) (cons ((mkNodeId (2)) 2) (cons ((mkNodeId (3)) 1) (cons ((mkNodeId (4)) 0) ()))))) 
                                    (mkDscMp (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) 
                                             (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) 
                                             (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) 
                                             (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ())))))) 
                        (mkTree (mkNode AND)
                          (cons (mkKnob (mkNullVex (cons (mkTree (mkNode A) ()) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 3)
                          (cons (mkKnob (mkNullVex (cons (mkTree (mkNode B) ()) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 2)
                          (cons (mkKnob (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 1)
                          (cons (mkKnob (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 0) ()))))))
   (add-atom &deme3 $deme3Rep))
!(let $deme3Instances (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 1 (cons 1 ()))))) (mkCscore 0 2 1.0 0.0 -1.0))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) (mkCscore -4 0 0.0 0.0 -4.0))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 2 ()))))) (mkCscore -3 1 0.5 0.0 -3.5))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 1 ()))))) (mkCscore -1 1 0.5 0.0 -1.5))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) (mkCscore -4 0 0.0 0.0 -4.0))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 1 ()))))) (mkCscore -1 1 0.5 0.0 -1.5))) ())))))))
   (add-atom &deme3 $deme3Instances))
!(add-atom &deme3 (mkDemeId "1.1"))
!(let $deme4Rep (mkRep
                           (mkKbMap (mkDscKbMp (cons ((mkNodeId (1)) 3) (cons ((mkNodeId (2)) 2) (cons ((mkNodeId (3)) 1) (cons ((mkNodeId (4)) 0) ()))))) 
                              (mkDscMp (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) 
                                       (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) 
                                       (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) 
                                       (cons ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))) ())))))) 

                           (mkTree (mkNode AND)
                             (cons (mkKnob (mkNullVex (cons (mkTree (mkNode A) ()) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 3)
                             (cons (mkKnob (mkNullVex (cons (mkTree (mkNode B) ()) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 2)
                             (cons (mkKnob (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 1)
                             (cons (mkKnob (mkNullVex (cons (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode B) ()) ()))) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 0) ()))))))
   (add-atom &deme4 $deme4Rep))
!(let $deme4Instances (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 1 ()))))) (mkCscore -1 1 0.5 0.0 -1.5))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 1 ()))))) (mkCscore -1 1 0.5 0.0 -1.5)))
                                                   (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 0 ()))))) (mkCscore -4 0 0.0 0.0 -4.0))) 
                                                   (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 1 ()))))) (mkCscore -1 1 0.5 0.0 -1.5))) 
                                                   (cons (mkSInst (mkPair (mkInst (cons 0 (cons 0 (cons 0 (cons 2 ()))))) (mkCscore -3 1 0.5 0.0 -3.5))) 
                                                   (cons (mkSInst (mkPair (mkInst (cons 0 (cons 2 (cons 0 (cons 1 ()))))) (mkCscore -1 3 1.5 0.0 -2.5))) 
                                                   (cons (mkSInst (mkPair (mkInst (cons 2 (cons 0 (cons 0 (cons 1 ()))))) (mkCscore -2 3 1.5 0.0 -3.5))) ()))))))))
   (add-atom &deme4 $deme4Instances))
!(add-atom &deme4 (mkDemeId "1.0"))
!(assertEqual
   (mergeDemes (&deme3 &deme4) (ttable2) (metaPop))

               (cons (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) 
                                    (cons (mkTree (mkNode A) ()) ())) 
                                    (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) 
                                    (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) 
                                    (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) 
                                    (cons (mkTree (mkNode D) ()) ())) ())))) ()))) 
                                    (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (cons 0 (cons 0 ())))) 
               (cons (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) 
                                    (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) 
                                    (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) 
                                    (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) 
                                     (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ())))) ()))
)
;; Action-deme variants of the two strategy demes: plain knob-FREE action
;; trees under an empty action knob map (mkDscMp ()), so getCandidate returns
;; the base tree for any instance. cscores are carried over verbatim from the
;; old testStrategyDeme/testStrategyDeme2. Under (mkActionCtx 1) the bscore is
;; RECOMPUTED via tttActionFitness (ordinal 0 -> minimax): both trees make no
;; useful opening -- (or_seq tttWin tttBlock) forfeits at once on the empty
;; board -- so each recomputes to a flat (mkBScore (-1.0)).
!(bind! &deme1 (new-space))
!(bind! &deme2 (new-space))

!(let $deme1Rep
  (mkRep
    (mkKbMap (mkDscMp ()))
    (mkTree (mkNode or_seq)
      (cons (mkTree (mkNode tttWin) ())
            (cons (mkTree (mkNode tttBlock) ()) ()))))
  (add-atom &deme1 $deme1Rep))
!(let $deme1Instances
  (mkSInstSet
    (cons (mkSInst (mkPair (mkInst (cons 1 (cons 1 ()))) (mkCscore 5.0 2 0.571 0.0 4.429))) ()))
  (add-atom &deme1 $deme1Instances))
!(add-atom &deme1 (mkDemeId "1"))

!(let $deme2Rep
  (mkRep
    (mkKbMap (mkDscMp ()))
    (mkTree (mkNode or_seq)
      (cons (mkTree (mkNode tttCenter) ())
            (cons (mkTree (mkNode tttSide) ()) ()))))
  (add-atom &deme2 $deme2Rep))
!(let $deme2Instances
  (mkSInstSet
    (cons (mkSInst (mkPair (mkInst (cons 1 (cons 1 ()))) (mkCscore 6.0 2 0.571 0.0 5.429))) ()))
  (add-atom &deme2 $deme2Instances))
!(add-atom &deme2 (mkDemeId "2"))

;; Bind the ttt experiment template so the action arm recomputes bscores.
!(set-param fitness tttActionFitness)
!(set-param bestScore tttActionBestScore)
!(set-param actions (quote (tttWin tttBlock tttCenter tttCorner tttSide)))
!(set-param perceptions (quote (tttCanWin tttCanBlock tttCenterFree)))

!(assertEqual
  (demeToTrees
    (match &deme1 (mkRep $kbMap $tree) (mkRep $kbMap $tree))
    (match &deme1 (mkSInstSet $instances) (mkSInstSet $instances))
    (match &deme1 (mkDemeId $id) (mkDemeId $id))
    (mkActionCtx 1))
  (cons (mkExemplar (mkTree (mkNode or_seq) (cons (mkTree (mkNode tttWin) ()) (cons (mkTree (mkNode tttBlock) ()) ()))) (mkDemeId "1") (mkCscore 5.0 2 0.571 0.0 4.429) (mkBScore (cons -1.0 ()))) ()))

;; mergeDemes (strategy variant): original positional args
;;   5 2 0 1   1 ()   3 0.004 1000
;; map to: nEval, maxCandPerDeme, minPoolSize, complexityTemperature,
;;         scoringContext=1, metapop=(), nToKeep, capCoef, genCount.
!(set-param nEval 5)
!(set-param maxCandPerDeme 2)
!(set-param minPoolSize 0)
!(set-param complexityTemperature 1)
!(set-param nToKeep 3)
!(set-param capCoef 0.004)
!(set-param genCount 1000)
!(assertEqual (mergeDemes (&deme1 &deme2) (mkActionCtx 1) ())
                  (cons (mkExemplar (mkTree (mkNode or_seq) (cons (mkTree (mkNode tttCenter) ()) (cons (mkTree (mkNode tttSide) ()) ()))) (mkDemeId "2") (mkCscore 6.0 2 0.571 0.0 5.429) (mkBScore (cons -1.0 ()))) ()))

;; ============================================================
;; mergeDemes with Diversity: Boolean Context (2 Demes)
;; Verifies setDiversity calculation over merged metapopulation:
;; anchor receives 0.0 uniformity penalty; clone receives 0.5.
;; ============================================================
!(set-param minPoolSize 2)
!(set-param complexityTemperature 2)
!(set-param diversityPressure 0.5)

!(assertEqual
   (let* (
          ($merged (mergeDemes (&deme3 &deme4) (ttable1) (metaPop)))
          ($anchor (OS.getByIdx 0 $merged))
          ($clone  (OS.getByIdx 1 $merged))
         )
     (
       (OS.length $merged)                        ;; minPoolSize 2 retains both candidates
       (getCandUniPen $anchor)                    ;; anchor gets zero diversity penalty
       (getCandUniPen $clone)                     ;; identical bscore clone penalized by pressure (0.5)
       (isApproxEq (getCandPenScore $clone) -0.8) ;; penalized score discounted by uniformity penalty (-0.3 - 0.5 = -0.8)
     ))
   (2 0.0 0.5 True))

;; ============================================================
;; mergeDemes with Diversity: Action Context
;; Verifies diversity penalty on action trees under mkActionCtx.
;; Anchor receives 0.0 penalty; clone receives 0.5 penalty.
;; ============================================================
!(set-param complexityTemperature 1)

!(assertEqual
   (let* (
          ($merged (mergeDemes (&deme1 &deme2) (mkActionCtx 1) ()))
          ($anchor (OS.getByIdx 0 $merged))
          ($clone  (OS.getByIdx 1 $merged))
         )
     (
       (OS.length $merged)                        ;; minPoolSize 2 keeps both action trees in pool
       (getCandUniPen $anchor)                    ;; anchor gets zero diversity penalty
       (getCandUniPen $clone)                     ;; behavioral clone receives diversity penalty (0.5)
       (isApproxEq (getCandPenScore $clone) 3.929) ;; penalized score discounted (4.429 - 0.5 = 3.929)
     ))
   (2 0.0 0.5 True))

;; ============================================================
;; mergeDemes with Diversity: Autoscale via Problem Context
;; Verifies autoscale updates diversityPressure from score range
;; (parity3: best 0.0, worst -8.0 -> range 8.0, 0.3 * 8.0 = 2.4).
;; ============================================================
!(set-param problem parity3)
!(set-param diversityAutoscale True)
!(set-param diversityPressure 0.3)
!(set-param complexityTemperature 10)

;; Trigger problemContext to autoscale diversity pressure against parity3 range
!(let ($_1 $_2 $_3) (problemContext)
   (assertEqual (param diversityPressure) 2.4))  ;; rescaled: 0.3 * (0.0 - (-8.0)) = 2.4

!(assertEqual
   (let* (
          ($merged (mergeDemes (&deme3 &deme4) (ttable1) (metaPop)))
          ($anchor (OS.getByIdx 0 $merged))
          ($promoted (OS.getByIdx 1 $merged))
          ($demotedClone (OS.getByIdx 2 $merged))
         )
     (
       (OS.length $merged)                               ;; retains candidates within score window
       (getCandUniPen $anchor)                           ;; anchor receives zero diversity penalty
       (getCandUniPen $promoted)                         ;; intermediate candidate receives distance-scaled penalty (1.2)
       (isApproxEq (getCandPenScore $promoted) -2.2)     ;; promoted candidate receives discounted score (-1.0 - 1.2 = -2.2)
       (getCandUniPen $demotedClone)                     ;; identical bscore clone receives full autoscaled penalty (2.4)
       (isApproxEq (getCandPenScore $demotedClone) -2.7) ;; clone demoted with discounted score (-0.3 - 2.4 = -2.7)
     ))
   (3 0.0 1.2 True 2.4 True))
