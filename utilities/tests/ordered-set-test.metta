; ! (register-module! ../../../metta-moses)
!(import! &self ../general-helpers)
!(import! &self ../ordered-set)
!(import! &self ../../metapopulation/exemplar-type)

;; Length of an ordered set
!(println! ("testing: OS.length"))
!(assertEqual (OS.length ()) 0)
!(assertEqual (OS.length (cons 1 ())) 1)
!(assertEqual (OS.length (cons 4 (cons 3 (cons 2 (cons 1 ()))))) 4)

; ;; Get element by index
!(println! ("OS.getByIdx"))
!(assertEqual (OS.getByIdx 0 ()) (Error 0 "empty set/index out of range"))
!(assertEqual (OS.getByIdx 3 (cons 3 (cons 2 (cons 1 ())))) (Error 0 "empty set/index out of range"))
!(assertEqual (OS.getByIdx 0 (cons 3 (cons 2 (cons 1 ())))) 3)
!(assertEqual (OS.getByIdx 1 (cons 3 (cons 2 (cons 1 ())))) 2)
!(assertEqual (OS.getByIdx 2 (cons 3 (cons 2 (cons 1 ())))) 1)

; ;; Insert numerals into an ordered set 
!(println! ("testing: OS.insert"))
!(assertEqual (OS.insert compareNum 3 (cons 2 (cons 1 ()))) (cons 3 (cons 2 (cons 1 ()))))
!(assertEqual (OS.insert compareNum 3 (cons 5 (cons 1 ()))) (cons 5 (cons 3 (cons 1 ()))))
!(assertEqual (OS.insert compareNum -1 (cons 5 (cons 1 ()))) (cons 5 (cons 1 (cons -1 ()))))

; ;; Exemplar comparisonstring-to-number 
!(println! ("testing: compareXmplr "))
!(assertEqual 
    (compareXmplr 
        (mkXmplr (mkTree (mkNode A) ()) (mkDemeId 5) (mkCscore (mkScoreT 0.9) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))
        (mkXmplr (mkTree (mkNode B) ()) (mkDemeId 6) (mkCscore (mkScoreT 0.3) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))) 
        G)
!(assertEqual 
    (compareXmplr 
        (mkXmplr (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())) (mkDemeId 6) (mkCscore (mkScoreT 0.4) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))
        (mkXmplr (mkTree (mkNode (NOT B)) ()) (mkDemeId 5) (mkCscore (mkScoreT 0.4) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))) 
        E)
!(assertEqual 
    (compareXmplr 
        (mkXmplr (mkTree (mkNode C) ()) (mkDemeId 3) (mkCscore (mkScoreT 0.3) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))
        (mkXmplr (mkTree (mkNode (NOT D)) ()) (mkDemeId 4) (mkCscore (mkScoreT 0.4) (mkComplexity 0.42) (mkScoreT 0.85) (mkScoreT 0.63)) (mkBscore NilNum))) L)

; ;; Insert exemplars into an oreded set
!(assertEqual 
    (OS.insert compareXmplr (mkXmplr (mkTree treeA) (mkDemeId 5) (mkCscore (mkScoreT 0.5) (mkComplexity 0.35) (mkScoreT 0.78) (mkScoreT 0.69)) (mkBscore (cons 1 (cons 0 NilNum)))) ())
    (cons (mkXmplr (mkTree treeA) (mkDemeId 5) (mkCscore (mkScoreT 0.5) (mkComplexity 0.35) (mkScoreT 0.78) (mkScoreT 0.69)) (mkBscore (cons 1 (cons 0 NilNum)))) ()))  

!(assertEqual 
    (OS.insert compareXmplr (mkXmplr (mkTree treeX) (mkDemeId 10) 
        (mkCscore (mkScoreT 0.6) (mkComplexity 0.4) (mkScoreT 0.2) (mkScoreT 0.1)) 
        (mkBscore (cons 3 (cons 2 NilNum)))) ())

    (cons (mkXmplr (mkTree treeX) (mkDemeId 10) 
        (mkCscore (mkScoreT 0.6) (mkComplexity 0.4) (mkScoreT 0.2) (mkScoreT 0.1)) 
        (mkBscore (cons 3 (cons 2 NilNum)))) ()))

!(assertEqual (OS.insert compareXmplr (mkXmplr (mkTree treeC) (mkDemeId 7) (mkCscore (mkScoreT 0.6) (mkComplexity 0.30) (mkScoreT 0.70) (mkScoreT 0.55)) (mkBscore 1.30))  
   (cons (mkXmplr (mkTree treeA) (mkDemeId 5) (mkCscore (mkScoreT 0.5) (mkComplexity 0.35) (mkScoreT 0.78) (mkScoreT 0.69)) (mkBscore (cons 1 (cons 0 NilNum))))
        (cons (mkXmplr (mkTree treeB) (mkDemeId 6) (mkCscore (mkScoreT 0.2) (mkComplexity 0.55) (mkScoreT 0.90) (mkScoreT 0.72)) (mkBscore 1.25))  
            ()))) 
    (cons (mkXmplr (mkTree treeC) (mkDemeId 7) (mkCscore (mkScoreT 0.6) (mkComplexity 0.30) (mkScoreT 0.70) (mkScoreT 0.55)) (mkBscore 1.30)) 
        (cons (mkXmplr (mkTree treeA) (mkDemeId 5) (mkCscore (mkScoreT 0.5) (mkComplexity 0.35) (mkScoreT 0.78) (mkScoreT 0.69)) (mkBscore (cons 1 (cons 0 NilNum))))
        (cons (mkXmplr (mkTree treeB) (mkDemeId 6) (mkCscore (mkScoreT 0.2) (mkComplexity 0.55) (mkScoreT 0.90) (mkScoreT 0.72)) (mkBscore 1.25))  
            ()))))
!(assertEqual 
    (OS.insert compareXmplr 
        (mkXmplr (mkTree treeB) (mkDemeId 15) 
            (mkCscore (mkScoreT 0.6) (mkComplexity 0.35) (mkScoreT 0.2) (mkScoreT 0.1)) 
            (mkBscore (cons 1 NilNum)))

        (cons (mkXmplr (mkTree treeA) (mkDemeId 5) 
            (mkCscore (mkScoreT 0.8) (mkComplexity 0.3) (mkScoreT 0.2) (mkScoreT 0.1)) 
            (mkBscore (cons 3 NilNum)))

        (cons (mkXmplr (mkTree treeC) (mkDemeId 25) 
            (mkCscore (mkScoreT 0.6) (mkComplexity 0.4) (mkScoreT 0.2) (mkScoreT 0.1)) 
            (mkBscore (cons 2 NilNum))) ())))

    (cons (mkXmplr (mkTree treeA) (mkDemeId 5) 
        (mkCscore (mkScoreT 0.8) (mkComplexity 0.3) (mkScoreT 0.2) (mkScoreT 0.1)) 
        (mkBscore (cons 3 NilNum)))

    (cons (mkXmplr (mkTree treeB) (mkDemeId 15) 
        (mkCscore (mkScoreT 0.6) (mkComplexity 0.35) (mkScoreT 0.2) (mkScoreT 0.1)) 
        (mkBscore (cons 1 NilNum)))

    (cons (mkXmplr (mkTree treeC) (mkDemeId 25) 
        (mkCscore (mkScoreT 0.6) (mkComplexity 0.4) (mkScoreT 0.2) (mkScoreT 0.1)) 
        (mkBscore (cons 2 NilNum))) ()))))


; ;; Take N exemplars from the metapopulation
!(println! ("testing: OS.takeN "))
!(assertEqual (OS.takeN 0 (cons 4 (cons 3 (cons 2 (cons 1 (cons 0 ())))))) ())
!(assertEqual (OS.takeN 1 (cons 4 (cons 3 (cons 2 (cons 1 (cons 0 ())))))) (cons 4 ()))
!(assertEqual (OS.takeN 2 (cons 4 (cons 3 (cons 2 (cons 1 (cons 0 ())))))) (cons 4 (cons 3 ())))
!(assertEqual (OS.takeN 3 (cons 4 (cons 3 (cons 2 (cons 1 (cons 0 ())))))) (cons 4 (cons 3 (cons 2 ()))))
!(assertEqual (OS.takeN 4 (cons 4 (cons 3 (cons 2 (cons 1 (cons 0 ())))))) (cons 4 (cons 3 (cons 2 (cons 1 ())))))
!(assertEqual (OS.takeN 5 (cons 4 (cons 3 (cons 2 (cons 1 (cons 0 ())))))) (cons 4 (cons 3 (cons 2 (cons 1 (cons 0 ()))))))
!(assertEqual (OS.takeN 6 (cons 4 (cons 3 (cons 2 (cons 1 (cons 0 ())))))) (cons 4 (cons 3 (cons 2 (cons 1 (cons 0 ()))))))

; ;; Test cases -- Remove by index
!(println! ("testing: OS.removeByIdx "))
!(assertEqual (OS.removeByIdx (cons 10 (cons 20 ())) 0) (cons 20 ()))        
!(assertEqual (OS.removeByIdx (cons a (cons b (cons c ()))) 1) (cons a (cons c ())))
!(assertEqual (OS.removeByIdx (cons 5 (cons 6 (cons 7 ()))) 2) (cons 5 (cons 6 ())))
!(assertEqual (OS.removeByIdx (cons 1 (cons 2 ())) 5) (Error () "empty set/index out of range"))

; ;; Test cases -- getTopN
!(println! ("testing: OS.getTopN"))
!(assertEqual
   (OS.getTopN 2
         (cons
            (mkExemplar (mkTree (mkNode A) ()) (mkDemeId "1") (mkCscore -0.1 2 0.1 0.1 -0.3) (mkBScore (cons 0 ())))
            (cons
               (mkExemplar (mkTree (mkNode B) ()) (mkDemeId "1") (mkCscore -0.2 3 0.1 0.1 -0.4) (mkBScore (cons 0 ())))
               (cons
                  (mkExemplar (mkTree (mkNode C) ()) (mkDemeId "1") (mkCscore -0.3 4 0.1 0.1 -0.5) (mkBScore (cons 0 ())))
                  ()))))
      (cons
         (mkExemplar (mkTree (mkNode A) ()) (mkDemeId "1") (mkCscore -0.1 2 0.1 0.1 -0.3) (mkBScore (cons 0 ())))
         (cons
            (mkExemplar (mkTree (mkNode B) ()) (mkDemeId "1") (mkCscore -0.2 3 0.1 0.1 -0.4) (mkBScore (cons 0 ())))
            ())))

!(assertEqual
   (OS.getTopN 5
         (cons
            (mkExemplar (mkTree (mkNode A) ()) (mkDemeId "1") (mkCscore -0.1 2 0.1 0.1 -0.3) (mkBScore (cons 0 ())))
            (cons
               (mkExemplar (mkTree (mkNode B) ()) (mkDemeId "1") (mkCscore -0.2 3 0.1 0.1 -0.4) (mkBScore (cons 0 ())))
               ())))
        (Error () "empty ordered set/ fewer items than required"))

; ;; added test for Os.contains
!(println! ("testing: OS.contains "))
!(assertEqual (OS.contains (cons 1 (cons 2 (cons 3 ()))) 2) True)
!(assertEqual (OS.contains (cons 1 (cons 2 (cons 3 ()))) 4) False)
!(assertEqual (OS.contains () 5) False)

!(println! ("testing: genericCompare"))
!(assertEqual (genericCompare 2 1) L)      
!(assertEqual (genericCompare 1 2) G)      
!(assertEqual (genericCompare 5 5) E)      
!(assertEqual (genericCompare 0 1) G)    
!(assertEqual (genericCompare 10 5) L)     

!(println! ("testing: OS.range"))
!(assertEqual (OS.range 0 3 ()) (cons 0 (cons 1 (cons 2 ()))))
!(assertEqual (OS.range 1 4 ()) (cons 1 (cons 2 (cons 3 ()))))
!(assertEqual (OS.range 5 5 ()) ())     ;; Empty range
!(assertEqual (OS.range 2 6 ()) (cons 2 (cons 3 (cons 4 (cons 5 ())))))
!(assertEqual (OS.range 0 1 ()) (cons 0 ()))  ;; Single element

!(println! ("testing: OS.union"))
!(assertEqual (OS.union (cons 0 (cons 1 ())) (cons 2 ())) 
               (cons 0 (cons 1 (cons 2 ()))))
!(assertEqual (OS.union (cons 1 (cons 3 ())) (cons 0 (cons 2 ()))) 
               (cons 0 (cons 1 (cons 2 (cons 3 ())))))
!(assertEqual (OS.union () (cons 5 ())) (cons 5 ()))    ;; Empty first set
!(assertEqual (OS.union (cons 5 ()) ()) (cons 5 ()))    ;; Empty second set
!(assertEqual (OS.union (cons 1 (cons 2 ())) (cons 2 (cons 3 ()))) 
               (cons 1 (cons 2 (cons 3 ()))))               ;; Overlapping sets

!(println! ("testing OS.difference"))
!(assertEqual (OS.difference (cons 0 (cons 1 (cons 2 ()))) (cons 1 ()) ()) 
               (cons 0 (cons 2 ())))
!(assertEqual (OS.difference (cons 1 (cons 2 (cons 3 ()))) (cons 2 (cons 4 ())) ()) 
               (cons 1 (cons 3 ())))
!(assertEqual (OS.difference () (cons 1 ()) ()) ())    ;; Empty first set
!(assertEqual (OS.difference (cons 1 (cons 2 ())) () ()) 
               (cons 1 (cons 2 ())))                          ;; Empty second set
!(assertEqual (OS.difference (cons 1 (cons 2 ())) (cons 1 (cons 2 ())) ()) 
               ())                                                 ;; Identical sets
!(println! ("testing: osToExpression"))
!(assertEqual (osToExpression (cons 0 (cons 1 (cons 2 ()))) ()) (0 1 2))
!(assertEqual (osToExpression () ()) ())                          ;; Empty set
!(assertEqual (osToExpression (cons 5 ()) ()) (5))              ;; Single element
!(assertEqual (osToExpression (cons 3 (cons 1 (cons 4 ()))) ()) (3 1 4))  ;; Order preserved

;; INFO: Commented out because no expressionToOS usage is found that relies on this function creating the order required
;; !(println! ("testing: expressionToOS"))
;; !(assertEqual (expressionToOS (2 0 1) ()) (cons 0 (cons 1 (cons 2 ()))))
;; !(assertEqual (expressionToOS () ()) ())                       ;; Empty expression
;; !(assertEqual (expressionToOS (5) ()) (cons 5 ()))           ;; Single element
;; !(assertEqual (expressionToOS (3 1 4 1 5 9) ()) (cons 1 (cons 3 (cons 4 (cons 5 (cons 9 ()))))))  ;; Duplicates removed, sorted
