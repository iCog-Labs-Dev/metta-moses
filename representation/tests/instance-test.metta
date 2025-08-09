!(register-module! ../../../metta-moses)

!(import! &self metta-moses:representation:instance)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:utilities:pair)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:scoring:cscore)

;; --- Tests for conversion helpers ---

Test instToExpr and exprToInst
!(assertEqual (instToExpr (mkInst Nil)) ())
!(assertEqual (instToExpr (mkInst (Cons 1 (Cons 2 (Cons 3 Nil))))) (1 2 3))
!(assertEqual (exprToInst ()) (mkInst Nil))
!(assertEqual (exprToInst (1 2 3)) (mkInst (Cons 1 (Cons 2 (Cons 3 Nil)))))

;; Test round-trip conversion for instances
!(assertEqual (exprToInst (instToExpr (mkInst Nil))) (mkInst Nil))
!(assertEqual (exprToInst (instToExpr (mkInst (Cons 1 (Cons 2 Nil))))) (mkInst (Cons 1 (Cons 2 Nil))))

; Test sInstToExpr and exprToSInst
!(assertEqual (sInstToExpr (mkSInst (mkPair (mkInst Nil) (mkCscore 0.0 0.0 0.0 0.0 0.0)))) (() (0.0 0.0 0.0 0.0 0.0)))
!(assertEqual (sInstToExpr (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 100.0 5.0 10.0 2.0 88.0)))) ((1 2) (100.0 5.0 10.0 2.0 88.0)))

;; Test round-trip conversion for scored instances
!(assertEqual (exprToSInst (sInstToExpr (mkSInst (mkPair (mkInst Nil) (mkCscore 0.0 0.0 0.0 0.0 0.0))))) (mkSInst (mkPair (mkInst Nil) (mkCscore 0.0 0.0 0.0 0.0 0.0))))
!(assertEqual (exprToSInst (sInstToExpr (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 100.0 5.0 10.0 2.0 88.0))))) (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 100.0 5.0 10.0 2.0 88.0))))

;; Test sInstSetToExpr and exprToSInstSet
!(assertEqual (sInstSetToExpr (mkSInstSet Nil)) ())
!(assertEqual (sInstSetToExpr (mkSInstSet (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore 0.0 0.0 0.0 0.0 0.0))) Nil))) ((() (0.0 0.0 0.0 0.0 0.0))))
!(assertEqual (sInstSetToExpr (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 100.0 5.0 10.0 2.0 88.0))) Nil))) (((1 2) (100.0 5.0 10.0 2.0 88.0))))

;; Test round-trip conversion for instance sets
!(assertEqual (exprToSInstSet (sInstSetToExpr (mkSInstSet Nil))) (mkSInstSet Nil))
!(assertEqual (exprToSInstSet (sInstSetToExpr (mkSInstSet (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore 0.0 0.0 0.0 0.0 0.0))) Nil)))) (mkSInstSet (Cons (mkSInst (mkPair (mkInst Nil) (mkCscore 0.0 0.0 0.0 0.0 0.0))) Nil)))

;; Test getSInstScore and getInst
!(assertEqual (getSInstScore (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 100.0 5.0 10.0 2.0 88.0)))) (mkCscore 100.0 5.0 10.0 2.0 88.0))
!(assertEqual (getInst (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore 100.0 5.0 10.0 2.0 88.0)))) (mkInst (Cons 1 (Cons 2 Nil))))
 
;; Instance related type testing
!(assertEqual (let $a (mkInst (Cons 1 (Cons 2 (Cons 3 (Cons 2.0 Nil))))) (get-type $a)) Instance)
!(assertEqual (let $a (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 3 (Cons 2.0 Nil))))) 3.2)) (get-type $a)) (ScoredInstance Number))
!(assertEqual (let $a (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 3 (Cons 2.0 Nil))))) 3.2)) Nil)) (get-type $a)) (InstanceSet Number))

;; sortDeme
!(assertEqual (sortDeme (mkSInstSet Nil)) (mkSInstSet Nil))

!(assertEqual (sortDeme (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.5 3 0.1 0.2 -0.8))) Nil))) 
                (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.5 3 0.1 0.2 -0.8))) Nil)))

!(assertEqual (sortDeme (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.1 2 0.2 0.3 -0.6))) 
                                        (Cons (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore -0.2 1 0.1 0.1 -0.4))) Nil)))) 
                                        
                                            (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore -0.2 1 0.1 0.1 -0.4))) 
                                                            (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.1 2 0.2 0.3 -0.6))) Nil))))

!(assertEqual (sortDeme (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore -0.4 1 0.1 0.1 -0.6))) 
                                        (Cons (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore -0.1 2 0.2 0.3 -0.6))) Nil)))) 
                                        
                                            (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore -0.4 1 0.1 0.1 -0.6)))
                                                            (Cons (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore -0.1 2 0.2 0.3 -0.6))) Nil))))                                              

;; Test instance>= comparator
!(assertEqual (instance>= (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 3 1.0 0.5 -3.5))) (mkSInst (mkPair (mkInst Nil) (mkCscore -3.0 2 1.0 0.5 -4.5)))) True)
!(assertEqual (instance>= (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 2 1.0 0.5 -3.5))) (mkSInst (mkPair (mkInst Nil) (mkCscore -1.0 4 1.0 0.5 -2.5)))) False)
! (assertEqual (instance>= (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 2 1.0 0.5 -3.5)))
                        (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 3 2.0 0.5 -4.5) ))) True) 