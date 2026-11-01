!(import! &self ../../utilities/general-helpers)
!(import! &self ../../parameters/registry)
!(import! &self ../../parameters/defaults)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/ordered-set)
!(import! &self ../../scoring/cscore.metta)
!(import! &self ../../utilities/tree)
!(import! &self ../../metapopulation/exemplar-selection)
!(import! &self ../../metapopulation/metapopulation)
(: A Bool)

;; Exemplar selection and metapopulation trimming must share the same C++
;; complexity temperature.  This guards against reintroducing compxyTemp as an
;; independent, silently colder selector setting.
!(set-param complexityTemperature 2000)
!(assertEqual (INV_TEMP) 0.05)
!(set-param complexityTemperature 6)

;; Get penalized scores
; !(assertEqual (getPnScore ()) ())
; !(assertEqual 
;     (getPnScore 
;         (cons (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 -0.4) (mkBScore (cons 0 (cons 0 ()))))
;         (cons (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ())))) 
;                  ())))
;     (cons -0.4 (cons -0.6 ())))
; !(assertEqual 
;     (getPnScore 
;         (cons 
;             (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ())))) 
;             (cons 
;                 (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ()))))
;                         ())))
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
(= (exemplar-list0) (cons (mkExemplar (treeA) (mkDemeId "1") (mkCscore 0.9 0.5 0.2 0.1 -0.6) (mkBscore (cons 1 (cons 0 ()))))
                        (cons (mkExemplar (treeB) (mkDemeId "2") (mkCscore 0.85 0.6 0.1 0.05 0.6) (mkBscore (cons 1 (cons 0 ()))))
                          (cons (mkExemplar (treeC) (mkDemeId "3") (mkCscore 0.4 0.7 0.05 0.01 0.3) (mkBscore (cons 1 (cons 0 ()))))
                            ()))))
!(assertEqual 
  (let $choice (rouletteSelect (exemplar-list0)
        (cons 0.996 (cons 1.0 (cons 0.9857 ()))) 2.9817)
          (OS.contains (exemplar-list0) $choice)) True)

(= (exemplar-list1) (cons (mkExemplar (treeA) (mkDemeId "9") (mkCscore 0.91 0.3 0.25 0.13 0.3) (mkBscore (cons 1 (cons 0 ())))) 
                        (cons (mkExemplar (treeY) (mkDemeId "10") (mkCscore 0.88 0.4 0.22 0.12 0.4) (mkBscore (cons 1 (cons 1 ())))) 
                          (cons (mkExemplar (treeZ) (mkDemeId "11") (mkCscore 0.83 0.5 0.15 0.10 0.5) (mkBscore (cons 0 (cons 1 ())))) 
                            ()))))
!(assertEqual 
  (let $choice (rouletteSelect (exemplar-list1) (cons 0.9753 (cons 0.9936 (cons 1.0 ()))) 2.9689)
    (OS.contains (exemplar-list1) $choice )) True)

(= (exemplar-list2) (cons (mkExemplar (treeA) (mkDemeId "7") (mkCscore 0.95 0.3 0.2 0.1 0.2) (mkBscore (cons 1 (cons 1 ()))))  
                        (cons (mkExemplar (tree2) (mkDemeId "8") (mkCscore 0.80 0.6 0.1 0.05 0.2) (mkBscore (cons 1 (cons 1 ()))))  
                          (cons (mkExemplar (tree3) (mkDemeId "12") (mkCscore 0.5 0.9 0.05 0.03 0.1) (mkBscore (cons 1 (cons 0 ()))))   
                            ()))))

!(assertEqual 
  (let $choice (rouletteSelect (exemplar-list2) (cons 0.9654 (cons 1.0 (cons 0.9057 ()))) 2.8711)
  (OS.contains (exemplar-list2) $choice)) True)

;; selectExemplar
!(assertEqual (selectExemplar ()) (Error () "empty metapopulation"))

(= (treeA-x) (mkExemplar treeA (mkDemeId "7") (mkCscore 0.95 0.3 0.2 0.1 0.4) (mkBscore (cons 1 (cons 1 ())))))

!(assertEqual (selectExemplar (cons (treeA-x) ())) (treeA-x))

;; Eligibility is an order-preserving structural-tree filter.  Deme IDs
;; and scores do not create separate visit allowances for the same tree.
(= (visitExemplarA $id $penalty)
   (mkExemplar (treeA) (mkDemeId $id)
     (mkCscore 0 0 0 0 $penalty) (mkBScore (0))))
(= (visitExemplarB $id)
   (mkExemplar (treeB) (mkDemeId $id)
     (mkCscore 0 0 0 0 0) (mkBScore (0))))
(= (visitExemplarC $id)
   (mkExemplar (treeC) (mkDemeId $id)
     (mkCscore 0 0 0 0 0) (mkBScore (0))))
(= (visitExemplarY $id)
   (mkExemplar (treeY) (mkDemeId $id)
     (mkCscore 0 0 0 0 0) (mkBScore (0))))

!(assertEqual (eligibleExemplars () () 0) ())

;; Exhausted candidates are removed without disturbing the relative order of
;; the candidates that remain.
!(assertEqual
  (eligibleExemplars
    ((visitExemplarA "a" 0)
     (visitExemplarB "b")
     (visitExemplarC "c")
     (visitExemplarY "y"))
    ((mkVisit (treeA) 1) (mkVisit (treeC) 2))
    0)
  ((visitExemplarB "b") (visitExemplarY "y")))

;; Both exemplars containing treeA share one count even though their deme IDs
;; and penalized scores differ.
!(assertEqual
  (eligibleExemplars
    ((visitExemplarA "a-1" 0)
     (visitExemplarB "b")
     (visitExemplarA "a-2" -1))
    ((mkVisit (treeA) 1))
    0)
  ((visitExemplarB "b")))

;; revisit=0 permits only the initial visit; positive N permits N additional
;; visits, and any negative value leaves even heavily visited trees eligible.
!(assertEqual
  (let* (
         ($exemplar (visitExemplarA "visit" 0))
         ($visits1 (recordVisit (treeA) ()))
         ($visits2 (recordVisit (treeA) $visits1))
        )
    ((visitCount (treeA) $visits2)
     (eligibleExemplars ($exemplar) () 0)
     (List.length (eligibleExemplars ($exemplar) $visits1 0))
     (List.length (eligibleExemplars ($exemplar) $visits1 1))
     (List.length (eligibleExemplars ($exemplar) $visits2 1))
     (eligibleExemplars ($exemplar) $visits2 -1)
     (selectEligibleExemplar ($exemplar) $visits2 1)))
  (2 ((visitExemplarA "visit" 0)) 0 1 0
     ((visitExemplarA "visit" 0))
     (Error () "empty metapopulation")))

;; Raw-best selection follows C++: lower complexity wins a raw-score tie, while
;; the earlier exemplar survives an exact raw/complexity tie. Penalized order
;; is deliberately irrelevant to this all-time candidate record.
(= (rawTestExemplar $tree $id $raw $complexity $penalized)
   (mkExemplar $tree (mkDemeId $id)
     (mkCscore $raw $complexity 0 0 $penalized) (mkBScore ($raw))))
!(assertEqual
  (bestRawExemplar
    ((rawTestExemplar (treeA) "first" -3 4 -1)
     (rawTestExemplar (treeB) "simpler-tie" -3 2 -20)
     (rawTestExemplar (treeC) "exact-tie" -3 2 0)
     (rawTestExemplar (treeY) "worse" -4 0 0)))
  (rawTestExemplar (treeB) "simpler-tie" -3 2 -20))

!(assertEqual (bestRawExemplar ()) ())

(= (test1-exemplars)
  (cons (mkExemplar (treeA) (mkDemeId "1") (mkCscore 0.8 0.3 0.1 0.01 0.4) (mkBscore (cons 1 (cons 1 ()))))  
    (cons (mkExemplar (tree2) (mkDemeId "2") (mkCscore 0.7 0.4 0.05 0.05 0.5) (mkBscore (cons 0 (cons 1 ())))) 
      (cons (mkExemplar (tree3) (mkDemeId "3") (mkCscore 0.6 0.5 0.0 0.0 0.6) (mkBscore (cons 1 (cons 0 ()))))    
        ()))))

!(assertEqual (let $choice (selectExemplar (test1-exemplars)) (OS.contains (test1-exemplars) $choice)) True)

(= (test2-exemplars)
  (cons (mkExemplar (treeA) (mkDemeId "101") (mkCscore 0.9 0.3 0.05 0.02 0.6) 
          (mkBscore (cons 1 (cons 1 (cons 1 (cons 1 ()))))))  
    (cons (mkExemplar (treeB) (mkDemeId "102") (mkCscore 0.6 0.5 0.1 0.1 0.5) (mkBscore (cons 1 (cons 1 (cons 1 (cons 1 ()))))))  
      (cons (mkExemplar (treeC) (mkDemeId "103") (mkCscore 0.4 0.4 0.05 0.1 0.4) (mkBscore (cons 0 (cons 0 (cons 1 (cons 0 ()))))))     
        ()))))
!(assertEqual (let $choice (selectExemplar (test2-exemplars)) (OS.contains (test2-exemplars) $choice)) True)

(= (metaPop) (cons (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ())) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ()))) (mkDemeId "1") (mkCscore -0.2 1 0.1 0.1 5) (mkBScore (cons 0 (cons 0 ()))))
                 (cons (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.6) (mkBScore (cons 0 (cons 0 ())))) 
                 (cons (mkExemplar (mkTree (mkNode OR) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode D) ()) ())) ())))) ())) (mkDemeId "1") (mkCscore -0.1 2 0.2 0.3 -0.006) (mkBScore (cons 0 (cons 0 ())))) ()))))
               
; ! (assertEqual (let $choice (selectExemplar metaPop) ((get-type $choice) (OS.contains metaPop $choice))) ((Exemplar Bool) True))
!(assertEqual (let $choice (selectExemplar (metaPop)) (OS.contains (metaPop) $choice))  True)
