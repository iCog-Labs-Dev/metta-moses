!(import! &self utilities/general-helpers)
!(import! &self utilities/ordered-set)
!(import! &self metapopulation/exemplar-type)

;; Exemplar initialization
!(assertEqual (xmplrInit (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) (mkDemeId 1))
    (mkXmplr 
        (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ())))
        (mkDemeId 1) 
        (mkCscore 
            (mkScoreT (pow-math 10 -37))
            (mkComplexity 0)
            (mkScoreT 0)
            (mkScoreT (pow-math 10 -37)))
        (mkBscore ())))
!(assertEqual 
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

!(assertEqual 
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
