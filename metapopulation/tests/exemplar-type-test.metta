! (register-module! ../../../metta-moses)
; ! (import! &self metta-moses:utilities:ordered-set)
! (import! &self metta-moses:metapopulation:exemplar-type)

;; Exemplar initialization
! (assertEqual (xmplrInit (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) (mkDemeId 1))
    (mkXmplr 
        (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil)))
        (mkDemeId 1) 
        (mkCscore 
            (mkScoreT (pow-math 10 -37))
            (mkComplexity 0)
            (mkScoreT 0)
            (mkScoreT (pow-math 10 -37)))
        (mkBscore Nil)))
! (assertEqual 
    (xmplrInit (mkTree (mkTree (mkNode A) Nil)) (mkDemeId 2))
    (mkXmplr 
        (mkTree (mkTree (mkNode A) Nil))
        (mkDemeId 2) 
        (mkCscore 
            (mkScoreT (pow-math 10 -37))
            (mkComplexity 0)
            (mkScoreT 0)
            (mkScoreT (pow-math 10 -37)))
        (mkBscore Nil)))

! (assertEqual 
    (xmplrInit (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) (mkDemeId 100))
    (mkXmplr 
        (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil)))
        (mkDemeId 100) 
        (mkCscore 
            (mkScoreT (pow-math 10 -37))
            (mkComplexity 0)
            (mkScoreT 0)
            (mkScoreT (pow-math 10 -37)))
        (mkBscore Nil)))
