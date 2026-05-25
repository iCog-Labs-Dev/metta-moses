!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/pair)
!(import! &self ../../scoring/cscore)
!(import! &self ../instance)

;; --- Tests for conversion helpers ---

;Test instToExpr and exprToInst
!(assertEqual (instToExpr (mkInst ())) ())
!(assertEqual (instToExpr (mkInst (cons 1 (cons 2 (cons 3 ()))))) (1 2 3))
!(assertEqual (exprToInst ()) (mkInst ()))
!(assertEqual (exprToInst (1 2 3)) (mkInst (cons 1 (cons 2 (cons 3 ())))))

;; Test round-trip conversion for instances
!(assertEqual (exprToInst (instToExpr (mkInst ()))) (mkInst ()))
!(assertEqual (exprToInst (instToExpr (mkInst (cons 1 (cons 2 ()))))) (mkInst (cons 1 (cons 2 ()))))

; Test sInstToExpr and exprToSInst
!(assertEqual (sInstToExpr (mkSInst (mkPair (mkInst ()) (mkCscore 0.0 0.0 0.0 0.0 0.0)))) (() (0.0 0.0 0.0 0.0 0.0)))
!(assertEqual (sInstToExpr (mkSInst (mkPair (mkInst (cons 1 (cons 2 ()))) (mkCscore 100.0 5.0 10.0 2.0 88.0)))) ((1 2) (100.0 5.0 10.0 2.0 88.0)))

;; Test round-trip conversion for scored instances
!(assertEqual (exprToSInst (sInstToExpr (mkSInst (mkPair (mkInst ()) (mkCscore 0.0 0.0 0.0 0.0 0.0))))) (mkSInst (mkPair (mkInst ()) (mkCscore 0.0 0.0 0.0 0.0 0.0))))
!(assertEqual (exprToSInst (sInstToExpr (mkSInst (mkPair (mkInst (cons 1 (cons 2 ()))) (mkCscore 100.0 5.0 10.0 2.0 88.0))))) (mkSInst (mkPair (mkInst (cons 1 (cons 2 ()))) (mkCscore 100.0 5.0 10.0 2.0 88.0))))

;; Test sInstSetToExpr and exprToSInstSet
!(assertEqual (sInstSetToExpr (mkSInstSet ())) ())
!(assertEqual (sInstSetToExpr (mkSInstSet (cons (mkSInst (mkPair (mkInst ()) (mkCscore 0.0 0.0 0.0 0.0 0.0))) ()))) ((() (0.0 0.0 0.0 0.0 0.0))))
!(assertEqual (sInstSetToExpr (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 1 (cons 2 ()))) (mkCscore 100.0 5.0 10.0 2.0 88.0))) ()))) (((1 2) (100.0 5.0 10.0 2.0 88.0))))

;; Test round-trip conversion for instance sets
!(assertEqual (exprToSInstSet (sInstSetToExpr (mkSInstSet ()))) (mkSInstSet ()))
!(assertEqual (exprToSInstSet (sInstSetToExpr (mkSInstSet (cons (mkSInst (mkPair (mkInst ()) (mkCscore 0.0 0.0 0.0 0.0 0.0))) ())))) (mkSInstSet (cons (mkSInst (mkPair (mkInst ()) (mkCscore 0.0 0.0 0.0 0.0 0.0))) ())))

;; Test getSInstScore and getInst
!(assertEqual (getSInstScore (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore 100.0 5.0 10.0 2.0 88.0)))) (mkCscore 100.0 5.0 10.0 2.0 88.0))
!(assertEqual (getInst (mkSInst (mkPair (mkInst (cons 1 (cons 2 ()))) (mkCscore 100.0 5.0 10.0 2.0 88.0)))) (mkInst (cons 1 (cons 2 ()))))

;; The test case below has been commented out because it fails in PeTTa
;; ;; Instance related type testing
;; !(assertEqual (let $a (mkInst (cons 1 (cons 2 (cons 3 (cons 2.0 ()))))) (get-type $a)) Instance)
;; !(assertEqual (let $a (mkSInst (mkPair (mkInst (cons 1 (cons 2 (cons 3 (cons 2.0 ()))))) 3.2)) (get-type $a)) (ScoredInstance Number))
;; !(assertEqual (let $a (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 1 (cons 2 (cons 3 (cons 2.0 ()))))) 3.2)) ())) (get-type $a)) (InstanceSet Number))

;; sortDeme
!(assertEqual (sortDeme (mkSInstSet ())) (mkSInstSet ()))

!(assertEqual (sortDeme (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore -0.5 3 0.1 0.2 -0.8))) ()))) 
                (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore -0.5 3 0.1 0.2 -0.8))) ())))

!(assertEqual (sortDeme (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore -0.1 2 0.2 0.3 -0.6))) 
                                        (cons (mkSInst (mkPair (mkInst (cons 2 ())) (mkCscore -0.2 1 0.1 0.1 -0.4))) ())))) 
                                        
                                            (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 2 ())) (mkCscore -0.2 1 0.1 0.1 -0.4))) 
                                                            (cons (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore -0.1 2 0.2 0.3 -0.6))) ()))))

!(assertEqual (sortDeme (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 3 ())) (mkCscore -0.4 1 0.1 0.1 -0.6))) 
                                        (cons (mkSInst (mkPair (mkInst (cons 4 ())) (mkCscore -0.1 2 0.2 0.3 -0.6))) ())))) 
                                        
                                            (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 3 ())) (mkCscore -0.4 1 0.1 0.1 -0.6)))
                                                            (cons (mkSInst (mkPair (mkInst (cons 4 ())) (mkCscore -0.1 2 0.2 0.3 -0.6))) ()))))                                              

;; Test instance> comparator
!(assertEqual (instance> (mkSInst (mkPair (mkInst ()) (mkCscore -2.0 3 1.0 0.5 -3.5))) (mkSInst (mkPair (mkInst ()) (mkCscore -3.0 2 1.0 0.5 -4.5)))) True)
!(assertEqual (instance> (mkSInst (mkPair (mkInst ()) (mkCscore -2.0 2 1.0 0.5 -3.5))) (mkSInst (mkPair (mkInst ()) (mkCscore -1.0 4 1.0 0.5 -2.5)))) False)
!(assertEqual (instance> (mkSInst (mkPair (mkInst ()) (mkCscore -2.0 2 1.0 0.5 -3.5)))
                        (mkSInst (mkPair (mkInst ()) (mkCscore -2.0 3 2.0 0.5 -4.5) ))) True) 

!(assertEqual 
    (sInstsToExp (cons (mkSInst (mkPair (mkInst (cons 2 (cons 0 ()))) (mkCscore -3 1 0.5 0.0 -3.5))) (cons (mkSInst (mkPair (mkInst (cons 0 (cons 1 ()))) (mkCscore -1 1 0.5 0.0 -1.5))) ())) ())
    (((0 1) (-1 1 0.5 0.0 -1.5)) ((2 0) (-3 1 0.5 0.0 -3.5))))
    
