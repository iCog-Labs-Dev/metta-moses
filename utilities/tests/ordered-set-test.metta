! (register-module! ../../../metta-moses)
! (import! &self metta-moses:utilities:ordered-set)
! (import! &self metta-moses:utilities:exemplar-type)

;; Length of an ordered set
! (assertEqual (OS.length NilOS) 0)
! (assertEqual (OS.length (ConsOS 1 NilOS)) 1)
! (assertEqual (OS.length (ConsOS 4 (ConsOS 3 (ConsOS 2 (ConsOS 1 NilOS))))) 4)

;; Get element by index
! (assertEqual (OS.getByIdx 0 NilOS) (Error 0 "empty set/index out of range"))
! (assertEqual (OS.getByIdx 3 (ConsOS 3 (ConsOS 2 (ConsOS 1 NilOS)))) (Error 0 "empty set/index out of range"))
! (assertEqual (OS.getByIdx 0 (ConsOS 3 (ConsOS 2 (ConsOS 1 NilOS)))) 3)
! (assertEqual (OS.getByIdx 1 (ConsOS 3 (ConsOS 2 (ConsOS 1 NilOS)))) 2)
! (assertEqual (OS.getByIdx 2 (ConsOS 3 (ConsOS 2 (ConsOS 1 NilOS)))) 1)

;; Insert numerals into an ordered set 
! (assertEqual (OS.insert cmprNum 3 (ConsOS 2 (ConsOS 1 NilOS))) (ConsOS 3 (ConsOS 2 (ConsOS 1 NilOS))))
! (assertEqual (OS.insert cmprNum 3 (ConsOS 5 (ConsOS 1 NilOS))) (ConsOS 5 (ConsOS 3 (ConsOS 1 NilOS))))
! (assertEqual (OS.insert cmprNum -1 (ConsOS 5 (ConsOS 1 NilOS))) (ConsOS 5 (ConsOS 1 (ConsOS -1 NilOS))))

;; Exemplar comparison
! (assertEqual 
    (cmprXmplr 
        (mkXmplr (mkTree (mkNode A) Nil) (mkDemeId 5) (mkCscore (mkScoreT 0.9) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))
        (mkXmplr (mkTree (mkNode B) Nil) (mkDemeId 6) (mkCscore (mkScoreT 0.3) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))) 
        G)
! (assertEqual 
    (cmprXmplr 
        (mkXmplr (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) Nil)) (mkDemeId 6) (mkCscore (mkScoreT 0.4) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))
        (mkXmplr (mkTree (mkNode (NOT B)) Nil) (mkDemeId 5) (mkCscore (mkScoreT 0.4) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))) 
        E)
! (assertEqual 
    (cmprXmplr 
        (mkXmplr (mkTree (mkNode C) Nil) (mkDemeId 3) (mkCscore (mkScoreT 0.3) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))
        (mkXmplr (mkTree (mkNode (NOT D)) Nil) (mkDemeId 4) (mkCscore (mkScoreT 0.4) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))) L)
                
;; Insert exemplars into an oreded set
! (assertEqual 
    (OS.insert cmprXmplr (mkXmplr (mkTree treeA) (mkDemeId 5) (mkCscore (mkScoreT 0.5) (mkComplexity 0.35) (mkScoreT 0.78) (mkScoreT 0.69)) (mkBscore (Cons 1 (Cons 0 NilNum)))) NilOS)
    (ConsOS (mkXmplr (mkTree treeA) (mkDemeId 5) (mkCscore (mkScoreT 0.5) (mkComplexity 0.35) (mkScoreT 0.78) (mkScoreT 0.69)) (mkBscore (Cons 1 (Cons 0 NilNum)))) NilOS))  

! (assertEqual 
    (OS.insert cmprXmplr (mkXmplr (mkTree treeX) (mkDemeId 10) 
        (mkCscore (mkScoreT 0.6) (mkComplexity 0.4) (mkScoreT 0.2) (mkScoreT 0.1)) 
        (mkBscore (Cons 3 (Cons 2 NilNum)))) NilOS)

    (ConsOS (mkXmplr (mkTree treeX) (mkDemeId 10) 
        (mkCscore (mkScoreT 0.6) (mkComplexity 0.4) (mkScoreT 0.2) (mkScoreT 0.1)) 
        (mkBscore (Cons 3 (Cons 2 NilNum)))) NilOS))

! (assertEqual (OS.insert cmprXmplr (mkXmplr (mkTree treeC) (mkDemeId 7) (mkCscore (mkScoreT 0.6) (mkComplexity 0.30) (mkScoreT 0.70) (mkScoreT 0.55)) (mkBscore 1.30))  
   (ConsOS (mkXmplr (mkTree treeA) (mkDemeId 5) (mkCscore (mkScoreT 0.5) (mkComplexity 0.35) (mkScoreT 0.78) (mkScoreT 0.69)) (mkBscore (Cons 1 (Cons 0 NilNum))))
        (ConsOS (mkXmplr (mkTree treeB) (mkDemeId 6) (mkCscore (mkScoreT 0.2) (mkComplexity 0.55) (mkScoreT 0.90) (mkScoreT 0.72)) (mkBscore 1.25))  
            NilOS))) 
    (ConsOS (mkXmplr (mkTree treeC) (mkDemeId 7) (mkCscore (mkScoreT 0.6) (mkComplexity 0.30) (mkScoreT 0.70) (mkScoreT 0.55)) (mkBscore 1.30)) 
        (ConsOS (mkXmplr (mkTree treeA) (mkDemeId 5) (mkCscore (mkScoreT 0.5) (mkComplexity 0.35) (mkScoreT 0.78) (mkScoreT 0.69)) (mkBscore (Cons 1 (Cons 0 NilNum))))
        (ConsOS (mkXmplr (mkTree treeB) (mkDemeId 6) (mkCscore (mkScoreT 0.2) (mkComplexity 0.55) (mkScoreT 0.90) (mkScoreT 0.72)) (mkBscore 1.25))  
            NilOS))))
(assertEqual 
    (OS.insert cmprXmplr 
        (mkXmplr (mkTree treeB) (mkDemeId 15) 
            (mkCscore (mkScoreT 0.6) (mkComplexity 0.35) (mkScoreT 0.2) (mkScoreT 0.1)) 
            (mkBscore (Cons 1 NilNum)))
        
        (ConsOS (mkXmplr (mkTree treeA) (mkDemeId 5) 
            (mkCscore (mkScoreT 0.8) (mkComplexity 0.3) (mkScoreT 0.2) (mkScoreT 0.1)) 
            (mkBscore (Cons 3 NilNum)))

        (ConsOS (mkXmplr (mkTree treeC) (mkDemeId 25) 
            (mkCscore (mkScoreT 0.6) (mkComplexity 0.4) (mkScoreT 0.2) (mkScoreT 0.1)) 
            (mkBscore (Cons 2 NilNum))) NilOS)))
        
    (ConsOS (mkXmplr (mkTree treeA) (mkDemeId 5) 
        (mkCscore (mkScoreT 0.8) (mkComplexity 0.3) (mkScoreT 0.2) (mkScoreT 0.1)) 
        (mkBscore (Cons 3 NilNum)))

    (ConsOS (mkXmplr (mkTree treeB) (mkDemeId 15) 
        (mkCscore (mkScoreT 0.6) (mkComplexity 0.35) (mkScoreT 0.2) (mkScoreT 0.1)) 
        (mkBscore (Cons 1 NilNum)))

    (ConsOS (mkXmplr (mkTree treeC) (mkDemeId 25) 
        (mkCscore (mkScoreT 0.6) (mkComplexity 0.4) (mkScoreT 0.2) (mkScoreT 0.1)) 
        (mkBscore (Cons 2 NilNum))) NilOS))))


;; Remove n exemplars from the metapopulation
;; Error case: Removing from an empty list
! (assertEqual (OS.removen 1 NilOS) (Error 1 "empty set/index out of range"))
! (assertEqual (OS.removen 4 (ConsOS 3 (ConsOS 2 (ConsOS 1 NilOS)))) (Error 4 "empty set/index out of range"))
! (assertEqual (OS.removen 1 (ConsOS 3 (ConsOS 2 (ConsOS 1 NilOS)))) (ConsOS 3 (ConsOS 2 NilOS)))  ;; Remove last element
! (assertEqual (OS.removen 2 (ConsOS 3 (ConsOS 2 (ConsOS 1 NilOS)))) (ConsOS 3 NilOS))  ;; Remove last two elements
! (assertEqual (OS.removen 3 (ConsOS 3 (ConsOS 2 (ConsOS 1 NilOS)))) NilOS)  ;; Remove all elements
