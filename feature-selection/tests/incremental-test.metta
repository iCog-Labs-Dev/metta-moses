;!(register-module! ../../../metta-moses)

!(import! &self ../../../metta-moses/utilities/list-methods)
!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/utilities/ordered-set)
!(import! &self ../../../metta-moses/feature-selection/feature-selection-helpers)
!(import! &self ../../../metta-moses/feature-selection/incremental)
!(import! &self ../../../metta-moses/utilities/lru-cache)

(= (andTable) 
   (mkITable
     (Cons (Cons True (Cons True (Cons True Nil)))
     (Cons (Cons True (Cons False (Cons False Nil)))
     (Cons (Cons False (Cons True (Cons False Nil)))
     (Cons (Cons False (Cons False (Cons False Nil))) Nil))))
     (Cons A (Cons B (Cons Output Nil)))))

(= (complexTable) 
    (mkITable 
        (Cons (Cons False (Cons False (Cons True (Cons True (Cons True Nil)))))
        (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
        (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
        (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil))))
        (Cons A (Cons B (Cons C (Cons D (Cons Output Nil)))))))

(= (xorTable) (mkITable
    (Cons (Cons True  (Cons True  (Cons False Nil)))
    (Cons (Cons True  (Cons False (Cons True  Nil)))
    (Cons (Cons False (Cons True  (Cons True  Nil)))
    (Cons (Cons False (Cons False (Cons False Nil))) Nil))))
    (Cons A (Cons B (Cons Output Nil)))))

(= (redundantTable) (mkITable 
    (Cons (Cons True  (Cons True  (Cons True  Nil)))
    (Cons (Cons True  (Cons True  (Cons True  Nil)))
    (Cons (Cons False (Cons False (Cons False Nil)))
    (Cons (Cons False (Cons False (Cons False Nil))) Nil))))
    (Cons A (Cons B (Cons Output Nil)))))

;; Mutual Information calculations
!(assertEqual (calculateMutualInformation (andTable) (0)) 0.311)      ;; Single feature A
!(assertEqual (calculateMutualInformation (andTable) (1)) 0.311)      ;; Single feature B
!(assertEqual (calculateMutualInformation (xorTable) (0)) 0.0)       ;; XOR: single features uninformative
!(assertEqual (calculateMutualInformation (xorTable) (1)) 0.0)       ;; XOR: single features uninformative
!(assertEqual (calculateMutualInformation (xorTable) (0 1)) 1.0)  ;; XOR: joint features fully informative
!(assertEqual (calculateMutualInformation (andTable) (0 1)) 0.811) ;; AND: joint features informative
!(assertEqual (calculateMutualInformation (andTable) (0 1)) 0.811) ;; AND table joint MI


;; High MI combinations pass threshold
!(assertEqual (filterRelevantCombinations (xorTable) (ConsOS (0 1) NilOS) 0.1 NilOS) 
               (ConsOS 0 (ConsOS 1 NilOS)))
!(assertEqual (filterRelevantCombinations (andTable) (ConsOS (0 1) NilOS) 0.1 NilOS) 
               (ConsOS 0 (ConsOS 1 NilOS)))
;; Single features below threshold (should return empty set)
!(assertEqual (filterRelevantCombinations (xorTable) (ConsOS (0) (ConsOS (1) NilOS)) 0.1 NilOS) 
               NilOS)  ;; XOR single features have 0 MI < 0.1
;; Mixed threshold test - only some combinations pass
!(assertEqual (filterRelevantCombinations (andTable) (ConsOS (0) (ConsOS (1) NilOS)) 0.4 NilOS) 
               NilOS)  ;; Both single features have MI 0.311 < 0.4

;; All combinations pass very low threshold
!(assertEqual (filterRelevantCombinations (complexTable) (ConsOS (0 1) NilOS) 0.0 NilOS) 
               (ConsOS 0 (ConsOS 1 NilOS)))
;; No redundancy in XOR table
!(assertEqual (findRedundantSubsets (xorTable) (ConsOS 0 (ConsOS 1 NilOS)) 0.1 1) NilOS)
;; Detect redundancy in redundantTable (A and B are identical)
!(assertEqual (findRedundantSubsets (redundantTable) (ConsOS 0 (ConsOS 1 NilOS)) 0.1 1) 
              (ConsOS 1 NilOS))  ;; Feature B (index 1) is redundant
;; No redundancy with very strict threshold
!(assertEqual (findRedundantSubsets (andTable) (ConsOS 0 (ConsOS 1 NilOS)) 0.000001 1) NilOS)
;; Test with more features
!(assertEqual (findRedundantSubsets (complexTable) (ConsOS 0 (ConsOS 1 (ConsOS 2 NilOS))) 0.1 1) 
               (ConsOS 1 NilOS))  

;; Single subset case
!(assertEqual (findBestSubset (xorTable) (ConsOS (0 1) NilOS) () -1) 
               (Cons (0 1) (Cons 1.0 Nil)))
;; Multiple subsets - should pick the best
!(assertEqual (findBestSubset (andTable) (ConsOS (0) (ConsOS (1) NilOS)) () -1) 
             (Cons (0) (Cons 0.311 Nil)))    ;; Both have same MI, first one returned


;; Test with redundancy removal
!(assertEqual (incrementalIterator (redundantTable) (ConsOS 0 (ConsOS 1 NilOS)) 0.8 1 0.5 1 NilOS) 
            (ConsOS 0 NilOS))  ;; Only one feature after redundancy removal

;; Target size selection
!(assertEqual (adaptiveSelection (complexTable) 2 3 0.4 0.0 1.0 0.01) 
              (ConsOS 0 (ConsOS 2 NilOS)))  ;; Should find ~2 features
;; Target size larger than available features
!(assertEqual (adaptiveSelection (xorTable) 5 3 0.4 0.0 1.0 0.01) 
                (ConsOS 0 (ConsOS 1 NilOS)))  ;; Can't exceed available features
;; Target size of 0 - should return empty set
!(assertEqual (adaptiveSelection (xorTable) 0 3 0.4 0.0 1.0 0.01) NilOS)

;; MAIN INTERFACE TESTS
;; XOR table with low threshold - both features needed
!(assertEqual (incrementalSelection (xorTable) 0.1 0 3 0.5) ((1.0 (0 1))))
;; AND table with moderate threshold
!(assertEqual (incrementalSelection (andTable) 0.02 0 2 0) ((0.811 (0 1))))
;; Redundant table with redundancy removal
!(assertEqual (incrementalSelection (redundantTable) 0.1 0 3 0.4) ((1.0 (0))))
;; Complex table with moderate threshold
!(assertEqual (incrementalSelection (complexTable) 0.05 0 2 0) ((1.0 (0 1 2))))

;; Return all features when both threshold and target are 0
!(assertEqual (incrementalSelection (complexTable) 0 0 0 0) ((1.0 (0 1 2 3))))
!(assertEqual (incrementalSelection (complexTable) 0 2 3 0.4) ((1.0 (0 2))))
!(assertEqual (incrementalSelection (xorTable) 0 1 3 0.5) ((1.0 (0 1))))  ;; Single XOR feature has 0 MI
!(assertEqual (incrementalSelection (redundantTable) 0 3 3 0.5) ((1.0 (0))))  ;; Only 1 non-redundant feature
!(assertEqual (incrementalSelection (xorTable) 2.0 0 3 0.0) ((0 ())))  ;; Threshold too high
!(assertEqual (incrementalSelection (xorTable) -1.0 0 3 0.0) ((1.0 (0 1))))  ;; Negative threshold (all features)


