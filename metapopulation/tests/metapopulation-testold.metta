! (register-module! ../../../metta-moses)
! (import! &self metta-moses:metapopulation:metapopulation)
! (import! &self metta-moses:scoring:cscore)
! (import! &self metta-moses:scoring:fitness)
! (import! &self metta-moses:scoring:bscore)
! (import! &self metta-moses:utilities:ordered-set)
! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:deme:deme-id-creation)

;; Test cases for getBetterCandidates
! (assertEqual (getBetterCandidates (ConsOS 
      (mkExemplar 
        (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) 
        (mkDemeId "1") 
        (mkCscore -0.1 2 0.1 0.1 -0.3) 
        (mkBScore (Cons 0.5 Nil))) 
      NilOS) -0.2) NilOS)

! (assertEqual 
      (getBetterCandidates 
            (ConsOS 
              (mkExemplar 
                (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) 
                (mkDemeId "1") 
                (mkCscore -0.1 2 0.1 0.1 -0.3) 
                (mkBScore (Cons 0.5 Nil))) 
              NilOS) 
        -0.4) 
              (ConsOS 
                (mkExemplar 
                  (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) 
                  (mkDemeId "1") 
                  (mkCscore -0.1 2 0.1 0.1 -0.3) 
                  (mkBScore (Cons 0.5 Nil))) 
                NilOS))

! (bind! pop1 (ConsOS 
                (mkExemplar 
                  (mkTree (mkNode XOR) (Cons (mkTree (mkNode X) Nil) (Cons (mkTree (mkNode Y) Nil) Nil))) 
                  (mkDemeId "1") 
                  (mkCscore -0.1 2 0.1 0.1 -0.3) 
                  (mkBScore (Cons 0.5 Nil))) 
                    (ConsOS 
                      (mkExemplar 
                        (mkTree (mkNode AND) (Cons (mkTree (mkNode M) Nil) (Cons (mkTree (mkNode N) Nil) Nil))) 
                        (mkDemeId "3") 
                        (mkCscore -0.2 1 0.1 0.1 -0.4) 
                        (mkBScore (Cons 0.3 Nil))) 
                      (ConsOS 
                        (mkExemplar 
                          (mkTree (mkNode NOT) (Cons (mkTree (mkNode Z) Nil) Nil)) 
                          (mkDemeId "2") 
                          (mkCscore -0.5 3 0.1 0.1 -0.9) 
                          (mkBScore (Cons 0.4 Nil))) 
                        NilOS))))

! (assertEqual (getBetterCandidates pop1 -0.5) 
                  (ConsOS 
                    (mkExemplar 
                      (mkTree (mkNode XOR) (Cons (mkTree (mkNode X) Nil) (Cons (mkTree (mkNode Y) Nil) Nil))) 
                      (mkDemeId "1") 
                      (mkCscore -0.1 2 0.1 0.1 -0.3) 
                      (mkBScore (Cons 0.5 Nil))) 
                    (ConsOS 
                      (mkExemplar 
                        (mkTree (mkNode AND) (Cons (mkTree (mkNode M) Nil) (Cons (mkTree (mkNode N) Nil) Nil))) 
                        (mkDemeId "3") 
                        (mkCscore -0.2 1 0.1 0.1 -0.4) 
                        (mkBScore (Cons 0.3 Nil))) 
                      NilOS)))
! (bind! pop2 (ConsOS (mkExemplar 
                        (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) 
                        (mkDemeId "1") 
                        (mkCscore -0.1 2 0.1 0.1 -0.3) 
                        (mkBScore (Cons 0.9 Nil))) 
                        (ConsOS  (mkExemplar 
                            (mkTree (mkNode NOT) (Cons (mkTree (mkNode C) Nil) Nil)) 
                            (mkDemeId "2") 
                            (mkCscore -0.2 3 0.1 0.1 -0.4) 
                            (mkBScore (Cons 0.8 Nil))) 
                          (ConsOS (mkExemplar 
                              (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) (Cons (mkTree (mkNode E) Nil) Nil))) 
                              (mkDemeId "3") 
                              (mkCscore -0.3 1 0.1 0.1 -0.5) 
                              (mkBScore (Cons 0.7 Nil))) 
                            (ConsOS (mkExemplar 
                                (mkTree (mkNode XOR) (Cons (mkTree (mkNode F) Nil) (Cons (mkTree (mkNode G) Nil) Nil))) 
                                (mkDemeId "4") 
                                (mkCscore -0.5 4 0.1 0.1 -0.7) 
                                (mkBScore (Cons 0.6 Nil))) 
                              (ConsOS (mkExemplar 
                                  (mkTree (mkNode IMPLIES) (Cons (mkTree (mkNode H) Nil) (Cons (mkTree (mkNode I) Nil) Nil))) 
                                  (mkDemeId "5") 
                                  (mkCscore -0.6 2 0.1 0.1 -0.8) 
                                  (mkBScore (Cons 0.5 Nil))) 
                                (ConsOS (mkExemplar 
                                    (mkTree (mkNode NAND) (Cons (mkTree (mkNode J) Nil) (Cons (mkTree (mkNode K) Nil) Nil))) 
                                    (mkDemeId "6") 
                                    (mkCscore -0.9 3 0.1 0.1 -1.1) 
                                    (mkBScore (Cons 0.4 Nil))) 
                                  NilOS)))))))
! (assertEqual 
  (getBetterCandidates pop2 -0.75) 
              (ConsOS 
                (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) 
                  (mkDemeId "1") 
                  (mkCscore -0.1 2 0.1 0.1 -0.3) 
                  (mkBScore (Cons 0.9 Nil))) 
                (ConsOS (mkExemplar 
                    (mkTree (mkNode NOT) (Cons (mkTree (mkNode C) Nil) Nil)) 
                    (mkDemeId "2") 
                    (mkCscore -0.2 3 0.1 0.1 -0.4) 
                    (mkBScore (Cons 0.8 Nil))) 
                  (ConsOS (mkExemplar 
                      (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) (Cons (mkTree (mkNode E) Nil) Nil))) 
                      (mkDemeId "3") 
                      (mkCscore -0.3 1 0.1 0.1 -0.5) 
                      (mkBScore (Cons 0.7 Nil))) 
                    (ConsOS (mkExemplar 
                        (mkTree (mkNode XOR) (Cons (mkTree (mkNode F) Nil) (Cons (mkTree (mkNode G) Nil) Nil))) 
                        (mkDemeId "4") 
                        (mkCscore -0.5 4 0.1 0.1 -0.7) 
                        (mkBScore (Cons 0.6 Nil))) 
                      NilOS)))))

;; Test cases for cullAtRandom
! (bind! pop3 (ConsOS 
                  (mkExemplar 
                    (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) 
                    (mkDemeId "1") 
                    (mkCscore -0.1 2 0.1 0.1 -0.3) 
                    (mkBScore (Cons 0.5 Nil))) 
                  (ConsOS 
                    (mkExemplar 
                      (mkTree (mkNode NOT) (Cons (mkTree (mkNode C) Nil) Nil)) 
                      (mkDemeId "2") 
                      (mkCscore -0.2 1 0.1 0.1 -0.4) 
                      (mkBScore (Cons 0.4 Nil))) 
                    (ConsOS 
                      (mkExemplar 
                        (mkTree (mkNode XOR) (Cons (mkTree (mkNode D) Nil) (Cons (mkTree (mkNode E) Nil) Nil))) 
                        (mkDemeId "3") 
                        (mkCscore -0.3 3 0.1 0.1 -0.5) 
                        (mkBScore (Cons 0.3 Nil))) 
                      NilOS))))
! (assertEqual (let $a (cullAtRandom pop3 1 2) (OS.length $a)) 1)

! (bind! pop4 (ConsOS 
        (mkExemplar 
          (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) 
          (mkDemeId "1") 
          (mkCscore -0.1 2 0.1 0.1 -0.3) 
          (mkBScore (Cons 0.5 Nil))) 
        (ConsOS 
          (mkExemplar 
            (mkTree (mkNode NOT) (Cons (mkTree (mkNode C) Nil) Nil)) 
            (mkDemeId "2") 
            (mkCscore -0.2 1 0.1 0.1 -0.4) 
            (mkBScore (Cons 0.4 Nil))) 
          (ConsOS 
            (mkExemplar 
              (mkTree (mkNode OR) (Cons (mkTree (mkNode D) Nil) (Cons (mkTree (mkNode E) Nil) Nil))) 
              (mkDemeId "3") 
              (mkCscore -0.3 3 0.1 0.1 -0.5) 
              (mkBScore (Cons 0.3 Nil))) 
            (ConsOS 
              (mkExemplar 
                (mkTree (mkNode NAND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) 
                (mkDemeId "4") 
                (mkCscore -0.4 2 0.1 0.1 -0.6) 
                (mkBScore (Cons 0.2 Nil))) 
              (ConsOS 
                (mkExemplar 
                  (mkTree (mkNode XOR) (Cons (mkTree (mkNode C) Nil) (Cons (mkTree (mkNode D) Nil) Nil))) 
                  (mkDemeId "5") 
                  (mkCscore -0.5 1 0.1 0.1 -0.7) 
                  (mkBScore (Cons 0.1 Nil))) 
                NilOS)))))) 

! (assertEqual (let $result (cullAtRandom pop4 2 2) (OS.length $result)) 3)  

;; Test cases for resizeMetapop
! (bind! pop5
  (ConsOS 
    (mkExemplar 
      (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) 
      (mkDemeId "1") 
      (mkCscore -0.1 2 0.1 0.1 -0.3) 
      (mkBScore (Cons 0.5 Nil)))

    (ConsOS 
      (mkExemplar 
        (mkTree (mkNode OR) (Cons (mkTree (mkNode D) Nil) (Cons (mkTree (mkNode E) Nil) Nil))) 
        (mkDemeId "2") 
        (mkCscore -0.2 3 0.1 0.1 -0.4) 
        (mkBScore (Cons 0.9 Nil)))

      (ConsOS 
        (mkExemplar 
          (mkTree (mkNode NOT) (Cons (mkTree (mkNode C) Nil) Nil)) 
          (mkDemeId "3") 
          (mkCscore -0.3 1 0.1 0.1 -0.5) 
          (mkBScore (Cons 0.4 Nil)))

        (ConsOS 
          (mkExemplar 
            (mkTree (mkNode AND) (Cons (mkTree (mkNode F) Nil) (Cons (mkTree (mkNode G) Nil) Nil))) 
            (mkDemeId "4") 
            (mkCscore -0.4 2 0.1 0.1 -0.6) 
            (mkBScore (Cons 0.2 Nil)))

          (ConsOS 
            (mkExemplar 
              (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) 
              (mkDemeId "5") 
              (mkCscore -0.5 1 0.1 0.1 -0.7) 
              (mkBScore (Cons 0.1 Nil)))

            (ConsOS 
              (mkExemplar 
                (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) Nil))) 
                (mkDemeId "6") 
                (mkCscore -0.6 3 0.1 0.1 -0.8) 
                (mkBScore (Cons 0.8 Nil)))

              (ConsOS 
                (mkExemplar 
                  (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) (Cons (mkTree (mkNode E) Nil) Nil))) 
                  (mkDemeId "7") 
                  (mkCscore -0.7 2 0.1 0.1 -0.9) 
                  (mkBScore (Cons 0.7 Nil)))

                (ConsOS 
                  (mkExemplar 
                    (mkTree (mkNode NOT) (Cons (mkTree (mkNode F) Nil) Nil)) 
                    (mkDemeId "8") 
                    (mkCscore -0.8 1 0.1 0.1 -1.0) 
                    (mkBScore (Cons 0.6 Nil)))
                  NilOS)))))))))

! (assertEqual (let $a (resizeMetapop pop5 3 5 3 0.004 1000) (OS.length $a)) 6)
! (assertEqual (let $a (resizeMetapop pop5 3 5 2 0.003 1000) (OS.length $a)) 4)

; ;; Testcases for compareExemplar
!(assertEqual
(compareExemplar 
(mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.1 2 0.1 0.1 -0.3) (mkBScore (Cons 0 (Cons 0 Nil))))
(mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.2 3 0.1 0.1 -0.4) (mkBScore (Cons 0 (Cons 0 Nil))))
)G)

!(assertEqual
(compareExemplar 
(mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.5 3 0.1 0.1 -0.7) (mkBScore (Cons 0 (Cons 0 Nil))))
(mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.5 2 0.1 0.1 -0.7) (mkBScore (Cons 0 (Cons 0 Nil))))
) L)

!(assertEqual
(compareExemplar 
(mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.5 3 0.1 0.1 -0.7) (mkBScore (Cons 0 (Cons 0 Nil))))
(mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.5 3 0.1 0.1 -0.7) (mkBScore (Cons 0 (Cons 0 Nil))))
) E)

;; Test cases for getExemplarBScore
!(assertEqual
(getExemplarBScore (mkExemplar (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.5 3 0.1 0.1 -0.7) (mkBScore (Cons 0 (Cons 0 Nil)))))
(mkBScore (Cons 0 (Cons 0 Nil))))

!(assertEqual
(getExemplarBScore (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.5 3 0.1 0.1 -0.7) (mkBScore (Cons 0 (Cons 0 Nil)))))
(mkBScore (Cons 0 (Cons 0 Nil))))

;; Test cases for getExemplarPenScore
!(assertEqual 
(getExemplarPenScore (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.5 3 0.1 0.1 -0.7) (mkBScore (Cons 0 (Cons 0 Nil)))))
-0.7)

;; Test cases for getExemplarCscore
!(assertEqual 
(getExemplarCscore (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.5 3 0.1 0.1 -0.7) (mkBScore (Cons 0 (Cons 0 Nil)))))
(mkCscore -0.5 3 0.1 0.1 -0.7))

;; Test cases for getExemplarTree
!(assertEqual 
(getExemplarTree (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.5 3 0.1 0.1 -0.7) (mkBScore (Cons 0 (Cons 0 Nil)))))
(mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))))

