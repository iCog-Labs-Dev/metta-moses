! (register-module! ../../../metta-moses)
! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:utilities:list-methods)

! (import! &self metta-moses:scoring:fitness)
! (import! &self metta-moses:scoring:bscore)
! (import! &self metta-moses:scoring:cscore)

; ;; Test cases for updatePenalizedScore
! (assertEqual
    (updatePenalizedScore (mkCscore (mkScoreT 0) (mkComplexity 2) (mkScoreT 0.3) (mkScoreT 0.5) (mkScoreT (pow-math 10 -308))) False)
    (mkCscore (mkScoreT 0) (mkComplexity 2) (mkScoreT 0.3) (mkScoreT 0.5) (mkScoreT -0.8)))
! (assertEqual
        (updatePenalizedScore (mkCscore (mkScoreT -1) (mkComplexity 3) (mkScoreT 0.2) (mkScoreT 0.4) (mkScoreT (pow-math 10 -308))) True)
        (mkCscore (mkScoreT -1) (mkComplexity 3) (mkScoreT 0.2) (mkScoreT 0.4) (mkScoreT -0.48)))
! (assertEqual
        (updatePenalizedScore (mkCscore (mkScoreT 0) (mkComplexity 5) (mkScoreT 0.1) (mkScoreT 0.9) (mkScoreT 0.01)) False)
        (mkCscore (mkScoreT 0) (mkComplexity 5) (mkScoreT 0.1) (mkScoreT 0.9) (mkScoreT -1.0)))
! (assertEqual
        (updatePenalizedScore (mkCscore (mkScoreT -3) (mkComplexity 1) (mkScoreT 0.7) (mkScoreT 1.0) (mkScoreT 100.0)) False)
        (mkCscore (mkScoreT -3) (mkComplexity 1) (mkScoreT 0.7) (mkScoreT 1.0) (mkScoreT -4.7)))

! (bind! ttable1 (mkITable (Cons (Cons True (Cons False (Cons True Nil)))
                        (Cons (Cons True (Cons True  (Cons True Nil))) Nil)) 
                        (Cons A (Cons B (Cons O Nil)))))
! (bind! ttable2 (mkITable
                    (Cons (Cons True (Cons True (Cons True Nil)))
                    (Cons (Cons True (Cons False (Cons False Nil)))
                    (Cons (Cons False (Cons True (Cons False Nil)))
                    (Cons (Cons False (Cons False (Cons False Nil))) Nil))))
                    (Cons A (Cons B (Cons Output Nil)))))

! (assertEqual 
        (getCscore ttable1 (buildTree (AND A B)) 0.3) 
            (mkCscore (mkScoreT -1) (mkComplexity 2) (mkScoreT 1.6362) (mkScoreT 0) (mkScoreT -2.6362)))
! (assertEqual 
        (getCscore ttable1 (buildTree (OR A B)) 0.2) 
            (mkCscore (mkScoreT 0) (mkComplexity 2) (mkScoreT 1.0) (mkScoreT 0) (mkScoreT -1.0)))
! (assertEqual 
        (getCscore ttable2 (buildTree (AND A B)) 0.2) 
            (mkCscore (mkScoreT 0) (mkComplexity 2) (mkScoreT 1.0) (mkScoreT 0) (mkScoreT -1.0)))
! (assertEqual 
        (getCscore ttable2 (buildTree (OR A B)) 0.2) 
            (mkCscore (mkScoreT -2) (mkComplexity 2) (mkScoreT 1.0) (mkScoreT 0) (mkScoreT -3.0)))
