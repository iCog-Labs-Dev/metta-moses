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
            (mkKbMap (mkDscMp ())) (mkTree (mkNode A) ()))
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
;;use List.length as it returns insatance not deme
;; Previous off-by-one expectations: 2 and 3.
;; !(assertEqual (List.length (crossTopOne (deme1) 3 0 4 (mkInst (cons 2 ())))) 2)
;; !(assertEqual (List.length (crossTopOne (deme1) 4 0 5 (mkInst (cons 2 ())))) 3)
!(assertEqual (List.length (crossTopOne (deme1) 3 0 4 (mkInst (cons 2 ())))) 3)
!(assertEqual (List.length (crossTopOne (deme1) 4 0 5 (mkInst (cons 2 ())))) 4)

!(assertEqual
  (crossTopOne
    (mkDeme
      (mkRep
        (mkKbMap (mkDscMp ()))
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
    ;; The score-5 instance lies outside sampleSize=4. Reference 2 equals the
    ;; base, so the three in-window targets remain 3, 4, and 5.
    (cons
      (mkSInst (mkPair (mkInst (cons 3 ())) (mkCscore (wScore) 0 0.0 0.0 (wScore))))
      (cons
        (mkSInst (mkPair (mkInst (cons 4 ())) (mkCscore (wScore) 0 0.0 0.0 (wScore))))
        (cons
          (mkSInst (mkPair (mkInst (cons 5 ())) (mkCscore (wScore) 0 0.0 0.0 (wScore)))) ()))))

;; Test deme: small population with simple integer instances and fixed scores
(= (deme2)
   (mkDeme
       (mkRep
           (mkKbMap
              (mkDscKbMp 
               (cons ()))
               (mkDscMp ()))
               (mkTree (mkNode A) ()))
             (mkSInstSet
                    (cons (mkSInst (mkPair (mkInst (cons 3 ())) (mkCscore 1 0 0 0 3)))
                          (cons (mkSInst (mkPair (mkInst (cons 2 ())) (mkCscore 1 0 0 0 2)))
                              (cons (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore 1 0 0 0 1)))
                                  (cons (mkSInst (mkPair (mkInst (cons 4 ())) (mkCscore 1 0 0 0 4)))
                                         (cons (mkSInst (mkPair (mkInst (cons 5 ())) (mkCscore 1 0 0 0 5)))
                                               (cons (mkSInst (mkPair (mkInst (cons 6 ())) (mkCscore 1 0 0 0 6)))
                                                      (cons (mkSInst (mkPair (mkInst (cons 7 ())) (mkCscore 1 0 0 0 7)))
                                                            (cons (mkSInst (mkPair (mkInst (cons 8 ())) (mkCscore 1 0 0 0 8)))()))))))))) (mkDemeId "2")))

;;crossPairsForRef test
 !(assertEqual
  (crossPairsForRef
     (cons (mkSInst (mkPair (mkInst (cons 3 ())) (mkCscore 0 0 0 0 2)))
        (cons (mkSInst (mkPair (mkInst (cons 2 ())) (mkCscore 0 0 0 0 3))) ()))
     (getInst (mkSInst (mkPair (mkInst (cons 5 ())) (mkCscore 0 0 0 0 3))))
     (mkInst (cons 9 ()))
     ()
     2)
   (cons (mkSInst (mkPair (mkInst (cons 5 ())) (worstCscore)))
     (cons (mkSInst (mkPair (mkInst (cons 5 ())) (worstCscore))) ())))

;; crossPairs Pairwise Test    
!(assertEqual
   (List.length
      (crossPairs
         ()
         (cons
            (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore 0 0 0 0 3)))
               (cons (mkSInst (mkPair (mkInst (cons 2 ())) (mkCscore 0 0 0 0 2)))
                 (cons (mkSInst (mkPair (mkInst (cons 3 ())) (mkCscore 0 0 0 0 1))) ())))
        (mkInst (cons 9 ()))
        ()
         2))
    2)
;; ----------------------------------------
;; crossTopTwo integration tests
;; ----------------------------------------
;; Instance Size test 
;; use List.length
!(assertEqual (List.length (crossTopTwo (deme2) 3 0 4 (mkInst (cons 3 ())))) 3)

;; full crossover test                                      
!(assertEqual
    (crossTopTwo
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
        (mkDemeId "1"))
      3 0 4 (mkInst (cons 2 ())))

    ;; SampleSize=4 excludes the later score-5 instance. The C++ pair order is
    ;; (0,1), (0,2), (1,2) after ranking the in-window sample.
    (cons (mkSInst (mkPair (mkInst (cons 3 ())) (mkCscore (wScore) 0 0.0 0.0 (wScore))))
      (cons (mkSInst (mkPair (mkInst (cons 4 ())) (mkCscore (wScore) 0 0.0 0.0 (wScore))))
        (cons (mkSInst (mkPair (mkInst (cons 4 ())) (mkCscore (wScore) 0 0.0 0.0 (wScore)))) ()))))

;; The old helper test called the former append-only five-argument API. It is
;; retained as a note now that the implementation models C++ destination slots:
;; !(assertEqual (List.length (crossTriples () $sample $base () 1)) 1)

;; C++ 3-simplex regression. With four ranked one-hot mutations and four
;; requested offspring, k runs to i-1 and writes n=C(i,3)+C(j,2)+k. Later loop
;; visits overwrite earlier slots, yielding the four combinations below.
(= (cppTripleSample)
   (cons (mkSInst (mkPair (mkInst (1 0 0 0)) (mkCscore 0 0 0 0 4)))
     (cons (mkSInst (mkPair (mkInst (0 1 0 0)) (mkCscore 0 0 0 0 3)))
       (cons (mkSInst (mkPair (mkInst (0 0 1 0)) (mkCscore 0 0 0 0 2)))
         (cons (mkSInst (mkPair (mkInst (0 0 0 1)) (mkCscore 0 0 0 0 1))) ())))))

;; C++ 2-simplex order is i=1.. and j=0..i-1. One-hot mutations
;; make every pair distinguishable and guard that traversal order.
!(assertEqual
  (crossPairs () (cppTripleSample) (mkInst (0 0 0 0)) () 4)
  (cons (mkSInst (mkPair (mkInst (1 1 0 0)) (worstCscore)))
    (cons (mkSInst (mkPair (mkInst (1 0 1 0)) (worstCscore)))
      (cons (mkSInst (mkPair (mkInst (0 1 1 0)) (worstCscore)))
        (cons (mkSInst (mkPair (mkInst (1 0 0 1)) (worstCscore))) ())))))

!(assertEqual
  (crossTriples () (cppTripleSample) 0 (mkInst (0 0 0 0))
    (makeCrossoverSlots 4) 4)
  (cons (mkSInst (mkPair (mkInst (1 1 1 0)) (worstCscore)))
    (cons (mkSInst (mkPair (mkInst (1 1 0 1)) (worstCscore)))
      (cons (mkSInst (mkPair (mkInst (1 0 1 1)) (worstCscore)))
        (cons (mkSInst (mkPair (mkInst (0 1 1 1)) (worstCscore))) ())))))

;; With a two-child limit, slot 1 must contain the later overwrite from i=3,
;; not the temporary child written while i=2.
!(assertEqual
  (crossTriples () (cppTripleSample) 0 (mkInst (0 0 0 0))
    (makeCrossoverSlots 2) 2)
  (cons (mkSInst (mkPair (mkInst (1 1 1 0)) (worstCscore)))
    (cons (mkSInst (mkPair (mkInst (1 1 0 1)) (worstCscore))) ())))


(= (deme3)
          (mkDeme
            (mkRep
              (mkKbMap
                 (mkDscKbMp 
                   (cons ()))
                  (mkDscMp ()))
              (mkTree (mkNode A) ()))
             (mkSInstSet
                        (cons
                           (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore 0 0 0 0 1)))
                           (cons
                              (mkSInst (mkPair (mkInst (cons 2 ())) (mkCscore 0 0 0 0 2)))
                              (cons
                              (mkSInst (mkPair (mkInst  (cons 3 ())) (mkCscore 0 0 0 0 3)))
                              (cons
                                 (mkSInst (mkPair (mkInst (cons 4 ())) (mkCscore 0 0 0 0 4)))
                                 (cons
                                    (mkSInst (mkPair (mkInst (cons 5 ())) (mkCscore 0 0 0 0 5)))
                                    (cons
                                       (mkSInst (mkPair (mkInst (cons 6 ())) (mkCscore 0 0 0 0 6)))
                                       (cons
                                          (mkSInst (mkPair (mkInst (cons 7 ())) (mkCscore 0 0 0 0 7)))
                                 ()))))))))
                        (mkDemeId "3")))

;; ----------------------------------------
;; crossTopThree integration tests
;; ----------------------------------------

;; Instance Size test 
;; use List.length
!(assertEqual (List.length (crossTopThree (deme3) 4 0 5 (mkInst  (cons 2 ())))) 4)

;; full crossover test
!(assertEqual
    (crossTopThree
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
        (mkDemeId "3")) 3 0 4 (mkInst (cons 2 ())))

      ;; The later score-5 instance is outside sampleSize=4. With a partial
      ;; three-child request, C++ returns as soon as loop index n reaches 3;
      ;; slot 2 therefore still contains the temporary i=3,j=1,k=1 write.
      (cons (mkSInst (mkPair (mkInst (cons 3 ())) (mkCscore (wScore) 0 0.0 0.0 (wScore))))
        (cons (mkSInst (mkPair (mkInst (cons 3 ())) (mkCscore (wScore) 0 0.0 0.0 (wScore))))
          ;; Previous conventional-combination expectation was instance 4.
          ;; (cons (mkSInst (mkPair (mkInst (cons 4 ())) (mkCscore (wScore) 0 0.0 0.0 (wScore)))) ())
          (cons (mkSInst (mkPair (mkInst (cons 3 ())) (mkCscore (wScore) 0 0.0 0.0 (wScore)))) ()))))
