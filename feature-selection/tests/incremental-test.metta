!(register-module! ../../../metta-moses)
! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:feature-selection:feature-selection-helpers)
! (import! &self metta-moses:feature-selection:incremental)


! (bind! myTable 
   (mkITable
     (Cons (Cons True (Cons True (Cons True Nil)))
     (Cons (Cons True (Cons False (Cons False Nil)))
     (Cons (Cons False (Cons True (Cons False Nil)))
     (Cons (Cons False (Cons False (Cons False Nil))) Nil))))
     (Cons A (Cons B (Cons Output Nil)))))

!(bind! complexTable 
    (mkITable 
        (Cons (Cons False (Cons False (Cons True (Cons True (Cons True Nil)))))
        (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
        (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
        (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil))))
        (Cons A (Cons B (Cons C (Cons D (Cons Output Nil)))))))

!(bind! xorTable (mkITable
    (Cons (Cons True  (Cons True  (Cons False Nil)))
    (Cons (Cons True  (Cons False (Cons True  Nil)))
    (Cons (Cons False (Cons True  (Cons True  Nil)))
    (Cons (Cons False (Cons False (Cons False Nil))) Nil))))
    (Cons A (Cons B (Cons Output Nil)))))

!(bind! redundantTable (mkITable 
    (Cons (Cons True  (Cons True  (Cons True  Nil)))
    (Cons (Cons True  (Cons True  (Cons True  Nil)))
    (Cons (Cons False (Cons False (Cons False Nil)))
    (Cons (Cons False (Cons False (Cons False Nil))) Nil))))
    (Cons A (Cons B (Cons Output Nil)))))

! (assertEqual (calculateMutualInformation xorTable (Cons 0 (Cons 1 Nil)))  1.0)
! (assertEqual (calculateMutualInformation myTable (Cons 0 Nil)) 0.311)
! (assertEqual (calculateMutualInformation myTable (Cons 0 (Cons 1 Nil))) 0.811)

! (assertEqual (filterRelevantCombinations xorTable (Cons (Cons 0 (Cons 1 Nil)) Nil) 0.1) (Cons 0 (Cons 1 Nil)))
! (assertEqual (filterRelevantCombinations myTable (Cons (Cons 0 (Cons 1 Nil)) Nil) 0.1) (Cons 0 (Cons 1 Nil)))
; ; ;; Features below threshold (should return Nil)
! (assertEqual (filterRelevantCombinations myTable (Cons (Cons 0 Nil) (Cons (Cons 1 Nil) Nil)) 0.4) Nil)
; ; ; ;; All features pass threshold
! (assertEqual (filterRelevantCombinations complexTable (Cons (Cons 0 (Cons 1 Nil)) Nil) 0.0) (Cons 0 (Cons 1 Nil)))


! (assertEqual (findRedundantFeatures xorTable (Cons 0 (Cons 1 Nil)) 0.1) Nil)
; ;; Detect redundancy (A and B identical in redundantTable)
! (assertEqual (findRedundantFeatures redundantTable (Cons 0 (Cons 1 Nil)) 0.1) (Cons 1 Nil))
; ;; No redundancy case
! (assertEqual (findRedundantFeatures myTable (Cons 0 (Cons 1 Nil)) 0.000001) Nil)
; ;; Partial redundancy
! (assertEqual (findRedundantFeatures complexTable (Cons 0 (Cons 3 Nil)) 0.1) (Cons 3 Nil))


; ;; Threshold based Selection
! (assertEqual (incrementalFeatureSelection xorTable 0.1 0 3 0.5)  (1.0 (1 0)))
! (assertEqual (incrementalFeatureSelection myTable 0.02 0 2 0) (0.811 (0 1)))
! (assertEqual (incrementalFeatureSelection redundantTable 0.1 0 3 0.4) (1.0 (0)))
! (assertEqual (incrementalFeatureSelection complexTable 0.05 0 2 0) (1.0 (0 1 2)))
! (assertEqual (incrementalFeatureSelection complexTable 0.01 0 0 0)  (1.0 (0 1 2)))

;; Adaptive feature Selection (Binary Search on Incremental Selection)
! (assertEqual (incrementalFeatureSelection complexTable 0 2 3 0.4) (1.0 (2 0)))
; ; 
