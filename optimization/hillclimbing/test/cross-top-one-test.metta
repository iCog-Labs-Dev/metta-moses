!(register-module! ../../../../metta-moses)


!(import! &self metta-moses:representation:instance)
!(import! &self metta-moses:representation:representation)
!(import! &self metta-moses:representation:create-representation)

!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:utilities:python-helpers)
!(import! &self metta-moses:utilities:general-helpers)

!(import! &self metta-moses:scoring:cscore)

!(import! &self metta-moses:deme:create-deme)

!(import! &self metta-moses:optimization:hillclimbing:cross-top-one)

(= (pyExprToList $expr) (py_exprToList $expr))

;; NOTE!!!!!!!
;; merger -- this is a function implemented as part if the main crossTopOne in optimization/hillclimbing/cross-top-one.metta but results in error unless this is imported in the test file
(: merger (-> Expression Instance Instance Expression))
(= (merger $targetInstances $baseInst $referenceInst)
    (collapse (let (mkSInst (mkPair $targetInst $score)) (superpose $targetInstances)
        (mkSInst (mkPair (mergeInstance $targetInst $baseInst $referenceInst) (worstCscore))))))

! (bind! deme1 
        (mkDeme 
        (mkRep 
            (mkKbMap 
                (mkDscKbMp 
                    (ConsMap NilMap)) 
                    (mkDscMp NilMMap)) (mkTree (mkNode A) Nil))
                    (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 1 2 3 4 1))) 
                        (Cons (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3))) 
                            (Cons (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 1 2 3 4 4)))
                                (Cons (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore 1 2 3 4 2))) 
                                    (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 1 2 3 4 5))) 
                                        (Cons (mkSInst (mkPair (mkInst (Cons 10 Nil)) (mkCscore 1 2 3 4 0.5))) 
                                            (Cons (mkSInst (mkPair (mkInst (Cons 12 Nil)) (mkCscore 1 2 3 4 0.25))) 
                                                (Cons (mkSInst (mkPair (mkInst (Cons 15 Nil)) (mkCscore 1 2 3 4 0.15))) Nil))))))))) (mkDemeId "1")))


;; Test cases  -- swapValue
! (assertEqual (swapValue 1 2 2) 1)     
! (assertEqual (swapValue 1 2 3) 3)     
! (assertEqual (swapValue a b b) a) 
! (assertEqual (swapValue x y z) z) 

;; Test cases -- compareAndSwap
! (assertEqual (compareAndSwap (Cons 0 Nil) (Cons 1 Nil) (Cons 1 Nil) Nil) (Cons 0 Nil))
! (assertEqual (compareAndSwap (Cons 0 (Cons 3 Nil)) (Cons 1 (Cons 1 Nil)) (Cons 2 (Cons 1 Nil)) Nil) (Cons 2 (Cons 3 Nil)))
! (assertEqual (compareAndSwap (Cons a (Cons b (Cons c Nil))) (Cons 1 (Cons 2 (Cons 3 Nil))) 
                                                            (Cons 1 (Cons 4 (Cons 5 Nil)))  Nil)
                                                                    (Cons a (Cons 4 (Cons 5 Nil))))

;; Test cases -- mergeInstance                                                                    
! (assertEqual 
    (mergeInstance (mkInst (Cons a (Cons b Nil))) (mkInst (Cons 1 (Cons 2 Nil))) (mkInst (Cons 1 (Cons 3 Nil)))) 
                (mkInst (Cons a (Cons 3 Nil))))
! (assertEqual (mergeInstance (mkInst (Cons a (Cons b Nil))) (mkInst (Cons 1 (Cons 2 Nil))) (mkInst (Cons 1 (Cons 2 Nil)))) 
                    (mkInst (Cons a (Cons b Nil))))
! (assertEqual (mergeInstance (mkInst (Cons a Nil)) (mkInst (Cons 1 (Cons 2 Nil))) (mkInst (Cons 1 (Cons 2 Nil)))) 
            (Error (1 2 2) "Unequal target base and/or reference sizes"))

;; Test cases -- merger
! (assertEqual 
    (merger ((mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 5))))
      (mkInst (Cons 1 Nil))
            (mkInst (Cons 2 Nil)))
            ((mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore -1.0000000000000006e308 0.0 0.0 0.0 -1.0000000000000006e308))))) 

! (assertEqual (merger ((mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 1 2 3 4 5)))
                        (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 1 2 3 4 5)))
                        (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 5))))
                        (mkInst (Cons 1 Nil)) (mkInst (Cons 2 Nil))) 

                        ((mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore -1.0000000000000006e308 0.0 0.0 0.0 -1.0000000000000006e308))) 
                            (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore -1.0000000000000006e308 0.0 0.0 0.0 -1.0000000000000006e308))) 
                                (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore -1.0000000000000006e308 0.0 0.0 0.0 -1.0000000000000006e308)))))
;; Test cases -- crossTopOne
! (let
    (mkDeme 
        (mkRep 
            (mkKbMap 
                (mkDscKbMp 
                    (ConsMap NilMap)) 
                    (mkDscMp NilMMap)) (mkTree (mkNode A) Nil))
                        (mkSInstSet $list) $demeId) (crossTopOne deme1 3 0 4 (mkInst (Cons 2 Nil))) (assertEqual (List.length $list) 10))
! (let
    (mkDeme 
        (mkRep 
            (mkKbMap 
                (mkDscKbMp 
                    (ConsMap NilMap)) 
                    (mkDscMp NilMMap)) (mkTree (mkNode A) Nil))
                        (mkSInstSet $list) $demeId) (crossTopOne deme1 4 0 5 (mkInst (Cons 2 Nil))) (assertEqual (List.length $list) 11))

! (assertEqual 
    (crossTopOne 
      (mkDeme 
        (mkRep 
          (mkKbMap (mkDscKbMp (ConsMap NilMap)) (mkDscMp NilMMap)) 
          (mkTree (mkNode A) Nil))
        (mkSInstSet 
          (Cons 
            (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 1 2 3 4 1)))
            (Cons 
              (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3)))
              (Cons 
                (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 1 2 3 4 4)))
                (Cons 
                  (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore 1 2 3 4 2)))
                  (Cons 
                    (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 1 2 3 4 5)))
                    Nil))))))
        (mkDemeId "1")) 3 0 4 (mkInst (Cons 2 Nil)))
    (mkDeme 
        (mkRep 
            (mkKbMap 
                (mkDscKbMp 
                    (ConsMap NilMap)) 
                    (mkDscMp NilMMap)) 
                    (mkTree (mkNode A) Nil)) 
                        (mkSInstSet 
                            (Cons (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 1 2 3 4 1))) 
                                (Cons (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 2 3 4 3))) 
                                    (Cons (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 1 2 3 4 4))) 
                                        (Cons (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore 1 2 3 4 2))) 
                                            (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 1 2 3 4 5))) 
                                                (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -1.0000000000000006e308 0.0 0.0 0.0 -1.0000000000000006e308))) 
                                                    (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore -1.0000000000000006e308 0.0 0.0 0.0 -1.0000000000000006e308))) Nil)))))))) (mkDemeId "1")))
