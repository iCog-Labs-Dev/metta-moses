!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/map)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../feature-selection/feature-selection-helpers)
!(import! &self ../../scoring/precision-bscore)

(= (andTable) 
   (mkITable
     (cons (cons True (cons True (cons False (cons False ()))))      
     (cons (cons True (cons False (cons True (cons False ()))))    
     (cons (cons True (cons False (cons False (cons False ())))) ())))
     (cons A (cons B (cons Output ())))))

;; Test data: Precision Table
; this is directy taken from the moses c++ test file
;; reference: https://github.com/opencog/moses/blob/master/tests/moses/precision.csv

(= (precisionTable)
   (mkITable 
     (cons (cons False (cons True (cons False (cons True (cons True (cons False (cons False (cons False (cons False (cons False ())))))))))) 
     (cons (cons False (cons False (cons False (cons False (cons False (cons False (cons False (cons True (cons True (cons True ()))))))))))
     (cons (cons False (cons False (cons False (cons False (cons False (cons True (cons True (cons True (cons True (cons True ())))))))))) ())))
     (cons v1 (cons v2 (cons target ())))))

(= (weightedPrecisionTable)
   (mkITable 
     (cons (cons True (cons True (cons False (cons False (cons False ())))))
     (cons (cons False (cons False (cons True (cons True (cons False ())))))
     (cons (cons 0.5 (cons 0.5 (cons 1.5 (cons 1.0 (cons 1.5 ())))))
     (cons (cons True (cons True (cons True (cons False (cons False ()))))) ()))))
     (cons v1 (cons v2 (cons Weight (cons target ()))))))

; Test of count Table
; !(assertEqual (countTable (True True True) 2 ()) (cons ((True True) (1 0)) ()))
; !(assertEqual (countTable (True False False) 2 ()) (cons ((True False) (0 1)) ()))
; !(assertEqual (countTable (True True False) 2 ()) (cons ((True True) (0 1)) ()))
; !(assertEqual (countTable () 0 ()) ())


;; Test of cTable
!(assertEqual (cTable ((True True False False) (True False True False) (True False False False)) (A B Output)) 
            (mkCTable (cons ((True True) (1 0)) (cons ((True False) (0 1)) (cons ((False True) (0 1)) (cons ((False False) (0 1)) ())))) (A B Output) 4)
  )

!(assertEqual (cTable ((False True False True True False False False False False) (False False False False False False False True True True) (False False False False False True True True True True)) (v1 v2 target))
            (mkCTable (cons ((False False) (2 2)) (cons ((True False) (0 3)) (cons ((False True) (3 0)) ()))) (v1 v2 target) 10)
  )


!(assertEqual (makePrecisionRow ((True True) (1 0)) ()) (cons (0.5 (0.5 1)) ()))
!(assertEqual (makePrecisionRow ((False True) (0 2)) ()) (cons (-0.5 (-1.0 2)) ()))
!(assertEqual (makePrecisionRow () ()) ())


!(assertEqual (createPrecisionRows (cons ((True True) (1 0)) 
                                 (cons ((True False) (0 1)) 
                                         (cons ((False True) (0 1)) ()))))  
                ;;result 
                ((0.5 (0.5 1)) (-0.5 (-0.5 1)) (-0.5 (-0.5 1)))             
  )

; Test of getActivationPenalty
!(assertEqual (getActivationPenalty 0.5 0.5 1.0 1.0) 0.0)     ;; At minimum boundary -> no penalty
!(assertEqual (getActivationPenalty 0.75 0.5 1.0 0.0) 0.0)    ;; No pressure -> no penalty
!(assertEqual (getActivationPenalty 1.0 0.5 1.0 1.0) 0.0)     ;; At maximum boundary -> no penalty


!(assertEqual (let $penaltyBelow (getActivationPenalty 0.3 0.5 1.0 1.0) (< $penaltyBelow 0)) True)  ;; Should be negative (penalty)

!(assertEqual (let* (
                        ($penalty1 (getActivationPenalty 0.3 0.5 1.0 1.0))
                        ($penalty2 (getActivationPenalty 0.3 0.5 1.0 2.0))
                    )
                    (< $penalty2 $penalty1)) True)  ;; Higher pressure -> more negative penalty

;; Test ExtractTable

(= (testRows) 
            (cons (cons True (cons True (cons False (cons False ()))))
            (cons (cons True (cons False (cons True (cons False ()))))
            (cons (cons False (cons False (cons False (cons False ()))))
            (cons (cons True (cons True (cons True (cons True ())))) 
            (cons (cons True (cons True (cons False (cons False ())))) ()))))))
            
(= (testLabels) (cons A (cons B (cons C (cons D (cons Output ()))))))

!(assertEqual (extractTable (0) (testRows) (testLabels) ())
                 (((True True False False) (True True False False)) (A Output))) ;; single feature extraction
!(assertEqual (extractTable (0 1) (testRows) (testLabels) ()) 
                (((True True False False) (True False True False) (True True False False)) (A B Output))) ;; two feature extraction

!(assertEqual (extractTable () (testRows) (testLabels) ())
            (((True True False False)) (Output))  ;; only extracts the labels
)


; Test of bestPossibleScore
!(assertEqual (let $bestScore (bestPossibleBScore ((0.5 (0.5 1)) (-0.5 (-0.5 1)) (-0.5 (-0.5 1))) 0.0 0.0 4 0.5 1.0 1.0 -1000.0)
            (< $bestScore 1.0)
    ) True
)

!(assertEqual (bestPossibleBScore () 0.0 0.0 4 0.5 1.0 1.0 -1000.0) -1000.0) ;; should return intial score
!(assertEqual (bestPossibleBScore ((1.0 (1.0 2)) (0.5 (0.5 2))) 0.0 0.0 4 0.5 1.0 1.0 0.0) 1.0)

; Test of PrecisionBScore
!(assertEqual (precisionBScore ((True False) (True False) (True False)) (A B Output) 1.0 0.5 1.0 2 ()) 1.0)

                                                                                                                                                                                                                                                    ;; this is the actual result in the moses test file too for precisionTable which is 5/7 = 0.7142857142857143
                                                                                                                                                                                                                                                    ;; reference: https://github.com/opencog/moses/blob/master/tests/moses/scoringUTest.cxxtest#L55
!(assertEqual (precisionBScore ((False True False True True False False False False False) (False False False False False False False True True True) (False False False False False True True True True True)) (v1 v2 target) 1.0 0.5 1.0 10 ()) 0.7142857142857143)

;; Test of prescorer
!(assertEqual (preScorer (1) (andTable) 1.0 0.5 1.0 True 0.001 ()) 0.4000799677107699)
!(assertEqual (preScorer (0 1) (andTable) 1.0 0.5 1.0 True 50.0 ()) 0.5)
!(assertEqual (preScorer (1) (precisionTable) 1.0 0.5 1.0 True 100.0 ()) 0.5)
!(assertEqual (preScorer () (andTable) 1.0 0.5 1.0 True 100.0 ()) 0.0)
;                                                                         ;; this is the actual result in the moses test file too for precisionTable which is 5/7 = 0.7142857142857143
;                                                                         ;; reference: https://github.com/opencog/moses/blob/master/tests/moses/scoringUTest.cxxtest#L55
!(assertEqual (preScorer (0 1) (precisionTable) 1.0 0.5 1.0 True 100.0 ()) 0.7142857142857143)

;; ====================================================================
;; Weighted Table Groundwork: delete_column, countTable, and cTable
;; ====================================================================

;; Test delete_column on (mkITable ...)
!(assertEqual
    (delete_column Weight (mkITable ((True False) (1.0 2.0) (True True)) (A Weight Output)))
    (mkITable ((True False) (True True)) (A Output)))

;; Test delete_column throws error on unknown column name
!(assertEqual
    (delete_column NonExistent (mkITable ((True False) (True True)) (A Output)))
    (Error NonExistent "Can't delete, unknown column name"))

!(assertEqual
    (delete_column "" (mkITable ((True False) (True True)) (A Output)))
    (Error "" "Can't delete, unknown column name"))

;; Test delete_column on raw ($columns $labels)
!(assertEqual
    (delete_column Weight ((True False) (1.0 2.0) (True True)) (A Weight Output))
    (((True False) (True True)) (A Output)))

;; Test countTable with fractional weights
!(assertEqual
    (countTable 0 ((True True) (False False)) (True False) (0.5 1.5) ())
    (cons ((True False) (0.5 0)) ()))

!(assertEqual
    (countTable 1 ((True True) (False False)) (True False) (0.5 1.5) (cons ((True False) (0.5 0)) ()))
    (cons ((True False) (0.5 1.5)) ()))

;; Test unweighted cTable on (mkITable ...) (1-arg overload)
!(assertEqual
    (cTable (mkITable ((True True False False) (True False True False) (True False False False)) (A B Output)))
    (mkCTable (cons ((True True) (1 0)) (cons ((True False) (0 1)) (cons ((False True) (0 1)) (cons ((False False) (0 1)) ())))) (A B Output) 4))

;; Test weighted cTable with weight column name
!(assertEqual
    (cTable ((True True False False) (0.5 1.5 2.0 2.5) (True False True False)) (A Weight Output) Weight)
    (mkCTable (cons ((True) (0.5 1.5)) (cons ((False) (2.0 2.5)) ())) (A Output) 6.5))

;; Test CTable accessors (getCTableTotalWeight, getCTableLabels, getCTableMap)
!(let $ct (cTable ((True True False False) (0.5 1.5 2.0 2.5) (True False True False)) (A Weight Output) Weight)
   (assertEqual (getCTableTotalWeight $ct) 6.5))

!(let $ct (cTable ((True True False False) (0.5 1.5 2.0 2.5) (True False True False)) (A Weight Output) Weight)
   (assertEqual (getCTableLabels $ct) (A Output)))

!(let $ct (cTable ((True True False False) (0.5 1.5 2.0 2.5) (True False True False)) (A Weight Output) Weight)
   (assertEqual (getCTableMap $ct) (cons ((True) (0.5 1.5)) (cons ((False) (2.0 2.5)) ()))))


;; ====================================================================
;; Weighted Precision Scoring: extractTable, precisionBScore, and preScorer
;; ====================================================================

;; Test extractTable with weight column on multi-feature table (filters out unselected B, preserves Weight and Output)
!(assertEqual 
    (extractTable (0) ((True False) (True True) (1.0 2.0) (True True)) (A B Weight Output) Weight)
    (((True False) (1.0 2.0) (True True)) (A Weight Output)))

;; Test unknown weight column error in preScorer using precisionTable
!(assertEqual
    (preScorer (0 1) (precisionTable) 1.0 0.5 1.0 True 100.0 NonExistent)
    (Error NonExistent "Can't score, unknown weight column"))

;; Test weighted preScorer on 5-row table with fractional weights (evaluates to 5/7 = 0.7142857142857143)
!(assertEqual
    (preScorer (0 1) (weightedPrecisionTable) 1.0 0.5 1.0 True 100.0 Weight)
    0.7142857142857143)
