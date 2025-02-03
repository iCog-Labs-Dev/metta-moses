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

;; getRule from sub-tree expression and grammarSpace
;;bop (bop exp1 exp2)
;;uop (uop exp1)
;;term x1 ==> (term x1)
;; $_ x1
(= (getRuleFromSubTree $expression $stocSpace)
    (unify $expression ($op $exp1 $exp2)
        (match $stocSpace (, ($opType $op $weight1)
                                ($exp ($opType $exp $exp) $weight2)

                        )
                        (($opType $op $weight1) ($exp ($opType $exp $exp) $weight2))

        )
        (unify $expression ($op $exp1)
            (match $stocSpace (, 
                                ($opType $op $weight1) 
                                ($exp ($opType $exp) $weight2)
                            )
                                (($opType $op $weight1) ($exp ($opType $exp) $weight2))
                            )
            ;; (match $grammarSpace ($parent $expression)
            ;;     (let* (
            ;;         (() (println! (This is the parent $parent)))
            ;;         (() (println! (This is the expression $expression)))

            ;;     )
            ;;         ($parent $expression)
            ;;     )  
            ;; )
            ;;(term $expression)
            (match $stocSpace ($parent $expression $weight)
                ($parent $expression $weight)
            )
        )
         
    )

)
;; a helper that extracts the best after comparing with the threshold.
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
        (update-atom $stocSpace ($lhs $rhs $weight) ($parent $child $updatedWeight))
    )
)
;; This procedure works if multiple weights happen 
(= (reinforceProd ($prod1 $prod2) $learnRate $cardinality $stocSpace)
    (let* (
        ($res (reinforceProd $prod1 $learnRate $cardinality $stocSpace))
        ($res' (reinforceProd $prod2 $learnRate $cardinality $stocSpace))
    )
        ()
    )
)
;; This procedure implements the punishing a specific production rule that is available.
(= (punishProd ($lhs $rhs $weight) $learnRate $cardinality $stocSpace)
    (let ($parent $child $updatedWeight) (updateWeight ($lhs $rhs $weight) $learnRate $cardinality dec)
        (update-atom $stocSpace ($lhs $rhs $weight) ($parent $child $updatedWeight))
    );; (exploitInstances $rhs $grammarSpace $stocSpace $explorationCoeff (- $depth 1))
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
(= (reinforceGrammarbasedOnTree $tree $learnRate $cardinality $grammarSpace $stocSpace)
    (let* (
        ($relations (getRelations $tree ()))
        ($prodRules (collapse (getRuleFromSubTree (superpose $relations) $stocSpace)))
        (() (println! (production rules $prodRules)))
        
    )
        (collapse (reinforceProd (superpose $prodRules) $learnRate $cardinality $stocSpace))
    )
)
;; The below piece of code punishes the production rule in a stochastic grammar based on a tree
(= (punishGrammarbasedOnTree $tree $learnRate $cardinality $grammarSpace $stocSpace)
    (let* (
        ($relations (getRelations $tree ()))
        ($prodRules (collapse (getRuleFromSubTree (superpose $relations) $stocSpace)))
        ;; (println (production rules $prodRules))
    )
        (collapse (punishProd (superpose $prodRules) $learnRate $cardinality $stocSpace))
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

(= (generateTrees $initSymbol $grammarSpace $stocSpace $explorationCoeff $depth)
    (if (== $initSymbol start)
        (generateTrees expr $grammarSpace $stocSpace $explorationCoeff $depth)
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
                                    ($head (generateTrees $rhs $grammarSpace $stocSpace $explorationCoeff (- $depth 1)))
                                    ($left (generateTrees $lhs $grammarSpace $stocSpace $explorationCoeff (- $depth 1)))
                                    ($right (generateTrees $lhs $grammarSpace $stocSpace $explorationCoeff (- $depth 1)))
                                    
                                )
                                    ($head $left $right)
                                )
                                (if (== $lhs uop)
                                    (let* (
                                        ($head (generateTrees $rhs $grammarSpace $stocSpace $explorationCoeff (- $depth 1)))
                                        ($left (generateTrees $lhs $grammarSpace $stocSpace $explorationCoeff (- $depth 1)))
                                    )
                                        ($head $left)
                                    )
                                    (let $rhs' (if (== (get-metatype $rhs) Expression) (car-atom $rhs) $rhs)
                                        (generateTrees $rhs' $grammarSpace $stocSpace $explorationCoeff (- $depth 1))
                                    )
                                )
                                
                            
                            )
                        
                            (generateTrees $lhs $grammarSpace $stocSpace $explorationCoeff (- $depth 1))
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
;; (= (generate $parentSymbol $initSymbol $grammarSpace $stocSpace $depth)
;;     (if (== (findSuitableProdRules $initSymbol $grammarSpace) ())
;;         (findAndReplace $parentSymbol $initSymbol)
;;     )
;; )
;; The following function is an adapter that integrates the scoring 
;; to the dataset
(=(fitnessWithdata $data)
    (fitness $data
             ((True (A True) (B False) (C True) (D True)) 
             (False (A False) (B True) (C False) (D False)) 
           (True (A True) (B False) (C False) (D True))))

)
;; This algorithm implements the main loop of the sggp algorithm
;; it works by generating trees from the stochastic grammar values
;; it filters the trees as good trees and bad trees
;; it reinforces the stochastic grammar based on the two classified syntax trees
;; The threshold is specified to the main loop which is given to the generic function 
;; called filterlist.
(= (sggpHelper $initSymbol $learnRate $mutationRate $thresholdProb $maxRecur $explorationCoeff $maxDepth $scoreFunc)
    (let () (println! ($maxRecur))
    (if (> $maxRecur 0)
        (let* (
            ($generatedInstances (collapse (unique (generateTrees $initSymbol &grammarSpace &stochasticGrammarSpace $explorationCoeff $maxDepth))))
            ($goodTrees (filterList >= $scoreFunc $generatedInstances $thresholdProb))
            ($badTrees (filterList < $scoreFunc $generatedInstances $thresholdProb))
            ($lenGood (len $goodTrees))
            ($lenBad (len $badTrees))
            ($reinforced (collapse (reinforceGrammarbasedOnTree (superpose $goodTrees) $learnRate $lenGood &grammarSpace &stochasticGrammarSpace)))
            ($punished (collapse (punishGrammarbasedOnTree (superpose $badTrees) $learnRate $lenBad &grammarSpace &stochasticGrammarSpace)))
        )
            (let () (println! (goodTrees ==> $goodTrees))
                (sggpHelper $initSymbol $learnRate $mutationRate $thresholdProb (- $maxRecur 1) $explorationCoeff $maxDepth $scoreFunc)
            )
            
        )
        ;; (generateInstances junctor &grammarSpace &stochasticGrammarSpace $maxDepth)
        (collapse (unique (generateTrees $initSymbol &grammarSpace &stochasticGrammarSpace $explorationCoeff $maxDepth)))
    )
)
)



