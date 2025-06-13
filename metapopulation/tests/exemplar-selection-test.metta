! (register-module! ../../../metta-moses)
! (import! &self metta-moses:utilities:ordered-set)
! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:metapopulation:exemplar-selection)
! (import! &self metta-moses:metapopulation:metapopulation)
! (import! &self metta-moses:utilities:tree)
(: A Bool)
;; Get penalized scores
! (assertEqual (getPnScore NilOS) Nil)
! (assertEqual 
    (getPnScore 
        (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (Cons 0 (Cons 0 Nil))))
        (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) 
                 NilOS)))
    (Cons -0.4 (Cons -0.6 Nil)))
! (assertEqual 
    (getPnScore 
        (ConsOS 
            (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) 
            (ConsOS 
                (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil))))
                        NilOS)))
    (Cons -0.6 (Cons -0.6 Nil)))

;; max of list of values of (List $a) type
! (assertEqual (List.max >= Nil) Nil)
! (assertEqual (List.max >= (Cons 0.75 Nil)) 0.75)
! (assertEqual (List.max >= (Cons 0.9 (Cons 0.5 Nil))) 0.9)
! (assertEqual (List.max >= (Cons 0.1 (Cons 0.4 (Cons 0.65 (Cons 0.9 Nil))))) 0.9)

;; Boltzman adjusted probablity values
! (assertEqual (let $a (List.sum (normalizeProbs INV_TEMP 0.5 (Cons 0.3 Nil))) (get-type $a)) Number)
! (assertEqual (let $a (List.sum (normalizeProbs INV_TEMP 0.7 (Cons 0.6 (Cons 0.2 Nil)))) (get-type $a)) Number)
! (assertEqual (let $a (List.sum (normalizeProbs INV_TEMP 0.95 (Cons 0.95 (Cons 0.9 (Cons 0.85 Nil))))) (get-type $a)) Number)
! (assertEqual (let $a (List.sum (normalizeProbs INV_TEMP 1.0 (Cons 0.9 (Cons 0.85 (Cons 0.95 (Cons 0.7 Nil)))))) (get-type $a)) Number)

;; roulette -- spinning the wheel favoring expressions with higher scores 
! (assertEqual (roulette (Cons 1.0 Nil) 0 0.57) 0)
! (assertEqual (roulette (Cons 1.0 (Cons 0.0067 Nil)) 0 0.9564) 0)
! (assertEqual (roulette (Cons 0.0821 (Cons 0.0067 (Cons 1 Nil))) 0 0.7622) 2)
! (assertEqual (roulette (Cons 0.2 (Cons 0.5 (Cons 0.6 (Cons 0.2 Nil)))) 0 1.1) 2)
! (assertEqual (roulette (Cons 0.0067 (Cons 0.0821 (Cons 1.0 Nil))) 0 0.0108) 1)

;; Tree Definitions
! (bind! treeA (mkTree (mkNode A) Nil))
! (bind! treeB (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode C) Nil) Nil))))
! (bind! treeC (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))))
! (bind! treeY (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode Z) Nil) Nil))))
! (bind! treeZ (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode X) Nil) Nil))))
! (bind! tree2 (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) Nil)))
! (bind! tree3 (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode E) Nil) Nil))))

;; rouletteSelect
! (assertEqual 
  (let $choice (rouletteSelect 
    (ConsOS 
        (mkExemplar treeA (mkDemeId "1") 
        (mkCscore 0.9 0.5 0.2 0.1 -0.6) 
        (mkBscore (Cons 1 (Cons 0 Nil))))
      (ConsOS 
        (mkExemplar treeB (mkDemeId "2") 
        (mkCscore 0.85 0.6 0.1 0.05 0.6) 
        (mkBscore (Cons 1 (Cons 0 Nil))))
        (ConsOS 
          (mkExemplar treeC (mkDemeId "3") 
          (mkCscore 0.4 0.7 0.05 0.01 0.3) 
          (mkBscore (Cons 1 (Cons 0 Nil))))
          NilOS)))
    (Cons 0.996 (Cons 1.0 (Cons 0.9857 Nil))) 2.9817)
  (get-type $choice)) (Exemplar Bool))

! (assertEqual 
  (let $choice (rouletteSelect 
    (ConsOS 
      (mkExemplar treeA (mkDemeId "9") 
          (mkCscore 0.91 0.3 0.25 0.13 0.3) 
          (mkBscore (Cons 1 (Cons 0 Nil)))) 
      (ConsOS 
          (mkExemplar treeY (mkDemeId "10") 
          (mkCscore 0.88 0.4 0.22 0.12 0.4) 
          (mkBscore (Cons 1 (Cons 1 Nil)))) 
        (ConsOS 
          (mkExemplar treeZ (mkDemeId "11") 
          (mkCscore 0.83 0.5 0.15 0.10 0.5) 
          (mkBscore (Cons 0 (Cons 1 Nil)))) 
          NilOS)))
    (Cons 0.9753 (Cons 0.9936 (Cons 1.0 Nil))) 2.9689)
  (get-type $choice)) (Exemplar Bool))

! (assertEqual 
  (let $choice (rouletteSelect 
    (ConsOS 
      (mkExemplar treeA (mkDemeId "7") 
          (mkCscore 0.95 0.3 0.2 0.1 0.2) 
          (mkBscore (Cons 1 (Cons 1 Nil))))  
      (ConsOS 
        (mkExemplar tree2 (mkDemeId "8") 
          (mkCscore 0.80 0.6 0.1 0.05 0.2) 
          (mkBscore (Cons 1 (Cons 1 Nil))))  
        (ConsOS 
          (mkExemplar tree3 (mkDemeId "12") 
          (mkCscore 0.5 0.9 0.05 0.03 0.1) 
          (mkBscore (Cons 1 (Cons 0 Nil))))   
          NilOS)))
    (Cons 0.9654 (Cons 1.0 (Cons 0.9057 Nil))) 2.8711)
  (get-type $choice)) (Exemplar Bool))

;; selectExemplar
! (assertEqual (selectExemplar NilOS) (Error NilOS "empty metapopulation"))

! (bind! treeA-x (mkExemplar treeA (mkDemeId "7") 
          (mkCscore 0.95 0.3 0.2 0.1 0.4) 
          (mkBscore (Cons 1 (Cons 1 Nil)))))
! (assertEqual (selectExemplar (ConsOS treeA-x NilOS)) treeA-x)

! (bind! test1-exemplars
  (ConsOS
    (mkExemplar treeA (mkDemeId "1") 
          (mkCscore 0.8 0.3 0.1 0.01 0.4) 
          (mkBscore (Cons 1 (Cons 1 Nil))))  
    (ConsOS
      (mkExemplar tree2 (mkDemeId "2") 
          (mkCscore 0.7 0.4 0.05 0.05 0.5) 
          (mkBscore (Cons 0 (Cons 1 Nil)))) 
      (ConsOS
        (mkExemplar tree3 (mkDemeId "3") 
          (mkCscore 0.6 0.5 0.0 0.0 0.6) 
          (mkBscore (Cons 1 (Cons 0 Nil))))    
        NilOS))))

! (assertEqual (let $choice (selectExemplar test1-exemplars) (OS.contains test1-exemplars $choice)) True)

! (bind! test2-exemplars
  (ConsOS
    (mkExemplar treeA (mkDemeId "101") 
          (mkCscore 0.9 0.3 0.05 0.02 0.6) 
          (mkBscore (Cons 1 (Cons 1 (Cons 1 (Cons 1 Nil))))))  
    (ConsOS
      (mkExemplar treeB (mkDemeId "102") 
          (mkCscore 0.6 0.5 0.1 0.1 0.5) 
          (mkBscore (Cons 1 (Cons 1 (Cons 1 (Cons 1 Nil))))))  
      (ConsOS
        (mkExemplar treeC (mkDemeId "103") 
          (mkCscore 0.4 0.4 0.05 0.1 0.4) 
          (mkBscore (Cons 0 (Cons 0 (Cons 1 (Cons 0 Nil))))))     
        NilOS))))
! (assertEqual (let $choice (selectExemplar test2-exemplars) (OS.contains test2-exemplars $choice)) True)

! (bind! metaPop (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 5) (mkBScore (Cons 0 (Cons 0 Nil))))
                 (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (Cons 0 (Cons 0 Nil)))) 
                 (ConsOS (mkExemplar (mkTree (mkNode OR) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.006) (mkBScore (Cons 0 (Cons 0 Nil)))) NilOS))))
               
! (assertEqual (let $choice (selectExemplar metaPop) ((get-type $choice) (OS.contains metaPop $choice))) ((Exemplar Bool) True))
