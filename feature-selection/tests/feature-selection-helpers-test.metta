; !(register-module! ../../../metta-moses)
!(import! &self ../../../metta-moses/feature-selection/feature-selection-helpers)
!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/utilities/list-methods)

;; Test
!(assertEqual (List.at 0 (Cons True (Cons False Nil))) True)
!(assertEqual (List.at 1 (Cons True (Cons False Nil))) False)
!(assertEqual (List.at 2 (Cons True (Cons False Nil))) (Error Nil "Empty List"))
!(assertEqual (List.at 0 Nil) (Error Nil "Empty List"))

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
!(assertEqual (List.uniqueValuesCount Nil ()) ()) ;; ?? is this really what I expect? if the list is empty
!(assertEqual (List.uniqueValuesCount (Cons True (Cons False (Cons True Nil))) ()) ((True 2) (False 1)))
!(assertEqual (List.uniqueValuesCount (Cons False (Cons False (Cons True (Cons True (Cons True Nil))))) ()) ((False 2) (True 3)))
!(assertEqual (List.uniqueValuesCount (Cons True (Cons True (Cons True (Cons False Nil)))) ()) ((True 3) (False 1)))

;; Test
(= (itable) 
    (Cons (Cons True (Cons False (Cons True Nil))) 
    (Cons (Cons False (Cons True (Cons False Nil))) Nil)))

!(assertEqual (Table.getColumn 0 Nil) Nil)
!(assertEqual (Table.getColumn 0 (itable)) (Cons True (Cons False Nil)))
!(assertEqual (Table.getColumn 1 (itable)) (Cons False (Cons True Nil)))
!(assertEqual (Table.getColumn 2 (itable)) (Cons True (Cons False Nil)))

;; Testcase for Table.getOutputColumn
!(assertEqual
    (Table.getOutputColumn (mkITable (Cons (Cons True (Cons False (Cons False Nil))) 
                                      (Cons (Cons False (Cons True (Cons False Nil))) 
                                      (Cons (Cons True (Cons True (Cons False Nil))) 
                                      Nil)))
                                      (Cons A (Cons B (Cons O Nil)))))                              
    (Cons False (Cons False (Cons False Nil))))

;; Test
!(assertEqual (Table.pop 0 Nil) Nil)
!(assertEqual (Table.pop 0 (itable)) 
        (Cons (Cons False (Cons True Nil)) 
        (Cons (Cons True (Cons False Nil)) Nil)))

!(assertEqual (insertPair > (2 1) ((4 0) (1 3))) ((4 0) (2 1) (1 3)))                   ;; fist value is score and second one feature index
!(assertEqual (insertPair > (2 1) ((4 0) (2 4) (1 3))) ((4 0) (2 1) (2 4) (1 3)))       

!(assertEqual (marginalProbs 10 ((A 4) (B 6))) ((A 0.4) (B 0.6)))
!(assertEqual (marginalProbs 5 ((X 5))) ((X 1)))
!(assertEqual (marginalProbs 8 ((P 2) (Q 2) (R 4))) ((P 0.25) (Q 0.25) (R 0.5)))
!(assertEqual (marginalProbs 1 ((Z 1))) ((Z 1)))
!(assertEqual (marginalProbs 100 ()) ())

!(assertEqual (mutualInformation (Cons True (Cons False Nil)) (Cons True (Cons False Nil))) 1.0)
!(assertEqual (mutualInformation (Cons True (Cons True Nil)) (Cons False (Cons False Nil))) 0.0)
!(assertEqual (mutualInformation (Cons A (Cons B (Cons A Nil))) (Cons X (Cons Y (Cons X Nil)))) 0.918)
!(assertEqual (mutualInformation (Cons A (Cons A (Cons A Nil))) (Cons X (Cons Y (Cons Z Nil)))) 0.0)
!(assertEqual (mutualInformation (Cons A (Cons B (Cons C Nil))) (Cons X (Cons Y (Cons Z Nil)))) 1.585)

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
            (Cons (Cons True (Cons True (Cons False (Cons True (Cons True Nil)))))
            (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
            (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
            (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil)))))

!(assertEqual (zipColumn (1 3) (table2)) (Cons (True True) (Cons (False True) (Cons (True True) (Cons (False True) Nil)))))
!(assertEqual (zipColumn (0 1 4) (table2)) (Cons (True True True) (Cons (True False True) (Cons (False True False) (Cons (False False False) Nil)))))
!(assertEqual (zipColumn (2) (table2)) (Cons (False) (Cons (False) (Cons (False) (Cons (False) Nil))))) 

; !(assertEqual (let $r (logMath 2 8) (- $r 3))  0.0)
; !(assertEqual (let $r (logMath 10 1000) (- $r 3))  0.0)

(= (table1) 
    (mkITable
        (Cons (Cons True (Cons False (Cons True Nil))) 
        (Cons (Cons False (Cons True (Cons False Nil))) Nil))
        (Cons A (Cons B (Cons O Nil)))))

!(assertEqual (filterTable (0) (table1)) 
                    (mkITable 
                            (Cons (Cons False (Cons True Nil)) 
                            (Cons (Cons True (Cons False Nil)) Nil)) 
                            (Cons B (Cons O Nil)))) 
!(assertEqual (filterTable (1) (table1)) 
                    (mkITable 
                            (Cons (Cons True (Cons True Nil)) 
                            (Cons (Cons False (Cons False Nil)) Nil)) 
                            (Cons A (Cons O Nil)))) 
!(assertEqual (filterTable (0 1) (table1)) 
                    (mkITable 
                            (Cons (Cons True Nil)
                            (Cons (Cons False Nil) Nil))
                            (Cons O Nil)))

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

!(assertEqual (getInputLabels (Cons A (Cons B (Cons O Nil)))) (B A))                            
!(assertEqual (getInputLabels (Cons A Nil)) ())                            

!(assertEqual (fsToNames (Cons A (Cons B (Cons C Nil))) (1)) (B))
!(assertEqual (fsToNames (Cons A (Cons B (Cons C Nil))) ()) ())

!(assertEqual (readjustIndices ((0.9 (0 2))) (Cons A (Cons B (Cons C (Cons D Nil)))) (Cons A (Cons B (Cons C (Cons D Nil))))) ((0.9 (0 2))))
!(assertEqual (readjustIndices ((0.8 (0 1))) (Cons A (Cons C Nil)) (Cons A (Cons B (Cons C (Cons D Nil))))) ((0.8 (0 2))))
!(assertEqual (readjustIndices ((0.6 (0 2)) (0.4 (1))) (Cons B (Cons C (Cons D Nil))) (Cons A (Cons B (Cons C (Cons D Nil))))) ((0.6 (1 3)) (0.4 (2))))
!(assertEqual (readjustIndices ((0.4 (1)) (0.5 (1 2))) (Cons A (Cons C (Cons D Nil))) (Cons A (Cons B (Cons C (Cons D Nil))))) ((0.4 (2)) (0.5 (2 3))))


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