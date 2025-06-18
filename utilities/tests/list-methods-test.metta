
!(register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:stdlib:meTTa-utils:utilities:data-structures:list-methods)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:representation:instance)
!(import! &self metta-moses:scoring:cscore)


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