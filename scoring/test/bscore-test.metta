!(register-module! ../../../metta-moses)

!(import! &self metta-moses:scoring:bscore)
!(import! &self metta-moses:scoring:fitness)

!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:utilities:general-helpers)

;; Test Types and type constructors
!(assertEqual
    (let $a (mkBScore (Cons 1 (Cons 0 (Cons 2 Nil)))) (get-type $a)) 
    BehavioralScore
 )
!(assertEqual
   (let $a (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil)))) (get-type $a))
   (ITable Number))
!(assertEqual
   (let $a (mkTruthTableBScore 1 0.2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil))))) (get-type $a))
   (TruthTableBScore Number))
!(assertEqual
   (let $a (createTruthTableBScore 0.2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil))))) (get-type $a))
   (TruthTableBScore Number))
!(assertEqual
   (createTruthTableBScore 0.2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil)))))
   (mkTruthTableBScore 0.2 1 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil))))))

;; Test Behavioral Score Helper functions
;; Test Sutract subtract behavioral scores pair wise
!(assertEqual
   (BScore.sub 
      (mkBScore (Cons 1 (Cons 0 (Cons 2 Nil))))
      (mkBScore (Cons 1 (Cons 0 (Cons 2 Nil))))) 
   (mkBScore (Cons 0 (Cons 0 (Cons 0 Nil)))))
!(assertEqual
   (BScore.sub 
      (mkBScore (Cons 1 (Cons 0 (Cons 2 Nil))))
      (mkBScore (Cons 1 (Cons 0 Nil))))
   (Error ((Cons 1 (Cons 0 (Cons 2 Nil))) (Cons 1 (Cons 0 Nil))) "Incompatible behavioral scores"))
;; Test Retrieve the table from a truth table bscore
!(assertEqual 
   (getTable (mkTruthTableBScore 0.2 1 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil))))))
   (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil)))))

;; Test Score Tree Helper Function test to replace all occurences of a given variable with a truth value 
!(assertEqual
   (replaceVarWithTruth (True A) (AND A B (OR A B (NOT A))))
   (AND True B (OR True B (NOT True))))
!(assertEqual
   (replaceVarWithTruth (False B) (AND A B (OR A B (NOT A))))
   (AND A False (OR A False (NOT A))))

;; Test Score Tree Helper function to replace all occurences of all variables with their corresponding truth values
!(assertEqual
   (replaceVarsWithTruth ((Cons A (Cons B Nil)) (AND A B (OR A B (NOT A)))) (Cons True (Cons False Nil)))
   (AND True False (OR True False (NOT True))))
!(assertEqual
   (replaceVarsWithTruth ((Cons A (Cons B Nil)) (AND A B (OR A B (NOT A)))) (Cons False (Cons True Nil)))
   (AND False True (OR False True (NOT False))))

;; Test Score Tree function, given a boolean expression and tree should return a behavioral score
!(assertEqual
   (scoreTree (mkITable (Cons (Cons True (Cons False (Cons False Nil)))
                        (Cons (Cons True (Cons True  (Cons True Nil))) Nil)) 
                        (Cons A (Cons B (Cons O Nil)))) 
              (buildTree (OR A B)))
   (mkBScore (Cons -1 (Cons 0 Nil))))
!(assertEqual
   (scoreTree (mkITable (Cons (Cons True (Cons False (Cons False Nil)))
                                   (Cons (Cons True (Cons True  (Cons True Nil))) Nil)) 
                                   (Cons A (Cons B (Cons O Nil)))) 
              (buildTree (AND A B)))
   (mkBScore (Cons 0 (Cons 0 Nil))))

;; Test sumBScore
!(assertEqual (sumBScore (mkBScore (Cons 1 (Cons 2 (Cons 0 (Cons 1 Nil)))))) 4)

;; Test Truth table bscore helper functions
!(assertEqual 
   (bestPossibleScore 
          (mkTruthTableBScore 0.2 1 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil))))))
   (mkBScore (Cons 0 Nil)))
!(assertEqual 
   (worstPossibleScore (mkTruthTableBScore 0.2 1 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil))))))
   (mkBScore (Cons -1 Nil)))
!(assertEqual 
   (minImprove (mkTruthTableBScore 0.2 1 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) Nil) (Cons A (Cons B (Cons C Nil))))))
   0.5
 )

;; Test Behavioral composite score helper functions
!(assertEqual
   (bestPossibleScore (mkBCScore (mkTruthTableBScore 0.2 2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) (Cons (Cons 0 (Cons 0 (Cons 1 Nil))) Nil)) (Cons A (Cons B (Cons C Nil)))))))
   0
 )
!(assertEqual
   (worstPossibleScore (mkBCScore (mkTruthTableBScore 0.2 2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) (Cons (Cons 0 (Cons 0 (Cons 1 Nil))) Nil)) (Cons A (Cons B (Cons C Nil)))))))
   -2
 )
!(assertEqual
   (minImprove (mkBCScore (mkTruthTableBScore 0.2 2 (mkITable (Cons (Cons 1 (Cons 0 (Cons 2 Nil))) (Cons (Cons 0 (Cons 0 (Cons 1 Nil))) Nil)) (Cons A (Cons B (Cons C Nil)))))))
   0.5
 )

;; Test Helper function to compare two elements and return a score
!(assertEqual (compareAndScore A B) -1)
!(assertEqual (compareAndScore A A) 0)

;; Test Wrapper function to get the complexity of a tree
!(assertEqual
   (getComplexity (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))
   1
 )
