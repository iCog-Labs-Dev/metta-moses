!(import! &self ../../utilities/tree)
!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)

!(import! &self ../fitness)
!(import! &self ../bscore)
!(import! &self ../cscore)
!(import! &self ../cacheSpace)

;; Tests for cScoreToExpr
!(assertEqual (cScoreToExpr (mkCscore 0.0 0.0 0.0 0.0 0.0)) ((0.0 0.0 0.0 0.0 0.0)))
!(assertEqual (cScoreToExpr (mkCscore 1.0 2.0 0.5 0.5 0.0)) ((1.0 2.0 0.5 0.5 0.0)))
!(assertEqual (cScoreToExpr (mkCscore -1.0 3.0 0.2 0.4 -0.8)) ((-1.0 3.0 0.2 0.4 -0.8)))
              
; ;; Test cases for updatePenalizedScore
!(assertEqual (updatePenalizedScore (mkCscore  0  2  0.3 0.5  (* -1 (pow-math 10 308))) False) (mkCscore  0  2  0.3  0.5 -0.8))
!(assertEqual (updatePenalizedScore (mkCscore  -1  3  0.2  0.4 (* -1 (pow-math 10 308))) True) (mkCscore  -1  3  0.2  0.4  -0.48))
!(assertEqual (updatePenalizedScore (mkCscore  0  5  0.1  0.9 (* -1 (pow-math 10 308))) False) (mkCscore  0  5  0.1 0.9 -1.0))
!(assertEqual (updatePenalizedScore (mkCscore  -3 1 0.7 1.0  (* -1 (pow-math 10 308))) False) (mkCscore  -3 1  0.7 1.0  -4.7))


(= (ttable1)
    (mkITable
        (Cons (Cons True (Cons False (Cons True Nil)))
        (Cons (Cons True (Cons True (Cons True Nil))) Nil))
        (Cons A (Cons B (Cons O Nil)))))

(= (ttable2)
    (mkITable
        (Cons (Cons True (Cons True (Cons True Nil)))
        (Cons (Cons True (Cons False (Cons False Nil)))
        (Cons (Cons False (Cons True (Cons False Nil)))
        (Cons (Cons False (Cons False (Cons False Nil))) Nil))))
        (Cons A (Cons B (Cons Output Nil)))))


!(assertEqual (getCscore (ttable1) (buildTree (AND A B)) 2.0 &cacheSpace) (mkCscore -1 2 1.0 0.0 -2.0))
!(assertEqual (getCscore (ttable1) (buildTree (OR A B)) 4 &cacheSpace) (mkCscore 0 2 0.5 0.0 -0.5))
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
