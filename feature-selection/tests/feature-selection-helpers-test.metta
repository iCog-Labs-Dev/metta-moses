!(register-module! ../../../metta-moses)
!(import! &self metta-moses:feature-selection:feature-selection-helpers)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:utilities:list-methods)

;; Test
! (assertEqual (List.at 0 (Cons True (Cons False Nil))) True)
! (assertEqual (List.at 1 (Cons True (Cons False Nil))) False)
! (assertEqual (List.at 2 (Cons True (Cons False Nil))) (Error (Cons True (Cons False Nil)) "Empty list"))
! (assertEqual (List.at 0 Nil) (Error Nil "Empty list"))

;; Test
! (assertEqual (patternExists (True 1) ()) False)
! (assertEqual (patternExists (True $x) ((False 2) (True 1))) True)
! (assertEqual (patternExists (False $x) ((True 7) (False 3))) True)
! (assertEqual (patternExists (False $x) ((False 2))) True)

;; Test
! (assertEqual (updateCount True ((True 1) (False 2))) ((True 2) (False 2)))  
! (assertEqual (updateCount False ((True 1) (False 1))) ((True 1) (False 2)))  
! (assertEqual (updateCount True ((False 5) (True 3))) ((False 5) (True 4)))  

;; Test
! (assertEqual (pairMax (foo 7) (bar 4)) (foo 7))
! (assertEqual (pairMax (alpha 3.5) (beta 3.5)) (alpha 3.5))
! (assertEqual (pairMax (x 1) (y 9)) (y 9))

;; Test
! (assertEqual (takeN 0 (True False True)) ())
! (assertEqual (takeN 2 (True False True)) (True False))
! (assertEqual (takeN 5 (True False)) (True False))
! (assertEqual (takeN 3 ()) ())

;; Test
! (assertEqual (List.uniqueValuesCount Nil ()) ()) ;; ?? is this really what I expect? if the list is empty
! (assertEqual (List.uniqueValuesCount (Cons True (Cons False (Cons True Nil))) ()) ((True 2) (False 1)))
! (assertEqual (List.uniqueValuesCount (Cons False (Cons False (Cons True (Cons True (Cons True Nil))))) ()) ((False 2) (True 3)))
! (assertEqual (List.uniqueValuesCount (Cons True (Cons True (Cons True (Cons False Nil)))) ()) ((True 3) (False 1)))

;; Test
! (bind! table 
    (Cons (Cons True (Cons False (Cons True Nil))) 
    (Cons (Cons False (Cons True (Cons False Nil))) Nil)))

! (assertEqual (Table.getColumn 0 Nil) Nil)
! (assertEqual (Table.getColumn 0 table) (Cons True (Cons False Nil)))
! (assertEqual (Table.getColumn 1 table) (Cons False (Cons True Nil)))
! (assertEqual (Table.getColumn 2 table) (Cons True (Cons False Nil)))

;; Test
! (assertEqual (Table.pop Nil) Nil)
! (assertEqual (Table.pop table) 
        (Cons (Cons False (Cons True Nil)) 
        (Cons (Cons True (Cons False Nil)) Nil)))

!(assertEqual (insertPair > (2 1) ((4 0) (1 3))) ((4 0) (2 1) (1 3)))                   ;; fist value is score and second one feature index
!(assertEqual (insertPair > (2 1) ((4 0) (2 4) (1 3))) ((4 0) (2 1) (2 4) (1 3)))       

! (assertEqual (marginalProbs 10 ((A 4) (B 6))) ((A 0.4) (B 0.6)))
! (assertEqual (marginalProbs 5 ((X 5))) ((X 1)))
! (assertEqual (marginalProbs 8 ((P 2) (Q 2) (R 4))) ((P 0.25) (Q 0.25) (R 0.5)))
! (assertEqual (marginalProbs 1 ((Z 1))) ((Z 1)))
! (assertEqual (marginalProbs 100 ()) ())

! (assertEqual (mutualInformation (Cons True (Cons False Nil)) (Cons True (Cons False Nil))) 1.0)
! (assertEqual (mutualInformation (Cons True (Cons True Nil)) (Cons False (Cons False Nil))) 0.0)
! (assertEqual (mutualInformation (Cons A (Cons B (Cons A Nil))) (Cons X (Cons Y (Cons X Nil)))) 0.918)
! (assertEqual (mutualInformation (Cons A (Cons A (Cons A Nil))) (Cons X (Cons Y (Cons Z Nil)))) 0.0)
! (assertEqual (mutualInformation (Cons A (Cons B (Cons C Nil))) (Cons X (Cons Y (Cons Z Nil)))) 1.585)


!(assertEqual (insertPair > (2 1) ((4 0) (1 3))) ((4 0) (2 1) (1 3)))                   ;; fist value is score and second one feature index
!(assertEqual (insertPair > (2 1) ((4 0) (2 4) (1 3))) ((4 0) (2 1) (2 4) (1 3)))       

! (assertEqual (isEqual (A B C) (A B C)) True)
! (assertEqual (isEqual (A B C) (C A B)) True)
! (assertEqual (isEqual (A B) (A B C)) False)
! (assertEqual (isEqual (A B) (A D)) False)

! (assertEqual (range 0 1 5) (0 1 2 3 4))
! (assertEqual (range 2 2 10) (2 4 6 8))
! (assertEqual (range 5 0 10) (Error 0 "Step value of 0 not allowed!!"))
! (assertEqual (range 10 1 5) ())

! (assertEqual (isPairEqual ((A B) 3) ((B A) 3)) True)
! (assertEqual (isPairEqual ((A B C) 5) ((C B A) 5)) True)
! (assertEqual (isPairEqual ((A B C) 4) ((C B A) 5)) False)
! (assertEqual (isPairEqual ((A B) 4) ((B A) 3)) False)
! (assertEqual (isPairEqual ((X Y Z) 2) ((X Y W) 2)) False)

! (assertTrue (isEqual (shuffle (A B C) ()) (A B C)))
! (assertTrue (isEqual (shuffle (X Y) ()) (X Y)))
! (assertTrue (isEqual (shuffle () ()) ()))
! (assertTrue (isEqual (shuffle (1 2 3 4) ()) (1 2 3 4)))

! (assertEqual (sortPairs pairMax (((A) 0.2) ((B) 0.8) ((C) 0.6) ((D) 0.4)) 2 ()) (((B) 0.8) ((C) 0.6)))
! (assertEqual (sortPairs pairMax (((X) 0.9) ((Y) 0.1) ((Z) 0.5)) 1 ()) (((X) 0.9)))
! (assertEqual (sortPairs pairMax (((P) 0.3) ((Q) 0.3) ((R) 0.2)) 2 ()) (((P) 0.3) ((Q) 0.3)))
! (assertEqual (sortPairs pairMax (((M) 0.7) ((N) 0.4) ((O) 0.9) ((P) 0.1)) 3 ()) (((O) 0.9) ((M) 0.7) ((N) 0.4)))

! (bind! table 
            (Cons (Cons True (Cons True (Cons False (Cons True (Cons True Nil)))))
            (Cons (Cons True (Cons False (Cons False (Cons True (Cons True Nil)))))
            (Cons (Cons False (Cons True (Cons False (Cons True (Cons False Nil)))))
            (Cons (Cons False (Cons False (Cons False (Cons True (Cons False Nil))))) Nil)))))

! (assertEqual (zipColumn (1 3) table) (Cons (True True) (Cons (False True) (Cons (True True) (Cons (False True) Nil)))))
! (assertEqual (zipColumn (0 1 4) table) (Cons (True True True) (Cons (True False True) (Cons (False True False) (Cons (False False False) Nil)))))
! (assertEqual (zipColumn (2) table) (Cons (False) (Cons (False) (Cons (False) (Cons (False) Nil))))) 

! (assertEqual (logMath 2 8)  3)
! (assertEqual (logMath 10 1000)  3)
