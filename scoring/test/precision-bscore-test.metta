; !(register-module! ../../../metta-moses)
!(import! &self ../../../metta-moses/feature-selection/feature-selection-helpers)
!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/utilities/list-methods)
!(import! &self ../../../metta-moses/utilities/map)
!(import! &self ../../../metta-moses/utilities/ordered-multimap)
!(import! &self ../../../metta-moses/scoring/precision-bscore)

(= (andTable) 
   (mkITable
     (Cons (Cons True (Cons True (Cons True Nil)))      
     (Cons (Cons True (Cons False (Cons False Nil)))    
     (Cons (Cons False (Cons True (Cons False Nil)))    
     (Cons (Cons False (Cons False (Cons False Nil))) Nil))))
     (Cons A (Cons B (Cons Output Nil)))))

; ;; Test data: Precision Table
; this is directy taken from the moses c++ test file
;; reference: https://github.com/opencog/moses/blob/master/tests/moses/precision.csv
(= (precisionTable)
   (mkITable
     (Cons (Cons False (Cons False (Cons False Nil)))  
     (Cons (Cons True  (Cons False (Cons False Nil)))   
     (Cons (Cons False (Cons False (Cons False Nil)))  
     (Cons (Cons True  (Cons False (Cons False Nil)))   
     (Cons (Cons True  (Cons False (Cons False Nil)))  
     (Cons (Cons False (Cons False (Cons True  Nil)))  
     (Cons (Cons False (Cons False (Cons True  Nil)))  
     (Cons (Cons False (Cons True  (Cons True  Nil)))  
     (Cons (Cons False (Cons True  (Cons True  Nil)))  
     (Cons (Cons False (Cons True  (Cons True  Nil))) Nil))))))))))
     (Cons v1 (Cons v2 (Cons target Nil)))))


; Test of count Table
; !(assertEqual (countTable (True True True) 2 NilMap) (ConsMap ((True True) (1 0)) NilMap))
; !(assertEqual (countTable (True False False) 2 NilMap) (ConsMap ((True False) (0 1)) NilMap))
; !(assertEqual (countTable (True True False) 2 NilMap) (ConsMap ((True True) (0 1)) NilMap))
; !(assertEqual (countTable () 0 NilMap) NilMap)


; Test of cTable
!(assertEqual (cTable ((True True True) (True False False) (False True False) (False False False)) (A B Output)) 
            (ConsMap ((True True) (1 0)) (ConsMap ((True False) (0 1)) (ConsMap ((False True) (0 1)) (ConsMap ((False False) (0 1)) NilMap))))
  )

!(assertEqual (cTable ((False False False) (True False False) (False False False) (True False False) (True False False) (False False True) (False False True) (False True True) (False True True) (False True True)) (v1 v2 target))
            (ConsMap ((False False) (2 2)) (ConsMap ((True False) (0 3)) (ConsMap ((False True) (3 0)) NilMap)))
  )


!(assertEqual (makePrecisionRow ((True True) (1 0)) NilMMap) (ConsMMap (0.5 (0.5 1)) NilMMap))
!(assertEqual (makePrecisionRow ((False True) (0 2)) NilMMap) (ConsMMap (-0.5 (-1.0 2)) NilMMap))
!(assertEqual (makePrecisionRow () NilMMap) NilMMap)


!(assertEqual (createPrecisionRows (ConsMap ((True True) (1 0)) 
                                 (ConsMap ((True False) (0 1)) 
                                         (ConsMap ((False True) (0 1)) NilMap))))  
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
            (Cons (Cons True (Cons True (Cons False (Cons True (Cons True Nil)))))
            (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
            (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
            (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil)))))
(= (testLabels) (Cons A (Cons B (Cons C (Cons D (Cons Output Nil))))))

!(assertEqual (extractTable (0) (testRows) (testLabels))
                 (((True True) (True True) (False False) (False False)) (A Output))) ;; single feature extraction
!(assertEqual (extractTable (0 1) (testRows) (testLabels)) 
                (((True True True) (True False True) (False True False) (False False False)) (A B Output))) ;; two feature extraction

!(assertEqual (extractTable () (testRows) (testLabels))
            (((True) (True) (False) (False)) (Output))  ;; only extracts the labels
)


; Test of bestPossibleScore
!(assertEqual (let $bestScore (bestPossibleBScore ((0.5 (0.5 1)) (-0.5 (-0.5 1)) (-0.5 (-0.5 1))) 0.0 0.0 4 0.5 1.0 1.0 -1000.0)
            (< $bestScore 1.0)
    ) True
)

!(assertEqual (bestPossibleBScore () 0.0 0.0 4 0.5 1.0 1.0 -1000.0) -1000.0) ;; should return intial score
!(assertEqual (bestPossibleBScore ((1.0 (1.0 2)) (0.5 (0.5 2))) 0.0 0.0 4 0.5 1.0 1.0 0.0) 1.0)

; Test of PrecisionBScore
!(assertEqual (precisionBScore ((True True True) (False False False)) (A B Output) 1.0 0.5 1.0 2) 1.0)

                                                                                                                                                                                                                                                    ;; this is the actual result in the moses test file too for precisionTable which is 5/7 = 0.7142857142857143
                                                                                                                                                                                                                                                    ;; reference: https://github.com/opencog/moses/blob/master/tests/moses/scoringUTest.cxxtest#L55
!(assertEqual (precisionBScore ((False False False) (True False False) (False False False) (True False False) (True False False) (False False True) (False False True) (False True True) (False True True) (False True True)) (v1 v2 target) 1.0 0.5 1.0 10) 0.7142857142857143)

;; Test of prescorer
!(assertEqual (preScorer (1) (andTable) 1.0 0.5 1.0 True 0.001) 0.4000799677107699)
!(assertEqual (preScorer (0 1) (andTable) 1.0 0.5 1.0 True 50.0) 0.5)
!(assertEqual (preScorer (1) (precisionTable) 1.0 0.5 1.0 True 100.0) 0.5)
!(assertEqual (preScorer () (andTable) 1.0 0.5 1.0 True 100.0) 0.0)
;                                                                         ;; this is the actual result in the moses test file too for precisionTable which is 5/7 = 0.7142857142857143
;                                                                         ;; reference: https://github.com/opencog/moses/blob/master/tests/moses/scoringUTest.cxxtest#L55
!(assertEqual (preScorer (0 1) (precisionTable) 1.0 0.5 1.0 True 100.0) 0.7142857142857143)
