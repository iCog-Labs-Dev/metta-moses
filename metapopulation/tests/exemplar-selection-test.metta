!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/utilities/list-methods)
!(import! &self ../../../metta-moses/utilities/ordered-set)
!(import! &self ../../../metta-moses/utilities/tree)
!(import! &self ../../../metta-moses/metapopulation/exemplar-selection)
!(import! &self ../../../metta-moses/metapopulation/metapopulation)
(: A Bool)
;; Get penalized scores
; !(assertEqual (getPnScore NilOS) ())
; !(assertEqual 
;     (getPnScore 
;         (ConsOS (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (cons 0 (cons 0 ()))))
;         (ConsOS (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ())))) 
;                  NilOS)))
;     (cons -0.4 (cons -0.6 ())))
; !(assertEqual 
;     (getPnScore 
;         (ConsOS 
;             (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ())))) 
;             (ConsOS 
;                 (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ()))))
;                         NilOS)))
;     (cons -0.6 (cons -0.6 ())))

; ;; max of list of values of (List $a) type
; !(assertEqual (List.max >= ()) ())
; !(assertEqual (List.max >= (cons 0.75 ())) 0.75)
; !(assertEqual (List.max >= (cons 0.9 (cons 0.5 ()))) 0.9)
; !(assertEqual (List.max >= (cons 0.1 (cons 0.4 (cons 0.65 (cons 0.9 ()))))) 0.9)

; ;; Boltzman adjusted probablity values
; !(assertEqual (let $a (List.sum (normalizeProbs (INV_TEMP) 0.5 (cons 0.3 ()))) (get-type $a)) Number)
; !(assertEqual (let $a (List.sum (normalizeProbs (INV_TEMP) 0.7 (cons 0.6 (cons 0.2 ())))) (get-type $a)) Number)
; !(assertEqual (let $a (List.sum (normalizeProbs (INV_TEMP) 0.95 (cons 0.95 (cons 0.9 (cons 0.85 ()))))) (get-type $a)) Number)
; !(assertEqual (let $a (List.sum (normalizeProbs (INV_TEMP) 1.0 (cons 0.9 (cons 0.85 (cons 0.95 (cons 0.7 ())))))) (get-type $a)) Number)

; ;; roulette -- spinning the wheel favoring expressions with higher scores 
; !(assertEqual (roulette (cons 1.0 ()) 0 0.57) 0)
; !(assertEqual (roulette (cons 1.0 (cons 0.0067 ())) 0 0.9564) 0)
; !(assertEqual (roulette (cons 0.0821 (cons 0.0067 (cons 1 ()))) 0 0.7622) 2)
; !(assertEqual (roulette (cons 0.2 (cons 0.5 (cons 0.6 (cons 0.2 ())))) 0 1.1) 2)
; !(assertEqual (roulette (cons 0.0067 (cons 0.0821 (cons 1.0 ()))) 0 0.0108) 1)

;; Tree Definitions
(= (treeA) (mkTree (mkNode A) ()))
(= (treeB) (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode C) ()) ()))))
(= (treeC) (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))))
(= (treeY) (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode Z) ()) ()))))
(= (treeZ) (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode X) ()) ()))))
(= (tree2) (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))
(= (tree3) (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode E) ()) ()))))

;; rouletteSelect
(= (exemplar-list0) (ConsOS (mkExemplar (treeA) (mkDemeId "1") (mkCscore 0.9 0.5 0.2 0.1 -0.6) (mkBscore (cons 1 (cons 0 ()))))
                        (ConsOS (mkExemplar (treeB) (mkDemeId "2") (mkCscore 0.85 0.6 0.1 0.05 0.6) (mkBscore (cons 1 (cons 0 ()))))
                          (ConsOS (mkExemplar (treeC) (mkDemeId "3") (mkCscore 0.4 0.7 0.05 0.01 0.3) (mkBscore (cons 1 (cons 0 ()))))
                            NilOS))))
!(assertEqual 
  (let $choice (rouletteSelect (exemplar-list0)
        (cons 0.996 (cons 1.0 (cons 0.9857 ()))) 2.9817)
          (OS.contains (exemplar-list0) $choice)) True)

(= (exemplar-list1) (ConsOS (mkExemplar (treeA) (mkDemeId "9") (mkCscore 0.91 0.3 0.25 0.13 0.3) (mkBscore (cons 1 (cons 0 ())))) 
                        (ConsOS (mkExemplar (treeY) (mkDemeId "10") (mkCscore 0.88 0.4 0.22 0.12 0.4) (mkBscore (cons 1 (cons 1 ())))) 
                          (ConsOS (mkExemplar (treeZ) (mkDemeId "11") (mkCscore 0.83 0.5 0.15 0.10 0.5) (mkBscore (cons 0 (cons 1 ())))) 
                            NilOS))))
!(assertEqual 
  (let $choice (rouletteSelect (exemplar-list1) (cons 0.9753 (cons 0.9936 (cons 1.0 ()))) 2.9689)
    (OS.contains (exemplar-list1) $choice )) True)

(= (exemplar-list2) (ConsOS (mkExemplar (treeA) (mkDemeId "7") (mkCscore 0.95 0.3 0.2 0.1 0.2) (mkBscore (cons 1 (cons 1 ()))))  
                        (ConsOS (mkExemplar (tree2) (mkDemeId "8") (mkCscore 0.80 0.6 0.1 0.05 0.2) (mkBscore (cons 1 (cons 1 ()))))  
                          (ConsOS (mkExemplar (tree3) (mkDemeId "12") (mkCscore 0.5 0.9 0.05 0.03 0.1) (mkBscore (cons 1 (cons 0 ()))))   
                            NilOS))))

!(assertEqual 
  (let $choice (rouletteSelect (exemplar-list2) (cons 0.9654 (cons 1.0 (cons 0.9057 ()))) 2.8711)
  (OS.contains (exemplar-list2) $choice)) True)

;; selectExemplar
!(assertEqual (selectExemplar NilOS) (Error NilOS "empty metapopulation"))

(= (treeA-x) (mkExemplar treeA (mkDemeId "7") (mkCscore 0.95 0.3 0.2 0.1 0.4) (mkBscore (cons 1 (cons 1 ())))))

!(assertEqual (selectExemplar (ConsOS (treeA-x) NilOS)) (treeA-x))

(= (test1-exemplars)
  (ConsOS (mkExemplar (treeA) (mkDemeId "1") (mkCscore 0.8 0.3 0.1 0.01 0.4) (mkBscore (cons 1 (cons 1 ()))))  
    (ConsOS (mkExemplar (tree2) (mkDemeId "2") (mkCscore 0.7 0.4 0.05 0.05 0.5) (mkBscore (cons 0 (cons 1 ())))) 
      (ConsOS (mkExemplar (tree3) (mkDemeId "3") (mkCscore 0.6 0.5 0.0 0.0 0.6) (mkBscore (cons 1 (cons 0 ()))))    
        NilOS))))

!(assertEqual (let $choice (selectExemplar (test1-exemplars)) (OS.contains (test1-exemplars) $choice)) True)

(= (test2-exemplars)
  (ConsOS (mkExemplar (treeA) (mkDemeId "101") (mkCscore 0.9 0.3 0.05 0.02 0.6) 
          (mkBscore (cons 1 (cons 1 (cons 1 (cons 1 ()))))))  
    (ConsOS (mkExemplar (treeB) (mkDemeId "102") (mkCscore 0.6 0.5 0.1 0.1 0.5) (mkBscore (cons 1 (cons 1 (cons 1 (cons 1 ()))))))  
      (ConsOS (mkExemplar (treeC) (mkDemeId "103") (mkCscore 0.4 0.4 0.05 0.1 0.4) (mkBscore (cons 0 (cons 0 (cons 1 (cons 0 ()))))))     
        NilOS))))
!(assertEqual (let $choice (selectExemplar (test2-exemplars)) (OS.contains (test2-exemplars) $choice)) True)

(= (metaPop) (ConsOS (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 5) (mkBScore (cons 0 (cons 0 ()))))
                 (ConsOS (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ())))) 
                 (ConsOS (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.006) (mkBScore (cons 0 (cons 0 ())))) NilOS))))
               
; ! (assertEqual (let $choice (selectExemplar metaPop) ((get-type $choice) (OS.contains metaPop $choice))) ((Exemplar Bool) True))
!(assertEqual (let $choice (selectExemplar (metaPop)) (OS.contains (metaPop) $choice))  True)
