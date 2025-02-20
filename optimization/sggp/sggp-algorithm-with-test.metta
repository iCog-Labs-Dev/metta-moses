;;An implementation of the paper called "Avoiding the Bloat with 
;;Stochastic Grammar-based Genetic Programming"

!(register-module! ../../../metta-moses)

!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:scoring:fitness)


!(bind! &grammarSpace (new-space))
!(bind! &stochasticGrammarSpace (new-space))
!(bind! &alphabetSpace (new-space))
!(bind! &trainingSpace (new-space))
!(bind! rand (py-atom random.randint)) ;;pseudo random integers
!(bind! random (py-atom random.random)) ;;pseudo random real numbers from 0 to 1
!(bind! pow (py-atom pow))


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
;; This function calculates probability of a production rule
(= (calculateProbability ($lhs $rhs) $space)
    (let* (
        ($totalValue (sum (extractWeightsFromParent $lhs $space)))
        ($weight (match $space ($lhs $rhs $value) $value))
    ) 
        (/ $weight $totalValue)
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

;; (= (filter $compSign $func $expression $threshold)
;;     (if ( $compSign ($func $expression) $threshold)
;;         (empty)
;;         $expression
;;     )
;; )
;; (= (filterList $compSign $func $expressions $threshold)
;;     (collapse (filter $compSign $func (superpose $expressions) $threshold))
;; )

;; getRule from sub-tree expression and grammarSpace
;;bop (bop exp1 exp2)
;;uop (uop exp1)
;;term x1 ==> (term x1)
;; $_ x1
;; (= (getRuleFromSubTree $expression $stocSpace)
;;     (unify $expression ($op $exp1 $exp2)
;;         (match $stocSpace (, ($opType $op $weight1)
;;                                 ($exp ($opType $exp $exp) $weight2)

;;                         )
;;                         (($opType $op $weight1) ($exp ($opType $exp $exp) $weight2))

;;         )
;;         (unify $expression ($op $exp1)
;;             (match $stocSpace (, 
;;                                 ($opType $op $weight1) 
;;                                 ($exp ($opType $exp) $weight2)
;;                             )
;;                                 (($opType $op $weight1) ($exp ($opType $exp) $weight2))
;;                             )
;;             ;; (match $grammarSpace ($parent $expression)
;;             ;;     (let* (
;;             ;;         (() (println! (This is the parent $parent)))
;;             ;;         (() (println! (This is the expression $expression)))

;;             ;;     )
;;             ;;         ($parent $expression)
;;             ;;     )  
;;             ;; )
;;             ;;(term $expression)
;;             (match $stocSpace ($parent $expression $weight)
;;                 ($parent $expression $weight)
;;             )
;;         )
         
;;     )

;; )

;; getRule from sub-tree expression and grammarSpace
;;bop (bop exp1 exp2)
;;uop (uop exp1)
;;term x1 ==> (term x1)
;; $_ x1
(= (getRuleFromSubTree $expression $stocSpace)
    (case $expression (
        (($op $exp1 $exp2) (match $stocSpace (, ($opType $op $weight1)
                                ($exp ($opType $exp $exp) $weight2)

                        )
                        (($opType $op $weight1) ($exp ($opType $exp $exp) $weight2))

        ))
        (($op $exp1) (match $stocSpace (, 
                                ($opType $op $weight1) 
                                ($exp ($opType $exp) $weight2)
                            )
                                (($opType $op $weight1) ($exp ($opType $exp) $weight2))
                            ))
        ($_ (match $stocSpace ($parent $expression $weight)
                ($parent $expression $weight)
            ))


    )
    )
)

;; a helper that extracts the best after comparing with the threshold.
(= (filter' $compSign $func $expression $threshold)
    (if ($compSign ($func $expression) $threshold)
        $expression
        (empty)
    )
)

;;The following function leverages Non-determinism to filter a function
;; based on a predicated
(= (filterList $compSign $func $expressions $threshold)
    (let $expressions' (superpose $expressions)
        (collapse (filter' $compSign $func $expressions' $threshold))
    )
)


;;This procedure implements the reinforcing the production rule that is available.
(= (reinforceProd ($lhs $rhs $weight) $learnRate $cardinality $stocSpace)
    (let ($parent $child $updatedWeight) (updateWeight ($lhs $rhs $weight) $learnRate $cardinality inc)
        (update-atom $stocSpace ($lhs $rhs $weight) ($parent $child $updatedWeight))
    )
)


;; This procedure works if multiple weights happen 
(= (reinforceProd ($prod1 $prod2) $learnRate $cardinality $stocSpace)
    (let* (
        ($res (reinforceProd $prod1 $learnRate $cardinality $stocSpace))
        ($res' (reinforceProd $prod2 $learnRate $cardinality $stocSpace))
        (() (println! (reinforceProd works)))
    )
        ()
    )
)


;; This procedure implements the punishing a specific production rule that is available.
(= (punishProd ($lhs $rhs $weight) $learnRate $cardinality $stocSpace)
    (let ($parent $child $updatedWeight) (updateWeight ($lhs $rhs $weight) $learnRate $cardinality dec)
        (update-atom $stocSpace ($lhs $rhs $weight) ($parent $child $updatedWeight))
    )
)
(= (punishProd ($prod1 $prod2) $learnRate $cardinality $stocSpace)
    (let* (
        ($res (punsihProd $prod1 $learnRate $cardinality $stocSpace))
        ($res' (punishProd $prod2 $learnRate $cardinality $stocSpace))
    )
        ()
    )
)



;; This procedure implements the reinforcement of the reinforcement of a grammar given a Tree
;; The below commented function call implements a parallelized update on the atomspace.
(= (reinforceGrammarbasedOnTree $tree $learnRate $cardinality $grammarSpace $stocSpace)
    (let* (
        ($relations (getRelations $tree ()))
        ($prodRules (collapse (getRuleFromSubTree (superpose $relations) $stocSpace)))
        ;; (() (println! (production rules $prodRules)))
    
    )
        (reinforceTreeHelper $prodRules $learnRate $cardinality $stocSpace)
        ;;(collapse (reinforceProd (superpose $prodRules) $learnRate $cardinality $stocSpace))
    )
)

;;Helper for a reinforceGrammarBased on Tree
(=(reinforceTreeHelper $distributedProdRules $learnRate $cardinality $stocSpace)
    (if (== $distributedTrees ())
        ()
        (let* (
            (($head $tail) (decons $distributedProdRules))
            ($reinforced (reinforceProd $head $learnRate $cardinality $stocSpace))
            ($stocAtoms (collapse (get-atoms $stocSpace)))
            (() (println! (stocAtoms $stocAtoms head $head tail $tail)))
        )
            (reinforceTreeHelper $tail $learnRate $cardinality $stocSpace)
        )
    )
)

;;iterates on a set of trees to reinforce grammars.
(= (reinforceTreeRulesIterator $setOfTrees $learnRate $cardinality  $grammarSpace $stocSpace)
    (if (== $setOfTrees ())
        ()
        (let* (
            (($head $tail) (decons $setOfTrees))
            ($_ (reinforceGrammarbasedOnTree $head $learnRate $cardinality  $grammarSpace $stocSpace))
        )
            (reinforceTreeRulesIterator $tail $learnRate $cardinality $grammarSpace $stocSpace)
        )
    )
)


;; $helper for punish tree helper
(=(punishTreeHelper $distributedProdRules $learnRate $cardinality $stocSpace)
    (if (== $distributedTrees ())
        ()
        (let* (
            (($head $tail) (decons $distributedProdRules))
            ($_ (punishProd $head $learnRate $cardinality $stocSpace))
        )
            (punishTreeHelper $tail $learnRate $cardinality $stocSpace)
        )
    )
)

;; The below piece of code punishes the production rule in a stochastic grammar based on a tree
(= (punishGrammarbasedOnTree $tree $learnRate $cardinality $grammarSpace $stocSpace)
    (let* (
        ($relations (getRelations $tree ()))
        ($prodRules (collapse (getRuleFromSubTree (superpose $relations) $stocSpace)))
        ;; (println (production rules $prodRules))
    )
        ;;(collapse (punishProd (superpose $prodRules) $learnRate $cardinality $stocSpace))
        (punishTreeHelper $prodRules $learnRate $cardinality $stocSpace)
    )
)


;;Iterates through punished trees and updates the stochastic grammar space 
(= (punishTreeRulesIterator $setOfTrees $learnRate $cardinality  $grammarSpace $stocSpace)
    (if (== $setOfTrees ())
        ()
        (let* (
            (($head $tail) (decons $setOfTrees))
            ($_ (punishGrammarbasedOnTree $head $learnRate $cardinality  $grammarSpace $stocSpace))
        )
            (punishTreeRulesIterator $tail $learnRate $cardinality $grammarSpace $stocSpace)
        )
    )
)



;;This function generates trees guided by the stochastic grammar
;; algorithm for generating instances // Exploitation purposes
;; step 1 start from an init symbol with a depth = n.
;; match the grammar atomspace to get matching tokens as a right handside from the context free grammar
;; select probabilistically the production rule that passes the threshold
;; build the tree recursively and non-deterministically. with depth (n-1)
;; and make the rhs to lhs and start step 2
;; Does this procedure result in a well formed tree?
;; Do this until the depth is n = 0
;; after finishing collapse the non-deterministic result.
;; Question, Does this result in a well formed tree?
;; Definition: A well formed tree is a recursive data structure were internal nodes have atleast two children 
;; This stands out if the internal node is not a NOT junctor.
;; If the internal node is a NOT junctor it will have a one child

(= (generateTrees $initSymbol $grammarSpace $stocSpace $depth)
    (if (== $initSymbol start)
        (generateTrees expr $grammarSpace $stocSpace $depth)
        (let $derivs (findSuitableProdRules $initSymbol $stocSpace)
            (if (== $derivs ())
                $initSymbol
                (if (<= $depth 0)
                    ;; (match $grammarSpace ($initSymbol $x) (if (== $x ()) $initSymbol $x))
                    (match $grammarSpace (term $x) $x)
                    (let* (
                        (($lhs $rhs $weight) (superpose $derivs))
                        ($calculatedProbability (calculateProbability ($lhs $rhs) $stocSpace))
                    )
                        (if (>= $calculatedProbability (random))
                            (if (== $lhs bop)
                                (let* (
                                    ($head (generateTrees $rhs $grammarSpace $stocSpace (- $depth 1)))
                                    ($left (generateTrees $lhs $grammarSpace $stocSpace (- $depth 1)))
                                    ($right (generateTrees $lhs $grammarSpace $stocSpace (- $depth 1)))
                                    
                                )
                                    ($head $left $right)
                                )
                                (if (== $lhs uop)
                                    (let* (
                                        ($head (generateTrees $rhs $grammarSpace $stocSpace (- $depth 1)))
                                        ($left (generateTrees $lhs $grammarSpace $stocSpace (- $depth 1)))
                                    )
                                        ($head $left)
                                    )
                                    (let $rhs' (if (== (get-metatype $rhs) Expression) (car-atom $rhs) $rhs)
                                        (generateTrees $rhs' $grammarSpace $stocSpace (- $depth 1))
                                    )
                                )
                                
                            
                            )
                        
                            (generateTrees $lhs $grammarSpace $stocSpace (- $depth 1))
                            ;; (This is calculated probability $calculatedProbability)
                            ;; (This is random value (random))
                        )
                        
                    )
            )

            )
        )
    ;
        
    )
)


;; The following function is an adapter that integrates the scoring 
;; to the dataset
(= (fitnessWithdata $data)
    (fitness $data
             ((True (x1 True) (x2 False)) 
             (False (x1 False) (x2 False)) 
           (True (x1 True) (x2 True))))

)


;; This algorithm implements the main loop of the sggp algorithm
;; it works by generating trees from the stochastic grammar values
;; it filters the trees as good trees and bad trees
;; it reinforces the stochastic grammar based on the two classified syntax trees
;; The threshold is specified to the main loop which is given to the generic function 
;; called filterlist.
(= (sggpHelper $initSymbol $learnRate $mutationRate $thresholdProb $maxRecur $maxDepth $scoreFunc)
    (let () (println! ($maxRecur))
    (if (> $maxRecur 0)
        (let* (
            ($generatedInstances (collapse (unique (generateTrees $initSymbol &grammarSpace &stochasticGrammarSpace $maxDepth))))
            ($_ (println! (generatedInstances ==> $generatedInstances)))
            ;;($collapsedValues (collapse $generatedInstances))
            ($goodTrees (collapse (filter' >= $scoreFunc (superpose $generatedInstances) $thresholdProb)))
            ($badTrees (collapse (filter' < $scoreFunc (superpose $generatedInstances) $thresholdProb)))
            ($_ (println! (goodTrees $goodTrees badTrees $badTrees)))
            ($lenGood (len $goodTrees))
            ($lenBad (len $badTrees))
            ($reinforced (collapse (reinforceTreeRulesIterator  $goodTrees $learnRate $lenGood &grammarSpace &stochasticGrammarSpace)))
            ($punished (collapse (punishTreeRulesIterator  $badTrees $learnRate $lenBad &grammarSpace &stochasticGrammarSpace)))
        )
            (let () (println! (goodTrees ==> $goodTrees))
                (sggpHelper $initSymbol $learnRate $mutationRate $thresholdProb (- $maxRecur 1) $maxDepth $scoreFunc)
            )
            
        )
        ;; (generateInstances junctor &grammarSpace &stochasticGrammarSpace $maxDepth)
        (collapse (unique (generateTrees $initSymbol &grammarSpace &stochasticGrammarSpace $maxDepth)))
    )
)
)






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tests



;; !(register-module! ../../../../metta-moses)
;; !(import! &self metta-moses:optimization:sggp:sggp-algorithm)
;; !(import! &self metta-moses:utilities:general-helpers)
;; !(import! &self metta-moses:scoring:fitness)
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
;; !(reinforceGrammarbasedOnTree (AND (OR x1 x2) x1) 0.01 15 &grammarSpace &stochasticGrammarSpace)
;; !(get-atoms &stochasticGrammarSpace)

;;Tests for reinforceGrammarBasedOnTree
!(reinforceGrammarbasedOnTree (AND (OR x1 x2) x1) 0.01 15 &grammarSpace &stochasticGrammarSpace)
!(let $reinforcedVal (collapse (reinforceGrammarbasedOnTree (AND (OR x1 x2) x1) 0.01 15 &grammarSpace &stochasticGrammarSpace))
    ;; (assertEqual (isEmpty $reinforcedVal) True)
    (the value of reinforced val $reinforcedVal)
)
!(assertEqual (collapse (reinforceGrammarbasedOnTree (OR x1 x2) 0.01 15 &grammarSpace &stochasticGrammarSpace)) ())
!(get-atoms &stochasticGrammarSpace)

;;Tests for punishGrammarBasedOnTree
!(assertEqual  (collapse (punishGrammarbasedOnTree (AND (OR x1 x2) x1) 0.01 15 &grammarSpace &stochasticGrammarSpace)) ()) 
;; !(assertEqual  (punishGrammarbasedOnTree (AND (OR x1 x2) x1) 0.01 15 &grammarSpace &stochasticGrammarSpace) ()) 

;;Tests for the generators
!(unique (generateTrees start &grammarSpace &stochasticGrammarSpace 3))
!(let $trees (collapse (unique (generateTrees start &grammarSpace &stochasticGrammarSpace 3)))
    (assertEqual (any (collapse (isWellFormed (superpose $trees)))) True)
)
!(let $trees (sggpHelper start 0.001 0.01 0.5 1 3 fitnessWithdata)
    (assertEqual (any (collapse (isWellFormed (superpose $trees)))) True)
)
;; !(fitnessWithdata (AND x1 (OR x1 x2)))
;; !(filter' >= fitnessWithdata (AND x1 x1) 0.5)
;;  !(fitnessWithdata (superpose ((AND x1 x1))))
;; !(collapse (filter' >= fitnessWithdata (NOT x1) 0.5))
;; !(getRelations () ())




 




