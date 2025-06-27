!(register-module! ../../../metta-moses)

!(import! &self metta-moses:representation:instance)
!(import! &self metta-moses:utilities:pair)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:scoring:cscore)

;; Instance related type testing
!(assertEqual (let $a (mkInst (Cons 1 (Cons 2 (Cons 3 (Cons 2.0 Nil))))) (get-type $a)) Instance)
!(assertEqual (let $a (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 3 (Cons 2.0 Nil))))) 3.2)) (get-type $a)) (ScoredInstance Number))
!(assertEqual (let $a (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 (Cons 3 (Cons 2.0 Nil))))) 3.2)) Nil)) (get-type $a)) (InstanceSet Number))

;; Test cases for insertSInst
! (assertEqual (insertSInst (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.5 3 0.1 0.2 -0.8))) Nil)
                    (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.5 3 0.1 0.2 -0.8))) Nil))

! (assertEqual (insertSInst (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore -0.4 1 0.1 0.1 -0.6)))
                                (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.1 2 0.2 0.3 -0.6))) Nil))
                            
                            (Cons (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore -0.4 1 0.1 0.1 -0.6)))  
                                    (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.1 2 0.2 0.3 -0.6))) Nil)))

! (assertEqual (insertSInst (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore -0.1 3 0.1 0.1 -0.3))) 
                            (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.5 2 0.2 0.3 -1.0))) Nil)) 
                                
                                (Cons (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore -0.1 3 0.1 0.1 -0.3))) 
                                    (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.5 2 0.2 0.3 -1.0))) Nil)))

! (assertEqual (insertSInst (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore -0.5 1 0.1 0.1 -0.7))) 
                                (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.5 2 0.1 0.1 -0.7))) Nil)) 
                                
                                    (Cons (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore -0.5 1 0.1 0.1 -0.7)))  
                                        (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.5 2 0.1 0.1 -0.7))) Nil)))
; ;; Test cases for sortSInst
! (assertEqual (sortSInst Nil) Nil)

! (assertEqual (sortSInst 
                    (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore -0.5 3 0.1 0.2 -0.8))) Nil))
                            (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore -0.5 3 0.1 0.2 -0.8))) Nil))

! (assertEqual (sortSInst 
                    (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.1 2 0.2 0.3 -0.6))) 
                        (Cons (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore -0.2 1 0.1 0.1 -0.4))) Nil)))
                            
                            (Cons (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore -0.2 1 0.1 0.1 -0.4)))
                                (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.1 2 0.2 0.3 -0.6))) Nil)))

! (assertEqual (sortSInst 
                    (Cons (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore -0.1 2 0.2 0.3 -0.6)))
                        (Cons (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore -0.4 1 0.1 0.1 -0.6))) Nil)))
                            
                            (Cons (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore -0.4 1 0.1 0.1 -0.6))) 
                                (Cons (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore -0.1 2 0.2 0.3 -0.6))) Nil)))

                                
;; sortDeme
! (assertEqual (sortDeme (mkSInstSet Nil)) (mkSInstSet Nil))

! (assertEqual (sortDeme (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.5 3 0.1 0.2 -0.8))) Nil))) 
                (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.5 3 0.1 0.2 -0.8))) Nil)))

! (assertEqual (sortDeme (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.1 2 0.2 0.3 -0.6))) 
                                        (Cons (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore -0.2 1 0.1 0.1 -0.4))) Nil)))) 
                                        
                                            (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore -0.2 1 0.1 0.1 -0.4))) 
                                                            (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -0.1 2 0.2 0.3 -0.6))) Nil))))

! (assertEqual (sortDeme (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore -0.4 1 0.1 0.1 -0.6))) 
                                        (Cons (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore -0.1 2 0.2 0.3 -0.6))) Nil)))) 
                                        
                                            (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore -0.4 1 0.1 0.1 -0.6)))
                                                            (Cons (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore -0.1 2 0.2 0.3 -0.6))) Nil))))

;; Testcase for getSInstScore
!(assertEqual 
   (getSInstScore (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore -0.1 2 0.2 0.3 -0.6))))
   (mkCscore -0.1 2 0.2 0.3 -0.6))

;; Testcase for getInst
!(assertEqual
   (getInst (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore -0.1 2 0.2 0.3 -0.6))))
   (mkInst (Cons 4 Nil)))
   
;; instance comparator
! (assertEqual (instance>= (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 3 1.0 0.5 -3.5) ))
                (mkSInst (mkPair (mkInst Nil) (mkCscore -3.0 2 1.0 0.5 -4.5)))) True)
! (assertEqual (instance>= (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 2 1.0 0.5 -3.5)))
                        (mkSInst (mkPair (mkInst Nil) (mkCscore -1.0 4 1.0 0.5 -2.5)))) False)                
! (assertEqual (instance>= (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 2 1.0 0.5 -3.5)))
                        (mkSInst (mkPair (mkInst Nil) (mkCscore -2.0 3 2.0 0.5 -4.5) ))) True)                        
