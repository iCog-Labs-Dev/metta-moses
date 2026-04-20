!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/utilities/list-methods)
!(import! &self ../../../metta-moses/utilities/ordered-set)
!(import! &self ../../../metta-moses/utilities/lru-cache)
!(import! &self ../../../metta-moses/feature-selection/feature-selection-helpers)
!(import! &self ../../../metta-moses/feature-selection/incremental)

(= (andTable) 
   (mkITable
     (cons (cons True (cons True (cons True ())))
     (cons (cons True (cons False (cons False ())))
     (cons (cons False (cons True (cons False ())))
     (cons (cons False (cons False (cons False ()))) ()))))
     (cons A (cons B (cons Output ())))))

(= (complexTable) 
    (mkITable 
        (cons (cons False (cons False (cons True (cons True (cons True ())))))
        (cons (cons True (cons False (cons False (cons True (cons True ())))))
        (cons (cons False (cons True (cons False (cons True (cons False ())))))
        (cons (cons False (cons False (cons False (cons True (cons False ()))))) ()))))
        (cons A (cons B (cons C (cons D (cons Output ())))))))

(= (xorTable) (mkITable
    (cons (cons True  (cons True  (cons False ())))
    (cons (cons True  (cons False (cons True  ())))
    (cons (cons False (cons True  (cons True  ())))
    (cons (cons False (cons False (cons False ()))) ()))))
    (cons A (cons B (cons Output ())))))

(= (redundantTable) (mkITable 
    (cons (cons True  (cons True  (cons True  ())))
    (cons (cons True  (cons True  (cons True  ())))
    (cons (cons False (cons False (cons False ())))
    (cons (cons False (cons False (cons False ()))) ()))))
    (cons A (cons B (cons Output ())))))

;; Mutual Information calculations
!(assertEqual (calculateMutualInformation (andTable) (0)) 0.311)      ;; Single feature A
!(assertEqual (calculateMutualInformation (andTable) (1)) 0.311)      ;; Single feature B
!(assertEqual (calculateMutualInformation (xorTable) (0)) 0.0)       ;; XOR: single features uninformative
!(assertEqual (calculateMutualInformation (xorTable) (1)) 0.0)       ;; XOR: single features uninformative
!(assertEqual (calculateMutualInformation (xorTable) (0 1)) 1.0)  ;; XOR: joint features fully informative
!(assertEqual (calculateMutualInformation (andTable) (0 1)) 0.811) ;; AND: joint features informative
!(assertEqual (calculateMutualInformation (andTable) (0 1)) 0.811) ;; AND table joint MI


;; High MI combinations pass threshold
!(assertEqual (filterRelevantCombinations (xorTable) (cons (0 1) ()) 0.1 ()) 
               (cons 0 (cons 1 ())))
!(assertEqual (filterRelevantCombinations (andTable) (cons (0 1) ()) 0.1 ()) 
               (cons 0 (cons 1 ())))
;; Single features below threshold (should return empty set)
!(assertEqual (filterRelevantCombinations (xorTable) (cons (0) (cons (1) ())) 0.1 ()) 
               ())  ;; XOR single features have 0 MI < 0.1
;; Mixed threshold test - only some combinations pass
!(assertEqual (filterRelevantCombinations (andTable) (cons (0) (cons (1) ())) 0.4 ()) 
               ())  ;; Both single features have MI 0.311 < 0.4

;; All combinations pass very low threshold
!(assertEqual (filterRelevantCombinations (complexTable) (cons (0 1) ()) 0.0 ()) 
               (cons 0 (cons 1 ())))
;; No redundancy in XOR table
!(assertEqual (findRedundantSubsets (xorTable) (cons 0 (cons 1 ())) 0.1 1) ())
;; Detect redundancy in redundantTable (A and B are identical)
!(assertEqual (findRedundantSubsets (redundantTable) (cons 0 (cons 1 ())) 0.1 1) 
              (cons 1 ()))  ;; Feature B (index 1) is redundant
;; No redundancy with very strict threshold
!(assertEqual (findRedundantSubsets (andTable) (cons 0 (cons 1 ())) 0.000001 1) ())
;; Test with more features
!(assertEqual (findRedundantSubsets (complexTable) (cons 0 (cons 1 (cons 2 ()))) 0.1 1) 
               (cons 1 ()))  

;; Single subset case
!(assertEqual (findBestSubset (xorTable) (cons (0 1) ()) () -1) 
               (cons (0 1) (cons 1.0 ())))
;; Multiple subsets - should pick the best
!(assertEqual (findBestSubset (andTable) (cons (0) (cons (1) ())) () -1) 
             (cons (0) (cons 0.311 ())))    ;; Both have same MI, first one returned


;; Test with redundancy removal
!(assertEqual (incrementalIterator (redundantTable) (cons 0 (cons 1 ())) 0.8 1 0.5 1 ()) 
            (cons 0 ()))  ;; Only one feature after redundancy removal

;; Target size selection
!(assertEqual (adaptiveSelection (complexTable) 2 3 0.4 0.0 1.0 0.01) 
              (cons 0 (cons 2 ())))  ;; Should find ~2 features
;; Target size larger than available features
!(assertEqual (adaptiveSelection (xorTable) 5 3 0.4 0.0 1.0 0.01) 
                (cons 0 (cons 1 ())))  ;; Can't exceed available features
;; Target size of 0 - should return empty set
!(assertEqual (adaptiveSelection (xorTable) 0 3 0.4 0.0 1.0 0.01) ())

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


