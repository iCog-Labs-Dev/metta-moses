!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/tree)

!(import! &self ../../scoring/cacheSpace)


!(import! &self ../fitness)
!(import! &self ../boolean-ops)
!(import! &self ../bscore)
!(import! &self ../cscore)

;; Tests for cScoreToExpr
!(assertEqual (cScoreToExpr (mkCscore 0.0 0.0 0.0 0.0 0.0)) ((0.0 0.0 0.0 0.0 0.0)))
!(assertEqual (cScoreToExpr (mkCscore 1.0 2.0 0.5 0.5 0.0)) ((1.0 2.0 0.5 0.5 0.0)))
!(assertEqual (cScoreToExpr (mkCscore -1.0 3.0 0.2 0.4 -0.8)) ((-1.0 3.0 0.2 0.4 -0.8)))

;; Test cases for updatePenalizedScore
!(assertEqual (updatePenalizedScore (mkCscore  0  2  0.3 0.5  (* -1 (pow-math 10 308))) False) (mkCscore  0  2  0.3  0.5 -0.8))
!(assertEqual (updatePenalizedScore (mkCscore  -1  3  0.2  0.4 (* -1 (pow-math 10 308))) True) (mkCscore  -1  3  0.2  0.4  -0.48))
!(assertEqual (updatePenalizedScore (mkCscore  0  5  0.1  0.9 (* -1 (pow-math 10 308))) False) (mkCscore  0  5  0.1 0.9 -1.0))
!(assertEqual (updatePenalizedScore (mkCscore  -3 1 0.7 1.0  (* -1 (pow-math 10 308))) False) (mkCscore  -3 1  0.7 1.0  -4.7))


(= (ttable1)
    (mkITable
        (cons (cons True (cons True ()))
        (cons (cons False (cons True ()))
        (cons (cons True (cons True ())) ())))
        (cons A (cons B (cons O ())))))

(= (ttable2)
    (mkITable
        (cons (cons True (cons True (cons False (cons False ()))))
        (cons (cons True (cons False (cons True (cons False ()))))
        (cons (cons True (cons False (cons False (cons False ())))) ())))
        (cons A (cons B (cons Output ())))))


;; candidates ride under quote: this file loads boolean-ops' AND/OR/NOT
;; eval clauses, so a bare (AND A B) at a call site would compile as a call.
!(assertEqual (getCscore (ttable1) (buildTree (quote (AND A B))) 2.0 &bscoreCache) (mkCscore -1 2 1.0 0.0 -2.0))
!(assertEqual (getCscore (ttable1) (buildTree (quote (OR A B))) 4 &bscoreCache) (mkCscore 0 2 0.5 0.0 -0.5))
;; the results of the following two tests will be the same as the above two because the trees are the same because it uses the cacheSpace
; ! (assertEqual (getCscore ttable2 (buildTree (AND A B)) 2.0) (mkCscore 0 2 1.0 0 -1.0))
; ! (assertEqual (getCscore ttable2 (buildTree (OR A B)) 1) (mkCscore -2 2 2.0 0 -4.0))

;; Test cases -- getComplexityCoef
!(assertEqual (getComplexityCoef 0.0) 0.0)
!(assertEqual (getComplexityCoef 2.0) 0.5)
!(assertEqual (getComplexityCoef 4) 0.25)

;; Test cases -- composite score less than comparator (via apply)
!(assertEqual (apply < (mkCscore -0.1 2 0.1 0.1 -0.3) (mkCscore -0.2 3 0.1 0.1 -0.4)) False)
!(assertEqual (apply < (mkCscore -0.5 3 0.1 0.1 -0.7) (mkCscore -0.5 2 0.1 0.1 -0.7)) True)
!(assertEqual (apply < (mkCscore -0.5 2 0.1 0.1 -0.7) (mkCscore -0.5 3 0.1 0.1 -0.7)) False)
!(assertEqual (apply < (mkCscore -0.5 2 0.1 0.1 nan) (mkCscore -0.5 3 0.1 0.1 -0.7)) True)

;; Test cases -- composite score equality comparator (via apply)
!(assertEqual (apply == (mkCscore -0.5 2 0.1 0.1 -0.7) (mkCscore -0.5 2 0.1 0.1 -0.7)) True)
!(assertEqual (apply == (mkCscore -0.5 2 0.1 0.1 -0.7) (mkCscore -0.5000001 2.0000001 0.1 0.1 -0.7000001)) True)
!(assertEqual (apply == (mkCscore -0.5 2 0.1 0.1 -0.7) (mkCscore -0.6 2 0.1 0.1 -0.8)) False)
!(assertEqual (apply == (mkCscore -0.5 2 0.1 0.1 -0.7) (mkCscore -0.5 3 0.1 0.1 -0.7)) False)

;; --- Tests for expression conversion functions ---

;; Test exprToCScore - converting expressions back to Cscore objects
!(assertEqual (exprToCScore ((0.0 0.0 0.0 0.0 0.0))) (mkCscore 0.0 0.0 0.0 0.0 0.0))
!(assertEqual (exprToCScore ((100.0 5.0 10.0 2.0 88.0))) (mkCscore 100.0 5.0 10.0 2.0 88.0))

;; Test round-trip conversion for cScoreToExpr and exprToCScore
!(assertEqual (let* (
  ($expr1 (cScoreToExpr (mkCscore 0.0 0.0 0.0 0.0 0.0)))
  ($result1 (exprToCScore $expr1))
) $result1) (mkCscore 0.0 0.0 0.0 0.0 0.0))

;; Test cScoreExpr< - comparing score expressions directly
;; Test cases where first score is less than second (should return True)
!(assertEqual (cScoreExpr< ((1.0 2.0 0.5 0.5 0.0)) ((0.0 0.0 0.0 0.0 0.0))) True)
!(assertEqual (cScoreExpr< ((-0.5 3 0.1 0.1 -0.7)) ((-0.4 2 0.1 0.1 -0.6))) True)
!(assertEqual (cScoreExpr< ((-0.5 3 0.1 0.1 -0.7)) ((-0.5 2 0.1 0.1 -0.7))) True)
;; Same penalized score, but first has lower complexity

;; Test cases where first score is greater than second (should return False)
!(assertEqual (cScoreExpr< ((0.0 0.0 0.0 0.0 0.0)) ((1.0 2.0 0.5 0.5 0.0))) False)
!(assertEqual (cScoreExpr< ((-0.4 2 0.1 0.1 -0.6)) ((-0.5 3 0.1 0.1 -0.7))) False)
!(assertEqual (cScoreExpr< ((-0.5 2 0.1 0.1 -0.7)) ((-0.5 3 0.1 0.1 -0.7))) False)  

;;
;; Test edge cases for cScoreExpr<
!(assertEqual (cScoreExpr< ((0.0 0.0 0.0 0.0 0.0)) ((0.0 0.0 0.0 0.0 0.0))) False)  ;; Equal scores
!(assertEqual (cScoreExpr< ((nan 0.0 0.0 0.0 nan)) ((0.0 0.0 0.0 0.0 0.0))) True)   ;;nan handling
!(assertEqual (cScoreExpr< ((0.0 0.0 0.0 0.0 0.0)) ((nan 0.0 0.0 0.0 nan))) False)  ;; nan handling

;; Test that cScoreExpr< matches apply < behavior for equivalent inputs
!(assertEqual (let* (
  ($score1 (mkCscore -0.1 2 0.1 0.1 -0.3))
  ($score2 (mkCscore -0.2 3 0.1 0.1 -0.4))
  ($expr1 (cScoreToExpr $score1))
  ($expr2 (cScoreToExpr $score2))
  ($exprResult (cScoreExpr< $expr1 $expr2))
  ($objResult (apply < $score1 $score2))
) (== $exprResult $objResult)) True)

!(assertEqual (let* (
  ($score3 (mkCscore -0.5 3 0.1 0.1 -0.7))
  ($score4 (mkCscore -0.5 2 0.1 0.1 -0.7))
  ($expr3 (cScoreToExpr $score3))
  ($expr4 (cScoreToExpr $score4))
  ($exprResult (cScoreExpr< $expr3 $expr4))
  ($objResult (apply < $score3 $score4))
) (== $exprResult $objResult)) True)

;; ============================================================
;; Tests for cScore>= (standard 2-arg and overloaded 4-arg)
;; ============================================================

;; 1. Standard 2-arg: Penalized score strictly greater
!(assertEqual (cScore>= (mkCscore 0.0 2 0.1 0.0 -0.5) (mkCscore 0.0 2 0.1 0.0 -0.8)) True)
!(assertEqual (cScore>= (mkCscore 0.0 2 0.1 0.0 -0.8) (mkCscore 0.0 2 0.1 0.0 -0.5)) False)

;; 2. Standard 2-arg: Penalized score tied -> lower complexity wins
!(assertEqual (cScore>= (mkCscore 0.0 2 0.1 0.0 -0.5) (mkCscore 0.0 3 0.1 0.0 -0.5)) True)
!(assertEqual (cScore>= (mkCscore 0.0 3 0.1 0.0 -0.5) (mkCscore 0.0 2 0.1 0.0 -0.5)) False)

;; 3. Overloaded 4-arg: Penalized score and complexity tied -> higher raw score wins
!(assertEqual (cScore>= (mkCscore -2.0 3 0.1 0.0 -3.0) 
                        (mkCscore -3.0 3 0.1 0.0 -3.0) 
                        (buildTree (quote (AND A B C))) 
                        (buildTree (quote (AND A B C)))) True)
!(assertEqual (cScore>= (mkCscore -3.0 3 0.1 0.0 -3.0) 
                        (mkCscore -2.0 3 0.1 0.0 -3.0) 
                        (buildTree (quote (AND A B C))) 
                        (buildTree (quote (AND A B C)))) False)

;; 4. Overloaded 4-arg: Penalized score, complexity, AND raw score tied -> smaller tree size wins
;; Tree 1: (AND A B C) -> complexity 3, treeSize 4
;; Tree 2: (AND A (OR (NOT B) (NOT C))) -> complexity 3, treeSize 7
!(assertEqual (cScore>= (mkCscore -3.0 3 0.1 0.0 -3.0) 
                        (mkCscore -3.0 3 0.1 0.0 -3.0) 
                        (buildTree (quote (AND A B C))) 
                        (buildTree (quote (AND A (OR (NOT B) (NOT C)))))) True)
!(assertEqual (cScore>= (mkCscore -3.0 3 0.1 0.0 -3.0) 
                        (mkCscore -3.0 3 0.1 0.0 -3.0) 
                        (buildTree (quote (AND A (OR (NOT B) (NOT C))))) 
                        (buildTree (quote (AND A B C)))) False)
