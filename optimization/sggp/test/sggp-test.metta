!(register-module! ../../../../metta-moses)
!(import! &self metta-moses:optimization:sggp:sggp-algorithm)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:scoring:fitness)
;; !(bind! pow (py-atom pow))

(= (containsThreeVals $tuple)
    (unify $tuple ($x $y $z) True False)
)

(= (isWellFormedHelper $tree)
    (if (== (get-metatype $tree) Expression)
        (let ($head $tail) (decons $tree)
            (if (and (isAtomJunctor $head) (>= (len $tail) 2))
                (isWellFormedHelper (superpose $tree))
                (if (and (== $head NOT) (== (len $tail) 1))
                    True
                    False
                )
            )
        )
        True
    )
)
(= (isWellFormed $tree)
    (let $truthVals (collapse (isWellFormedHelper $tree))
        (all $truthVals)
    )
)



;; Tests for assign weights
!(assertEqual (assignWeight (expr (bop expr expr)) 5) (expr (bop expr expr) 5))
!(assertEqual (assignWeight (expr (uop expr)) 4) (expr (uop expr) 4))
!(assertEqual (assignWeight (expr term) 4) (expr term 4))
;; !(initializeGrammarSpace &grammarSpace)
!(assertEqual (updateWeight (expr (bop expr expr) 4) 0.5 5 inc) (expr (bop expr expr) (* 4 (pow (+ 1 0.5) 5))))
;; Tests for extracting parents
!(assertEqual (extractParent (expr (bop expr expr))) expr)
!(assertEqual (extractParent (expr (bop expr expr) 5)) expr)

;;tests for initiailizing single left hand side 

!(initializeGrammarSpace &grammarSpace)
;; !(superpose (initializeForSingleLhs &grammarSpace expr))
!(let $processedInitialization (initializeForSingleLhs &grammarSpace expr)
    (assertEqual (all (collapse (containsThreeVals (superpose $processedInitialization)))) True)
)
!(assertEqual (mutateRule (expr (bop expr expr) 5) 0.1) (expr (bop expr expr) 0.5))
;; !(isWellFormed (AND x1 x2))
;; !(isWellFormed (AND x1))
;; !(isWellFormed (AND x1 (OR x1 (AND x1 x2))))
;; !(isWellFormed (AND x1 (OR x1 (AND x1))))
;; !(isWellFormed x1)



