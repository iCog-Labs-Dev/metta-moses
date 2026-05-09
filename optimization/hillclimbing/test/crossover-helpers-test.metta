!(import! &self ../../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../../metta-moses/utilities/list-methods)
!(import! &self ../../../../metta-moses/representation/instance)
!(import! &self ../../../../metta-moses/representation/representation)
!(import! &self ../../../../metta-moses/representation/create-representation)
!(import! &self ../../../../metta-moses/scoring/cscore)
!(import! &self ../../../../metta-moses/deme/create-deme)

!(import! &self ../../../../metta-moses/optimization/hillclimbing/cross-top-one-helpers)
!(import! &self ../../../../metta-moses/optimization/hillclimbing/cross-top-one)
!(import! &self ../../../../metta-moses/optimization/hillclimbing/crossover-helpers)


;; --------------------------------------  
;;        crossTopTwo and it's helper Tests       
;;------------------------------------------

;; Test deme: small population with simple integer instances and fixed scores
(= (deme2)
   (mkDeme
       (mkRep
           (mkKbMap
              (mkDscKbMp (ConsMap NilMap))
              (mkDscMp NilMMap))
           (mkTree (mkNode A) Nil))
        (mkSInstSet
            (cons (mkSInst (mkPair (mkInst (cons 3 Nil)) (mkCscore 1 0 0 0 3)))
            (cons (mkSInst (mkPair (mkInst (cons 2 Nil)) (mkCscore 1 0 0 0 2)))
            (cons (mkSInst (mkPair (mkInst (cons 1 Nil)) (mkCscore 1 0 0 0 1)))
            (cons (mkSInst (mkPair (mkInst (cons 4 Nil)) (mkCscore 1 0 0 0 4)))
            Nil)))))
    (mkDemeId "2")
    )
)


;;---Test cases----
   
;; Test inner crossover loop
;; Crosses a reference instance against a list of candidate instances
  !(assertEqual
  (List.length
  (crossPairsToRef
      (cons
        (mkSInst (mkPair (mkInst (cons 3 Nil)) (mkCscore 0 0 0 0 2)))
        (cons
          (mkSInst (mkPair (mkInst (cons 2 Nil)) (mkCscore 0 0 0 0 3)))
          Nil))
      (getInst
          (mkSInst (mkPair (mkInst (cons 5 Nil)) (mkCscore 0 0 0 0 3))))
        (mkInst (cons 9 Nil))
      Nil
      2))
      2)


;; Test outer crossover loop
;; Ensures full pair generation from a candidate list
!(assertEqual
(List.length (crossPairs
      (cons
        (mkSInst (mkPair (mkInst (cons 3 Nil)) (mkCscore 0 0 0 0 2)))
        (cons
          (mkSInst (mkPair (mkInst (cons 2 Nil)) (mkCscore 0 0 0 0 3)))
          (cons
          (mkSInst (mkPair (mkInst (cons 5 Nil)) (mkCscore 0 0 0 0 3)))
          Nil)))
         (mkInst (cons 9 Nil))
         3
      ))
      3
      )
   
;; Full integration test for crossTopTwo
;; Runs 2-simplex crossover on deme and verifies final merged deme output
!(assertEqual
    (List.length (crossTopTwo (deme2)  5  0 10 (mkInst (cons 4 Nil))))
    5)

;;-----------------------------------
;;       crossTopThree and its helper Tests   
;;-----------------------------------

;;--------- Test Cases-------------;;



;; --- getInst test --
;; Ensures getInst correctly extracts raw instance from mkSInst wrapper
!(assertEqual
  (getInst (mkSInst (mkPair (mkInst (cons 5 Nil)) (mkCscore 0 0 0 0 1))))
  (mkInst (cons 5 Nil)))

;; --- mergeTriple test --
;; Tests sequential 3-step merge: k → iRef → jRef
;; NOTE: expected result should validate final merged scored instance 
;;expected : (mkSInst (mkPair (mkInst (cons b (cons 2 Nil))) (mkCscore (its score))))
     
!(assertEqual
(List.length (mergeTriple
            (getInst
              (mkSInst (mkPair (mkInst (cons a (cons 5 Nil))) (mkCscore 0 0 0 0 1))))
              (mkInst (cons a (cons 3 Nil)))
            (getInst
              (mkSInst (mkPair (mkInst (cons b (cons  3 Nil))) (mkCscore 0 0 0 0 2))))
            (getInst
                (mkSInst (mkPair (mkInst (cons a (cons 2 Nil))) (mkCscore 0 0 0 0 3)))))
     )
     1
)

;; Verifies inner loop respects generation limit constraint
  !(assertEqual
  (List.length
    (crossInnerLoop
      (cons
        (mkSInst (mkPair (mkInst (cons 5 Nil)) (mkCscore 0 0 0 0 1)))
        (cons
          (mkSInst (mkPair (mkInst (cons 3 Nil)) (mkCscore 0 0 0 0 2)))
          (cons
            (mkSInst (mkPair (mkInst (cons 2 Nil)) (mkCscore 0 0 0 0 3)))
            Nil)))
      (mkInst (cons 9 Nil))
      (mkInst (cons 8 Nil))
      (mkInst (cons 0 Nil))
      Nil
      3))
  3)


 ;; k-level crossover loop assertion
!(assertEqual
   (List.length (crossInnerLoop
      (cons
        (mkSInst (mkPair (mkInst (cons 5 Nil)) (mkCscore 0 0 0 0 1)))
        (cons
          (mkSInst (mkPair (mkInst (cons 3 Nil)) (mkCscore 0 0 0 0 2)))
          (cons
            (mkSInst (mkPair (mkInst (cons 2 Nil)) (mkCscore 0 0 0 0 3)))
            Nil)))
      (mkInst (cons 9 Nil))   
      (mkInst (cons 8 Nil))   
      (mkInst (cons 0 Nil))  
         Nil                  
           3 ))
           3)

;; Checks j-loop aggregation over multiple k-combinations
;; Ensures correct propagation of inner loop results
  !(assertEqual
       (List.length
            (crossMiddleLoop
            (cons
              (mkSInst (mkPair (mkInst (cons 3 Nil)) (mkCscore 0 0 0 0 2)))
              (cons
                (mkSInst (mkPair (mkInst (cons 2 Nil)) (mkCscore 0 0 0 0 3)))
                Nil))

            (mkInst (cons 9 Nil))

            (cons
              (mkSInst (mkPair (mkInst (cons 5 Nil)) (mkCscore 0 0 0 0 1)))
              (cons
                (mkSInst (mkPair (mkInst (cons 3 Nil)) (mkCscore 0 0 0 0 2)))
                (cons
                  (mkSInst (mkPair (mkInst (cons 2 Nil)) (mkCscore 0 0 0 0 3)))
                  Nil)))
                
            (mkInst (cons 0 Nil))
            Nil
            4))
            4)

;; Ensures full i-j-k crossover pipeline respects  generation limit 
!(assertEqual
   (List.length
      (crossOuterLoop
         (cons
            (mkSInst (mkPair (mkInst (cons 1 Nil)) (mkCscore 0 0 0 0 1)))
            (cons
               (mkSInst (mkPair (mkInst (cons 2 Nil)) (mkCscore 0 0 0 0 2)))
               (cons
                  (mkSInst (mkPair (mkInst (cons 3 Nil)) (mkCscore 0 0 0 0 3)))
                  (cons
                     (mkSInst (mkPair (mkInst (cons 4 Nil)) (mkCscore 0 0 0 0 4)))
                     Nil))))
         (mkInst (cons 0 Nil))
         2))
         2
)
;; Ensures outer loop respects global generation limit
!(assertEqual
   (List.length
      (crossOuterLoop
         (cons
            (mkSInst (mkPair (mkInst (cons 1 Nil)) (mkCscore 0 0 0 0 1)))
            (cons
               (mkSInst (mkPair (mkInst (cons 2 Nil)) (mkCscore 0 0 0 0 2)))
               (cons
                  (mkSInst (mkPair (mkInst (cons 3 Nil)) (mkCscore 0 0 0 0 3)))
                  Nil)))
         (mkInst (cons 0 Nil))
         4))
         4)





(= (deme3)
          (mkDeme
            (mkRep
              (mkKbMap (mkDscKbMp (consMap NilMap)) (mkDscMp NilMMap))
              (mkTree (mkNode A) Nil))

            (mkSInstSet
            (cons
                (mkSInst (mkPair (mkInst (cons a (cons 1 Nil))) (mkCscore 0 0 0 0 1)))
                (cons
                  (mkSInst (mkPair (mkInst (cons b (cons 2 Nil))) (mkCscore 0 0 0 0 2)))
                  (cons
                    (mkSInst (mkPair (mkInst (cons c (cons 3 Nil))) (mkCscore 0 0 0 0 3)))
                    (cons
                      (mkSInst (mkPair (mkInst (cons a (cons 4 Nil))) (mkCscore 0 0 0 0 4)))
                      Nil)))))

            (mkDemeId "3")))



;; Full system test: 3-simplex crossover on deme3
;; Validates end-to-end pipeline behavior
!(crossTopThree (deme3) 2 0 5 (mkInst (cons b (cons 2 Nil))))








   
  






  
