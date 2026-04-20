!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/utilities/list-methods)
!(import! &self ../../../metta-moses/representation/instance)
!(import! &self ../../../metta-moses/scoring/cscore)



;; Test cases for List.foldr
!(assertEqual (List.foldr + 0 (cons 1 (cons 2 (cons 3 (cons 4 ()))))) 10)
!(assertEqual (List.foldr * 1 (cons 1 (cons 2 (cons 3 (cons 4 ()))))) 24)
!(assertEqual (List.foldr - 0 (cons 10 (cons 5 (cons 2 ())))) 7)  


;; Test cases for List.foldr
!(assertEqual (List.foldl + 0 (cons 1 (cons 2 (cons 3 (cons 4 ()))))) 10)
!(assertEqual (List.foldl * 1 (cons 1 (cons 2 (cons 3 (cons 4 ()))))) 24)
!(assertEqual (List.foldl - 0 (cons 10 (cons 5 (cons 2 ())))) 7)

;; Test cases for List.sum

!(assertEqual (List.sum (cons 1 (cons 2 (cons 3 (cons 2 (cons 3 ())))))) 11)
!(assertEqual (List.sum (cons 1 (cons 2 (cons 3 (cons 4 ()))))) 10)
!(assertEqual (List.sum (cons 3.0 (cons 4.0 (cons 5.0 (cons 5.0 (cons 5.0 (cons 5.0 (cons 4.0 (cons 5.0 (cons 4.0 (cons 4.0 (cons 4.0 (cons 5.0 (cons 5.0 (cons 4.0 (cons 5.0 (cons 5.0 (cons 5.0 (cons 4.0 (cons 5.0 (cons 5.0 (cons 5.0 (cons 5.0 (cons 5.0 (cons 4.0 (cons 5.0 (cons 4.0 ()))))))))))))))))))))))))))) 119.0)


;; Test cases for List.append
!(assertEqual (List.append 3 (cons 1 (cons 2 ()))) (cons 1 (cons 2 (cons 3 ()))))
!(assertEqual (List.append 4 (cons 2 (cons 3 ()))) (cons 2 (cons 3 (cons 4 ()))))
!(assertEqual (List.append 10 (cons 5 (cons 6 (cons 7 ())))) (cons 5 (cons 6 (cons 7 (cons 10 ())))))

;; Test cases for List.getByIdx
!(assertEqual (List.getByIdx (cons 1 (cons 2 (cons 3 ()))) 0) 1)
!(assertEqual (List.getByIdx (cons 10 (cons 20 (cons 30 ()))) 1) 20)
!(assertEqual (List.getByIdx (cons 100 (cons 200 (cons 300 ()))) 0) 100)
!(assertEqual (List.getByIdx (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 (cons 6 (cons 7 (cons 8 (cons 9 (cons 10 (cons 11 (cons 12 (cons 13 (cons 14 (cons 15 (cons 16 (cons 17 (cons 18 (cons 19 (cons 20 ())))))))))))))))))))) 0) 1)

;; Test cases for List.insert
!(assertEqual (List.insert 2 (cons 1 (cons 3 (cons 4 ())))) (cons 1 (cons 2 (cons 3 (cons 4 ())))))
!(assertEqual (List.insert 5 (cons 2 (cons 3 (cons 7 ())))) (cons 2 (cons 3 (cons 5 (cons 7 ())))))
!(assertEqual (List.insert 1 (cons 2 (cons 3 (cons 4 ())))) (cons 1 (cons 2 (cons 3 (cons 4 ())))))

;; Test cases for List.sort
!(assertEqual (List.sort (cons 3 (cons 2 (cons 3 ())))) (cons 2 (cons 3 (cons 3 ()))))
!(assertEqual (List.sort (cons 5 (cons 3 (cons 1 (cons 4 ()))))) (cons 1 (cons 3 (cons 4 (cons 5 ())))))
!(assertEqual (List.sort (cons 9 (cons 7 (cons 8 (cons 6 ()))))) (cons 6 (cons 7 (cons 8 (cons 9 ())))))
!(assertEqual (List.sort (cons 9 (cons 7 (cons 8 (cons 6 ())))) >) (cons 9 (cons 8 (cons 7 (cons 6 ())))))
;; Test cases for List.length
!(assertEqual (List.length (cons 1 (cons 2 (cons 3 ())))) 3)
!(assertEqual (List.length (cons 10 (cons 20 (cons 30 (cons 40 ()))))) 4)
!(assertEqual (List.length (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 (cons 6 (cons 7 (cons 8 (cons 9 (cons 10 (cons 11 (cons 12 (cons 13 (cons 14 (cons 15 (cons 16 (cons 17 (cons 18 (cons 19 (cons 20 ()))))))))))))))))))))) 20)

;; Test cases for List.map
!(assertEqual (List.map isEven (cons 1 (cons 2 (cons 3 ())))) (cons False (cons True (cons False ()))))
!(assertEqual (List.map isOdd ()) ())

!(assertEqual (List.mapOverArg $f () $arg) ())
!(assertEqual (List.mapOverArg + (cons 1 ()) 1) (cons 2 ()))

;; Test cases for List.filter
!(assertEqual (List.filter isEven (cons 1 (cons 2 (cons 3 ())))) (cons 2 ()))
!(assertEqual (List.filter isOdd (cons 2 (cons 2 (cons 4 ())))) ())
!(assertEqual (List.filter isOdd ()) ())


;; Test cases for List.listToExpr
!(assertEqual (List.listToExpr ()) ())
!(assertEqual (List.listToExpr (cons 1 (cons 3 (cons 4 ())))) (1 3 4))

;; Test cases for List.max
!(assertEqual (List.max >= (cons 2 (cons 5 (cons 1 ())))) 5)
!(assertEqual (List.max >= (cons 42 ())) 42)
!(assertEqual (List.max >>= (cons (mkSize 1) (cons (mkSize 3) (cons (mkSize 2) ())))) (mkSize 3))

;; Test cases for List.contains
!(assertEqual (List.contains 2 (cons 1 (cons 2 (cons 3 ())))) True)
!(assertEqual (List.contains 4 (cons 1 (cons 2 (cons 3 ())))) False)
!(assertEqual (List.contains 1 ()) False)

;; Test cases for List.replaceAt
!(assertEqual (List.replaceAt (cons 1 (cons 2 (cons 3 ()))) 0 9) (cons 9 (cons 2 (cons 3 ()))))
!(assertEqual (List.replaceAt (cons 1 (cons 2 (cons 3 ()))) 1 9) (cons 1 (cons 9 (cons 3 ()))))
!(assertEqual (List.replaceAt () 0 5) ())

;; Test case for List.prepend
!(assertEqual (List.prepend 0 ()) (cons 0 ()))
!(assertEqual (List.prepend 0 (cons 1 ())) (cons 0 (cons 1 ())))
!(assertEqual (List.prepend 0 (cons 1 (cons 2 ()))) (cons 0 (cons 1 (cons 2 ()))))

;; Test case of List.index
!(assertEqual (List.index () A) -1)
!(assertEqual (List.index (cons A (cons B (cons C ()))) A) 0)
!(assertEqual (List.index (cons B (cons C ())) A) -1)
!(assertEqual (List.index (cons D (cons B (cons C (cons A ())))) A) 3)
!(assertEqual (List.index (cons D (cons A (cons C ()))) A) 1)
!(assertEqual (List.index (cons D (cons A (cons A ()))) A) 1)

;; Test case for List.head
!(assertEqual (List.head ()) (Error () EmptyList))
!(assertEqual (List.head (cons 1 (cons 2 ()))) 1)

;; Test case for List.tail
!(assertEqual (List.tail ()) ())
!(assertEqual (List.tail (cons 1 (cons 2 ()))) (cons 2 ()))


; ;; Test case for List.sub
!(assertEqual (List.sub (cons 1 (cons 3 ())) (cons 0 (cons 3 ()))) (cons 1 (cons 0 ())))

!(assertEqual (List.sub (cons 1 (cons 3 ())) (cons 0 (cons 3 (cons 2 ())))) (Error (cons 2 ()) LenghtOfListNotEqual))

;; Test case for List.zip
!(assertEqual (List.zip (cons 1 (cons 2 ())) (cons A (cons B ()))) (cons (1 A) (cons (2 B) ())))
!(assertEqual (List.zip (cons False (cons True ())) (cons A (cons B ()))) (cons (False A) (cons (True B) ())))
!(assertEqual (List.zip (cons False (cons True ())) (cons A ())) (cons (False A) ()))
!(assertEqual (List.zip (cons False ()) (cons A (cons A (cons B ())))) (cons (False A) ()))

;; Test case for List.zipWith
!(assertEqual (List.zipWith == (cons 1 (cons 2 ())) (cons A (cons B ()))) (cons False (cons False ())))
!(assertEqual (List.zipWith == (cons False (cons True ())) (cons A (cons B ()))) (cons False (cons False ())))
!(assertEqual (List.zipWith == (cons False (cons True ())) (cons A ())) (cons False ()))
!(assertEqual (List.zipWith == (cons False ()) (cons A (cons A (cons B ())))) (cons False ()))

;; Test case for List.drop
!(assertEqual (List.drop 5 (cons A (cons B ()))) ())
!(assertEqual (List.drop 1 (cons A (cons B ()))) (cons B ()))
!(assertEqual (List.drop 2 (cons A (cons B (cons C ())))) (cons C ()))


; ;; Test case for List.flatten

!(assertEqual (List.flatten (cons (cons 1 ()) (cons (cons 2 ()) ()))) (cons 1 (cons 2 ())))
!(assertEqual (List.flatten (cons (cons 1 ()) (cons (cons 2 (cons 3 ())) ()))) (Error (cons 2 (cons 3 ())) "Can't be flattened"))

;; Test case for List.repeat
!(assertEqual (List.repeat 0 0) ())
!(assertEqual (List.repeat 3 0) (cons 0 (cons 0 (cons 0 ()))))

;; Test cases for List.concat
!(assertEqual (List.concat (cons 1 (cons 2 ())) (cons 3 (cons 4 ()))) (cons 1 (cons 2 (cons 3 (cons 4 ())))))
!(assertEqual (List.concat (cons 5 (cons 6 (cons 7 ()))) (cons 8 ())) (cons 5 (cons 6 (cons 7 (cons 8 ())))))
!(assertEqual (List.concat () (cons 10 (cons 11 (cons 12 ())))) (cons 10 (cons 11 (cons 12 ()))))

;; Test cases for List.removeAtIdx
!(assertEqual (List.removeAtIdx (cons 1 (cons 2 (cons 3 ()))) 0) (cons 2 (cons 3 ())))
!(assertEqual (List.removeAtIdx (cons 1 (cons 2 (cons 3 ()))) 1) (cons 1 (cons 3 ())))
!(assertEqual (List.removeAtIdx (cons 1 (cons 2 (cons 3 ()))) 3) (cons 1 (cons 2 (cons 3 ()))))

;; Test cases for List.isMember
!(assertEqual (List.isMember 2 (cons 1 (cons 2 (cons 3 ())))) True)
!(assertEqual (List.isMember 4 (cons 1 (cons 2 (cons 3 ())))) False)

;; List.partialSort -- for list of Scored instances

!(assertEqual (List.partialSort <= (cons 3 (cons 2 (cons 1 ()))) 0 ()) (cons 1 (cons 3 (cons 2 ()))))
!(assertEqual (List.partialSort instance>
                            (cons (mkSInst (mkPair (mkInst ()) (mkCscore 1 2 3 4 15)))
                                (cons (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore 1 2 3 4 5)))
                                (cons (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore 1 2 3 4 0.5))) ()))) 2 ())
                                    
                                (cons (mkSInst (mkPair (mkInst ()) (mkCscore 1 2 3 4 15))) 
                                        (cons (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore 1 2 3 4 5)))
                                        (cons (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore 1 2 3 4 0.5))) ()))))

!(assertEqual (List.partialSort instance>
                        (cons (mkSInst (mkPair (mkInst ()) (mkCscore -2.0 1 1.0 0.5 -3.5)))
                            (cons (mkSInst (mkPair (mkInst ()) (mkCscore -1.0 2 1.0 0.5 -2.5)))
                            (cons (mkSInst (mkPair (mkInst ()) (mkCscore -3.0 3 1.0 0.5 -4.5))) ())))2 ())
    
      (cons (mkSInst (mkPair (mkInst ()) (mkCscore -1.0 2 1.0 0.5 -2.5)))
        (cons  (mkSInst (mkPair (mkInst ()) (mkCscore -2.0 1 1.0 0.5 -3.5)))
            (cons (mkSInst (mkPair (mkInst ()) (mkCscore -3.0 3 1.0 0.5 -4.5))) ()))))

!(assertEqual (List.partialSort instance>
      (cons (mkSInst (mkPair (mkInst ()) (mkCscore -2.0 3 1.0 0.5 -3.5)))
        (cons  (mkSInst (mkPair (mkInst ()) (mkCscore -2.0 2 1.0 0.5 -3.5)))
          (cons (mkSInst (mkPair (mkInst ()) (mkCscore -2.0 1 1.0 0.5 -3.5))) ()))) 2 ())
    
          (cons (mkSInst (mkPair (mkInst ()) (mkCscore -2.0 1 1.0 0.5 -3.5)))
                (cons (mkSInst (mkPair (mkInst ()) (mkCscore -2.0 2 1.0 0.5 -3.5)))
                    (cons (mkSInst (mkPair (mkInst ()) (mkCscore -2.0 3 1.0 0.5 -3.5))) ()))))

!(assertEqual (List.partialSort instance>
                                (cons (mkSInst (mkPair (mkInst ()) (mkCscore -3.0 2 1.0 0.5 -4.5)))
                                    (cons (mkSInst (mkPair (mkInst ()) (mkCscore -1.0 3 1.0 0.5 -2.5)))
                                        (cons (mkSInst (mkPair (mkInst ()) (mkCscore -2.0 1 1.0 0.5 -3.5))) ()))) 2 ())
            (cons (mkSInst (mkPair (mkInst ()) (mkCscore -1.0 3 1.0 0.5 -2.5)))
                (cons (mkSInst (mkPair (mkInst ()) (mkCscore -2.0 1 1.0 0.5 -3.5)))
                    (cons (mkSInst (mkPair (mkInst ()) (mkCscore -3.0 2 1.0 0.5 -4.5))) ()))))   

;; For list of numbers             
!(assertEqual (List.partialSort (cons 5 (cons 1 (cons 8 (cons 3 ())))) 2 ()) 
                                (cons 8 (cons 5 (cons 1 (cons 3 ())))) )
!(assertEqual (List.partialSort (cons -4 (cons -3 (cons -2 (cons -1 ())))) 2 ()) 
                                    (cons -1 (cons -2 (cons -4 (cons -3 ())))))
!(assertEqual (List.partialSort (cons 5 (cons 1 (cons 8 (cons 3 (cons 1 (cons 7 ())))))) 3 ()) 
                                (cons 8 (cons 7 (cons 5 (cons 1 (cons 3 (cons 1 ())))))))

;; For List.takeN 
!(assertEqual (List.takeN 2 (cons 2 (cons 1 (cons 3 ())))) (cons 2 (cons 1 ())))                                 
!(assertEqual (List.takeN 0 (cons 2 (cons 1 (cons 3 ())))) ())                                 

;; List.takeNFrom test cases
!(assertEqual (List.takeNFrom 2 3 (cons 0 (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 ())))))))
               (cons 2 (cons 3 (cons 4 ()))))
!(assertEqual (List.takeNFrom 0 3 (cons 0 (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 ())))))))

               (cons 0 (cons 1 (cons 2 ()))))

!(assertEqual (List.takeNFrom 3 2 (cons 0 (cons 1 (cons 2 (cons 3 (cons 4 ()))))))
               (cons 3 (cons 4 ())))
!(assertEqual (List.takeNFrom 4 3 (cons 0 (cons 1 (cons 2 (cons 3 (cons 4 ()))))))
               (cons 4 ()))
!(assertEqual (List.takeNFrom 10 2 (cons 0 (cons 1 (cons 2 (cons 3 ())))))
               ())
!(assertEqual (List.takeNFrom 2 0 (cons 0 (cons 1 (cons 2 (cons 3 ())))))
               ())
!(assertEqual (List.takeNFrom 0 2 ())
               ())
!(assertEqual (List.takeNFrom 4 1 (cons 0 (cons 1 (cons 2 (cons 3 (cons 4 ()))))))
               (cons 4 ()))
!(assertEqual (List.takeNFrom 2 10 (cons 0 (cons 1 (cons 2 (cons 3 ())))))
               (cons 2 (cons 3 ())))
!(assertEqual (List.takeNFrom 2 10 (cons 0 (cons 1 (cons 2 (cons 3 (cons 4 ()))))))
               (cons 2 (cons 3 (cons 4 ()))))

;; List.generate test cases
!(assertEqual (List.generate 3 5) (cons 5 (cons 5 (cons 5 ()))))  
!(assertEqual (List.generate 5 3) (cons 3 (cons 3 (cons 3 (cons 3 (cons 3 ()))))))
!(assertEqual (List.generate 0 3) ())
!(assertEqual (List.generate 3 0) (cons 0 (cons 0 (cons 0 ()))))

;; Normal removal from head
!(assertEqual (List.pop 0 (cons 1 (cons 2 (cons 3 ())))) (cons 2 (cons 3 ())))
!(assertEqual (List.pop 1 (cons 1 (cons 2 (cons 3 ())))) (cons 1 (cons 3 ())))
!(assertEqual (List.pop 0 (cons 42 ())) ())
!(assertEqual (List.pop 0 ()) (Error () EmptyList))

!(assertEqual (List.splitAt 1 (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 ())))))) ((cons 1 ()) (cons 2 (cons 3 (cons 4 (cons 5 ()))))))
!(assertEqual (List.splitAt 0 (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 ())))))) (() (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 ())))))))
!(assertEqual (List.splitAt 3 (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 ())))))) ((cons 1 (cons 2 (cons 3 ()))) (cons 4 (cons 5 ()))))
!(assertEqual (List.splitAt 5 (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 ())))))) ((cons 1 (cons 2 (cons 3 (cons 4 (cons 5 ()))))) ()))
!(assertEqual (List.splitAt 6 (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 ())))))) ((cons 1 (cons 2 (cons 3 (cons 4 (cons 5 ()))))) ()))

!(assertEqual (List.appendList () ()) ())
