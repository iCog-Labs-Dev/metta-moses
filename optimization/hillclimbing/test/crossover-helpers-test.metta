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


(= (demeSize (mkDeme $rep (mkSInstSet $list) $demeId)) (List.length $list))
;; --------------------------------------  
;;        crossTopTwo and it's helper Tests       
;;------------------------------------------

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
                                  ())))))
    (mkDemeId "2")
    )
)


;;---Test cases----
   
;; Test inner crossover loop
;; Crosses a reference instance against a list of candidate instances
 !(assertEqual
  (crossPairsToRef
     (cons
        (mkSInst (mkPair (mkInst (cons 3 ())) (mkCscore 0 0 0 0 2)))
        (cons
           (mkSInst (mkPair (mkInst (cons 2 ())) (mkCscore 0 0 0 0 3)))
           ()))
       (getInst
        (mkSInst (mkPair (mkInst (cons 5 ())) (mkCscore 0 0 0 0 3))))
      (mkInst (cons 9 ()))
     ()
     2)

  (cons
     (mkSInst
        (mkPair
           (mkInst (cons 5 ()))
           (worstCscore)))
     (cons
        (mkSInst
           (mkPair
              (mkInst (cons 5 ()))
              (worstCscore)))
        ()))
)


;; Test outer crossover loop
;; Ensures full pair generation from a candidate list
!(assertEqual  (demeSize (crossTopTwo (deme2) 3 0 4 (mkInst (cons 3 ())))) 7)

!(assertEqual
   (crossTopTwo (deme2) 3 0 4 (mkInst (cons 3 ())))
   (mkDeme
      (mkRep
         (mkKbMap
            (mkDscKbMp (cons ()))
            (mkDscMp ()))
         (mkTree (mkNode A) ()))
      (mkSInstSet

         ;; original instances first
         (cons
            (mkSInst (mkPair (mkInst (cons 3 ())) (mkCscore 1 0 0 0 3)))
            (cons
               (mkSInst (mkPair (mkInst (cons 2 ())) (mkCscore 1 0 0 0 2)))
               (cons
                  (mkSInst (mkPair (mkInst (cons 1 ())) (mkCscore 1 0 0 0 1)))
                  (cons
                     (mkSInst (mkPair (mkInst (cons 4 ())) (mkCscore 1 0 0 0 4)))

                     ;; generated crossover instances
                     (cons
                        (mkSInst
                           (mkPair
                              (mkInst (cons 2 ()))
                              (worstCscore)))
                        (cons
                           (mkSInst
                              (mkPair
                                 (mkInst (cons 1 ()))
                                 (worstCscore)))
                           (cons
                              (mkSInst
                                 (mkPair
                                    (mkInst (cons 2 ()))
                                    (worstCscore)))
                              (cons
                                 (mkSInst
                                    (mkPair
                                       (mkInst (cons 4 ()))
                                       (worstCscore)))
                                 (cons
                                    (mkSInst
                                       (mkPair
                                          (mkInst (cons 4 ()))
                                          (worstCscore)))
                                    (cons
                                       (mkSInst
                                          (mkPair
                                             (mkInst (cons 4 ()))
                                             (worstCscore)))
                                       ()))))))))))))  (mkDemeId "2"))
  
;;-----------------------------------
;;       crossTopThree and its helper Tests   
;;-----------------------------------

;;--------- Test Cases-------------;;

;; --- getInst test --
;; Ensures getInst correctly extracts raw instance from mkSInst wrapper
!(assertEqual
  (getInst (mkSInst (mkPair (mkInst (cons 5 ())) (mkCscore 0 0 0 0 1))))
  (mkInst (cons 5 ())))



;; --- mergeTriple test --
;; Tests sequential 3-step merge: k → iRef → jRef
!(assertEqual
        (mergeTriple
                (getInst
                  (mkSInst
                      (mkPair
                        (mkInst (cons a (cons 5 ())))
                        (mkCscore 0 0 0 0 1))))
                (mkInst (cons a (cons 3 ())))
                (getInst
                  (mkSInst
                      (mkPair
                        (mkInst (cons b (cons 3 ())))
                        (mkCscore 0 0 0 0 2))))
                (getInst
                  (mkSInst
                      (mkPair
                        (mkInst (cons a (cons 2 ())))
                        (mkCscore 0 0 0 0 3)))))
            (mkSInst
                (mkPair
                  (mkInst (cons b (cons 2 ())))
                  (worstCscore)))
    )

;; Verifies inner loop respects generation limit constraint

!(assertEqual
   (crossInnerLoop
            (cons
              (mkSInst
                  (mkPair
                    (mkInst (cons a (cons 5 ())))
                    (mkCscore 0 0 0 0 1)))
              (cons
                  (mkSInst
                    (mkPair
                        (mkInst (cons b (cons 3 ())))
                        (mkCscore 0 0 0 0 2)))
                  ()))
            (mkInst (cons a (cons 9 ())))
            (mkInst (cons b (cons 8 ())))
            (mkInst (cons a (cons 0 ())))
            ()
            2)
        (cons
            (mkSInst
              (mkPair
                  (mkInst (cons b (cons 9 ())))
                  (worstCscore)))
            (cons
              (mkSInst
                  (mkPair
                    (mkInst (cons b (cons 9 ())))
                    (worstCscore)))
              ())))

;; Checks j-loop aggregation over multiple k-combinations
;; Ensures correct propagation of inner loop results

!(assertEqual
   (crossMiddleLoop
      (cons
         (mkSInst
            (mkPair
               (mkInst (cons 3 ()))
               (mkCscore 0 0 0 0 2)))
         (cons
            (mkSInst
               (mkPair
                  (mkInst (cons 2 ()))
                  (mkCscore 0 0 0 0 3)))
            ()))
      (mkInst (cons 9 ()))
      (cons
         (mkSInst
            (mkPair
               (mkInst (cons 5 ()))
               (mkCscore 0 0 0 0 1)))
         (cons
            (mkSInst
               (mkPair
                  (mkInst (cons 3 ()))
                  (mkCscore 0 0 0 0 2)))
            (cons
               (mkSInst
                  (mkPair
                     (mkInst (cons 2 ()))
                     (mkCscore 0 0 0 0 3)))
               ())))
      (mkInst (cons 0 ()))
      ()
      3)

   (cons
      (mkSInst
         (mkPair
            (mkInst (cons 3 ()))
            (worstCscore)))
      (cons
         (mkSInst
            (mkPair
               (mkInst (cons 3 ()))
               (worstCscore)))
         (cons
            (mkSInst
               (mkPair
                  (mkInst (cons 3 ()))
                  (worstCscore)))
            ()))))

;; Ensures full i-j-k crossover pipeline respects  generation limit 
!(assertEqual
   (crossOuterLoop
      (cons
         (mkSInst
            (mkPair
               (mkInst (cons 1 ()))
               (mkCscore 0 0 0 0 1)))
         (cons
            (mkSInst
               (mkPair
                  (mkInst (cons 2 ()))
                  (mkCscore 0 0 0 0 2)))
            (cons
               (mkSInst
                  (mkPair
                     (mkInst (cons 3 ()))
                     (mkCscore 0 0 0 0 3)))
               (cons
                  (mkSInst
                     (mkPair
                        (mkInst (cons 4 ()))
                        (mkCscore 0 0 0 0 4)))
                  ()))))

      (mkInst (cons 2 ()))
      3)

   (cons
      (mkSInst
         (mkPair
            (mkInst (cons 1 ()))
            (worstCscore)))
      (cons
         (mkSInst
            (mkPair
               (mkInst (cons 1 ()))
               (worstCscore)))
         (cons
            (mkSInst
               (mkPair
                  (mkInst (cons 1 ()))
                  (worstCscore)))
            ()))))
   
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
                      ())))))

            (mkDemeId "3")))

;; Full system test: 3-simplex crossover on deme3
;; Validates end-to-end pipeline behavior
!(assertEqual (demeSize (crossTopThree (deme3) 2 0 5 (mkInst  (cons 2 ())))) 5)









   
  






  
