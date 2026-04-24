!(import! &self ../../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../../metta-moses/utilities/list-methods)
!(import! &self ../../../../metta-moses/utilities/tree)

!(import! &self ../../../../metta-moses/representation/instance)
!(import! &self ../../../../metta-moses/representation/representation)
!(import! &self ../../../../metta-moses/representation/create-representation)


!(import! &self ../../../../metta-moses/scoring/cscore)

!(import! &self ../../../../metta-moses/deme/create-deme)

!(import! &self ../../../../metta-moses/optimization/hillclimbing/cross-top-one-helpers)
!(import! &self ../../../../metta-moses/optimization/hillclimbing/cross-top-one) ;; notice the / in the import statements -- looks like this is required for every additional inner level of dir you have to go

(= (wScore) (* -1 (pow-math 10 100))) ;; bind worst score value 

(= (demeSize (mkDeme $rep (mkSInstSet $list) $demeId)) (List.length $list))

(= (deme1) 
        (mkDeme 
        (mkRep 
            (mkKbMap 
                (mkDscKbMp 
                    (cons ())) 
                    (mkDscMp ())) (mkTree (mkNode A) ()))
                    (mkSInstSet (cons (mkSInst (mkPair (mkInst (cons 5 ())) (mkCscore 1 2 3 4 1))) 
                        (cons (mkSInst (mkPair (mkInst (cons 3 ())) (mkCscore 1 2 3 4 3))) 
                            (cons (mkSInst (mkPair (mkInst (cons 2 ())) (mkCscore 1 2 3 4 4)))
                                (cons (mkSInst (mkPair (mkInst (cons 4 ())) (mkCscore 1 2 3 4 2))) 
                                    (cons (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore 1 2 3 4 5))) 
                                        (cons (mkSInst (mkPair (mkInst (cons 10 ())) (mkCscore 1 2 3 4 0.5))) 
                                            (cons (mkSInst (mkPair (mkInst (cons 12 ())) (mkCscore 1 2 3 4 0.25))) 
                                                (cons (mkSInst (mkPair (mkInst (cons 15 ())) (mkCscore 1 2 3 4 0.15))) ()))))))))) (mkDemeId "1")))


;; Test cases  -- swapValue
!(assertEqual (swapValue 1 2 2) 1)     
!(assertEqual (swapValue 1 2 3) 3)     
!(assertEqual (swapValue a b b) a) 
!(assertEqual (swapValue x y z) z) 

;; Test cases -- compareAndSwap
!(assertEqual (compareAndSwap (cons 0 ()) (cons 1 ()) (cons 1 ()) ()) (cons 0 ()))
!(assertEqual (compareAndSwap (cons 0 (cons 3 ())) (cons 1 (cons 1 ())) (cons 2 (cons 1 ())) ()) (cons 2 (cons 3 ())))
!(assertEqual (compareAndSwap (cons a (cons b (cons c ()))) (cons 1 (cons 2 (cons 3 ()))) 
                                                            (cons 1 (cons 4 (cons 5 ())))  ())
                                                                    (cons a (cons 4 (cons 5 ()))))

;; Test cases -- mergeInstance                                                                    
!(assertEqual 
    (mergeInstance (mkInst (cons a (cons b ()))) (mkInst (cons 1 (cons 2 ()))) (mkInst (cons 1 (cons 3 ())))) 
                (mkInst (cons a (cons 3 ()))))
!(assertEqual (mergeInstance (mkInst (cons a (cons b ()))) (mkInst (cons 1 (cons 2 ()))) (mkInst (cons 1 (cons 2 ())))) 
                    (mkInst (cons a (cons b ()))))
!(assertEqual (mergeInstance (mkInst (cons a ())) (mkInst (cons 1 (cons 2 ()))) (mkInst (cons 1 (cons 2 ())))) 
            (Error (1 2 2) "Unequal target base and/or reference sizes"))

;; Test cases -- merger
!(assertEqual 
    (merger ((mkSInst (mkPair (mkInst (cons 3 ())) (mkCscore 1 2 3 4 5))))
      (mkInst (cons 1 ()))
            (mkInst (cons 2 ())))
            ((mkSInst (mkPair (mkInst (cons 2 ())) (mkCscore (wScore) 0 0.0 0.0 (wScore)))))) 

!(assertEqual (merger ((mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore 1 2 3 4 5)))
                        (mkSInst (mkPair (mkInst (cons 2 ())) (mkCscore 1 2 3 4 5)))
                        (mkSInst (mkPair (mkInst (cons 3 ())) (mkCscore 1 2 3 4 5))))
                        (mkInst (cons 1 ())) (mkInst (cons 2 ()))) 

                        ((mkSInst (mkPair (mkInst (cons 2 ())) (mkCscore (wScore) 0 0.0 0.0 (wScore)))) 
                            (mkSInst (mkPair (mkInst (cons 2 ())) (mkCscore (wScore) 0 0.0 0.0 (wScore)))) 
                                (mkSInst (mkPair (mkInst (cons 2 ())) (mkCscore (wScore) 0 0.0 0.0 (wScore))))))
;; Test cases -- crossTopOne
!(assertEqual (demeSize (crossTopOne (deme1) 3 0 4 (mkInst (cons 2 ())))) 10)
!(assertEqual (demeSize (crossTopOne (deme1) 4 0 5 (mkInst (cons 2 ())))) 11)

!(assertEqual 
    (crossTopOne 
      (mkDeme 
        (mkRep 
          (mkKbMap (mkDscKbMp (cons ())) (mkDscMp ())) 
          (mkTree (mkNode A) ()))
        (mkSInstSet 
          (cons 
            (mkSInst (mkPair (mkInst (cons 5 ())) (mkCscore 1 2 3 4 1)))
            (cons 
              (mkSInst (mkPair (mkInst (cons 3 ())) (mkCscore 1 2 3 4 3)))
              (cons 
                (mkSInst (mkPair (mkInst (cons 2 ())) (mkCscore 1 2 3 4 4)))
                (cons 
                  (mkSInst (mkPair (mkInst (cons 4 ())) (mkCscore 1 2 3 4 2)))
                  (cons 
                    (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore 1 2 3 4 5)))
                    ()))))))
        (mkDemeId "1")) 3 0 4 (mkInst (cons 2 ())))
    (mkDeme 
        (mkRep 
            (mkKbMap 
                (mkDscKbMp 
                    (cons ())) 
                    (mkDscMp ())) 
                    (mkTree (mkNode A) ())) 
                        (mkSInstSet 
                            (cons (mkSInst (mkPair (mkInst (cons 5 ())) (mkCscore 1 2 3 4 1))) 
                                (cons (mkSInst (mkPair (mkInst (cons 3 ())) (mkCscore 1 2 3 4 3))) 
                                    (cons (mkSInst (mkPair (mkInst (cons 2 ())) (mkCscore 1 2 3 4 4))) 
                                        (cons (mkSInst (mkPair (mkInst (cons 4 ())) (mkCscore 1 2 3 4 2))) 
                                            (cons (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore 1 2 3 4 5))) 
                                                (cons (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore (wScore) 0 0.0 0.0 (wScore)))) 
                                                    (cons (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore (wScore) 0 0.0 0.0 (wScore)))) ())))))))) (mkDemeId "1")))
