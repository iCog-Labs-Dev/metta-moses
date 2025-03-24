!(register-module! ../../../../metta-moses)
!(import! &self metta-moses:optimization:sggp:sggp-algorithm)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:scoring:fitness)
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
;;This is a function that checks if the enteries within an S-expression is an empty S-expression.
(= (isEmpty $exp) (all (collapse (if (== (superpose $exp) ()) True False))))
;; !(isEmpty (() ()))

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
!(addTerminalsToSpace (x1 x2) &grammarSpace)
!(initializeStochasticSpace &alphabetSpace &grammarSpace &stochasticGrammarSpace)
;; !(superpose (initializeForSingleLhs &grammarSpace expr))
!(let $processedInitialization (initializeForSingleLhs &grammarSpace expr)
    (assertEqual (all (collapse (containsThreeVals (superpose $processedInitialization)))) True)
)
!(assertEqual (mutateRule (expr (bop expr expr) 5) 0.1) (expr (bop expr expr) 0.5))
!(get-atoms &stochasticGrammarSpace)
!(get-atoms &grammarSpace)
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
;; Tests for getRuleFromSubTree
;; !(superpose (getRuleFromSubTree x1 &stochasticGrammarSpace))
!(getRuleFromSubTree x1 &stochasticGrammarSpace)
!(let $evaluated (getRuleFromSubTree x1 &stochasticGrammarSpace)
    (assertEqual (containsThreeVals $evaluated) True)
)
!(let $evaluated (getRuleFromSubTree (OR x1 x2) &stochasticGrammarSpace) 
    (assertEqual (all (collapse (containsThreeVals (superpose $evaluated)))) True)
)
!(let $evaluated (getRuleFromSubTree (OR x1 (AND x1 x2)) &stochasticGrammarSpace)
    (assertEqual (all (collapse (containsThreeVals (superpose $evaluated)))) True)
)
;; !(assertEqual (getRuleFromSubTree (NOT x1) &stochasticGrammarSpace) ((uop NOT) (expr (uop expr) $x2)))
!(let $evaluated (getRuleFromSubTree (NOT x1) &stochasticGrammarSpace) 
    (assertEqual (all (collapse (containsThreeVals (superpose $evaluated)))) True)
)
;; Tests for reinforceProdgrammar
!(let $weight (match &stochasticGrammarSpace (expr (bop expr expr) $x) $x)
    (assertEqual (reinforceProd (expr (bop expr expr) $weight) 0.1 10 &stochasticGrammarSpace) ())
)
!(let $weight (match &stochasticGrammarSpace (expr (uop expr) $x) $x)
    (assertEqual (reinforceProd (expr (uop expr) $weight) 0.1 10 &stochasticGrammarSpace) ())
)

;;Tests for punishProd
!(let $weight (match &stochasticGrammarSpace (expr (bop expr expr) $x) $x)
    (assertEqual (punishProd (expr (bop expr expr) $weight) 0.1 10 &stochasticGrammarSpace) ())
)
!(let $weight (match &stochasticGrammarSpace (expr (uop expr) $x) $x)
    (assertEqual (punishProd (expr (uop expr) $weight) 0.1 10 &stochasticGrammarSpace) ())
)
!(reinforceGrammarbasedOnTree (AND (OR x y) x) 0.01 15 &grammarSpace &stochasticGrammarSpace)
;;Tests for reinforceGrammarBasedOnTree
!(assertEqual (isEmpty (reinforceGrammarbasedOnTree (AND (OR x y) x) 0.01 15 &grammarSpace &stochasticGrammarSpace)) True)
!(assertEqual (isEmpty (reinforceGrammarbasedOnTree (OR x y) 0.01 15 &grammarSpace &stochasticGrammarSpace)) True)
!(get-atoms &stochasticGrammarSpace)
;;Tests for punishGrammarBasedOnTree
!(assertEqual (isEmpty (punishGrammarbasedOnTree (AND (OR x y) x) 0.01 15 &grammarSpace &stochasticGrammarSpace)) True)
!(assertEqual (isEmpty (punishGrammarbasedOnTree (AND (OR x y) x) 0.01 15 &grammarSpace &stochasticGrammarSpace)) True)
;;Tests for the generators
!(unique (generateTrees start &grammarSpace &stochasticGrammarSpace 3 3))
!(let $trees (collapse (unique (generateTrees start &grammarSpace &stochasticGrammarSpace 3 3)))
    (assertEqual (any (collapse (isWellFormed (superpose $trees)))) True)
)
!(let $trees (sggpHelper start 0.001 0.01 0.5 1 2 3 fitnessWithdata)
    (assertEqual (any (collapse (isWellFormed (superpose $trees)))) True)
)
;; !(fitnessWithdata (AND x1 (OR x1 x2)))
;; !(filter' >= fitnessWithdata (AND x1 x1) 0.5)
;;  !(fitnessWithdata (superpose ((AND x1 x1))))
;; !(collapse (filter' >= fitnessWithdata (NOT x1) 0.5))
;; !(getRelations () ())




 

