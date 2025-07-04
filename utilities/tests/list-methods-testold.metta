
!(register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:representation:instance)
!(import! &self metta-moses:scoring:cscore)


;; Test cases for List.foldr
!(assertEqual (List.foldr + 0 (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil))))) 10)
!(assertEqual (List.foldr * 1 (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil))))) 24)
!(assertEqual (List.foldr - 0 (Cons 10 (Cons 5 (Cons 2 Nil)))) 7)  


;; Test cases for List.foldr
!(assertEqual (List.foldl + 0 (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil))))) 10)
!(assertEqual (List.foldl * 1 (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil))))) 24)
!(assertEqual (List.foldl - 0 (Cons 10 (Cons 5 (Cons 2 Nil)))) 7)

;; Test cases for List.sum
!(assertEqual (List.sum (Cons 1 (Cons 2 (Cons 3 (Cons 2 (Cons 3 Nil)))))) 11)
!(assertEqual (List.sum (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil))))) 10)
!(assertEqual (List.sum (Cons 3.0 (Cons 4.0 (Cons 5.0 (Cons 5.0 (Cons 5.0 (Cons 5.0 (Cons 4.0 (Cons 5.0 (Cons 4.0 (Cons 4.0 (Cons 4.0 (Cons 5.0 (Cons 5.0 (Cons 4.0 (Cons 5.0 (Cons 5.0 (Cons 5.0 (Cons 4.0 (Cons 5.0 (Cons 5.0 (Cons 5.0 (Cons 5.0 (Cons 5.0 (Cons 4.0 (Cons 5.0 (Cons 4.0 Nil))))))))))))))))))))))))))) 119)

;; Test cases for List.append
!(assertEqual (List.append 3 (Cons 1 (Cons 2 Nil))) (Cons 1 (Cons 2 (Cons 3 Nil))))
!(assertEqual (List.append 4 (Cons 2 (Cons 3 Nil))) (Cons 2 (Cons 3 (Cons 4 Nil))))
!(assertEqual (List.append 10 (Cons 5 (Cons 6 (Cons 7 Nil)))) (Cons 5 (Cons 6 (Cons 7 (Cons 10 Nil)))))

;; Test cases for List.getByIdx
!(assertEqual (List.getByIdx (Cons 1 (Cons 2 (Cons 3 Nil))) 0) 1)
!(assertEqual (List.getByIdx (Cons 10 (Cons 20 (Cons 30 Nil))) 1) 20)
!(assertEqual (List.getByIdx (Cons 100 (Cons 200 (Cons 300 Nil))) 0) 100)
!(assertEqual (List.getByIdx (Cons 1 (Cons 2 (Cons 3 (Cons 4 (Cons 5 (Cons 6 (Cons 7 (Cons 8 (Cons 9 (Cons 10 (Cons 11 (Cons 12 (Cons 13 (Cons 14 (Cons 15 (Cons 16 (Cons 17 (Cons 18 (Cons 19 (Cons 20 Nil)))))))))))))))))))) 0) 1)

;; Test cases for List.insert
!(assertEqual (List.insert 2 (Cons 1 (Cons 3 (Cons 4 Nil)))) (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))))
!(assertEqual (List.insert 5 (Cons 2 (Cons 3 (Cons 7 Nil)))) (Cons 2 (Cons 3 (Cons 5 (Cons 7 Nil)))))
!(assertEqual (List.insert 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))))

;; Test cases for List.sort
!(assertEqual (List.sort (Cons 3 (Cons 2 (Cons 3 Nil)))) (Cons 2 (Cons 3 (Cons 3 Nil))))
!(assertEqual (List.sort (Cons 5 (Cons 3 (Cons 1 (Cons 4 Nil))))) (Cons 1 (Cons 3 (Cons 4 (Cons 5 Nil)))))
!(assertEqual (List.sort (Cons 9 (Cons 7 (Cons 8 (Cons 6 Nil))))) (Cons 6 (Cons 7 (Cons 8 (Cons 9 Nil)))))


;; Test cases for List.length
!(assertEqual (List.length (Cons 1 (Cons 2 (Cons 3 Nil)))) 3)
!(assertEqual (List.length (Cons 10 (Cons 20 (Cons 30 (Cons 40 Nil))))) 4)
!(assertEqual (List.length (Cons 1 (Cons 2 (Cons 3 (Cons 4 (Cons 5 (Cons 6 (Cons 7 (Cons 8 (Cons 9 (Cons 10 (Cons 11 (Cons 12 (Cons 13 (Cons 14 (Cons 15 (Cons 16 (Cons 17 (Cons 18 (Cons 19 (Cons 20 Nil))))))))))))))))))))) 20)

;; Test cases for List.map
!(assertEqual (List.map isEven (Cons 1 (Cons 2 (Cons 3 Nil)))) (Cons False (Cons True (Cons False Nil))))
!(assertEqual (List.map isOdd Nil) Nil)


;; Test cases for List.filter
!(assertEqual (List.filter isEven (Cons 1 (Cons 2 (Cons 3 Nil)))) (Cons 2 Nil))
!(assertEqual (List.filter isOdd (Cons 2 (Cons 2 (Cons 4 Nil)))) Nil)
!(assertEqual (List.filter isOdd Nil) Nil)


;; Test cases for List.listToExpr
!(assertEqual (List.listToExpr Nil) ())
!(assertEqual (List.listToExpr (Cons 1 (Cons 3 (Cons 4 Nil)))) (1 3 4))

;; Test cases for List.max
!(assertEqual (List.max >= (Cons 2 (Cons 5 (Cons 1 Nil)))) 5)
!(assertEqual (List.max >= (Cons 42 Nil)) 42)
!(assertEqual (List.max >>= (Cons (mkSize 1) (Cons (mkSize 3) (Cons (mkSize 2) Nil)))) (mkSize 3))

;; Test cases for List.contains
!(assertEqual (List.contains 2 (Cons 1 (Cons 2 (Cons 3 Nil)))) True)
!(assertEqual (List.contains 4 (Cons 1 (Cons 2 (Cons 3 Nil)))) False)
!(assertEqual (List.contains 1 Nil) False)

;; Test cases for List.replaceAt
!(assertEqual (List.replaceAt (Cons 1 (Cons 2 (Cons 3 Nil))) 0 9) (Cons 9 (Cons 2 (Cons 3 Nil))))
!(assertEqual (List.replaceAt (Cons 1 (Cons 2 (Cons 3 Nil))) 1 9) (Cons 1 (Cons 9 (Cons 3 Nil))))
!(assertEqual (List.replaceAt Nil 0 5) Nil)

;; Test case for List.prepend
!(assertEqual (List.prepend 0 Nil) (Cons 0 Nil))
!(assertEqual (List.prepend 0 (Cons 1 Nil)) (Cons 0 (Cons 1 Nil)))
!(assertEqual (List.prepend 0 (Cons 1 (Cons 2 Nil))) (Cons 0 (Cons 1 (Cons 2 Nil))))

;; Test case of List.index
!(assertEqual (List.index Nil A) -1)
!(assertEqual (List.index (Cons A (Cons B (Cons C Nil))) A) 0)
!(assertEqual (List.index (Cons B (Cons C Nil)) A) -1)
!(assertEqual (List.index (Cons D (Cons B (Cons C (Cons A Nil)))) A) 3)
!(assertEqual (List.index (Cons D (Cons A (Cons C Nil))) A) 1)
!(assertEqual (List.index (Cons D (Cons A (Cons A Nil))) A) 1)

;; Test case for List.head
!(assertEqual (List.head Nil) (Error Nil EmptyList))
!(assertEqual (List.head (Cons 1 (Cons 2 Nil))) 1)

;; Test case for List.tail
!(assertEqual (List.tail Nil) Nil)
!(assertEqual (List.tail (Cons 1 (Cons 2 Nil))) (Cons 2 Nil))

;; Test case for List.sub
!(assertEqual (List.sub (Cons 1 (Cons 3 Nil)) (Cons 0 (Cons 3 Nil))) (Cons 1 (Cons 0 Nil)))
!(assertEqual (List.sub (Cons 1 (Cons 3 Nil)) (Cons 0 (Cons 3 (Cons 2 Nil)))) (Error (Cons 2 Nil) LenghtOfListNotEqual))

;; Test case for List.zip
!(assertEqual (List.zip (Cons 1 (Cons 2 Nil)) (Cons A (Cons B Nil))) (Cons (1 A) (Cons (2 B) Nil)))
!(assertEqual (List.zip (Cons False (Cons True Nil)) (Cons A (Cons B Nil))) (Cons (False A) (Cons (True B) Nil)))
!(assertEqual (List.zip (Cons False (Cons True Nil)) (Cons A Nil)) (Cons (False A) Nil))
!(assertEqual (List.zip (Cons False Nil) (Cons A (Cons A (Cons B Nil)))) (Cons (False A) Nil))

;; Test case for List.zipWith
!(assertEqual (List.zipWith == (Cons 1 (Cons 2 Nil)) (Cons A (Cons B Nil))) (Cons False (Cons False Nil)))
!(assertEqual (List.zipWith == (Cons False (Cons True Nil)) (Cons A (Cons B Nil))) (Cons False (Cons False Nil)))
!(assertEqual (List.zipWith == (Cons False (Cons True Nil)) (Cons A Nil)) (Cons False Nil))
!(assertEqual (List.zipWith == (Cons False Nil) (Cons A (Cons A (Cons B Nil)))) (Cons False Nil))

;; Test case for List.drop
!(assertEqual (List.drop 5 (Cons A (Cons B Nil))) Nil)
!(assertEqual (List.drop 1 (Cons A (Cons B Nil))) (Cons B Nil))
!(assertEqual (List.drop 2 (Cons A (Cons B (Cons C Nil)))) (Cons C Nil))

;; Test case for List.flatten
!(assertEqual (List.flatten (Cons (Cons 1 Nil) (Cons (Cons 2 Nil) Nil))) (Cons 1 (Cons 2 Nil)))
!(assertEqual (List.flatten (Cons (Cons 1 Nil) (Cons (Cons 2 (Cons 3 Nil)) Nil))) (Error (Cons 2 (Cons 3 Nil)) "Can't be flattened"))

;; Test case for List.repeat
!(assertEqual (List.repeat 0 0) Nil)
!(assertEqual (List.repeat 3 0) (Cons 0 (Cons 0 (Cons 0 Nil))))

;; Test cases for List.concat
!(assertEqual (List.concat (Cons 1 (Cons 2 Nil)) (Cons 3 (Cons 4 Nil))) (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))))
!(assertEqual (List.concat (Cons 5 (Cons 6 (Cons 7 Nil))) (Cons 8 Nil)) (Cons 5 (Cons 6 (Cons 7 (Cons 8 Nil)))))
!(assertEqual (List.concat Nil (Cons 10 (Cons 11 (Cons 12 Nil)))) (Cons 10 (Cons 11 (Cons 12 Nil))))

;; Test cases for List.removeAtIdx
!(assertEqual (List.removeAtIdx (Cons 1 (Cons 2 (Cons 3 Nil))) 0) (Cons 2 (Cons 3 Nil)))
!(assertEqual (List.removeAtIdx (Cons 1 (Cons 2 (Cons 3 Nil))) 1) (Cons 1 (Cons 3 Nil)))
!(assertEqual (List.removeAtIdx (Cons 1 (Cons 2 (Cons 3 Nil))) 3) (Cons 1 (Cons 2 (Cons 3 Nil))))

;; Test cases for List.isMember
!(assertEqual (List.isMember 2 (Cons 1 (Cons 2 (Cons 3 Nil)))) True)
!(assertEqual (List.isMember 4 (Cons 1 (Cons 2 (Cons 3 Nil)))) False)

;; List.partialSort -- for list of Scored instances
! (assertEqual (List.partialSort instance>=
                            (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore 1 2 3 4 15)))
                                (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 1 2 3 4 5)))
                                (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 1 2 3 4 0.5))) Nil))) 2 Nil)
                                    
                                (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore 1 2 3 4 15))) 
                                        (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 1 2 3 4 5)))
                                        (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 1 2 3 4 0.5))) Nil))))

! (assertEqual (List.partialSort instance>=
                        (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 1 1.0 0.5 -3.5)))
                            (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore -1.0 2 1.0 0.5 -2.5)))
                            (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore -3.0 3 1.0 0.5 -4.5))) Nil)))2 Nil)
    
      (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore -1.0 2 1.0 0.5 -2.5)))
        (Cons  (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 1 1.0 0.5 -3.5)))
            (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore -3.0 3 1.0 0.5 -4.5))) Nil))))

! (assertEqual (List.partialSort instance>=
      (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 3 1.0 0.5 -3.5)))
        (Cons  (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 2 1.0 0.5 -3.5)))
          (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 1 1.0 0.5 -3.5))) Nil))) 2 Nil)
    
          (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 1 1.0 0.5 -3.5)))
                (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 2 1.0 0.5 -3.5)))
                    (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 3 1.0 0.5 -3.5))) Nil))))

! (assertEqual (List.partialSort instance>=
                                (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore -3.0 2 1.0 0.5 -4.5)))
                                    (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore -1.0 3 1.0 0.5 -2.5)))
                                        (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 1 1.0 0.5 -3.5))) Nil))) 2 Nil)
            (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore -1.0 3 1.0 0.5 -2.5)))
                (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 1 1.0 0.5 -3.5)))
                    (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore -3.0 2 1.0 0.5 -4.5))) Nil))))   

;; For list of numbers             
! (assertEqual (List.partialSort (Cons 5 (Cons 1 (Cons 8 (Cons 3 Nil)))) 2 Nil) 
                                (Cons 8 (Cons 5 (Cons 1 (Cons 3 Nil)))) )
! (assertEqual (List.partialSort (Cons -4 (Cons -3 (Cons -2 (Cons -1 Nil)))) 2 Nil) 
                                    (Cons -1 (Cons -2 (Cons -4 (Cons -3 Nil)))))
! (assertEqual (List.partialSort (Cons 5 (Cons 1 (Cons 8 (Cons 3 (Cons 1 (Cons 7 Nil)))))) 3 Nil) 
                                (Cons 8 (Cons 7 (Cons 5 (Cons 1 (Cons 3 (Cons 1 Nil)))))))

;; For List.takeN 
! (assertEqual (List.takeN 2 (Cons 2 (Cons 1 (Cons 3 Nil)))) (Cons 2 (Cons 1 Nil)))                                 
! (assertEqual (List.takeN 0 (Cons 2 (Cons 1 (Cons 3 Nil)))) Nil)                                 

;; List.takeNFrom test cases
! (assertEqual (List.takeNFrom 2 3 (Cons 0 (Cons 1 (Cons 2 (Cons 3 (Cons 4 (Cons 5 Nil)))))))
               (Cons 2 (Cons 3 (Cons 4 Nil))))
! (assertEqual (List.takeNFrom 0 3 (Cons 0 (Cons 1 (Cons 2 (Cons 3 (Cons 4 (Cons 5 Nil)))))))
               (Cons 0 (Cons 1 (Cons 2 Nil))))
! (assertEqual (List.takeNFrom 3 2 (Cons 0 (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil))))))
               (Cons 3 (Cons 4 Nil)))
! (assertEqual (List.takeNFrom 4 3 (Cons 0 (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil))))))
               (Cons 4 Nil))
! (assertEqual (List.takeNFrom 10 2 (Cons 0 (Cons 1 (Cons 2 (Cons 3 Nil)))))
               Nil)
! (assertEqual (List.takeNFrom 2 0 (Cons 0 (Cons 1 (Cons 2 (Cons 3 Nil)))))
               Nil)
! (assertEqual (List.takeNFrom 0 2 Nil)
               Nil)
! (assertEqual (List.takeNFrom 4 1 (Cons 0 (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil))))))
               (Cons 4 Nil))
! (assertEqual (List.takeNFrom 2 10 (Cons 0 (Cons 1 (Cons 2 (Cons 3 Nil)))))
               (Cons 2 (Cons 3 Nil)))
! (assertEqual (List.takeNFrom 2 10 (Cons 0 (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil))))))
               (Cons 2 (Cons 3 (Cons 4 Nil))))

;; List.generate test cases
!(assertEqual (List.generate 3 5) (Cons 5 (Cons 5 (Cons 5 Nil))))  
!(assertEqual (List.generate 5 3) (Cons 3 (Cons 3 (Cons 3 (Cons 3 (Cons 3 Nil))))))
!(assertEqual (List.generate 0 3) Nil)
!(assertEqual (List.generate 3 0) (Cons 0 (Cons 0 (Cons 0 Nil))))