!(import! &self ../../../metta-moses/utilities/ordered-set)
!(import! &self ../../../metta-moses/metapopulation/exemplar-type)

;; Exemplar initialization
!(test (xmplrInit (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) (mkDemeId 1))
    (mkXmplr 
        (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ())))
        (mkDemeId 1) 
        (mkCscore 
            (mkScoreT (pow-math 10 -37))
            (mkComplexity 0)
            (mkScoreT 0)
            (mkScoreT (pow-math 10 -37)))
        (mkBscore ())))
!(test 
    (xmplrInit (mkTree (mkTree (mkNode A) ())) (mkDemeId 2))
    (mkXmplr 
        (mkTree (mkTree (mkNode A) ()))
        (mkDemeId 2) 
        (mkCscore 
            (mkScoreT (pow-math 10 -37))
            (mkComplexity 0)
            (mkScoreT 0)
            (mkScoreT (pow-math 10 -37)))
        (mkBscore ())))

!(test 
    (xmplrInit (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) (mkDemeId 100))
    (mkXmplr 
        (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ())))
        (mkDemeId 100) 
        (mkCscore 
            (mkScoreT (pow-math 10 -37))
            (mkComplexity 0)
            (mkScoreT 0)
            (mkScoreT (pow-math 10 -37)))
        (mkBscore ())))
