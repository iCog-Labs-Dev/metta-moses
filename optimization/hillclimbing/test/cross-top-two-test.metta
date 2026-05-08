!(import! &self ../../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../../metta-moses/utilities/list-methods)
!(import! &self ../../../../metta-moses/representation/instance)
!(import! &self ../../../../metta-moses/representation/representation)
!(import! &self ../../../../metta-moses/representation/create-representation)
!(import! &self ../../../../metta-moses/scoring/cscore)
!(import! &self ../../../../metta-moses/deme/create-deme)

!(import! &self ../../../../metta-moses/optimization/hillclimbing/cross-top-one-helpers);;
!(import! &self ../../../../metta-moses/optimization/hillclimbing/cross-top-three-helpers);; to use getInst
!(import! &self ../../../../metta-moses/optimization/hillclimbing/cross-top-two-helpers)
!(import! &self ../../../../metta-moses/optimization/hillclimbing/cross-top-two)



;; Test deme: small population with simple integer instances and fixed scores
(= (deme2)
   (mkDeme
       (mkRep
           (mkKbMap
              (mkDscKbMp (ConsMap NilMap))
              (mkDscMp NilMMap))
           (mkTree (mkNode A) Nil))
        (mkSInstSet
            (Cons (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 1 0 0 0 3)))
            (Cons (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 1 0 0 0 2)))
            (Cons (mkSInst (mkPair (mkInst (Cons 1 Nil)) (mkCscore 1 0 0 0 1)))
            (Cons (mkSInst (mkPair (mkInst (Cons 4 Nil)) (mkCscore 1 0 0 0 4)))
            Nil)))))
    (mkDemeId "2")
    )
)


;;        ---Test cases----
   
;; Test inner crossover loop
;; Crosses a reference instance against a list of candidate instances
  !(assertEqual
  (List.length
  (crossPairsToRef
      (Cons
        (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 0 0 0 0 2)))
        (Cons
          (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 0 0 0 0 3)))
          Nil))
      (getInst
          (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 0 0 0 0 3))))
        (mkInst (Cons 9 Nil))
      Nil
      2))
      2)


;; Test outer crossover loop
;; Ensures full pair generation from a candidate list
!(assertEqual
(List.length (crossPairs
      (Cons
        (mkSInst (mkPair (mkInst (Cons 3 Nil)) (mkCscore 0 0 0 0 2)))
        (Cons
          (mkSInst (mkPair (mkInst (Cons 2 Nil)) (mkCscore 0 0 0 0 3)))
          (Cons
          (mkSInst (mkPair (mkInst (Cons 5 Nil)) (mkCscore 0 0 0 0 3)))
          Nil)))
         (mkInst (Cons 9 Nil))
         3
      ))
      3
      )
   
;; Full integration test for crossTopTwo
;; Runs 2-simplex crossover on deme and verifies final merged deme output
!(assertEqual
    (List.length (crossTopTwo (deme2)  5  0 10 (mkInst (Cons 4 Nil))))
    5)






   
  






  
