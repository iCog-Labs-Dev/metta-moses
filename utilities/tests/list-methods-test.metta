
!(register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:general-helpers)


;; Test cases for List.foldr
!(assertEqual (List.foldr + 0 (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil))))) 10)
!(assertEqual (List.foldr * 1 (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil))))) 24)
!(assertEqual (List.foldr - 0 (Cons 10 (Cons 5 (Cons 2 Nil)))) 7)  

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