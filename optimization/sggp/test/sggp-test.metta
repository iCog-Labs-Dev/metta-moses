!(register-module! ../../../../metta-moses)
!(import! &self metta-moses:optimization:sggp:sggp-algorithm)
!(import! &self metta-moses:utilities:general-helpers)
;; !(import! &self metta-moses:utilities:test-helpers)
!(import! &self metta-moses:scoring:fitness)
;; !(bind! pow (py-atom pow))
;; This function checks if a tuple contains three entries
;; Example if tuple == (a b c) then the output will be true
;; if tuple == (a b) the the output will be false
(= (containsThreeVals $tuple)
    (unify $tuple ($x $y $z) True False)
)
;; The below two set of functions checks if the function is well formed. Well-formed 
;; In this context means that binary operators like AND and OR contain two or more children
;; NOT contains one child. And in addition it checks if terminals variables are leaf nodes.
(= (isWellFormedHelper $tree)
    (if (== (get-metatype $tree) Expression)
        (let ($head $tail) (decons $tree)
            (if (and (isAtomJunctor $head) (>= (len $tail) 2))
                (isWellFormedHelper (superpose $tail))
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
!(initializeAlphabetSpace &alphabetSpace)
!(addTerminalsToSpace (x y) &grammarSpace)
!(initializeStochasticSpace &alphabetSpace &grammarSpace &stochasticGrammarSpace)
;; !(superpose (initializeForSingleLhs &grammarSpace expr))
!(let $processedInitialization (initializeForSingleLhs &grammarSpace expr)
    (assertEqual (all (collapse (containsThreeVals (superpose $processedInitialization)))) True)
)
!(assertEqual (mutateRule (expr (bop expr expr) 5) 0.1) (expr (bop expr expr) 0.5))
!(get-atoms &stochasticGrammarSpace)

;; Tests for well formed expression.
!(assertEqual (isWellFormed (AND x1 x2)) True)
!(assertEqual (isWellFormed (AND x1)) False)
!(assertEqual (isWellFormed (AND x1 (OR x1 (AND x1 x2)))) True)
!(assertEqual (isWellFormed (AND x1 (OR x1 (AND x1)))) False)
!(assertEqual (isWellFormed (AND x1 (OR x1 (AND x1)))) False)
!(assertEqual (isWellFormed x1) True)
;; Tests for get Relations 
!(assertEqual (getRelations (AND x1 (OR x1 x2)) ()) (x1 (AND x1 (OR x1 x2)) x2 x1 (OR x1 x2)))
!(assertEqual (getRelations (AND x1 x2) ()) (x2 x1 (AND x1 x2)))
!(assertEqual (getRelations (AND x1 (OR x1 (AND x3 x4))) ()) (x1 (AND x1 (OR x1 (AND x3 x4))) x1 (OR x1 (AND x3 x4)) x4 x3 (AND x3 x4)))





 

