!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/tree)

!(import! &self ../fitness)
!(import! &self ../bscore)


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
   (createTruthTableBScore 0.2 (mkITable (cons (cons 1 (cons 0 (cons 2 ()))) ()) (cons A (cons B (cons C ())))))
   (mkTruthTableBScore 0.2 1 (mkITable (cons (cons 1 (cons 0 (cons 2 ()))) ()) (cons A (cons B (cons C ()))))))

;; Test Behavioral Score Helper functions
;; Test Sutract subtract behavioral scores pair wise
!(assertEqual
   (BScore.sub 
      (mkBScore (cons 1 (cons 0 (cons 2 ()))))
      (mkBScore (cons 1 (cons 0 (cons 2 ()))))) 
   (mkBScore (cons 0 (cons 0 (cons 0 ())))))
!(assertEqual
   (BScore.sub 
      (mkBScore (cons 1 (cons 0 (cons 2 ()))))
      (mkBScore (cons 1 (cons 0 ()))))
   (Error ((cons 1 (cons 0 (cons 2 ()))) (cons 1 (cons 0 ()))) "Incompatible behavioral scores"))
;; Test Retrieve the table from a truth table bscore
!(assertEqual 
   (getTable (mkTruthTableBScore 0.2 1 (mkITable (cons (cons 1 (cons 0 (cons 2 ()))) ()) (cons A (cons B (cons C ()))))))
   (mkITable (cons (cons 1 (cons 0 (cons 2 ()))) ()) (cons A (cons B (cons C ())))))

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
     (scoreTree (mkITable (cons (cons True (cons False (cons False ())))
                          (cons (cons True (cons True  (cons True ()))) ()))
                          (cons A (cons B (cons O ()))))
                (buildTree $cand) &bscoreCache)
     (mkBScore (cons -1 (cons 0 ())))))

!(let $cand (quote (AND A B))
   (assertEqual
     (scoreTree (mkITable (cons (cons True (cons False (cons False ())))
                                     (cons (cons True (cons True  (cons True ()))) ()))
                                     (cons A (cons B (cons O ()))))
                (buildTree $cand) &bscoreCache)
     (mkBScore (cons 0 (cons 0 ())))))

;; Test sumBScore
!(assertEqual (sumBScore (mkBScore (cons 1 (cons 2 (cons 0 (cons 1 ())))))) 4)

;; Test Truth table bscore helper functions
!(assertEqual 
   (bestPossibleScore 
          (mkTruthTableBScore 0.2 1 (mkITable (cons (cons 1 (cons 0 (cons 2 ()))) ()) (cons A (cons B (cons C ()))))))
   (mkBScore (cons 0 ())))
!(assertEqual 
   (worstPossibleScore (mkTruthTableBScore 0.2 1 (mkITable (cons (cons 1 (cons 0 (cons 2 ()))) ()) (cons A (cons B (cons C ()))))))
   (mkBScore (cons -1 ())))
!(assertEqual 
   (minImprove (mkTruthTableBScore 0.2 1 (mkITable (cons (cons 1 (cons 0 (cons 2 ()))) ()) (cons A (cons B (cons C ()))))))
   0.5
 )

;; Test Behavioral composite score helper functions
!(assertEqual
   (bestPossibleScore (mkBCScore (mkTruthTableBScore 0.2 2 (mkITable (cons (cons 1 (cons 0 (cons 2 ()))) (cons (cons 0 (cons 0 (cons 1 ()))) ())) (cons A (cons B (cons C ())))))))
   0
 )
!(assertEqual
   (worstPossibleScore (mkBCScore (mkTruthTableBScore 0.2 2 (mkITable (cons (cons 1 (cons 0 (cons 2 ()))) (cons (cons 0 (cons 0 (cons 1 ()))) ())) (cons A (cons B (cons C ())))))))
   -2
 )
!(assertEqual
   (minImprove (mkBCScore (mkTruthTableBScore 0.2 2 (mkITable (cons (cons 1 (cons 0 (cons 2 ()))) (cons (cons 0 (cons 0 (cons 1 ()))) ())) (cons A (cons B (cons C ())))))))
   0.5
 )

;; Test Helper function to compare two elements and return a score
!(assertEqual (compareAndScore A B) -1)
!(assertEqual (compareAndScore A A) 0)

;; Test Wrapper function to get the complexity of a tree
!(assertEqual
   (getComplexity (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())) ())))
   1
 )

;; Test getArgLabels function to extract argument labels from an ITable

!(assertEqual (getArgLabels (mkITable
  (cons (cons True (cons False (cons True ()))) ())
  (cons A (cons B (cons Y ())))
))
  (A B)
)

!(assertEqual (getArgLabels (mkITable
  (cons (cons 1 (cons 2 (cons 3 ()))) ())
  (cons X (cons Y (cons Z ())))
))
  (X Y)
)
