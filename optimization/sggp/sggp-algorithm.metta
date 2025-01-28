;;An implementation of the paper called "Avoiding the Bloat with 
;;Stochastic Grammar-based Genetic Programming"
;
!(bind! &grammarSpace (new-space))
!(bind! &stochasticGrammarSpace (new-space))
!(bind! &alphabetSpace (new-space))
!(bind! &trainingSpace (new-space))
!(bind! rand (py-atom random.randint)) ;;pseudo random integers
!(bind! random (py-atom random.random)) ;;pseudo random real numbers from 0 to 1
!(bind! pow (py-atom pow))
(= (initializeAlphabetSpace $alphabetSpace)
    (add-reduct $alphabetSpace (superpose (start expr bop uop term)))
)
;;The below procedure will initialize the grammarSpace with a cfg
;; Written in context free grammar it will contain the following representation
;; <start> -> <expr>
;; <expr>  -> <bop> <expr> <expr> |
;;            <uop> <expr> |
;;            <term>
;; <bop>   -> AND | OR
;; <uop>   -> NOT
(= (initializeGrammarSpace $grammarSpace)
    (add-reduct $grammarSpace (superpose (
            (start expr)
            (expr (bop expr expr))
            (expr (uop expr))
            (expr term)
            (bop AND)
            (bop OR)
            (uop NOT)

        )
    )
    )
)
;; This function initializes the alphabet atom space with the non-terminals 
;; start expr bop uop term
(= (initializeAlphabetSpace $alphabetSpace)
    (add-reduct $alphabetSpace (superpose (start expr bop uop term)))
)
;; The following function filters production-rule provided a left hand side
;; <start> -> <expr>
;; <expr>  -> <bop> <expr> <expr> |
;;            <uop> <expr> |
;;            <term>
;; <bop>   -> AND | OR
;; <uop>   -> NOT
;; given  (filterProductionByLeftHandSide &grammarSpace expr) gives ((expr (bop expr expr) (expr (uop expr)) (expr term)))
(= (filterProductionByLeftHandSide $space $left)
    (collapse (match $space ($left $rhs) ($left $rhs)))
)
;; given a production it returns a new weighted production rule
;; example: input: (exp (uop exp)) ((exp (uop exp)) 5)
(= (assignWeight $rule $weight)
    (let ($parent $child) $rule
        ($parent $child $weight)
    )
)
;; This function adds terminals to the grammar space
;; for instance if the input is for $terminals is (x y z)
;;adds (term x), (term y) and (term z)
(= (addTerminalsToSpace $terminals $space)
    (add-atom $space (term (superpose $terminals)))
)
;;The below function initializes a weighted stochastic grammar for a single parent.
(= (initializeForSingleLhs $grammarSpace $parent)
    (let* (
            ($children (filterProductionByLeftHandSide $grammarSpace $parent))
            ($weight (rand 5 10)) ;;a random initial value to be assigned as weights
            ($weightedChildren (collapse (assignWeight (superpose $children) $weight)))
        )
        $weightedChildren
    )
)
;;This function updates weights using increment logic 
(= (updateWeight ($lhs $rhs $weight) $learnRate $cardinality inc)
    (let $updatedWeight (* $weight (pow (+ 1 $learnRate) $cardinality)) ($lhs $rhs $updatedWeight))
)
;; This function updates weights using decrement logic
(= (updateWeight ($lhs $rhs $weight) $learnRate $cardinality dec)
    (let $updatedWeight (/ $weight (pow (- 1 $learnRate) $cardinality)) ($lhs $rhs $updatedWeight))
)
;; The following function extracts the parent from the given tuple.
(= (extractParent ($lhs $rhs)) $lhs)
(= (extractParent ($lhs $rhs $weight)) $lhs)

;; the below function initializes a stochastic space.
(= (initializeStochasticSpace $alphabetSpace $grammarSpace $stocSpace)
    (let* (
        ($grammarAtoms (collapse (get-atoms $alphabetSpace)))
        ($weightedAtoms (collapse (initializeForSingleLhs $grammarSpace (superpose $grammarAtoms))))
    )
        (addListToSpace $stocSpace (superpose $weightedAtoms))
    )
    
)
;;This is a function that returns a modified rule due to mutation.
(= (mutateRule ($lhs $rhs $weight) $mutationRate) ($lhs $rhs (* $weight $mutationRate)))

;;This function extracts the weights of production rules from the atomspace 
;;The parent represents a left hand side production rule
(= (extractWeightsFromParent $parent $space)
    (collapse (match $space ($parent $child $weight) $weight))
)
;; check if the atom is a junctor
(= (isAtomJunctor $token)
    (if (or (== $token AND) (== $token OR)) True False)
)
;; This function fetches stochastic production rules with the same left hand side (lhs)
;; Example: input => expr output => (expr (bop expr expr) 7), (expr (uop expr) 4)
(= (findSuitableProdRules $lhs $stocSpace)
    (collapse (match $stocSpace ($lhs $rhs $weight) ($lhs $rhs $weight)))
)
;; getRelations separates a tree to a parent-child a reverse parseable expressions to the production 
;; rules.
;; Example: input => (AND x1 (OR x1 x2)), output ((AND x1 (OR x1 x2)) (OR x1 x2) x1 x2)
(= (getRelations $tree $accum)
    (if (== $tree ())  
        $accum 
        (let* (
            ($head (car-atom $tree))
            ($tail (cdr-atom $tree))
        )
            (if (== (get-metatype $head) Expression)
                (let* (
                    ($recur-result (getRelations $head ()))
                    ($newAccum (concatTuple $accum $recur-result))
                )
                    (getRelations $tail $newAccum)
                )
                (if (isAtomJunctor $head)
                    (let* (
                        ($left (car-atom $tail))
                        ($tail' (cdr-atom $tail))
                        ($right (car-atom $tail'))
                        ($newAccum (cons-atom ($head $left $right) $accum))
                    )
                        (getRelations $tail $newAccum)
                    )
                    (if (== $head NOT)
                        (let* (
                            ($child (car-atom $tail))
                            ($newAccum (cons-atom ($head $child) $accum))

                        )
                            (getRelations $tail $newAccum)
                        )
                        (let $newAccum (cons-atom $head $accum)
                            (getRelations $tail $newAccum)
                        )
                    )

                )
            )
        )
    )
)

(= (filter $compSign $func $expression $threshold)
    (if ( $compSign ($func $expression) $threshold)
        (empty)
        $expression
    )
)
(= (filterList $compSign $func $expressions $threshold)
    (collapse (filter $compSign $func (superpose $expressions) $threshold))
)
;;This procedure implements the reinforcing the production rule that is available.
(= (reinforceProd ($lhs $rhs $weight) $learnRate $cardinality $stocSpace)
    (let ($parent $child $updatedWeight) (updateWeight ($lhs $rhs $weight) $learnRate $cardinality inc)
        (updateAtomSpace $stocSpace ($lhs $rhs $weight) ($parent $child $updatedWeight))
    )
)
;; This procedure implements the punishing a specific production rule that is available.
(= (punishProd ($lhs $rhs $weight) $learnRate $cardinality $stocSpace)
    (let ($parent $child $updatedWeight) (updateWeight ($lhs $rhs $weight) $learnRate $cardinality dec)
        (updateAtomSpace $stocSpace ($lhs $rhs $weight) ($parent $child $updatedWeight))
    );; (exploitInstances $rhs $grammarSpace $stocSpace $explorationCoeff (- $depth 1))
)




