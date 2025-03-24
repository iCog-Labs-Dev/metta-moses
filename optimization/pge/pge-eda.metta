;; module import

;; ! (register-module! ../../metta-moses)

;; ! (import! &self metta-moses:utilities:general-helpers)
;; ! (import! &self metta-moses:scoring:fitness)

;; python bindings for random number generation and rounding

! (bind! np (py-atom numpy))
! (bind! round (py-atom round))

;; space bindings

! (bind! &grammar (new-space))
! (bind! &geno (new-space))
! (bind! &count (new-space))
! (bind! &population (new-space))
! (bind! &scored (new-space))

;; adding the grammar

! (add-reduct &grammar 
                (superpose 
                        ((start expr 0)
                         (expr (bop expr expr) 0)
                         (expr (uop expr) 1)
                         (expr term 2)
                         (bop AND 0)
                         (bop OR 1)
                         (uop NOT 0)
                         (term A 0)
                         (term B 1))))

;; global constants -- 
;;                length of grammar (L), 
;;                set of grammar non-terminals (NTS) , 
;;                test data (DATA)  , 
;;                max-wrap (WRAP), 
;;                round-off precision (PREC)
;;                Generation count (G)
;;                Expression count (E)

! (bind! L (sum` (collapse (match &grammar ($nt $r $i) 1))))
! (bind! NTS (collapse (unique (match &grammar ($nt $r $i) $nt))))

! (bind! DATA ((False (A False) (B False))
                (False (A False) (B True))
                (False (A True) (B False))
                (True (A True) (B True))))

! (bind! WRAP 1)
! (bind! MAXITER (* L WRAP))
! (bind! PENALITY 0.1) 
! (bind! FACTOR 0.05)
! (bind! PREC 3)
! (bind! G 2)
! (bind! E 1)

;; ::::::::::::: CREATING GENOTYPE :::::::::::::
;; createGenotype -- creates genptype of a specified length in the range taking random values in the range [0,1] from the uniform distribution
;;                   makes use of python/numpy uniform distributed random variable generator
;;              $n -- length of the genotype tuple
;;              $prec -- rounding off precision value
;;              $random -- random number to prevent metta from caching results
;;              Examples :- 
;;                      (createGenotype 9 3 dummy)
;;                      -- 1st run -- (0.227 0.584 0.498 0.364 0.912 0.881 0.504 0.206 0.119)
;;                      -- 2nd run -- (0.71 0.511 0.312 0.676 0.281 0.669 0.128 0.857 0.848)
;;                      -- 3rd run -- (0.467 0.206 0.563 0.957 0.029 0.907 0.423 0.675 0.231)

(: (createGenotype (-> Number Number Number Expression)))
(= (createGenotype $n $prec $random)
    (if (== $n 0)
        ()
        (let* 
            (   
                ($first (round ((py-dot np random.uniform)0 1) $prec))
                ($c (createGenotype (- $n 1) $prec ((py-atom random.random)))))

            (cons-atom $first $c))))

;; setGenotype -- calls the genotype generator, createGenotype,  and adds the genotyoe to space
;;              $prec -- rounding off precision value
;;              $n -- genotype length
;;              $gtSpace -- genotype space
;;              $random -- random number to prevent metta from caching results
;;                      $g -- generated genotype

(= (setGenotype $prec $n $gtSpace $random)
    (let*
        (   
            ($g (createGenotype $n $prec ((py-atom random.random))))
            ($geno (genotype $g))
            (() (match $gtSpace (genotype $genotype) (remove-atom $gtSpace (genotype $genotype)))))

         (add-atom $gtSpace $geno)))

;; ::::::::::::: ASSIGNING INITIAL PROBABILITIES :::::::::::::
;; iProbs --    assigns equal probability values for production rules in a non-terminal before the start of expression generation
;;              counts the total number of production rules in a non-terminal, $nr, and assigns 1/$nr to each production rule
;;              adds the new production rule atoms to the sapce with probability values added like ($nt $r $iP $i)
;;              $gSpace -- grammar space
;;              $nts -- the set non-terminals
;;                      $nt -- a non-terminal
;;                      $r -- a porduction
;;                      $i -- production rule index
;;                      $nr -- number of production rules in a non-terminal
;;                      $iP -- initial probability
;; Note:-   iProbs doesn't remove the old grammar pattern it just adds a new pattern with probability values
;;          So when queries with (get-atoms) attoms with the old pattern ($nt $r $i) are returned as well


(= (iProbs $gSpace $nts)
    (collapse (let*
        (
            ($nt (superpose $nts))
            ($nr (sum` (collapse (match $gSpace ($nt $r $i) 1))))
            ($iP (round (/ 1.0 $nr) PREC))
            (() (match $gSpace ($nt $r $i) (add-atom $gSpace ($nt $r $iP $i)))))

        (empty))))

;; sum` -- helper function get sum of numeric tuple

(= (sum` $list)
    (if (== $list ())
        0
        (let*
            (
                ($f (car-atom $list))
                ($t (cdr-atom $list))
            )
            (if (== $t ())
                $f
                (+ $f (sum` $t)) ))))

;; ::::::::::::: PICKING PRODUCTION RULES BASED ON GENOTYPE AND CUMMULATIVE PROBABILITIES :::::::::::::
;; getRule -- retrieves the correct production rule based on cummulative probablity values
;; Parameteres:- $nt -- a non-terminal
;;               $cSpace -- count space
;;               $codon -- probability of picking a production rule taken from the genotype tuple index by index
;;               $iCProb -- the initial cummulative probablity that starts as 0 and keeps being updated
;;               $i -- index of the expansion options for a given non-terminal for ordered exploration,  it starts as 0
;;               $gSpace -- grammar space
;;               $random -- random number to prevent metta from caching results 
;;                      $nt -- a non-terminal
;;                      $r -- a production rule
;;                      $p -- probablity value associated with a 
;;                      $i -- production rule index
;; Examples:- 
;;               (getRule start &grammar &count 0.61 0 0 $dummy) -- expr             
;;               (getRule expr &grammar &count 0.26 0 0 $dummy) -- (bop expr expr)           
;;               (getRule expr &grammar &count 0.7 0 0 $dummy) -- term             
            
(= (getRule $nt $gSpace $cSpace $codon $iCProb $i $random)
    (match $gSpace ($nt $r $p $i) 
            (if (<= $codon (+ $p $iCProb))
                (let () (prCounter $cSpace $nt $r ((py-atom random.random)))
                    $r)
                (getRule $nt $gSpace $cSpace $codon (+ $p $iCProb) (+ $i 1) ((py-atom random.random))))))

;; ::::::::::::: SET AND GET CODON :::::::::::::
;; getCodon -- returns a codon from the genotype by using an index value
;;              $gtSpace -- genotype space which contains codon-index as well
;;              $random -- random number to prevent metta from caching results
;;                      $i -- index gotten from &geno (codon-index $i)
;;                      $g -- a genotype tuple
;;                      $len -- length of genotype tuple
;;                      $index -- value in the range [0 (- $len 1)] obtained using module 

(= (getCodon $gtSpace $random)
    (let*
        ( 
            ($i (match $gtSpace (codon-index $ind) $ind))
            ($g (match $gtSpace (genotype $geno) $geno))
            ($index (% $i L)))

        (selectByIndex $g $index)))

;; updateIndex -- increments the codon-index value by 1 when called
;;              $gtSpace -- genotype space
;;              $random -- random number to prevent metta from caching results
;;                      $i -- old index
;;                      $next -- new index (+ 1 $i)

(= (updateIndex $gtSpace $random)
    (let*
        (
            ($i (match $gtSpace (codon-index $i) $i))
            (() (remove-atom $gtSpace (codon-index $i)))
            ($next (+ 1 $i))
        )
        (add-atom $gtSpace (codon-index $next))))

;; ::::::::::::: GENERATE PHENOTYPE :::::::::::::
;; genPhen -- generates phenotype starting from start symbol and using the genotype information to map productio rules
;;              $gSpace -- grammar space
;;              $gtSpace -- genotype space
;;              $nts -- set of non-terminals
;;              $start -- the start symbol
;;              $maxIter -- maximum iteration length
;;              $random -- random number to prevent metta from caching results
;;                      $mapped -- a terminal symbol after having been transformed from a non-terminal using the grammar 
;;                      $codon -- a probablity value gotten from &gtSpace 
;;                      $r -- variable to store recursive call to the function genPhen
;;                      $codon -- a probablity value gotten from &gtSpace 
;;                      $nextRule -- production rule picked from the set of available expansions of a non-terminal based on probability values
;;                      $codonIndex -- the updated condon index value

(= (genPhen $gSpace $cSpace $gtSpace $nts $start $maxIter $random)
    (if (and (isLiteral $start) (not (isMember $start $nts)))
        $start
        (if (== (get-metatype $start) Expression)

            (let* 
                (
                    (($f $t) (decons $start))
                    ($mapped (genPhen $gSpace $cSpace $gtSpace $nts $f $maxIter ((py-atom random.random))))
                    )

                (if (== $t ())
                    (cons-atom $mapped $t)
                    (let $r (genPhen $gSpace $cSpace $gtSpace $nts $t $maxIter ((py-atom random.random)))
                        (cons-atom $mapped $r) )))                  

            (let*
                (   
                    ($codon (getCodon $gtSpace ((py-atom random.random))))
                    ($nextRule (getRule $start $gSpace $cSpace $codon 0 0 (py-atom random.random)))
                
                    (() (println! $nextRule))
                    (() (updateIndex $gtSpace ((py-atom random.random))))
                    ($codonIndex (match $gtSpace (codon-index $i) $i)))

                (if (< $codonIndex $maxIter)
                    (genPhen $gSpace $cSpace $gtSpace $nts $nextRule $maxIter ((py-dot np random.uniform)0 1))

                    null )))))

;; prCounter -- increments a production rule's count by one when called
;;              $cSpace -- count space
;;              $nt -- a non-terminal
;;              $r -- a production rule
;;              $random -- random number to prevent metta from caching results
;;                      $c -- count variable
;;                      $i -- index variable
;;                      $next -- next index to access the next production rule of a non-terminal

(= (prCounter $cSpace $nt $r $random)
    (let* 
        (
            (($c $i) (match $cSpace ($nt $r $c $i) ($c $i)))
            (() (remove-atom $cSpace ($nt $r $c $i)))
            ($next (+ 1 $c)))

        (add-atom $cSpace ($nt $r $next $i))))

;; ;; ::::::::::::: GENERATE GENERATION :::::::::::::
;; genG -- generate a single generation of size n
;;              $n -- population size
;;              $gSpace -- grammar space
;;              $gtSpace -- genotype space
;;              $genSpace -- space for population
;;              $maxCount -- number of inidviduals to generate
;;              $start -- start symbol
;;              $genId -- genertion id for identification of genrations -- stays the same for a generation of individuals
;;              $$id -- id for an individual expression -- unique for an expression in a generation
;;              $random -- needed to prevent metta from caching results of recursive calls              
;;                      $exp -- indvidual expression
;;                      $g -- genotype tuple used for the expression
;;                      $c -- production rule count info for an expression collected in a tuple

(= (genG $gSpace $cSpace $gtSpace $popSpace $maxCount $start $genId $id $random)
    (if (< $id $maxCount)
        (let*
            (   
                (() (setGenotype PREC L $gtSpace ((py-atom random.random))))
                ($exp (genPhen $gSpace $cSpace $gtSpace NTS $start MAXITER ((py-atom random.random))))
                (() (resetIndex $gtSpace))
                ($g (getGeno $gtSpace ((py-atom random.random))))

                ($c (getCount $cSpace ((py-atom random.random))))
                (() (add-atom $popSpace ($genId $id $exp $g $c)))
                (() (rCount $cSpace ((py-atom random.random)))))
            
                (genG $gSpace $cSpace $gtSpace $popSpace $maxCount $start $genId (+ 1 $id) ((py-atom random.random))))
        () ))

;; resetIndex -- resets the codon index to zero for the next round of generation
;;          $gtSpace -- genotype space
;;                  $ind -- previous index value

(= (resetIndex $gtSpace)
    (collapse (let*
        (
            ($ind (match $gtSpace (codon-index $ind) $ind))
            (() (remove-atom $gtSpace (codon-index $ind)))
            (() (add-atom $gtSpace (codon-index 0))))

        (empty) )))

;; retrive genotype information for the inidividual

(= (getGeno $gtSpace $random)
    (match $gtSpace (genotype $g) $g))

;; getCount -- returns count of all production rules for appending to individual expression metta data
;;              $cSpace -- count space
;;                      $nt -- a non-terminal
;;                      $r -- a production rule
;;                      $c -- production rule referal count
;;                      $i -- index

(= (getCount $cSpace $random)
   (collapse (match $cSpace ($nt $r $c $i) ($nt $r $c))))

;; iCount -- initialize count space with all zero(0) counts of production rules 
;;              $gSpace -- grammar space
;;              $cSpace -- count space
;;                      $nt -- a non-terminal
;;                      $r -- a production rule
;;                      $i -- index

(= (iCount $gSpace $cSpace)
    (collapse (let*
        (
            (($nt $r $i) (match $gSpace ($nt $r $t) ($nt $r $t)))
            (() (add-atom $cSpace ($nt $r 0 $i)))
        )
        (empty))))

;; cleanSpace -- removes all elements from space

(= (cleanSpace $space)
    (collapse (let $atoms (get-atoms $space)
            (remove-atom $space $atoms))))

;; rCount -- resets counts

(= (rCount $cSpace $random)
    (collapse (let* 
        (
            (($nt $r $c $i) (match $cSpace ($nt $r $c $i) ($nt $r $c $i)))
            (() (remove-atom $cSpace ($nt $r $c $i)))
            (() (add-atom $cSpace ($nt $r 0 $i))))

        (empty) )))

;; :::::::::::::::: UPDATE PROBABILITIES ::::::::::::::::
;; updateProbablity -- updates probability of a derivation rules based on count information from &count space 
;;              $gSpace -- grammar space
;;              $popSpace -- population space
;;              $nts -- set of non-terminals
;;              $$gId -- generation ID 
;;              $id -- ID of an expression in the genaration space 
;;              $lambda -- learning factor
;;                      $c -- all the production rule reference counts in one tuple
;;                      ($nt $r $cnt) -- deconstructed tuple of non-terminal, a production rule and it's count
;;                      $sums -- sums of counts of all production rules of non-terminals (superposed)
;;                      ($nt $r $oldP $ind) -- each non-terminal/production rule pair matched with the corresponding probability value

(= (updateProbability $gSpace $popSpace $nts $gId $id $lambda)
    (collapse 
        (let*
            (
                ($c (match $popSpace ($gId $id $exp $g $c) $c))
                (($nt $r $cnt) (superpose $c))
                ($sums (getCountSum $c $nt))
                (($nt $r $oldP $ind) (match $gSpace ($nt $r $p $i) ($nt $r $p $i)))

                ($newP (if (== $cnt 0)
                            (round (- $oldP (* $lambda $oldP)) PREC)
                            (let $incP (+ $oldP (/ (* $cnt $lambda) $sums))
                                (round (min $incP 1) PREC)
                            )))
                (() (remove-atom $gSpace ($nt $r $oldP $ind)))
                (() (add-atom $gSpace ($nt $r $newP $ind))))

        (empty) )))

;; getCountSum -- returns sum of all the referral counts of a non-terminal
;;              $iCount -- all the production rule counts used in an expression given as tuple of tuples of counts
;;              $nt -- a non-terminal
;;                      $r -- a production rule
;;                      $c -- count values

(= (getCountSum $iCount $nt)
    (sum` (collapse (let $cs (superpose $iCount)
            (unify $cs ($nt $r $c) $c (empty))))))

;; normalizeP -- adjusts probabilities of derivation rules sum to be exactly one
;;              chucks if sum of probablities of all rules is greater than one
;;              if so, subtract from all derivation rules the same amount given by the following formula
;;              $gSpace -- grammar space
;;              $$nts -- non-terminal set
;;                      ($nt $r $i) -- (a non-terminal, a production rule, index)
;;                      $probSums -- sum of probabilties of all production rules of a non-terminal
;;                      $j -- number of production rules of a non-terminal
;;                      $diff -- difference of sum of probabilities of all production rules of a non-terminal from 1 (unity)

(= (normalizeP $gSpace $nts)
    (collapse (let*
        (
            ($nt (superpose $nts))
            ($probSums (sum` (collapse (match $gSpace ($nt $r $p $i) $p))))
            ($j (sum` (collapse (match $gSpace ($nt $r $p $i) 1))))
            ($diff (round (/ (- 1 $probSums) $j) PREC))
            (($oldProb $newProb $r $i) (match $gSpace ($nt $r $p $i) ($p (round (+ $p $diff) PREC) $r $i)))
            (() (remove-atom $gSpace ($nt $r $oldProb $i)))
        )
        
        (add-atom $gSpace ($nt $r $newProb $i)))))

;; addGenBest -- adds the max scored individual to space &scored
;;              $genId -- generation ID
;;              $popSpace -- population space -- could contain multiple generations
;;              $sSpace -- space for scored inidviduals info
;;                      $iId -- individual ID in a generation
;;                      $g -- individual genotype
;;                      $c -- production rule referal count
;;                      $gBest -- best indvidual of the generation as (score genId iId expression)

(= (addGenBest $genId $popSpace $sSpace)
     (let*
            (
                ($scoredEx (collapse (match $popSpace ($genId $iId $exp $g $c) ((penalizedFitness $exp DATA PENALITY) $genId $iId $exp))))
                ($gBest (getMaxWithKey $scoredEx))
            )
            (add-atom $sSpace $gBest)))

;; applyProbUpdate -- applies the probability update based on wh
;;             uses output of (rndBool) function to decide which best to use for porabability update (current generation or overall)
;;             if (rndBool) returns true -- overall best (entire population) if false --> current generation's best
;;                  $genId -- unique generation Id
;;                  $gSpace -- grammar space
;;                  $popSpace -- population space where all individuals are stored
;;                  $sSpace -- scored space
;;                          $best -- description of the best individual as a tuple (score $genId $iId $exp)

(= (applyProbUpdate $genId $gSpace $popSpace $sSpace)
    (collapse
            (let*
                (
                    (($s $gId $id $exp) (if (rBool)
                                            (getOverallBest $sSpace)
                                            (match $sSpace ($s $genId $iId $exp) ($s $genId $iId $exp))))
                    (() (updateProbability $gSpace $popSpace NTS $gId $id FACTOR))
                    (() (normalizeP $gSpace NTS)))
                
                (empty))))
                 
;; rBool -- random boolean value for choosing between the generation or oveall best

(= (rBool) 
    (let $bit ((py-dot np random.randint)0 2) (== $bit 1)))

;; getMaxWithKey -- gets the max scoring individual using score as key
;;              $tuple -- tuple containing tuples of individual expression scores, generation id, individual id and the inidvidual
;;                      $t -- superposed tuple elements, i.e., inidvidual elements
;;                      $maxKey -- maximum score value being used as sorting key

(= (getMaxWithKey $tuple)
    (let $best 
        (collapse (let*
                (
                    ($t (superpose $tuple))
                    ($key (car-atom $t)) 
                    ($keys (collapse (let $el (superpose $tuple) (car-atom $el)))) 
                    ($max (maxOfTuple $keys))
                )
                (if (== $max $key)
                    $t
                    (empty) )))
        (car-atom $best) ))

(= (maxOfTuple $expr)
    (let*
        (
            ($f (car-atom $expr))
            ($t (cdr-atom $expr)))

        (if (== $t ())
            $f
            (max` $f (maxOfTuple $t)))))

(= (max` $x $y) (if (< $x $y) $y $x))

;; getOverallBest -- gets the individual which is the best of all the scored inidviduals in &scored space
;;              $sSpace -- scored space
;;                      $s -- score
;;                      $genId -- generation ID in a population
;;                      $iId -- individual ID in a generation
;;                      $b -- best individuals in a tuple -- b/c there could be more than one having the same score

(= (getOverallBest $sSpace)
    (let $scoredExps (collapse (match $sSpace ($s $genId $iId $exp) ($s $genId $iId $exp)))
        (getMaxWithKey $scoredExps)))

;; genPop -- generate $ngen number of generations each with $ni individuals
;;              $args -- args 
;;              $popSize -- population size in termns of generation count
;;              $genId -- unique generation identifier
;;              $exCount -- expression count in a generation

(= (genPop $gSpace $cSpace $gtSpace $popSpace $sSpace $popSize $start $genId $exCount $random)
    (if (< $genId $popSize)
        (let*
            (   
                (() (println! $genId))
                (() (genG $gSpace $cSpace $gtSpace $popSpace E $start $genId $exCount ((py-atom random.random))))
                (() (addGenBest $genId $popSpace $sSpace))
                (() (if (== $genId (- $popSize 1))
                        ()
                        (applyProbUpdate $genId $gSpace $popSpace $sSpace)))
            )
            (genPop $gSpace $cSpace $gtSpace $popSpace $sSpace $popSize $start (+ 1 $genId) $exCount ((py-atom random.random)))   
        )
        ()))

;; main -- iniitalizes the genotype, count space and calls the genPop function for generation of generations of indivdiulas
;;               $gSpace -- grammar space$cSpace $gtSpace $popSpace $sSpace $start $genCount $expCount
;;               $cSpace -- count space
;;               $gtSpace -- genotype space 
;;               $popSpace -- expression population space 
;;               $sSpace -- scored instances space
;;               $start -- start symbol 
;;               $genCount -- generation count
;;               $expCount -- individual expression count
;;                      ($s $gId $iId $exp) -- (score, generation id, expression id, expression)

(= (main $gSpace $cSpace $gtSpace $popSpace $sSpace $start $genCount $expCount)
    (let*
        (
            (() (add-atom $gtSpace (genotype (1 2 3 4))))
            (() (add-atom $gtSpace (codon-index 0)))
            (() (iProbs $gSpace NTS))
            (() (iCount $gSpace $cSpace))
            (() (genPop $gSpace $cSpace $gtSpace $popSpace $sSpace G $start $genCount $expCount ((py-atom random.random))))
            (($s $gId $iId $exp) (getOverallBest $sSpace))
        )
        $exp
))

;; ! (main &grammar &count &geno &population &scored start 0 0)
;; ! (match &grammar ($nt $r $p $i) ($nt $r $p $i))
