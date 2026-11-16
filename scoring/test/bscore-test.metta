!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/map)
!(import! &self ../../utilities/tree)

!(import! &self ../cacheSpace)
!(import! &self ../fitness)
!(import! &self ../boolean-ops)
!(import! &self ../bscore)
!(import! &self ../precision-bscore)


;; Test Types and type constructors    ;;; Fix: type system not working in peTTa 
;; !(assertEqual
;;     (let $a (mkBScore (cons 1 (cons 0 (cons 2 ())))) (get-type $a)) 
;;     BehavioralScore
;;  )
; !(assertEqual
;    (let $a (mkITable (cons (cons 1 (cons 0 (cons 2 ()))) ()) (cons A (cons B (cons C ())))) (get-type $a))
;    (ITable Number))
; !(assertEqual
;    (let $a (mkTruthTableBScore 1 0.2 (mkITable (cons (cons 1 (cons 0 (cons 2 ()))) ()) (cons A (cons B (cons C ()))))) (get-type $a))
;    (TruthTableBScore Number))
; !(assertEqual
;    (let $a (createTruthTableBScore 0.2 (mkITable (cons (cons 1 (cons 0 (cons 2 ()))) ()) (cons A (cons B (cons C ()))))) (get-type $a))
;    (TruthTableBScore Number))

!(assertEqual
   (createTruthTableBScore 0.2 (mkITable (cons (cons 1 ())
                                         (cons (cons 0 ())
                                         (cons (cons 2 ()) ()))) (cons A (cons B (cons C ())))))
   (mkTruthTableBScore 0.2 1 (mkITable (cons (cons 1 ())
                                       (cons (cons 0 ())
                                       (cons (cons 2 ()) ()))) (cons A (cons B (cons C ()))))))

;; Test Score Tree Helper Function test to replace all occurences of a given variable with a truth value
;; Boolean expressions ride under quote/let: this file loads boolean-ops'
;; AND/OR/NOT eval clauses, so a bare tuple at a call site would compile
;; as a call instead of data.
!(let* (($in (quote (AND A B (OR A B (NOT A))))) ($exp (quote (AND True B (OR True B (NOT True))))))
   (assertEqual (replaceVarWithTruth (True A) $in) $exp))
!(let* (($in (quote (AND A B (OR A B (NOT A))))) ($exp (quote (AND A False (OR A False (NOT A))))))
   (assertEqual (replaceVarWithTruth (False B) $in) $exp))

;; Test Score Tree Helper function to replace all occurences of all variables with their corresponding truth values
!(let* (($in (quote (AND A B (OR A B (NOT A))))) ($exp (quote (AND True False (OR True False (NOT True))))))
   (assertEqual (replaceVarsWithTruth ((cons A (cons B ())) $in) (cons True (cons False ()))) $exp))
!(let* (($in (quote (AND A B (OR A B (NOT A))))) ($exp (quote (AND False True (OR False True (NOT False))))))
   (assertEqual (replaceVarsWithTruth ((cons A (cons B ())) $in) (cons False (cons True ()))) $exp))

;; Test Score Tree function, given a boolean expression and tree should return a behavioral score
!(let $cand (quote (OR A B))
   (assertEqual
     (scoreTree (mkITable (cons (cons True (cons True ()))
                          (cons (cons False (cons True ()))
                          (cons (cons False (cons True ())) ())))
                          (cons A (cons B (cons O ()))))
                (buildTree $cand) &bscoreCache)
     (mkBScore (cons -1 (cons 0 ())))))

!(let $cand (quote (AND A B))
   (assertEqual
     (scoreTree (mkITable (cons (cons True (cons True ()))
                          (cons (cons False (cons True ()))
                          (cons (cons False (cons True ())) ())))
                                     (cons A (cons B (cons O ()))))
                (buildTree $cand) &bscoreCache)
     (mkBScore (cons 0 (cons 0 ())))))

;; Test sumBScore
!(assertEqual (sumBScore (mkBScore (cons 1 (cons 2 (cons 0 (cons 1 ())))))) 4)

;; Test Truth table bscore helper functions
!(assertEqual 
   (bestPossibleScore 
          (mkTruthTableBScore 0.2 1 (mkITable (cons (cons 1 ())
                                              (cons (cons 0 ())
                                              (cons (cons 2 ()) ()))) (cons A (cons B (cons C ()))))))
   (mkBScore (cons 0 ())))
!(assertEqual 
   (worstPossibleScore (mkTruthTableBScore 0.2 1 (mkITable (cons (cons 1 ())
                                                           (cons (cons 0 ())
                                                           (cons (cons 2 ()) ()))) (cons A (cons B (cons C ()))))))
   (mkBScore (cons -1 ())))
!(assertEqual 
   (minImprove (mkTruthTableBScore 0.2 1 (mkITable (cons (cons 1 ())
                                                   (cons (cons 0 ())
                                                   (cons (cons 2 ()) ()))) (cons A (cons B (cons C ()))))))
   0.5
 )

;; Test Behavioral composite score helper functions
!(assertEqual
   (bestPossibleScore (mkBCScore (mkTruthTableBScore 0.2 2 (mkITable (cons (cons 1 (cons 0 ()))
                                                                     (cons (cons 0 (cons 0 ()))
                                                                     (cons (cons 2 (cons 1 ())) ()))) (cons A (cons B (cons C ())))))))
   0
 )
!(assertEqual
   (worstPossibleScore (mkBCScore (mkTruthTableBScore 0.2 2 (mkITable (cons (cons 1 (cons 0 ()))
                                                                      (cons (cons 0 (cons 0 ()))
                                                                      (cons (cons 2 (cons 1 ())) ()))) (cons A (cons B (cons C ())))))))
   -2
 )
!(assertEqual
   (minImprove (mkBCScore (mkTruthTableBScore 0.2 2 (mkITable (cons (cons 1 (cons 0 ()))
                                                              (cons (cons 0 (cons 0 ()))
                                                              (cons (cons 2 (cons 1 ())) ()))) (cons A (cons B (cons C ())))))))
   0.5
 )

;; Test Helper function to compare two elements and return a score
!(assertEqual (compareAndScore A B) -1)
!(assertEqual (compareAndScore A A) 0)

;; Test Helper function compareAndScoreCTable
!(assertEqual (compareAndScoreCTable True ((True True) (1 0))) 0)
!(assertEqual (compareAndScoreCTable False ((True True) (1 0))) -1)
!(assertEqual (compareAndScoreCTable True ((True False) (0 1))) -1)
!(assertEqual (compareAndScoreCTable False ((True False) (0 1))) 0)
!(assertEqual (compareAndScoreCTable True ((True) (0.5 1.5))) -1.5)
!(assertEqual (compareAndScoreCTable False ((True) (0.5 1.5))) -0.5)

;; ====================================================================
;; Compressed Table Test: scoreTree with (mkCTable ...)
;; ====================================================================

;; Test unweighted cTable scoreTree on AND tree:
;; Table has 4 patterns: (True True)->pos:1, (True False)->neg:1, (False True)->neg:1, (False False)->neg:1
;; Candidate (AND A B) predicts True on (True True) [penalty 0], False on rest [penalty 0 each]
!(let* (
        ($_ (resetSubtreeCache))
        ($ct (mkCTable (cons ((True True) (1 0))
                       (cons ((True False) (0 1))
                       (cons ((False True) (0 1))
                       (cons ((False False) (0 1)) ()))))
                       (cons A (cons B (cons Output ()))) 4))
        ($tree (buildTree (quote (AND A B))))
       )
   (assertEqual (scoreTree $ct $tree &bscoreCache)
                (mkBScore (cons 0 (cons 0 (cons 0 (cons 0 ())))))))

;; Candidate (OR A B) on same table:
;; (True True)->True (neg:0 -> 0), (True False)->True (neg:1 -> -1), (False True)->True (neg:1 -> -1), (False False)->False (pos:0 -> 0)
!(let* (
        ($_ (resetSubtreeCache))
        ($ct (mkCTable (cons ((True True) (1 0))
                       (cons ((True False) (0 1))
                       (cons ((False True) (0 1))
                       (cons ((False False) (0 1)) ()))))
                       (cons A (cons B (cons Output ()))) 4))
        ($tree (buildTree (quote (OR A B))))
       )
   (assertEqual (scoreTree $ct $tree &bscoreCache)
                (mkBScore (cons 0 (cons -1 (cons -1 (cons 0 ())))))))

;; Test weighted cTable scoreTree with fractional weights:
;; Pattern (True) has (pos:0.5, neg:1.5); Pattern (False) has (pos:2.0, neg:2.5)
;; Candidate (mkTree (mkNode A) ()) predicts True on (True) [penalty -1.5], False on (False) [penalty -2.0]
!(let* (
        ($_ (resetSubtreeCache))
        ($ct (mkCTable (cons ((True) (0.5 1.5)) 
                       (cons ((False) (2.0 2.5)) ())) 
                       (cons A (cons Output ())) 6.5))
        ($tree (mkTree (mkNode A) ()))
       )
   (assertEqual (scoreTree $ct $tree &bscoreCache)
                (mkBScore (cons -1.5 (cons -2.0 ())))))

;; ====================================================================
;; Compressed Table (CTable) Evolutionary Scoring Functions
;; (createTruthTableBScore, bestPossibleScore, worstPossibleScore, minImprove)
;; Classic C++ References: moses/scoring/bscores.cc#L350-L425
;; ====================================================================

;; Test createTruthTableBScore with (mkCTable ...)
!(let* (
        ($ct (mkCTable (cons ((True True) (1 0))
                       (cons ((True False) (0 1))
                       (cons ((False True) (0 1))
                       (cons ((False False) (0 1)) ()))))
                       (cons A (cons B (cons Output ()))) 4))
        ($tt (createTruthTableBScore 0.2 $ct))
       )
   (assertEqual $tt (mkTruthTableBScore 0.2 4 $ct)))

;; Test unweighted CTable bestPossibleScore, worstPossibleScore, minImprove:
;; Unweighted table: all patterns have pos=1, neg=0 or pos=0, neg=1.
;; bestPossibleScore: - min(pos, neg) = 0 for all patterns.
;; worstPossibleScore: - abs(pos - neg) = -1 for all patterns.
;; minImprove: 0.5 * min_diff = 0.5 * 1.0 = 0.5.
!(let* (
        ($ct (mkCTable (cons ((True True) (1 0))
                       (cons ((True False) (0 1))
                       (cons ((False True) (0 1))
                       (cons ((False False) (0 1)) ()))))
                       (cons A (cons B (cons Output ()))) 4))
        ($tt (createTruthTableBScore 0.2 $ct))
       )
   (assertEqual (bestPossibleScore $tt)
                (mkBScore (cons 0 (cons 0 (cons 0 (cons 0 ())))))))

!(let* (
        ($ct (mkCTable (cons ((True True) (1 0))
                       (cons ((True False) (0 1))
                       (cons ((False True) (0 1))
                       (cons ((False False) (0 1)) ()))))
                       (cons A (cons B (cons Output ()))) 4))
        ($tt (createTruthTableBScore 0.2 $ct))
       )
   (assertEqual (worstPossibleScore $tt)
                (mkBScore (cons -1 (cons -1 (cons -1 (cons -1 ())))))))

!(let* (
        ($ct (mkCTable (cons ((True True) (1 0))
                       (cons ((True False) (0 1))
                       (cons ((False True) (0 1))
                       (cons ((False False) (0 1)) ()))))
                       (cons A (cons B (cons Output ()))) 4))
        ($tt (createTruthTableBScore 0.2 $ct))
       )
   (assertEqual (minImprove $tt) 0.5))

;; Test weighted/noisy CTable bestPossibleScore, worstPossibleScore, minImprove:
;; Pattern (True) has (pos:0.5, neg:1.5) -> best: -0.5, worst: -1.0, diff: 1.0
;; Pattern (False) has (pos:2.0, neg:2.5) -> best: -2.0, worst: -0.5, diff: 0.5
;; minImprove: 0.5 * min(1.0, 0.5) = 0.5 * 0.5 = 0.25.
!(let* (
        ($ct (mkCTable (cons ((True) (0.5 1.5)) 
                       (cons ((False) (2.0 2.5)) ())) 
                       (cons A (cons Output ())) 6.5))
        ($tt (createTruthTableBScore 0.1 $ct))
       )
   (assertEqual (bestPossibleScore $tt)
                (mkBScore (cons -0.5 (cons -2.0 ())))))

!(let* (
        ($ct (mkCTable (cons ((True) (0.5 1.5)) 
                       (cons ((False) (2.0 2.5)) ())) 
                       (cons A (cons Output ())) 6.5))
        ($tt (createTruthTableBScore 0.1 $ct))
       )
   (assertEqual (worstPossibleScore $tt)
                (mkBScore (cons -1.0 (cons -0.5 ())))))

!(let* (
        ($ct (mkCTable (cons ((True) (0.5 1.5)) 
                       (cons ((False) (2.0 2.5)) ())) 
                       (cons A (cons Output ())) 6.5))
        ($tt (createTruthTableBScore 0.1 $ct))
       )
   (assertEqual (minImprove $tt) 0.25))

;; Test Behavioral composite score (mkBCScore ...) with CTable:
;; bestPossibleScore on mkBCScore: sum(-0.5, -2.0) = -2.5
;; worstPossibleScore on mkBCScore: sum(-1.0, -0.5) = -1.5
;; minImprove on mkBCScore: delegates to TruthTableBScore -> 0.25
!(let* (
        ($ct (mkCTable (cons ((True) (0.5 1.5)) 
                       (cons ((False) (2.0 2.5)) ())) 
                       (cons A (cons Output ())) 6.5))
        ($bc (mkBCScore (createTruthTableBScore 0.1 $ct)))
       )
   (assertEqual (bestPossibleScore $bc) -2.5))

!(let* (
        ($ct (mkCTable (cons ((True) (0.5 1.5)) 
                       (cons ((False) (2.0 2.5)) ())) 
                       (cons A (cons Output ())) 6.5))
        ($bc (mkBCScore (createTruthTableBScore 0.1 $ct)))
       )
   (assertEqual (worstPossibleScore $bc) -1.5))

!(let* (
        ($ct (mkCTable (cons ((True) (0.5 1.5)) 
                       (cons ((False) (2.0 2.5)) ())) 
                       (cons A (cons Output ())) 6.5))
        ($bc (mkBCScore (createTruthTableBScore 0.1 $ct)))
       )
   (assertEqual (minImprove $bc) 0.25))
