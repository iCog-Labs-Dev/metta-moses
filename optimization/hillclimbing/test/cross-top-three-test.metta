
!(import! &self ../../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../../metta-moses/utilities/list-methods)
!(import! &self ../../../../metta-moses/representation/instance)
!(import! &self ../../../../metta-moses/representation/representation)
!(import! &self ../../../../metta-moses/representation/create-representation)
!(import! &self ../../../../metta-moses/scoring/cscore)
!(import! &self ../../../../metta-moses/deme/create-deme)


!(import! &self ../../../../metta-moses/optimization/hillclimbing/cross-top-one-helpers)
!(import! &self ../../../../metta-moses/optimization/hillclimbing/cross-top-one)

!(import! &self ../../../../metta-moses/optimization/hillclimbing/cross-top-three-helpers)
!(import! &self ../../../../metta-moses/optimization/hillclimbing/cross-top-three)
!(import! &self ../../../../metta-moses/optimization/hillclimbing/cross-top-two-helpers)
!(import! &self ../../../../metta-moses/optimization/hillclimbing/cross-top-two)



;;  -------Test Cases-----------


;; --- getInst test --
;; Ensures getInst correctly extracts raw instance from mkSInst wrapper
!(assertEqual
  (getInst (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 0 0 0 0 1))))
  (mkInst (Cons 5 Nil)))

;; --- mergeTriple test --
;; Tests sequential 3-step merge: k → iRef → jRef
;; NOTE: expected result should validate final merged scored instance 
;;expected : (mkSInst (mkPair (mkInst (Cons b (Cons 2 Nil))) (mkCscore (its score))))
     
!(mergeTriple
   (getInst
     (mkSInst (mkPair (mkInst (Cons a (Cons 5 Nil))) (mkCscore 0 0 0 0 1))))
    (mkInst (Cons a (Cons 0 Nil)))
   (getInst
     (mkSInst (mkPair (mkInst (Cons b (Cons  3 Nil))) (mkCscore 0 0 0 0 2))))
   (getInst
       (mkSInst (mkPair (mkInst (Cons a (Cons 2 Nil))) (mkCscore 0 0 0 0 3)))))

;; Verifies inner loop respects generation limit constraint
  !(assertEqual
  (List.length
    (crossInnerLoop
      (Cons
        (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 0 0 0 0 1)))
        (Cons
          (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 0 0 0 0 2)))
          (Cons
            (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 0 0 0 0 3)))
            Nil)))
      (mkInst (Cons 9 Nil))
      (mkInst (Cons 8 Nil))
      (mkInst (Cons 0 Nil))
      Nil
      3))
  3)


 ;; Runs k-level crossover loop 
!(crossInnerLoop
      (Cons
        (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 0 0 0 0 1)))
        (Cons
          (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 0 0 0 0 2)))
          (Cons
            (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 0 0 0 0 3)))
            Nil)))
      (mkInst (Cons 9 Nil))   
      (mkInst (Cons 8 Nil))   
      (mkInst (Cons 0 Nil))  
         Nil                  
           3 )

  ;; Checks j-loop aggregation over multiple k-combinations
;; Ensures correct propagation of inner loop results
  !(assertEqual
       (List.length
            (crossMiddleLoop
            (Cons
              (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 0 0 0 0 2)))
              (Cons
                (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 0 0 0 0 3)))
                Nil))

            (mkInst (Cons 9 Nil))

            (Cons
              (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 0 0 0 0 1)))
              (Cons
                (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 0 0 0 0 2)))
                (Cons
                  (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 0 0 0 0 3)))
                  Nil)))
                
            (mkInst (Cons 0 Nil))
            Nil
            4))
            4)

 ;; Executes full i-j-k crossover pipeline 
;; Used for manual verification/debugging   
!(crossOuterLoop
         (Cons
            (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 0 0 0 0 1)))
            (Cons
               (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 0 0 0 0 2)))
               (Cons
                  (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 0 0 0 0 3)))
                  (Cons
                     (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore 0 0 0 0 4)))
                     Nil))))
         (mkInst (Cons 0 Nil))
         2)
;; Ensures outer loop respects global generation limit
!(assertEqual
   (List.length
      (crossOuterLoop
         (Cons
            (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 0 0 0 0 1)))
            (Cons
               (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 0 0 0 0 2)))
               (Cons
                  (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 0 0 0 0 3)))
                  Nil)))
         (mkInst (Cons 0 Nil))
         4))
         4)





(= (deme3)
          (mkDeme
            (mkRep
              (mkKbMap (mkDscKbMp (ConsMap NilMap)) (mkDscMp NilMMap))
              (mkTree (mkNode A) Nil))

            (mkSInstSet

              (Cons
                (mkSInst (mkPair (mkInst (Cons a (Cons 1 Nil))) (mkCscore 0 0 0 0 1)))
                (Cons
                  (mkSInst (mkPair (mkInst (Cons b (Cons 2 Nil))) (mkCscore 0 0 0 0 2)))
                  (Cons
                    (mkSInst (mkPair (mkInst (Cons c (Cons 3 Nil))) (mkCscore 0 0 0 0 3)))
                    (Cons
                      (mkSInst (mkPair (mkInst (Cons a (Cons 4 Nil))) (mkCscore 0 0 0 0 4)))
                      Nil)))))

            (mkDemeId "3")))



;; Full system test: 3-simplex crossover on deme3
;; Validates end-to-end pipeline behavior
!(crossTopThree (deme3) 2 0 5 (mkInst (Cons b (Cons 2 Nil))))

  
  


   