! (register-module! ../../../metta-moses)
! (import! &self metta-moses:utilities:ordered-set)
! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:metapopulation:exemplar-type)
! (import! &self metta-moses:metapopulation:exemplar-selection)

;; Get penalized scores
! (assertEqual (getPnScore NilOS) Nil)
! (assertEqual 
    (getPnScore 
        (ConsOS 
            (mkXmplr (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) 
            (mkDemeId 1) 
                (mkCscore (mkScoreT 0.8) (mkComplexity 0.3) (mkScoreT 0.1) (mkScoreT 0.05)) 
                (mkBscore (Cons 1 (Cons 0 (Cons 1 Nil))))) 
                    NilOS))
    (Cons (mkScoreT 0.65) Nil))
! (assertEqual 
    (getPnScore 
        (ConsOS 
            (mkXmplr (mkTree (mkNode OR) Nil) (mkDemeId 1) 
                (mkCscore (mkScoreT 0.8) (mkComplexity 0.3) (mkScoreT 0.1) (mkScoreT 0.05)) 
                (mkBscore (Cons 1 (Cons 0 (Cons 1 Nil))))) 
            (ConsOS 
                (mkXmplr (mkTree (mkNode B) Nil) (mkDemeId 2) 
                    (mkCscore (mkScoreT 0.7) (mkComplexity 0.4) (mkScoreT 0.1) (mkScoreT 0.1)) 
                    (mkBscore (Cons 0 (Cons 1 (Cons 1 Nil))))) 
                        NilOS)))
    (Cons (mkScoreT 0.65) (Cons (mkScoreT 0.5) Nil)))
! (assertEqual 
    (getPnScore 
        (ConsOS 
            (mkXmplr (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil)))
                (mkDemeId 1) 
                (mkCscore (mkScoreT 0.8) (mkComplexity 0.3) (mkScoreT 0.1) (mkScoreT 0.05)) 
                (mkBscore (Cons 1 (Cons 0 (Cons 1 Nil))))) 
            (ConsOS 
                (mkXmplr (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) (Cons (mkTree (mkNode C) Nil) Nil))) (mkDemeId 2) 
                    (mkCscore (mkScoreT 0.7) (mkComplexity 0.4) (mkScoreT 0.1) (mkScoreT 0.1)) 
                    (mkBscore (Cons 0 (Cons 1 (Cons 1 Nil))))) 
                (ConsOS 
                    (mkXmplr (mkTree (mkNode NOT) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode B) Nil) Nil)) Nil))) Nil)) (mkDemeId 3) 
                        (mkCscore (mkScoreT 0.4) (mkComplexity 0.35) (mkScoreT 0.2) (mkScoreT 0.1)) 
                        (mkBscore (Cons 1 (Cons 1 (Cons 0 Nil))))) 
                            NilOS))))
    (Cons (mkScoreT 0.65) (Cons (mkScoreT 0.5) (Cons (mkScoreT 0.1) Nil))))

;; max of list of values of (List $a) type
! (assertEqual (List.max >>= Nil) Nil)
! (assertEqual (List.max >>= (Cons (mkScoreT 0.75) Nil)) (mkScoreT 0.75))
! (assertEqual (List.max >>= (Cons (mkScoreT 0.9) (Cons (mkScoreT 0.5) Nil))) (mkScoreT 0.9))
! (assertEqual (List.max >>= (Cons (mkScoreT 0.1) (Cons (mkScoreT 0.4) (Cons (mkScoreT 0.65) (Cons (mkScoreT 0.9) Nil))))) (mkScoreT 0.9))

;; Boltzman adjusted probablity values
! (assertEqual (let $a (List.sum adder (normalizeProbs INV_TEMP (mkScoreT 0.5) (Cons (mkScoreT 0.3) Nil))) (get-type $a)) ScoreT)
! (assertEqual (let $a (List.sum adder (normalizeProbs INV_TEMP (mkScoreT 0.7) (Cons (mkScoreT 0.6) (Cons (mkScoreT 0.2) Nil)))) (get-type $a)) ScoreT)
! (assertEqual (let $a (List.sum adder (normalizeProbs INV_TEMP (mkScoreT 0.95) (Cons (mkScoreT 0.95) (Cons (mkScoreT 0.9) (Cons (mkScoreT 0.85) Nil))))) (get-type $a)) ScoreT)
! (assertEqual (let $a (List.sum adder (normalizeProbs INV_TEMP (mkScoreT 1.0) (Cons (mkScoreT 0.9) (Cons (mkScoreT 0.85) (Cons (mkScoreT 0.95) (Cons (mkScoreT 0.7) Nil)))))) (get-type $a)) ScoreT)

;; roulette -- spinning the wheel favoring expressions with higher scores 
! (assertEqual (roulette (Cons (mkScoreT 1.0) Nil) 0 0.57) 0)
! (assertEqual (roulette (Cons (mkScoreT 1.0) (Cons (mkScoreT 0.0067) Nil)) 0 0.9564) 0)
! (assertEqual (roulette (Cons (mkScoreT 0.0821) (Cons (mkScoreT 0.0067) (Cons (mkScoreT 1) Nil))) 0 0.7622) 2)
! (assertEqual (roulette (Cons (mkScoreT 0.2) (Cons (mkScoreT 0.5) (Cons (mkScoreT 0.6) (Cons (mkScoreT 0.2) Nil)))) 0 1.1) 2)
! (assertEqual (roulette (Cons (mkScoreT 0.0067) (Cons (mkScoreT 0.0821) (Cons (mkScoreT 1.0) Nil))) 0 0.0108) 1)

;; Tree Definitions
! (bind! treeA (mkTree (mkNode A) Nil))
! (bind! treeB (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) Nil))))
! (bind! treeC (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))))
! (bind! treeY (mkTree (mkNode AND) (Cons (mkTree (mkNode Y) Nil) (Cons (mkTree (mkNode Z) Nil) Nil))))
! (bind! treeZ (mkTree (mkNode OR) (Cons (mkTree (mkNode Z) Nil) (Cons (mkTree (mkNode X) Nil) Nil))))
! (bind! tree2 (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)))
! (bind! tree3 (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) (Cons (mkTree (mkNode E) Nil) Nil))))

;; rouletteSelect
! (assertEqual 
  (let $choice (rouletteSelect 
    (ConsOS 
      (mkXmplr treeA (mkDemeId 1) 
        (mkCscore (mkScoreT 0.9) (mkComplexity 0.5) (mkScoreT 0.2) (mkScoreT 0.1)) 
        (mkBscore (Cons 1 (Cons 0 Nil))))
      (ConsOS 
        (mkXmplr treeB (mkDemeId 2) 
          (mkCscore (mkScoreT 0.85) (mkComplexity 0.6) (mkScoreT 0.1) (mkScoreT 0.05)) 
          (mkBscore (Cons 1 (Cons 1 Nil))))
        (ConsOS 
          (mkXmplr treeC (mkDemeId 3) 
            (mkCscore (mkScoreT 0.4) (mkComplexity 0.7) (mkScoreT 0.05) (mkScoreT 0.01)) 
            (mkBscore (Cons 0 (Cons 1 Nil))))
          NilOS)))
    (Cons (mkScoreT 0.996) (Cons (mkScoreT 1.0) (Cons (mkScoreT 0.9857) Nil))) (mkScoreT 2.9817))
  (get-type $choice)) Xmplr)

! (assertEqual 
  (let $choice (rouletteSelect 
    (ConsOS 
      (mkXmplr treeA (mkDemeId 9) 
        (mkCscore (mkScoreT 0.91) (mkComplexity 0.3) (mkScoreT 0.25) (mkScoreT 0.13)) 
        (mkBscore (Cons 1 (Cons 0 Nil))))
      (ConsOS 
        (mkXmplr treeY (mkDemeId 10) 
          (mkCscore (mkScoreT 0.88) (mkComplexity 0.4) (mkScoreT 0.22) (mkScoreT 0.12)) 
          (mkBscore (Cons 1 (Cons 1 Nil))))
        (ConsOS 
          (mkXmplr treeZ (mkDemeId 11) 
            (mkCscore (mkScoreT 0.83) (mkComplexity 0.5) (mkScoreT 0.15) (mkScoreT 0.10)) 
            (mkBscore (Cons 0 (Cons 1 Nil))))
          NilOS)))
    (Cons (mkScoreT 0.9753) (Cons (mkScoreT 0.9936) (Cons (mkScoreT 1.0) Nil))) (mkScoreT 2.9689))
  (get-type $choice)) Xmplr)

! (assertEqual 
  (let $choice (rouletteSelect 
    (ConsOS 
      (mkXmplr treeA (mkDemeId 7) 
        (mkCscore (mkScoreT 0.95) (mkComplexity 0.3) (mkScoreT 0.2) (mkScoreT 0.1)) 
        (mkBscore (Cons 1 (Cons 1 Nil))))
      (ConsOS 
        (mkXmplr tree2 (mkDemeId 8) 
          (mkCscore (mkScoreT 0.80) (mkComplexity 0.6) (mkScoreT 0.1) (mkScoreT 0.05)) 
          (mkBscore (Cons 1 (Cons 1 Nil))))
        (ConsOS 
          (mkXmplr tree3 (mkDemeId 12) 
            (mkCscore (mkScoreT 0.5) (mkComplexity 0.9) (mkScoreT 0.05) (mkScoreT 0.03)) 
            (mkBscore (Cons 1 (Cons 0 Nil))))
          NilOS)))
    (Cons (mkScoreT 0.9654) (Cons (mkScoreT 1.0) (Cons (mkScoreT 0.9057) Nil))) (mkScoreT 2.8711))
  (get-type $choice)) Xmplr)

;; selectExemplar
! (assertEqual (selectExemplar NilOS) (Error NilOS "empty metapopulation"))

! (bind! treeA-x (mkXmplr treeA (mkDemeId 7) 
                (mkCscore (mkScoreT 0.95) (mkComplexity 0.3) (mkScoreT 0.2) (mkScoreT 0.1)) 
                    (mkBscore (Cons 1 (Cons 1 Nil)))))
! (assertEqual (selectExemplar (ConsOS treeA-x NilOS)) treeA-x)

! (bind! test1-exemplars
  (ConsOS
    (mkXmplr treeA (mkDemeId 1)
      (mkCscore (mkScoreT 0.8) (mkComplexity 0.3) (mkScoreT 0.1) (mkScoreT 0.05))
      (mkBscore (Cons 1 (Cons 1 Nil))))
    (ConsOS
      (mkXmplr tree2 (mkDemeId 2)
        (mkCscore (mkScoreT 0.7) (mkComplexity 0.4) (mkScoreT 0.05) (mkScoreT 0.05))
        (mkBscore (Cons 0 (Cons 1 Nil))))
      (ConsOS
        (mkXmplr tree3 (mkDemeId 3)
          (mkCscore (mkScoreT 0.6) (mkComplexity 0.5) (mkScoreT 0.0) (mkScoreT 0.0))
          (mkBscore (Cons 1 (Cons 0 Nil))))
        NilOS))))
! (assertEqual (let $choice (selectExemplar test1-exemplars) (OS.contains test1-exemplars $choice)) True)

! (bind! test2-exemplars
  (ConsOS
    (mkXmplr treeA (mkDemeId 101)
      (mkCscore (mkScoreT 0.9) (mkComplexity 0.3) (mkScoreT 0.05) (mkScoreT 0.02))
      (mkBscore (Cons 1 (Cons 1 (Cons 1 (Cons 1 Nil))))))
    (ConsOS
      (mkXmplr treeB (mkDemeId 102)
        (mkCscore (mkScoreT 0.6) (mkComplexity 0.5) (mkScoreT 0.1) (mkScoreT 0.1))
        (mkBscore (Cons 1 (Cons 0 (Cons 1 (Cons 0 Nil))))))
      (ConsOS
        (mkXmplr treeC (mkDemeId 103)
          (mkCscore (mkScoreT 0.4) (mkComplexity 0.4) (mkScoreT 0.05) (mkScoreT 0.1))
          (mkBscore (Cons 0 (Cons 0 (Cons 1 (Cons 0 Nil))))))
        NilOS))))
! (assertEqual (let $choice (selectExemplar test2-exemplars) (OS.contains test2-exemplars $choice)) True)
