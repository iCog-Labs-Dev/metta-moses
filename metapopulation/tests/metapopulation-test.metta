!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/utilities/list-methods)
!(import! &self ../../../metta-moses/utilities/ordered-set)
!(import! &self ../../../metta-moses/utilities/tree)
!(import! &self ../../../metta-moses/scoring/cscore)
!(import! &self ../../../metta-moses/scoring/fitness)
!(import! &self ../../../metta-moses/scoring/bscore)
!(import! &self ../../../metta-moses/metapopulation/metapopulation)
!(import! &self ../../../metta-moses/deme/deme-id-creation)

;; Test cases for getBetterCandidates
!(assertEqual (getBetterCandidates (cons 
      (mkExemplar 
        (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) 
        (mkDemeId "1") 
        (mkCscore -0.1 2 0.1 0.1 -0.3) 
        (mkBScore (cons 0.5 ()))) 
      ()) -0.2) ())

!(assertEqual 
      (getBetterCandidates 
            (cons 
              (mkExemplar 
                (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) 
                (mkDemeId "1") 
                (mkCscore -0.1 2 0.1 0.1 -0.3) 
                (mkBScore (cons 0.5 ()))) 
              ()) 
        -0.4) 
              (cons 
                (mkExemplar 
                  (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) 
                  (mkDemeId "1") 
                  (mkCscore -0.1 2 0.1 0.1 -0.3) 
                  (mkBScore (cons 0.5 ()))) 
                ()))

(= (pop1) (cons 
                (mkExemplar 
                  (mkTree (mkNode XOR) (cons (mkTree (mkNode X) ()) (cons (mkTree (mkNode Y) ()) ()))) 
                  (mkDemeId "1") 
                  (mkCscore -0.1 2 0.1 0.1 -0.3) 
                  (mkBScore (cons 0.5 ()))) 
                    (cons 
                      (mkExemplar 
                        (mkTree (mkNode AND) (cons (mkTree (mkNode M) ()) (cons (mkTree (mkNode N) ()) ()))) 
                        (mkDemeId "3") 
                        (mkCscore -0.2 1 0.1 0.1 -0.4) 
                        (mkBScore (cons 0.3 ()))) 
                      (cons 
                        (mkExemplar 
                          (mkTree (mkNode NOT) (cons (mkTree (mkNode Z) ()) ())) 
                          (mkDemeId "2") 
                          (mkCscore -0.5 3 0.1 0.1 -0.9) 
                          (mkBScore (cons 0.4 ()))) 
                        ()))))

!(assertEqual (getBetterCandidates (pop1) -0.5) 
                  (cons 
                    (mkExemplar 
                      (mkTree (mkNode XOR) (cons (mkTree (mkNode X) ()) (cons (mkTree (mkNode Y) ()) ()))) 
                      (mkDemeId "1") 
                      (mkCscore -0.1 2 0.1 0.1 -0.3) 
                      (mkBScore (cons 0.5 ()))) 
                    (cons 
                      (mkExemplar 
                        (mkTree (mkNode AND) (cons (mkTree (mkNode M) ()) (cons (mkTree (mkNode N) ()) ()))) 
                        (mkDemeId "3") 
                        (mkCscore -0.2 1 0.1 0.1 -0.4) 
                        (mkBScore (cons 0.3 ()))) 
                      ())))
(= (pop2) (cons (mkExemplar 
                        (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) 
                        (mkDemeId "1") 
                        (mkCscore -0.1 2 0.1 0.1 -0.3) 
                        (mkBScore (cons 0.9 ()))) 
                        (cons  (mkExemplar 
                            (mkTree (mkNode NOT) (cons (mkTree (mkNode C) ()) ())) 
                            (mkDemeId "2") 
                            (mkCscore -0.2 3 0.1 0.1 -0.4) 
                            (mkBScore (cons 0.8 ()))) 
                          (cons (mkExemplar 
                              (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) (cons (mkTree (mkNode E) ()) ()))) 
                              (mkDemeId "3") 
                              (mkCscore -0.3 1 0.1 0.1 -0.5) 
                              (mkBScore (cons 0.7 ()))) 
                            (cons (mkExemplar 
                                (mkTree (mkNode XOR) (cons (mkTree (mkNode F) ()) (cons (mkTree (mkNode G) ()) ()))) 
                                (mkDemeId "4") 
                                (mkCscore -0.5 4 0.1 0.1 -0.7) 
                                (mkBScore (cons 0.6 ()))) 
                              (cons (mkExemplar 
                                  (mkTree (mkNode IMPLIES) (cons (mkTree (mkNode H) ()) (cons (mkTree (mkNode I) ()) ()))) 
                                  (mkDemeId "5") 
                                  (mkCscore -0.6 2 0.1 0.1 -0.8) 
                                  (mkBScore (cons 0.5 ()))) 
                                (cons (mkExemplar 
                                    (mkTree (mkNode NAND) (cons (mkTree (mkNode J) ()) (cons (mkTree (mkNode K) ()) ()))) 
                                    (mkDemeId "6") 
                                    (mkCscore -0.9 3 0.1 0.1 -1.1) 
                                    (mkBScore (cons 0.4 ()))) 
                                  ())))))))
!(assertEqual 
  (getBetterCandidates (pop2) -0.75) 
              (cons 
                (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) 
                  (mkDemeId "1") 
                  (mkCscore -0.1 2 0.1 0.1 -0.3) 
                  (mkBScore (cons 0.9 ()))) 
                (cons (mkExemplar 
                    (mkTree (mkNode NOT) (cons (mkTree (mkNode C) ()) ())) 
                    (mkDemeId "2") 
                    (mkCscore -0.2 3 0.1 0.1 -0.4) 
                    (mkBScore (cons 0.8 ()))) 
                  (cons (mkExemplar 
                      (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) (cons (mkTree (mkNode E) ()) ()))) 
                      (mkDemeId "3") 
                      (mkCscore -0.3 1 0.1 0.1 -0.5) 
                      (mkBScore (cons 0.7 ()))) 
                    (cons (mkExemplar 
                        (mkTree (mkNode XOR) (cons (mkTree (mkNode F) ()) (cons (mkTree (mkNode G) ()) ()))) 
                        (mkDemeId "4") 
                        (mkCscore -0.5 4 0.1 0.1 -0.7) 
                        (mkBScore (cons 0.6 ()))) 
                      ())))))

;; Test cases for cullAtRandom
(= (pop3) (cons 
                  (mkExemplar 
                    (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) 
                    (mkDemeId "1") 
                    (mkCscore -0.1 2 0.1 0.1 -0.3) 
                    (mkBScore (cons 0.5 ()))) 
                  (cons 
                    (mkExemplar 
                      (mkTree (mkNode NOT) (cons (mkTree (mkNode C) ()) ())) 
                      (mkDemeId "2") 
                      (mkCscore -0.2 1 0.1 0.1 -0.4) 
                      (mkBScore (cons 0.4 ()))) 
                    (cons 
                      (mkExemplar 
                        (mkTree (mkNode XOR) (cons (mkTree (mkNode D) ()) (cons (mkTree (mkNode E) ()) ()))) 
                        (mkDemeId "3") 
                        (mkCscore -0.3 3 0.1 0.1 -0.5) 
                        (mkBScore (cons 0.3 ()))) 
                      ()))))
!(assertEqual (let $a (cullAtRandom (pop3) 1 2) (OS.length $a)) 1)

(= (pop4) (cons 
        (mkExemplar 
          (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) 
          (mkDemeId "1") 
          (mkCscore -0.1 2 0.1 0.1 -0.3) 
          (mkBScore (cons 0.5 ()))) 
        (cons 
          (mkExemplar 
            (mkTree (mkNode NOT) (cons (mkTree (mkNode C) ()) ())) 
            (mkDemeId "2") 
            (mkCscore -0.2 1 0.1 0.1 -0.4) 
            (mkBScore (cons 0.4 ()))) 
          (cons 
            (mkExemplar 
              (mkTree (mkNode OR) (cons (mkTree (mkNode D) ()) (cons (mkTree (mkNode E) ()) ()))) 
              (mkDemeId "3") 
              (mkCscore -0.3 3 0.1 0.1 -0.5) 
              (mkBScore (cons 0.3 ()))) 
            (cons 
              (mkExemplar 
                (mkTree (mkNode NAND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) 
                (mkDemeId "4") 
                (mkCscore -0.4 2 0.1 0.1 -0.6) 
                (mkBScore (cons 0.2 ()))) 
              (cons 
                (mkExemplar 
                  (mkTree (mkNode XOR) (cons (mkTree (mkNode C) ()) (cons (mkTree (mkNode D) ()) ()))) 
                  (mkDemeId "5") 
                  (mkCscore -0.5 1 0.1 0.1 -0.7) 
                  (mkBScore (cons 0.1 ()))) 
                ())))))) 

!(assertEqual (let $result (cullAtRandom (pop4) 2 2) (OS.length $result)) 3)  

;; Test cases for resizeMetapop
(= (pop5)
  (cons 
    (mkExemplar 
      (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) 
      (mkDemeId "1") 
      (mkCscore -0.1 2 0.1 0.1 -0.3) 
      (mkBScore (cons 0.5 ())))

    (cons 
      (mkExemplar 
        (mkTree (mkNode OR) (cons (mkTree (mkNode D) ()) (cons (mkTree (mkNode E) ()) ()))) 
        (mkDemeId "2") 
        (mkCscore -0.2 3 0.1 0.1 -0.4) 
        (mkBScore (cons 0.9 ())))

      (cons 
        (mkExemplar 
          (mkTree (mkNode NOT) (cons (mkTree (mkNode C) ()) ())) 
          (mkDemeId "3") 
          (mkCscore -0.3 1 0.1 0.1 -0.5) 
          (mkBScore (cons 0.4 ())))

        (cons 
          (mkExemplar 
            (mkTree (mkNode AND) (cons (mkTree (mkNode F) ()) (cons (mkTree (mkNode G) ()) ()))) 
            (mkDemeId "4") 
            (mkCscore -0.4 2 0.1 0.1 -0.6) 
            (mkBScore (cons 0.2 ())))

          (cons 
            (mkExemplar 
              (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) 
              (mkDemeId "5") 
              (mkCscore -0.5 1 0.1 0.1 -0.7) 
              (mkBScore (cons 0.1 ())))

            (cons 
              (mkExemplar 
                (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ()) ()))) 
                (mkDemeId "6") 
                (mkCscore -0.6 3 0.1 0.1 -0.8) 
                (mkBScore (cons 0.8 ())))

              (cons 
                (mkExemplar 
                  (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) (cons (mkTree (mkNode E) ()) ()))) 
                  (mkDemeId "7") 
                  (mkCscore -0.7 2 0.1 0.1 -0.9) 
                  (mkBScore (cons 0.7 ())))

                (cons 
                  (mkExemplar 
                    (mkTree (mkNode NOT) (cons (mkTree (mkNode F) ()) ())) 
                    (mkDemeId "8") 
                    (mkCscore -0.8 1 0.1 0.1 -1.0) 
                    (mkBScore (cons 0.6 ())))
                  ())))))))))

!(assertEqual (let $a (resizeMetapop (pop5) 3 5 3 0.004 1000) (OS.length $a)) 6)
!(assertEqual (let $a (resizeMetapop (pop5) 3 5 2 0.003 1000) (OS.length $a)) 4)

;; Testcases for compareExemplar
!(assertEqual
        (compareExemplar 
            (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.1 2 0.1 0.1 -0.3) (mkBScore (cons 0 (cons 0 ()))))
            (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.2 3 0.1 0.1 -0.4) (mkBScore (cons 0 (cons 0 ()))))
            ) E)

!(assertEqual
        (compareExemplar 
            (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.5 3 0.1 0.1 -0.7) (mkBScore (cons 0 (cons 0 ()))))
            (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.5 2 0.1 0.1 -0.7) (mkBScore (cons 0 (cons 0 ()))))
            ) L)

!(assertEqual
        (compareExemplar 
            (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.5 3 0.1 0.1 -0.7) (mkBScore (cons 0 (cons 0 ()))))
            (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.5 3 0.1 0.1 -0.7) (mkBScore (cons 0 (cons 0 ()))))
            ) E)

;; Test cases for getExemplarBScore
!(assertEqual
            (getExemplarBScore (mkExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.5 3 0.1 0.1 -0.7) (mkBScore (cons 0 (cons 0 ())))))
            (mkBScore (cons 0 (cons 0 ()))))

!(assertEqual
            (getExemplarBScore (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.5 3 0.1 0.1 -0.7) (mkBScore (cons 0 (cons 0 ())))))
            (mkBScore (cons 0 (cons 0 ()))))

;; Test cases for getExemplarPenScore
!(assertEqual 
            (getExemplarPenScore (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.5 3 0.1 0.1 -0.7) (mkBScore (cons 0 (cons 0 ())))))
            -0.7)

;; Test cases for getExemplarCscore
!(assertEqual 
            (getExemplarCscore (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.5 3 0.1 0.1 -0.7) (mkBScore (cons 0 (cons 0 ())))))
            (mkCscore -0.5 3 0.1 0.1 -0.7))

;; Test cases for getExemplarTree
!(assertEqual 
            (getExemplarTree (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.5 3 0.1 0.1 -0.7) (mkBScore (cons 0 (cons 0 ())))))
            (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))))

