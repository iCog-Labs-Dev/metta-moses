! (register-module! ../../../metta-moses)
! (import! &self metta-moses:utilities:ordered-set)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:metapopulation:exemplar-type)

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
! (assertEqual (OS.insert compareNum 3 (ConsOS 2 (ConsOS 1 NilOS))) (ConsOS 3 (ConsOS 2 (ConsOS 1 NilOS))))
! (assertEqual (OS.insert compareNum 3 (ConsOS 5 (ConsOS 1 NilOS))) (ConsOS 5 (ConsOS 3 (ConsOS 1 NilOS))))
! (assertEqual (OS.insert compareNum -1 (ConsOS 5 (ConsOS 1 NilOS))) (ConsOS 5 (ConsOS 1 (ConsOS -1 NilOS))))

;; Exemplar comparison
! (assertEqual 
    (compareXmplr 
        (mkXmplr (mkTree (mkNode A) Nil) (mkDemeId 5) (mkCscore (mkScoreT 0.9) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))
        (mkXmplr (mkTree (mkNode B) Nil) (mkDemeId 6) (mkCscore (mkScoreT 0.3) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))) 
        G)
! (assertEqual 
    (compareXmplr 
        (mkXmplr (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) Nil)) (mkDemeId 6) (mkCscore (mkScoreT 0.4) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))
        (mkXmplr (mkTree (mkNode (NOT B)) Nil) (mkDemeId 5) (mkCscore (mkScoreT 0.4) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))) 
        E)
! (assertEqual 
    (compareXmplr 
        (mkXmplr (mkTree (mkNode C) Nil) (mkDemeId 3) (mkCscore (mkScoreT 0.3) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))
        (mkXmplr (mkTree (mkNode (NOT D)) Nil) (mkDemeId 4) (mkCscore (mkScoreT 0.4) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))) L)
                
;; Insert exemplars into an oreded set
! (assertEqual 
    (OS.insert compareXmplr (mkXmplr (mkTree treeA) (mkDemeId 5) (mkCscore (mkScoreT 0.5) (mkComplexity 0.35) (mkScoreT 0.78) (mkScoreT 0.69)) (mkBscore (Cons 1 (Cons 0 NilNum)))) NilOS)
    (ConsOS (mkXmplr (mkTree treeA) (mkDemeId 5) (mkCscore (mkScoreT 0.5) (mkComplexity 0.35) (mkScoreT 0.78) (mkScoreT 0.69)) (mkBscore (Cons 1 (Cons 0 NilNum)))) NilOS))  

! (assertEqual 
    (OS.insert compareXmplr (mkXmplr (mkTree treeX) (mkDemeId 10) 
        (mkCscore (mkScoreT 0.6) (mkComplexity 0.4) (mkScoreT 0.2) (mkScoreT 0.1)) 
        (mkBscore (Cons 3 (Cons 2 NilNum)))) NilOS)

    (ConsOS (mkXmplr (mkTree treeX) (mkDemeId 10) 
        (mkCscore (mkScoreT 0.6) (mkComplexity 0.4) (mkScoreT 0.2) (mkScoreT 0.1)) 
        (mkBscore (Cons 3 (Cons 2 NilNum)))) NilOS))

! (assertEqual (OS.insert compareXmplr (mkXmplr (mkTree treeC) (mkDemeId 7) (mkCscore (mkScoreT 0.6) (mkComplexity 0.30) (mkScoreT 0.70) (mkScoreT 0.55)) (mkBscore 1.30))  
   (ConsOS (mkXmplr (mkTree treeA) (mkDemeId 5) (mkCscore (mkScoreT 0.5) (mkComplexity 0.35) (mkScoreT 0.78) (mkScoreT 0.69)) (mkBscore (Cons 1 (Cons 0 NilNum))))
        (ConsOS (mkXmplr (mkTree treeB) (mkDemeId 6) (mkCscore (mkScoreT 0.2) (mkComplexity 0.55) (mkScoreT 0.90) (mkScoreT 0.72)) (mkBscore 1.25))  
            NilOS))) 
    (ConsOS (mkXmplr (mkTree treeC) (mkDemeId 7) (mkCscore (mkScoreT 0.6) (mkComplexity 0.30) (mkScoreT 0.70) (mkScoreT 0.55)) (mkBscore 1.30)) 
        (ConsOS (mkXmplr (mkTree treeA) (mkDemeId 5) (mkCscore (mkScoreT 0.5) (mkComplexity 0.35) (mkScoreT 0.78) (mkScoreT 0.69)) (mkBscore (Cons 1 (Cons 0 NilNum))))
        (ConsOS (mkXmplr (mkTree treeB) (mkDemeId 6) (mkCscore (mkScoreT 0.2) (mkComplexity 0.55) (mkScoreT 0.90) (mkScoreT 0.72)) (mkBscore 1.25))  
            NilOS))))
(assertEqual 
    (OS.insert compareXmplr 
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


;; Take N exemplars from the metapopulation
! (assertEqual (OS.takeN 0 (ConsOS 4 (ConsOS 3 (ConsOS 2 (ConsOS 1 (ConsOS 0 NilOS)))))) NilOS)
! (assertEqual (OS.takeN 1 (ConsOS 4 (ConsOS 3 (ConsOS 2 (ConsOS 1 (ConsOS 0 NilOS)))))) (ConsOS 4 NilOS))
! (assertEqual (OS.takeN 2 (ConsOS 4 (ConsOS 3 (ConsOS 2 (ConsOS 1 (ConsOS 0 NilOS)))))) (ConsOS 4 (ConsOS 3 NilOS)))
! (assertEqual (OS.takeN 3 (ConsOS 4 (ConsOS 3 (ConsOS 2 (ConsOS 1 (ConsOS 0 NilOS)))))) (ConsOS 4 (ConsOS 3 (ConsOS 2 NilOS))))
! (assertEqual (OS.takeN 4 (ConsOS 4 (ConsOS 3 (ConsOS 2 (ConsOS 1 (ConsOS 0 NilOS)))))) (ConsOS 4 (ConsOS 3 (ConsOS 2 (ConsOS 1 NilOS)))))
! (assertEqual (OS.takeN 5 (ConsOS 4 (ConsOS 3 (ConsOS 2 (ConsOS 1 (ConsOS 0 NilOS)))))) (ConsOS 4 (ConsOS 3 (ConsOS 2 (ConsOS 1 (ConsOS 0 NilOS))))))
! (assertEqual (OS.takeN 6 (ConsOS 4 (ConsOS 3 (ConsOS 2 (ConsOS 1 (ConsOS 0 NilOS)))))) (ConsOS 4 (ConsOS 3 (ConsOS 2 (ConsOS 1 (ConsOS 0 NilOS))))))

;; Test cases -- Remove by index
! (assertEqual (OS.removeByIdx (ConsOS 10 (ConsOS 20 NilOS)) 0) (ConsOS 20 NilOS))        
! (assertEqual (OS.removeByIdx (ConsOS a (ConsOS b (ConsOS c NilOS))) 1) (ConsOS a (ConsOS c NilOS)))
! (assertEqual (OS.removeByIdx (ConsOS 5 (ConsOS 6 (ConsOS 7 NilOS))) 2) (ConsOS 5 (ConsOS 6 NilOS)))
! (assertEqual (OS.removeByIdx (ConsOS 1 (ConsOS 2 NilOS)) 5) (Error NilOS "empty set/index out of range"))  

;; Test cases -- getTopN
!(assertEqual
   (OS.getTopN 2
      (mkOS
         (Cons
            (mkExemplar (mkTree (mkNode A) Nil) (mkDemeId "1") (mkCscore -0.1 2 0.1 0.1 -0.3) (mkBScore (Cons 0 Nil)))
            (Cons
               (mkExemplar (mkTree (mkNode B) Nil) (mkDemeId "1") (mkCscore -0.2 3 0.1 0.1 -0.4) (mkBScore (Cons 0 Nil)))
               (Cons
                  (mkExemplar (mkTree (mkNode C) Nil) (mkDemeId "1") (mkCscore -0.3 4 0.1 0.1 -0.5) (mkBScore (Cons 0 Nil)))
                  Nil)))))
   (mkOS
      (Cons
         (mkExemplar (mkTree (mkNode A) Nil) (mkDemeId "1") (mkCscore -0.1 2 0.1 0.1 -0.3) (mkBScore (Cons 0 Nil)))
         (Cons
            (mkExemplar (mkTree (mkNode B) Nil) (mkDemeId "1") (mkCscore -0.2 3 0.1 0.1 -0.4) (mkBScore (Cons 0 Nil)))
            Nil))))

!(assertEqual
   (OS.getTopN 5
      (mkOS
         (Cons
            (mkExemplar (mkTree (mkNode A) Nil) (mkDemeId "1") (mkCscore -0.1 2 0.1 0.1 -0.3) (mkBScore (Cons 0 Nil)))
            (Cons
               (mkExemplar (mkTree (mkNode B) Nil) (mkDemeId "1") (mkCscore -0.2 3 0.1 0.1 -0.4) (mkBScore (Cons 0 Nil)))
               Nil))))
   (mkOS
      (Cons
         (mkExemplar (mkTree (mkNode A) Nil) (mkDemeId "1") (mkCscore -0.1 2 0.1 0.1 -0.3) (mkBScore (Cons 0 Nil)))
         (Cons
            (mkExemplar (mkTree (mkNode B) Nil) (mkDemeId "1") (mkCscore -0.2 3 0.1 0.1 -0.4) (mkBScore (Cons 0 Nil)))
            Nil))))