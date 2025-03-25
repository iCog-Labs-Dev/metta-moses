;; Probabilistic Grammatical Evolution (PGE) is a variant of Grammatical
;; which introduces a new genotypic representation and new mapping mech-
;; anism for GE. Specifically, we resort to a Probabilistic Context-Free
;; Grammar (PCFG) where its probabilities are adapted during the evolu-
;; tionary process, taking into account the productions chosen to construct
;; the fittest individual. The genotype is a list of real values, where each
;; value represents the likelihood of selecting a derivation rule


;; ! (register-module! ./utilities)
;; ! (import! &self utilities:general-helpers)
;; ! (import! &self scoring:fitness)

;; python bindings for random number generation and rounding
! (bind! np (py-atom numpy))
! (bind! rd (py-atom round))

;;;;;;;;;           ;;;;;;;;;;
;;;;;;;;;  spaces   ;;;;;;;;;;
;;;;;;;;;           ;;;;;;;;;;

! (bind! &grammar (new-space))
! (bind! &genoSpace (new-space))
! (bind! &count (new-space))
! (bind! &scored (new-space))
! (bind! &best (new-space))


!(add-atom &grammar (start expr 0))
!(add-atom &grammar (expr (bop expr expr) 0))
!(add-atom &grammar (expr (uop expr) 1))
!(add-atom &grammar (expr term 2))
!(add-atom &grammar (bop AND 0))
!(add-atom &grammar (bop OR 1))
!(add-atom &grammar (uop NOT 0))
!(add-atom &grammar (term A 0))
!(add-atom &grammar (term B 1))
!(add-atom &grammar (term C 2))

;;;;;;;;;           ;;;;;;;;;;
;;;;;;;;; constants ;;;;;;;;;;
;;;;;;;;;           ;;;;;;;;;;

! (bind! popSize 5)    
! (bind! numOfGen 2)
! (bind! prec 3)
! (bind! data (
                (False (A False) (B False))
                (False (A False) (B True))
                (False (A True) (B False))
                (True (A True) (B True))))

! (bind! Len (sum (collapse (match &grammar ($nt $r $i) 1))) )
! (bind! maxIter (* (sum (collapse (match &grammar ($nt $r $i) 1))) 1) )
! (bind! NTS (collapse (unique (match &grammar ($nt $r $i) $nt))))
! (bind! mutationPro 0.5)
! (bind! crossoverPro 0.9)
! (bind! lambda 0.1)
! (add-reduct &best ((py-atom "float('-inf')") (phenoType) (genoType)))

;; ::::::::::::: CREATING GENOTYPE :::::::::::::

;; createGenotype creates a genotype tuple of specified length with values in the range [0, 1], rounded to a specified precision.
;; Parameters:
;;          $n: Length of the genotype tuple.
;;          $prec: Number of significant digits for rounding.
;; Example:
;;          (createGenotype 9 3) ; creates a tuple of 9 floats, each rounded to 3 decimal places.
;;          (0.227 0.584 0.498 0.364 0.912 0.881 0.504 0.206 0.119)
;;          (0.71 0.511 0.312 0.676 0.281 0.669 0.128 0.857 0.848)
;;          (0.467 0.206 0.563 0.957 0.029 0.907 0.423 0.675 0.231)

(: (createGenotype (-> Number Number (Expression))))
(= (createGenotype $n prec )
    (if (== $n 0)
        ()
        (let*
            (
                ($r (rd ((py-dot np random.uniform)0 1) prec))
                ($c (createGenotype (- $n 1) prec ))
            )
            (cons-atom $r $c))))

;; ::::::::::::: CREATING POPULATION :::::::::::::

;; initializePop creates an initial population of genotypes and add them all to the &genoSpace.
;; Parameters:
;;          $n: The number of individuals (genotypes) to create in the population.
;;          Len:  The length of each genotype (assumed to be a global constant).
;;          prec: The precision to use when creating the genotype (assumed to be a global constant).

(= (initializePop $genoSpace $n)
    (if (== $n 0)
        (empty)
        (let*
            (
                ($geno (createGenotype Len prec ))
                (() (add-atom $genoSpace $geno ))
            )
            (initializePop $genoSpace (- $n 1))
        )

    )
)

;; ::::::::::::: ASSIGNING INITIAL PROBABILITIES :::::::::::::
;; iProbs -- assigns equal probability values for production rules in a non-terminal
;;          counts the total number of production rules ($n) assigns 1/n to each production rule
;;          adds the new production rule atoms to the sapce like ($nt $r $iP $i)
;;          $grammarSpace -- grammar space
;;          $nt --  non-terminal
;;          $r --  production rule
;;          $idx -- production rule index
;;          $nr -- number of production rules for a non-terminal
;;          $iP -- initial probability
;;          3 -- decimal places to rounding off to
;; Note:-   iProbs doesn't remove the old grammar pattern it just adds a new pattern with probability values
;;          So when queries with (get-atoms) attoms with the old pattern ($nt $r $i) are returned as well

(= (iProbs $grammarSpace)
    (let*
        (
            ; ($nts (collapse (unique (match $grammarSpace ($nt $r $i) $nt))))
            ($nt (superpose NTS))
            ($nr (sum (collapse (match $grammarSpace ($nt $r $idx) 1))))
            ($iP (rd (/ 1.0 $nr) 3))
        )
        (match $grammarSpace ($nt $r $idx) (add-atom $grammarSpace ($nt $r $iP $idx))) ;; add new atoms with probability values, we don't remove because removing is extensive
    )
)


! (iProbs &grammar)

;; initializeCount -- initializes the count space with count values of 0.0 for the best individual

! (match &grammar ($nt $r $i) (add-atom &count ($nt $r 0.0 $i)))

;; ::::::::::::: PICKING PRODUCTION RULES BASED ON GENOTYPE AND CUMMULATIVE PROBABILITIES :::::::::::::
;; getRule :- selects a production rule based on a codon value and cumulative probabilities.
;; Parameters:
;;    $nt: The non-terminal symbol to expand.
;;    $grammarSpace: The space containing grammar rules with probabilities.
;;    $countSpace: The space for tracking production rule usage counts.
;;    $codon: A value from the genotype used to select a production rule.
;;    $iCProb: The initial cumulative probability (typically 0).
;;    $idx: The index of the current production rule being considered.
;;    $isBest: A flag indicating if this selection is for the best individual (for count updating).
;; Returns:
;;    The selected production rule ($r).

(= (getRule $nt $grammarSpace $countSpace $codon $iCProb $idx $isBest)
    (match $grammarSpace ($nt $r $p $idx)
            (if (<= $codon (+ $p $iCProb))
                (if $isBest
                    (let () (prCounter $countSpace $nt $r) $r)
                    $r
                )
                (getRule $nt $grammarSpace $countSpace $codon (+ $p $iCProb) (+ $idx 1) $isBest)
            )
    )
)


;; ::::::::::::: Reset PRODUCTION RULES counts :::::::::::::
;; resetCount resets the usage counts of all production rules in the count space to zero.
;; Parameters:
;;    $countSpace: The space where production rule usage counts are stored.
(: (resetCount (-> Grounded empty )))
(= (resetCount $countSpace )
    (collapse (match $countSpace ($nt $r $c $idx)
                    (let () (remove-atom $countSpace ($nt $r $c $idx))
                            (add-atom $countSpace ($nt $r 0.0 $idx)))
              )
    )
    
)

;; ::::::::::::: Reset SCORE SPACE :::::::::::::
;; resetScore -- resets the score space for the next generation
(= (resetScore $scoreSpace )
    (collapse (match $scoreSpace $x (remove-atom $scoreSpace $x) ))  
)

;; prCounter -- increments a production rule's count by one when called
;;              $countSpace -- count space
;;              $nt -- a non-terminal
;;              $r -- a production rule
;;                  $c -- count variable
;;                  $idx -- index variable

(= (prCounter $countSpace $nt $r)
    (let*
        (
            (($c $idx) (match $countSpace ($nt $r $c $idx) ($c $idx)))
            (() (remove-atom $countSpace ($nt $r $c $idx)))
            ($next (+ 1 $c))
        )
        (add-atom $countSpace ($nt $r $next $idx))
    )
)


;; getCodon -- returns a codon from the genotype by using an index value
;; parameters:
;;              $genotypes -- a genotype tuple
;;              $idx -- index value

(= (getCodon $genotypes $idx)
    (let $index (% $idx Len) (selectByIndex $genotypes $index))
)


;; ::::::::::::::::                              ::::::::::::::::::     ;;
;; :::::::::::::       updateProbability            :::::::::::::::     ;;
;; ::::::::::::::::                              ::::::::::::::::::     ;;

;; updateProbablity updates the probabilities of derivation rules based on count information.
;; Parameters:
;;    $grammarSpace: The space containing grammar rules with probabilities.
;;    $countSpace: The space where production rule usage counts of the best individual selected.
;;    $lambda: The learning rate or step size for updating probabilities.

(= (updateProbability $grammarSpace $countSpace $lambda)
    (let*
        (
            ; (() (println! ("updating probability")))
            ($nt  (unique (match $countSpace ($nt $r $c $idx) $nt)))  
            ($total (sum (collapse (match $countSpace ($nt $r $c $idx) $c))))
            (() (probHelper $nt $total $countSpace $grammarSpace $lambda))
        )

        ()
    )
)
;; probHelper update probabilities for a specific non-terminal.
;; Parameters:
;;    $nt: The non-terminal symbol being processed.
;;    $total: The total count of all production rules for the specific non-terminal.
;;    $countSpace: The space where production rule usage counts are stored.
;;    $grammarSpace: The space containing grammar rules with probabilities.
;;    $lambda: The learning rate or step size for updating probabilities.
(= (probHelper $nt $total $countSpace $grammarSpace $lambda)
    (let*
        (
            (($r $c) (match $countSpace ($nt $r $c $idx) ($r $c)))
            (($oldP $idx)  (match $grammarSpace ($nt $r $p $idx) ($p $idx) ))
        )
        (if (> $c 0)
            (let*
                (
                    ($incP (+ $oldP (/ (* $c $lambda) $total)))
                    ($newP (rd (min $incP 1) 3))
                    (() (remove-atom $grammarSpace ($nt $r $oldP $idx)))
                )
                (add-atom $grammarSpace ($nt $r $newP $idx))
            )
            (let*
                (
                    ($newP (rd (- $oldP (* $lambda $oldP)) 3))
                    (() (remove-atom $grammarSpace ($nt $r $oldP $idx)))
                )
                (add-atom $grammarSpace ($nt $r $newP $idx))
            )
        )
    )
)

;; normalizeP ensures the total probability for each non-terminal in $gSpace sums to 1.
;; Steps:
;;   1. Calculate the current total probability ($probSums).  
;;   2. Compute the difference ($diff) needed so that all rules sum to 1.  
;;   3. Add $diff to each rule’s probability, removing the old atom and adding a new one with the updated probability.

(= (normalizeP $gSpace)
    (let*
        (
            (() (println! ("normalizing")))
            ($nt (unique (match $gSpace ($nt $r $i) $nt)))
            ($probSums (sum (collapse (match $gSpace ($nt $r $p $i) $p))))
            ($j (sum (collapse (match $gSpace ($nt $r $p $i) 1))))
            ($diff (rd (/ (- 1.0 $probSums) $j) 3))
            (($oldProb $newProb $r $i) (match $gSpace ($nt $r $p $i) ($p (rd (+ $p $diff) 3) $r $i)))
            (() (remove-atom $gSpace ($nt $r $oldProb $i)))
        )
        
        (add-atom $gSpace ($nt $r $newProb $i))
    )
)

;; updateOverallBest - updates the overall best individual based on the best individual of the current generation.
;; Parameters:
;;    $bestSpace: The space containing the overall best until the current generation.
;;    $overallBest: The best individual found so far.
;;    $genBest: The best individual of the current generation.

(= (updateOverallBest $bestSpace $overallBest $genBest)
    (let*
        (
            ; (() (println! ("updating overall best")))
            (($oldScore $oldPhe $oldGen) $overallBest)
            (($score $phenoType $genoType) $genBest)
        )
        (if (>= $score $oldScore)
            (let*
                (
                    (() (remove-atom $bestSpace ($oldScore $oldPhe $oldGen)))
                    (() (add-atom $bestSpace ($score $phenoType $genoType)))
                    
                )
                ()
            )
            ()
        )
        
    )
)


;;    ::::::::::::::                      ::::::::::::::::::     ;;
;;    :::::::::::::: VARIATION OPERATORS  ::::::::::::::::::     ;;
;;    ::::::::::::::                      ::::::::::::::::::     ;;

;; crossover performs a single-point crossover between two parent genotypes ($p1 and $p2).
;; It selects a random split point, cuts both genotypes at that index, and concatenates
;; the head of $p1 with the tail of $p2 to produce the offspring.
;; Parameters:
;;    $p1: The first parent genotype.
;;    $p2: The second parent genotype.
(= (crossover $p1 $p2)
    (let*
        (
            ($len (len $p1))
            ($rand ((py-atom random.randint) 0 (- $len 1)))
            (($head $tail) (splitAt $rand $p1))
            (($head2 $tail2) (splitAt $rand $p2))
        )
        (concatTuple $head $tail2)

    )
)

; ;; This function performs mutation on a given genotype. Each codon in the genotype has a probability of mutation
; ;; If a codon is selected for mutation, it is replaced with a new random value
; ;; Example:
; ;;         (mutate (1 2 3 4 5) 0.1 ()) -> (1 2 3 4 5) with a low probability of mutation
; ;;         (mutate (1 2 3 4 5) 0.9 ()) -> (x x x x x) with a high probability of mutation

(= (mutate $genotype $probMutation)
    (if (== $genotype ())
        () 
        (let* (
                ($head (car-atom $genotype))
                ($tail (cdr-atom $genotype))
                ($rand (rd ((py-dot np random.uniform) 0 1) 3))  ;; Generate a random number in [0,1] (rounded to 3 decimal places for precision)
                ($newCodon (if (< $rand $probMutation)            ;; If the random number is less than the probability of mutation, replace the codon with a new random value
                              (rd ((py-dot np random.uniform) 0 1) 3)  
                              $head))  
                ($rest (mutate $tail $probMutation))
            )
            (cons-atom $newCodon $rest)  
        )
    )
)

;; genNewPop generates a new population of offspring from an existing population.
;; Parameters:
;;   $numPop: The number of new individuals to generate.
;;   $population: The current population of genotypes.
;; Process:
;;   1. If $numPop is 0, return an empty list.
;;   2. Otherwise, select two parents $p1 and $p2 at random from $population.
;;   3. Generate a random number $rand in [0,1].
;;   4. If $rand < crossoverPro, produce an offspring by crossing over $p1 and $p2; otherwise, mutate $p1.
;;   5. Recursively call genNewPop to produce the remaining offspring.

(= (genNewPop $numPop $population )
    (if (== $numPop 0)
        ()

        (let*
            (
                ($idx ( (py-atom random.randint) 0 (- (len $population) 1)))
                ($p1 (selectByIndex $population $idx))
                ($idx2 ((py-atom random.randint) 0 (- (len $population) 1)))
                ($p2 (selectByIndex $population $idx2))
                (() (println! ("p1 " $p1 " idx " $idx " p2 " $p2 " idx2 " $idx2)))
                ($rand ((py-dot np random.uniform) 0 1))
                ($child (if (< $rand crossoverPro)
                            (crossover $p1 $p2)
                            (mutate $p1 mutationPro) ))
            )
            (let $tail (genNewPop (- $numPop 1) $population) (cons-atom $child $tail))

        )
    )
)

;; ::::::::::::: GENERATE PHENOTYPE :::::::::::::
;; genPhen generates a phenotype by recursively expanding non-terminals in a grammar.
;; It uses codons from a genotype to select production rules (via getRule).
;; If $start is a literal that’s not in $nts, it returns $start.
;; If $start is an Expression, it deconstructs and processes each part.
;; Otherwise, it retrieves a codon and picks a rule, then continues until $maxIter is reached or the resulting expression is fully expanded.
;; Parameters:
;;          $grammarSpace -- grammar space
;;          $countSpace   -- count space
;;          $genoType     -- individual genotype information
;;          $nts          -- a set of unique non-terminals of the grammar
;;          $start        -- nontermninal symbol to start them mapping
;;          $maxIter      -- maximum number of wrapping iterations
;;          $idx          -- index of the genotype tuple
;;          $isBest       -- boolean value to check if the best individual is being mapped


(= (genPhen $grammarSpace $countSpace $genoType $nts $start $maxIter $idx $isBest)
    (if (and (isLiteral $start) (not (isMember $start $nts)))
        $start
        (if (== (get-metatype $start) Expression)
            (let*
                (
                    (($f $t) (decons $start))
                    ($mapped (genPhen $grammarSpace $countSpace $genoType $nts $f $maxIter $idx $isBest) )
                )
                (if (== $t ())
                    (cons-atom $mapped $t)
                    (let $r (genPhen $grammarSpace  $countSpace $genoType $nts $t $maxIter (+ $idx 1) $isBest )
                        (cons-atom $mapped $r))))
            (let*
                (
                    ($codon (getCodon $genoType $idx ))
                    ($nextRule (getRule $start $grammarSpace $countSpace $codon 0 0 $isBest))
                )
                (if (< $idx $maxIter)
                    (genPhen $grammarSpace $countSpace $genoType $nts $nextRule $maxIter (+ $idx 1) $isBest)
                    null
                )
            )
        )
    )
)


;; ::::::::::::: EVALUATING POPULATION :::::::::::::
;; evaluate generates a phenotype from a genotype, calculates its fitness, and stores the result.
;; Parameters:
;;    $grammarSpace: The space containing grammar rules.
;;    $countSpace: The space for tracking production rule usage counts.
;;    $scoreSpace: The space where scored individuals are stored.
;;    $genoType: The genotype to be evaluated.

(= (evaluate $grammarSpace $countSpace $scoreSpace $genoType)
     (let*
        (
            (() (println! ("genoType -------------" $genoType)))
            ($phenoType (genPhen $grammarSpace $countSpace $genoType NTS start maxIter 0 False)) ;; mapping the individual genotype 
            ($score (penalizedFitness $phenoType data lambda)) 
        )
        (add-atom $scoreSpace ($score $phenoType $genoType )) ;; add scored individuals to the scored space

     )
)
;; runGen orchestrates a generation of the evolutionary process:
;; 1. Evaluates all individuals in the current population.
;; 2. Sorts the population by fitness, identifies the best individual, and updates the overall best.
;; 3. Adapts grammar probabilities based on counts from the best individual.
;; 4. Resets the count and score spaces.
;; 5. Creates a new generation via crossover or mutation, then recurses until $numOfGen reaches 0.
(= (runGen $grammarSpace $countSpace $scoreSpace $bestSpace $numOfGen $population $flag)
    (let*
        (
            (() (println! ("numOfGen " $numOfGen)))
            ($_ (collapse (evaluate $grammarSpace $countSpace $scoreSpace (superpose $population))))  ;; maping is here
            ($sortedPop (sortNestedTuple (collapse (match $scoreSpace $x $x)) reverse))
            (() (println! ("sortedPop " $sortedPop)))
            ($genBest (first $sortedPop))
            ($overallBest (match $bestSpace ($sc $ph $gen) ($sc $ph $gen)))
            (($score $phen $geno) (if $flag $genBest $overallBest))                            ;; selecting individual to update the probability   
            ($_~ (genPhen $grammarSpace $countSpace $geno NTS start maxIter 0 True))           ;; mapping the best individual and finding the count of the production rules
            ($_` (collapse (updateProbability $grammarSpace $countSpace lambda)))              ;; update the probabilities of the grammar space by taking the count of the best indvidual from countSpace
            ($_`` (collapse (normalizeP $grammarSpace)))                                       ;; normalize the probabilities of the grammar space            
            ($_```  (resetCount $countSpace))                                                  ;; reset the count space for the next generation
            ($_rest (resetScore $scoreSpace))                                                  ;; reset the scored space for the next generation
            ($- (updateOverallBest $bestSpace $overallBest $genBest))                          ;; update the overall best individual
            (() (println! ("overallBest " $overallBest)))
            (($_s $_p $_elite) (first $sortedPop))
            ($newGen (genNewPop (- popSize 1) $population))
            ($newPopulation (cons-atom $_elite $newGen))
        )
        (if (== $numOfGen 0)
            (best individual found $overallBest)
            (runGen $grammarSpace $countSpace $scoreSpace $bestSpace (- $numOfGen 1) $newPopulation (not $flag))
        )
        

    )
)

;; mainLoop initializes the population and runs the evolutionary process.
;; Parameters:
;;    $grammarSpace: The space containing grammar rules.
;;    $genoSpace: The space where genotypes are stored.
;;    $countSpace: The space for tracking production rule usage counts.
;;    $scoreSpace: The space where scored individuals are stored.
;;    $bestSpace: The space containing the overall best individual.
;;    numOfGen: The number of generations to run.
;;    popSize: The size of the population.
;; Process:
;;    1. Initializes the population with the specified size.
;;    2. Retrieves the initialized population from $genoSpace.
;;    3. Runs the evolutionary process for the specified number of generations.
;;    4. Outputs the best individual found.

(= (mainLoop $grammarSpace $genoSpace $countSpace $scoreSpace $bestSpace numOfGen popSize )
    (let*
        (  
            (() (collapse (initializePop $genoSpace popSize)))
            ($population  (collapse (get-atoms &genoSpace)))
            ; (() (println! ("population " $population)))
            ($_run (collapse (runGen $grammarSpace $countSpace $scoreSpace $bestSpace numOfGen $population True)))

        )
        (The best individual found is (match &best $x $x))
    )
)
