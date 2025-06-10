! (register-module! ../../../metta-moses)
! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:utilities:list-methods)

! (import! &self metta-moses:scoring:fitness)
! (import! &self metta-moses:scoring:bscore)
! (import! &self metta-moses:scoring:cscore)

! (bind! nan (py-atom math.nan))

; ;; Test cases for updatePenalizedScore
! (assertEqual (updatePenalizedScore (mkCscore  0  2  0.3 0.5  (* -1 (pow-math 10 308))) False) (mkCscore  0  2  0.3  0.5 -0.8))
! (assertEqual (updatePenalizedScore (mkCscore  -1  3  0.2  0.4 (* -1 (pow-math 10 308))) True) (mkCscore  -1  3  0.2  0.4  -0.48))
! (assertEqual (updatePenalizedScore (mkCscore  0  5  0.1  0.9 (* -1 (pow-math 10 308))) False) (mkCscore  0  5  0.1 0.9 -1.0))
! (assertEqual (updatePenalizedScore (mkCscore  -3 1 0.7 1.0  (* -1 (pow-math 10 308))) False) (mkCscore  -3 1  0.7 1.0  -4.7))

! (bind! ttable1 (mkITable (Cons (Cons True (Cons False (Cons True Nil)))
                        (Cons (Cons True (Cons True  (Cons True Nil))) Nil)) 
                        (Cons A (Cons B (Cons O Nil)))))
! (bind! ttable2 (mkITable
                    (Cons (Cons True (Cons True (Cons True Nil)))
                    (Cons (Cons True (Cons False (Cons False Nil)))
                    (Cons (Cons False (Cons True (Cons False Nil)))
                    (Cons (Cons False (Cons False (Cons False Nil))) Nil))))
                    (Cons A (Cons B (Cons Output Nil)))))

! (assertEqual (getCscore ttable1 (buildTree (AND A B)) 2.0) (mkCscore -1 2 1 0 -2))
! (assertEqual (getCscore ttable1 (buildTree (OR A B)) 4) (mkCscore 0 2 0.5 0 -0.5))
! (assertEqual (getCscore ttable2 (buildTree (AND A B)) 2.0) (mkCscore 0 2 1.0 0 -1.0))
! (assertEqual (getCscore ttable2 (buildTree (OR A B)) 1) (mkCscore -2 2 2.0 0 -4.0))

;; Test cases -- getComplexityCoef
! (assertEqual (getComplexityCoef 0.0) 0.0)
! (assertEqual (getComplexityCoef 2.0) 0.5)
! (assertEqual (getComplexityCoef 4) 0.25)

;; Test cases -- composite score less than comparator
! (assertEqual (cScore< (mkCscore -0.1 2 0.1 0.1 -0.3) (mkCscore -0.2 3 0.1 0.1 -0.4)) False)
! (assertEqual (cScore< (mkCscore -0.5 3 0.1 0.1 -0.7) (mkCscore -0.5 2 0.1 0.1 -0.7)) True)
! (assertEqual (cScore< (mkCscore -0.5 2 0.1 0.1 -0.7) (mkCscore -0.5 3 0.1 0.1 -0.7)) False)
! (assertEqual (cScore< (mkCscore -0.5 2 0.1 0.1 nan) (mkCscore -0.5 3 0.1 0.1 -0.7)) True)

;; Test cases -- composite score equality comparator 
! (assertEqual (cScore== (mkCscore -0.5 2 0.1 0.1 -0.7) (mkCscore -0.5 2 0.1 0.1 -0.7)) True)
! (assertEqual (cScore== (mkCscore -0.5 2 0.1 0.1 -0.7) (mkCscore -0.5000001 2.0000001 0.1 0.1 -0.7000001)) True)
! (assertEqual (cScore== (mkCscore -0.5 2 0.1 0.1 -0.7) (mkCscore -0.6 2 0.1 0.1 -0.8)) False)
! (assertEqual (cScore== (mkCscore -0.5 2 0.1 0.1 -0.7) (mkCscore -0.5 3 0.1 0.1 -0.7)) False)
