!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/utilities/list-methods)
!(import! &self ../../../metta-moses/feature-selection/feature-selection-helpers)

;; Test
!(assertEqual (List.at 0 (cons True (cons False ()))) True)
!(assertEqual (List.at 1 (cons True (cons False ()))) False)
!(assertEqual (List.at 2 (cons True (cons False ()))) (Error () "Empty List"))
!(assertEqual (List.at 0 ()) (Error () "Empty List"))

;; Test
!(assertEqual (patternExists (True 1) ()) False)
!(assertEqual (patternExists (True $x) ((False 2) (True 1))) True)
!(assertEqual (patternExists (False $x) ((True 7) (False 3))) True)
!(assertEqual (patternExists (False $x) ((False 2))) True)

;; Test
!(assertEqual (updateCount True ((True 1) (False 2))) ((True 2) (False 2)))  
!(assertEqual (updateCount False ((True 1) (False 1))) ((True 1) (False 2)))  
!(assertEqual (updateCount True ((False 5) (True 3))) ((False 5) (True 4)))  

;; Test
!(assertEqual (pairMax (7 foo) (4 bar)) (7 foo))
!(assertEqual (pairMax (3.5 alpha) (3.5 beta)) (3.5 alpha))
!(assertEqual (pairMax (1 x) (9 y)) (9 y))

;; Test
!(test (takeN 0 (True False True)) ())
!(assertEqual (takeN 2 (True False True)) (True False))
!(assertEqual (takeN 5 (True False)) (True False))
!(assertEqual (takeN 3 ()) ())
; ;; Test
!(assertEqual (List.uniqueValuesCount () ()) ()) ;; ?? is this really what I expect? if the list is empty
!(assertEqual (List.uniqueValuesCount (cons True (cons False (cons True ()))) ()) ((True 2) (False 1)))
!(assertEqual (List.uniqueValuesCount (cons False (cons False (cons True (cons True (cons True ()))))) ()) ((False 2) (True 3)))
!(assertEqual (List.uniqueValuesCount (cons True (cons True (cons True (cons False ())))) ()) ((True 3) (False 1)))

;; Test
(= (itable) 
    (cons (cons True (cons False (cons True ()))) 
    (cons (cons False (cons True (cons False ()))) ())))

!(assertEqual (Table.getColumn 0 ()) ())
!(assertEqual (Table.getColumn 0 (itable)) (cons True (cons False ())))
!(assertEqual (Table.getColumn 1 (itable)) (cons False (cons True ())))
!(assertEqual (Table.getColumn 2 (itable)) (cons True (cons False ())))

;; Testcase for Table.getOutputColumn
!(assertEqual
    (Table.getOutputColumn (mkITable (cons (cons True (cons False (cons False ()))) 
                                      (cons (cons False (cons True (cons False ()))) 
                                      (cons (cons True (cons True (cons False ()))) 
                                      ())))
                                      (cons A (cons B (cons O ())))))                              
    (cons False (cons False (cons False ()))))

;; Test
!(assertEqual (Table.pop 0 ()) ())
!(assertEqual (Table.pop 0 (itable)) 
        (cons (cons False (cons True ())) 
        (cons (cons True (cons False ())) ())))


;; Test lexicographic ordering of featureSets
!(assertEqual (featureSet< 0 (1 0) (4 2)) true)
!(assertEqual (featureSet< 10000 (1 0) (4 2)) true)
!(assertEqual (featureSet< 0 (4 2) (1 0)) false)
!(assertEqual (featureSet< 10000 (4 2) (1 0)) false)

!(assertEqual (insertPair > (2 1) ((4 0) (1 3))) ((4 0) (2 1) (1 3)))                   ;; fist value is score and second one feature index
!(assertEqual (insertPair > (2 1) ((4 0) (2 4) (1 3))) ((4 0) (2 1) (2 4) (1 3)))       
!(assertEqual (insertPair > (featureSet< 0) (2 (1 0)) ((4 (1 0)) (2 (4 1)) (1 (3 1)))) ((4 (1 0)) (2 (1 0)) (2 (4 1)) (1 (3 1))))

!(assertEqual (marginalProbs 10 ((A 4) (B 6))) ((A 0.4) (B 0.6)))
!(assertEqual (marginalProbs 5 ((X 5))) ((X 1)))
!(assertEqual (marginalProbs 8 ((P 2) (Q 2) (R 4))) ((P 0.25) (Q 0.25) (R 0.5)))
!(assertEqual (marginalProbs 1 ((Z 1))) ((Z 1)))
!(assertEqual (marginalProbs 100 ()) ())

!(assertEqual (mutualInformation (cons True (cons False ())) (cons True (cons False ()))) 1.0)
!(assertEqual (mutualInformation (cons True (cons True ())) (cons False (cons False ()))) 0.0)
!(assertEqual (mutualInformation (cons A (cons B (cons A ()))) (cons X (cons Y (cons X ())))) 0.918)
!(assertEqual (mutualInformation (cons A (cons A (cons A ()))) (cons X (cons Y (cons Z ())))) 0.0)
!(assertEqual (mutualInformation (cons A (cons B (cons C ()))) (cons X (cons Y (cons Z ())))) 1.585)

!(assertEqual (insertPair > (2 1) ((4 0) (1 3))) ((4 0) (2 1) (1 3)))                   ;; fist value is score and second one feature index
!(assertEqual (insertPair > (2 1) ((4 0) (2 4) (1 3))) ((4 0) (2 1) (2 4) (1 3)))       

!(assertEqual (isEqual (A B C) (A B C)) True)
!(assertEqual (isEqual (A B C) (C A B)) True)
!(assertEqual (isEqual (A B) (A B C)) False)
!(assertEqual (isEqual (A B) (A D)) False)

!(assertEqual (range 0 1 5) (0 1 2 3 4))
!(assertEqual (range 2 2 10) (2 4 6 8))
!(assertEqual (range 5 0 10) (Error 0 "Step value of 0 not allowed!!"))
!(assertEqual (range 10 1 5) ())

!(assertEqual (isPairEqual (3 (A B)) (3 (B A))) True)
!(assertEqual (isPairEqual (5 (A B C)) (5 (C B A))) True)
!(assertEqual (isPairEqual (5 (A B C)) (4 (C B A))) False)
!(assertEqual (isPairEqual (3 (A B)) (2 (B A))) False)
!(assertEqual (isPairEqual (2 (X Y Z)) (2 (X Y W))) False)

!(assertEqual (isEqual (shuffle (A B C) ()) (A B C)) True)
!(assertEqual (isEqual (shuffle (X Y) ()) (X Y)) True)
!(assertEqual (isEqual (shuffle () ()) ()) True)
!(assertEqual (isEqual (shuffle (1 2 3 4) ()) (1 2 3 4)) True)

!(assertEqual (sortPairs pairMax ((0.2 (A)) (0.8 (B)) (0.6 (C)) (0.4 (D))) 2 ()) ((0.8 (B)) (0.6 (C))))
!(assertEqual (sortPairs pairMax ((0.9 (X)) (0.1 (Y)) (0.5 (Z))) 1 ()) ((0.9 (X))))
;; !(assertEqual (sortPairs pairMax ((0.3 (P)) (0.3 (Q)) (0.2 (R))) 2 ()) ((0.3 (P)) (0.3 (Q))))
!(assertEqual (sortPairs pairMax ((0.7 (M)) (0.4 (N)) (0.9 (O)) (0.1 (P))) 3 ()) ((0.9 (O)) (0.7 (M)) (0.4 (N))))

(= (table2) 
            (cons (cons True (cons True (cons False (cons True (cons True ())))))
            (cons (cons True (cons False (cons False (cons True (cons True ())))))
            (cons (cons False (cons True (cons False (cons True (cons False ())))))
            (cons (cons False (cons False (cons False (cons True (cons False ()))))) ())))))

!(assertEqual (zipColumn (1 3) (table2)) (cons (True True) (cons (False True) (cons (True True) (cons (False True) ())))))
!(assertEqual (zipColumn (0 1 4) (table2)) (cons (True True True) (cons (True False True) (cons (False True False) (cons (False False False) ())))))
!(assertEqual (zipColumn (2) (table2)) (cons (False) (cons (False) (cons (False) (cons (False) ()))))) 

; !(assertEqual (let $r (logMath 2 8) (- $r 3))  0.0)
; !(assertEqual (let $r (logMath 10 1000) (- $r 3))  0.0)

(= (table1) 
    (mkITable
        (cons (cons True (cons False (cons True ()))) 
        (cons (cons False (cons True (cons False ()))) ()))
        (cons A (cons B (cons O ())))))

!(assertEqual (filterTable (0) (table1)) 
                    (mkITable 
                            (cons (cons False (cons True ())) 
                            (cons (cons True (cons False ())) ())) 
                            (cons B (cons O ())))) 
!(assertEqual (filterTable (1) (table1)) 
                    (mkITable 
                            (cons (cons True (cons True ())) 
                            (cons (cons False (cons False ())) ())) 
                            (cons A (cons O ())))) 
!(assertEqual (filterTable (0 1) (table1)) 
                    (mkITable 
                            (cons (cons True ())
                            (cons (cons False ()) ()))
                            (cons O ())))

;; test for incremental selection Utility functions
!(assertEqual  (set ((A B) (B A) (C D)) ())  ((A B) (C D)))
!(assertEqual  (set ((X Y) (Z W)) ()) ((X Y) (Z W)))
!(assertEqual (set ((A B)) ()) ((A B)))
!(assertEqual  (set () ())  ())
!(assertEqual (set ((A A) (A A) (A A)) ()) ((A A)))

;; powerset test
!(assertEqual (powerSet (0 1 2) 0 True) (()))
!(assertEqual (powerSet (0 1) 1 False) ((0) (1) ()))
!(assertEqual (powerSet (2 0 1) 1 True) ((2) (0) (1)))
!(assertEqual (powerSet (0 1 2) 2 True) ((1 0) (2 0) (2 1))) 
!(assertEqual (powerSet (0 1 2) 3 True) ((2 1 0)))
!(assertEqual (powerSet (0 1 2) 3 False) ((2 1 0) (1 0) (2 0) (2 1) (0) (1) (2) ()))
!(assertEqual (powerSet (0 1 2 3) 3 True) ((2 1 0) (3 1 0) (3 2 0) (3 2 1)))
!(assertEqual (powerSet (0 1) 3 True) ())  ;; Impossible combination size

!(assertEqual (isWithin 0.0 0.0001 0.0001) True)   ;; Exactly at tolerance
!(assertEqual (isWithin 0.0 0.05 0.1) True)        ;; Within tolerance
!(assertEqual (isWithin 0.0 0.2 0.1) False)        ;; Outside tolerance
!(assertEqual (isWithin 1.0 1.005 0.01) True)      ;; Small difference
!(assertEqual (isWithin 5.0 5.1 0.05) False)       ;; Difference too large

!(assertEqual (getInputLabels (cons A (cons B (cons O ())))) (B A))                            
!(assertEqual (getInputLabels (cons A ())) ())                            

!(assertEqual (fsToNames (cons A (cons B (cons C ()))) (1)) (B))
!(assertEqual (fsToNames (cons A (cons B (cons C ()))) ()) ())

!(assertEqual (readjustIndices ((0.9 (0 2))) (cons A (cons B (cons C (cons D ())))) (cons A (cons B (cons C (cons D ()))))) ((0.9 (0 2))))
!(assertEqual (readjustIndices ((0.8 (0 1))) (cons A (cons C ())) (cons A (cons B (cons C (cons D ()))))) ((0.8 (0 2))))
!(assertEqual (readjustIndices ((0.6 (0 2)) (0.4 (1))) (cons B (cons C (cons D ()))) (cons A (cons B (cons C (cons D ()))))) ((0.6 (1 3)) (0.4 (2))))
!(assertEqual (readjustIndices ((0.4 (1)) (0.5 (1 2))) (cons A (cons C (cons D ()))) (cons A (cons B (cons C (cons D ()))))) ((0.4 (2)) (0.5 (2 3))))


; Test of CalculateConfidence
!(assertEqual 
   (let* (
       ($conf1 (calculateConfidence 1 10 0.1))
       ($conf2 (calculateConfidence 2 10 0.1))
     )
     (< $conf1 $conf2)) True)  ;; more features → higher confidence

!(assertEqual
   (let* (
       ($conf2 (calculateConfidence 2 10 0.1))
       ($conf3 (calculateConfidence 2 20 0.1))
     )
     (< $conf2 $conf3)) True)  ;; bigger dataset → higher confidence

!(assertEqual (calculateConfidence 1 0 0.1) 0.0)  ;; No features -> confidence 0
