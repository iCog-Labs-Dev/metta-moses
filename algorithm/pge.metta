! (register-module! ../../metta-moses)
! (import! &self metta-moses:utilities:general-helpers)

;; python bindings for random number generation and rounding
! (bind! np (py-atom numpy))
! (bind! rd (py-atom round))

;; &grammar -- space for grammar rule, genotype
! (bind! &grammar (new-space))
! (bind! &geno (new-space))
! (bind! &count (new-space))

!(add-atom &grammar (start expr 0))
!(add-atom &grammar (expr (bop expr expr) 0))
!(add-atom &grammar (expr (uop expr) 1))
!(add-atom &grammar (expr term 2))
!(add-atom &grammar (bop AND 0))
!(add-atom &grammar (bop OR 1))
!(add-atom &grammar (uop NOT 0))
!(add-atom &grammar (term X 0))
!(add-atom &grammar (term Y 1))

;; ::::::::::::: CREATING GENOTYPE :::::::::::::
;; createGenotype of a specified length in the range[0,1] and rounded off 
;; Parameters:- 
;;          $n length of the genotype tuple
;;          $prec signinfican digits for round function
;;          $r a random float in the range (0 1) 
;;          $c carries recursive calls to the createGenotype function with updated length (- $len 1) parameter
;; Example :- 
;;          (createGenotype 9 3)
;;          -- 1st run -- (0.227 0.584 0.498 0.364 0.912 0.881 0.504 0.206 0.119)
;;          -- 2nd run -- (0.71 0.511 0.312 0.676 0.281 0.669 0.128 0.857 0.848)
;;          -- 3rd run -- (0.467 0.206 0.563 0.957 0.029 0.907 0.423 0.675 0.231)

(: (createGenotype (-> Number Number Expression)))
(= (createGenotype $n $prec $random)
    (if (== $n 0)
        ()
        (let* 
            (   
                ($r (rd ((py-dot np random.uniform)0 1) $prec))
                ($c (createGenotype (- $n 1) $prec ((py-dot np random.uniform)0 1)))
            )
            (cons-atom $r $c))))
    
;; setGenotype -- calculates the number of all derivation rules ($n) and calls the createGenotype 
;;                function to generate tuple of uniform random values of length $n
;;              gSpace -- grammar space
;;              tSpace -- genotype space
;;              $n -- total number of derivation rules in the grammar
;;              $nt -- a non-terminal
;;              $r -- a production rule
;;              $i -- index of a derivation rule in a non-terminal
;;              $g -- generated genotype
;;              3 -- decimal places to rounding off to

(= (setGenotype $gSpace $tSpace $random)
    (let*
        (   
            ($n (sum (collapse (match $gSpace ($nt $r $i) 1))))
            ($g (createGenotype $n 3 ((py-dot np random.uniform)0 1)))
            ($geno (genotype $g))
            (() (match $tSpace (genotype $genotype) (remove-atom $tSpace (genotype $genotype))))
            (() (println! $geno))
        )
         (add-atom $tSpace $geno)))

; ! (setGenotype &grammar &geno)

;; ::::::::::::: ASSIGNING INITIAL PROBABILITIES :::::::::::::
;; iProbs -- assigns equal probability values for production rules in a non-terminal
;;          counts the total number of production rules ($n) assigns 1/n to each production rule
;;          adds the new production rule atoms to the sapce like ($nt $r $iP $i)
;;          $gSpace -- grammar space
;;          $nts -- all unique non-terminals in the production rule
;;          $nt -- a non-terminal
;;          $r -- a 
;;          $i -- production rule index
;;          $nr -- number of production rules for a non-terminal
;;          $iP -- initial probability
;;          3 -- decimal places to rounding off to
;; Note:-   iProbs doesn't remove the old grammar pattern it just adds a new pattern with probability values
;;          So when queries with (get-atoms) attoms with the old pattern ($nt $r $i) are returned as well

(= (iProbs $gSpace)
    (let*
        (
            ($nts (collapse (unique (match $gSpace ($nt $r $i) $nt))))
            ($nt (superpose $nts))
            ($nr (sum (collapse (match $gSpace ($nt $r $i) 1))))
            ($iP (rd (/ 1 $nr) 3))
        )
        (match $gSpace ($nt $r $i) (add-atom $gSpace ($nt $r $iP $i)))))

! (iProbs &grammar)
; ! (get-atoms &grammar)

;; ::::::::::::: PICKING PRODUCTION RULES BASED ON GENOTYPE AND CUMMULATIVE PROBABILITIES :::::::::::::
;; getRule gets the correct production rule based on cummulative probablity values
;; Parameteres:- $nt -- a non-terminal
;;               $gSpace -- grammar space
;;               $cSpace -- count space
;;               $tProb -- probabilty of derviation options from the genotype tuple
;;               $iCProb -- the initial cummulative probablity that starts as 0 and keeps being updated
;;               $i -- index of the expansion options for a given non-terminal for ordered exploration,  it starts as 0
;;               $dummy -- needed to prevent metta from caching results of recursive calls
;; $internal variables 
;;               $nt -- a non-terminal
;;               $r -- a production rule
;;               $p -- probablity value associated with a 
;;               $i -- production rule index
;; Examples:- 
;;               (getRule start &grammar 0.61 0 0) -- expr             
;;               (getRule expr &grammar 0.26 0 0) -- (bop expr expr)           
;;               (getRule expr &grammar 0.7 0 0) -- term             
            
(= (getRule $nt $gSpace $cSpace $tProb $iCProb $i $dummy)
    (match $gSpace ($nt $r $p $i) 
            (if (<= $tProb (+ $p $iCProb))
                (let () (prCounter $cSpace $nt $r ((py-dot np random.uniform)0 1))
                    $r)
                (getRule $nt $gSpace $cSpace $tProb (+ $p $iCProb) (+ $i 1) $dummy))))

;; ::::::::::::: SET AND GET CODON :::::::::::::
;; initialize codon index 0
! (add-atom &geno (codon-index 0))
! (add-atom &geno (genotype (0 1 2 3 4)))

;; getCodon -- returns a codon from the genotype by using an index value
;;          $tSpace -- genotype space -- contains codon-index as well
;;          $gSpace -- grammar space
;;          $dummy -- needed to prevent metta from caching results of recursive calls
;;              $i -- index gotten from &geno (codon-index $i)
;;              $g -- a genotype tuple
;;              $len -- length of genotype tuple
;;              $index -- value in the range [0 (- $len 1)] obtained using module 

(= (getCodon $tSpace $gSpace $dummy)
    (let*
        ( 
            ($i (match $tSpace (codon-index $ind) $ind))
             (() (println! ("codon index " $i)))
            ($g (match $tSpace (genotype $geno) $geno))
            ($len (sum (collapse (match $gSpace ($nt $r $p $index) 1))))
            ($index (% $i $len))
           
        )
        (selectByIndex $g $index)))

;; updateIndex -- increments the codon-index value by 1 when called
;;              $tSpace -- genotype space
;;              $dummy -- needed to prevent metta from caching results of recursive calls
;;                  $i -- old index
;;                  $next -- new index (+ 1 $i)

(= (updateIndex $tSpace $dummy)
    (let*
        (
            ($i (match $tSpace (codon-index $i) $i))
            (() (remove-atom $tSpace (codon-index $i)))
            ($next (+ 1 $i))
        )
        (add-atom $tSpace (codon-index $next))))

;; ::::::::::::: GENERATE PHENOTYPE :::::::::::::
;; genPhen -- generates phenotype starting from start symbol and using the genotype information to map productio rules
;;          $gSpace -- grammar space
;;          $tSpace -- genotype space
;;          $start -- the start symbol
;;          $random -- needed to prevent metta from caching results of recursive calls
;;              $codon -- a probablity value gotten from &tSpace
;;              $nts -- a set of unique non-terminals of the grammar
;;              

(= (genPhen $gSpace $cSpace $tSpace $nts $start $maxIter $random)
    (if (and (isLiteral $start) (not (isMember $start $nts)))
        $start
        (if (== (get-metatype $start) Expression)
            (let* 
                (
                    (($f $t) (decons $start))
                    ($mapped (genPhen $gSpace $cSpace $tSpace $nts $f $maxIter ((py-atom random.random))))
                    (() (println! ("mapped    " $mapped))))
                (if (== $t ())
                    (cons-atom $mapped $t)
                    (let $r (genPhen $gSpace $cSpace $tSpace $nts $t $maxIter ((py-atom random.random)))
                        (cons-atom $mapped $r))))                   
            (let*
                (
                    ($codon (getCodon $tSpace $gSpace ((py-dot np random.uniform)0 1)))
                    ($nextRule (getRule $start $gSpace $cSpace $codon 0 0 ((py-atom random.random))))
                    (() (println! ("next codon " $codon)))
                    (() (println! ("next rule " $nextRule)))
                    (() (updateIndex $tSpace ((py-dot np random.uniform)0 1)))
                    ($codonIndex (match $tSpace (codon-index $i) $i))
                )
                (if (< $codonIndex $maxIter)
                    (genPhen $gSpace $cSpace $tSpace $nts $nextRule $maxIter ((py-dot np random.uniform)0 1))
                    ()
                )
                ))))

;; genI -- generates an individual expression 
;;          $gSpace -- grammar space
;;          $tSpace -- genotype space
;;          $start -- start symbol
;;          $random -- needed to prevent metta from caching results of recursive calls
;;              $nts -- tuple of unique non-terminals
;;              $maxIter -- tuple of unique non-terminals

(= (genI $gSpace $cSpace $tSpace $start $random)
    (let* 
        (
            ($nts (collapse (unique (match $gSpace ($nt $r $i) $nt))))
            ($maxIter (* (sum (collapse (match $gSpace ($nt $r $i) 1))) 1))
        )
        (genPhen $gSpace $cSpace $tSpace $nts $start $maxIter ((py-dot np random.uniform)0 1))
        ))
; ! (genI &grammar &count &geno start ())
;; ::::::::::::: TEST GENERATE INIDVIDUAL :::::::::::::
; ! (genI &grammar &geno start ((py-atom random.random)))
; ! (get-atoms &geno)

;; ;; ::::::::::::: GENERATE GENERATION :::::::::::::
;; genG -- generate a single generation of size n
;;          $n -- population size
;;          $gSpace -- grammar space
;;          $tSpace -- genotype space
;;          $genSpace -- space for population
;;          $start -- start symbol 
;;          $random -- needed to prevent metta from caching results of recursive calls
;;          $id -- id for indvidual
;;              $i -- indvidual expression

! (bind! &generation (new-space))

(= (genG $n $gSpace $cSpace $tSpace $genSpace $start $random $id)
    (if (>= $n 1)
        (let*
            (   
                (() (println! (""N"" $n)))
                (() (setGenotype $gSpace $tSpace ((py-dot np random.uniform)0 1)))
                ; (() (iCount $cSpace ((py-dot np random.uniform)0 1)))
                ($i (genI $gSpace $cSpace $tSpace $start ((py-dot np random.uniform)0 1)))
                ;; restet codon index 
                (()(match $tSpace (codon-index $ind) (remove-atom $tSpace (codon-index $ind))))
                (() (add-atom $tSpace (codon-index 0)))
                ($g (getGeno $tSpace))
                ($c (getCount $cSpace ((py-dot np random.uniform)0 1)))
                (() (add-atom $genSpace ($id (indivdual $i) $g $c)))
                ; (() (println! (match $genSpace ($id (indivdual $i) $g $c) $c)))
                ($_ (iCount $cSpace ((py-atom random.random))))
            )
            
                (genG (- $n 1) $gSpace $cSpace $tSpace $genSpace $start ((py-atom random.random)) (+ $id 1))
        )
    ;    (let $i (genI $gSpace $tSpace $start ((py-atom random.random)))
    ;         (add-atom $genSpace ($id (indivdual $i)))
    ;    )
    ; (empty)
    ; (genG 0 $gSpace $cSpace $tSpace $genSpace $start ((py-atom random.random)) (+ $id 1))
    ()
    )
)

(= (getGeno $tSpace)
    (match $tSpace (genotype $g) (genotype $g))
)

;; iCount -- a function to get and initialize count of derivation options to 0
;; should be able to reset counts from previous iteration
;;              $gSpace -- grammar space
;;              $cSpace -- production rule count space
;;                  $nt -- a non-terminal 
;;                  $r -- a production rule
;;                  $i -- index
;;                  $c -- referral count
 
;; assign random (could be zero) count for each  production rule so that reset operation is possible
;; 
! (match &grammar ($nt $r $i) (add-atom &count ($nt $r 0 $i)))

(= (iCount $cSpace $random)
    (collapse (match $cSpace ($nt $r $c $i) (let () (remove-atom $cSpace ($nt $r $c $i))
                                        (add-atom $cSpace ($nt $r 0 $i)))
    )))
; (= (resetCount $cSpace $random)
;     (let $nts (collapse (unique (match $cSpace ($nt $r $c $i) $nt)))
;         (iCount $cSpace $nts ((py-dot np random.uniform)0 1))
;     )
; )
;; prCounter -- increments a production rule's count by one when called
;;              $cSpace -- count space
;;              $nt -- a non-terminal
;;              $r -- a production rule
;;                  $c -- count variable
;;                  $i -- index variable

(= (prCounter $cSpace $nt $r $random)
    (let* 
        (
            (($c $i) (match $cSpace ($nt $r $c $i) ($c $i)))
            (() (remove-atom $cSpace ($nt $r $c $i)))
            ($next (+ 1 $c))
        )
        (add-atom $cSpace ($nt $r $next $i))))


(= (getCountSum $iCount $nt)
    (sum (collapse (let $cs (superpose $iCount)
            (unify $cs ($nt $r $c) $c
                    (empty))))))

;; getCount -- returns count of all production rules for appending to individual expression metta data
;;              $cSpace -- count space
;;                  $nt -- a non-terminal
;;                  $r -- a production rule
;;                  $c -- production rule referal count
;;                  $i -- index

(= (getCount $cSpace $random)
   (collapse (match $cSpace ($nt $r $c $i) ($nt $r $c))))

(= (getSum $cI $nts)
    (collapse (let*
        (
            ($nt (unique (match &count ($nt $r $c $i) $nt)))
        )
       (unify $cI ($nt $r $c) $c (empty))
    ))
)

! (genG 1 &grammar &count &geno &generation start ((py-dot np random.uniform)0 1) 0)

; ! (get-atoms &generation)

;; :::::::::::::::: SAMPLE OUTPUTS ::::::::::::::::

; (0 (indivdual X) (genotype (0.126 0.859 0.231 0.164 0.233 0.418 0.247 0.275 0.115)) (count (expr (uop expr) 0) (expr (bop expr expr) 0) (expr term 1) (term Y 0) (term X 1) (uop NOT 0) (start expr 1) (bop AND 0) (bop OR 0))), 

; (1 (indivdual X) (genotype (0.126 0.859 0.231 0.164 0.233 0.418 0.247 0.275 0.115)) (count (expr (bop expr expr) 0) (expr (uop expr) 0) (expr term 1) (term Y 0) (term X 1) (uop NOT 0) (start expr 1) (bop AND 0) (bop OR 0))), 


; (2 (indivdual (NOT Y)) (genotype (0.126 0.859 0.231 0.164 0.233 0.418 0.247 0.275 0.115)) (count (expr (bop expr expr) 0) (expr (uop expr) 1) (expr term 1) (term Y 1) (term X 0) (uop NOT 1) (start expr 1) (bop AND 0) (bop OR 0)))


;; ::::::::::::: test phonetype generation :::::::::::::::
; ! (setGenotype &grammar &geno ((py-dot np random.uniform)0 1))
; ! (genPhen &grammar &count &geno (start expr bop uop term) start ((py-dot np random.uniform)0 1))
;; ::::::::::::: test phonetype generation :::::::::::::::

;; :::::::::::::::: UPDATE PROBABILITIES ::::::::::::::::
;; updateProbablity -- updates probability of a derivation rules based on count information from &count space 
;;              $gSpace -- grammar space
;;              $genSpace -- generation space
;;              $id -- ID of an expression in the genaration space 
;;;             $lambda -- learning factor 

(= (updateProbability $gSpace $genSpace $id $lambda)
    (let*
        (
            ($c (match $genSpace ($id $i $g $c) $c))
            ($counts (superpose $c))
            ($nt (unique (match $gSpace ($nt $r $i) $nt)))
            ($sums (getCountSum $c $nt))
        )
        (unify $counts ($nt $r $cnt) 
                (if (== $cnt 0)
                    (let* 
                        (
                            (($nt $r $oldP $i) (match &grammar ($nt $r $p $i) ($nt $r $p $i)))
                            ($newP (rd (- $oldP (* $lambda $oldP)) 3))
                            (() (remove-atom &grammar ($nt $r $oldP $i)))
                        )
                        (add-atom &grammar ($nt $r $newP $i))
                    )
                    (let*
                        (
                            (($nt $r $oldP $i) (match &grammar ($nt $r $p $i) ($nt $r $p $i)))
                            ($incP (+ $oldP (/ (* $cnt $lambda) $sums)))
                            ($newP (rd (min $incP 1) 3))
                            (() (remove-atom &grammar ($nt $r $oldP $i)))
                        )
                        (add-atom &grammar ($nt $r $newP $i))
                    )
                )
                    (empty))))


;; normalize -- adjusts probabilities of derivation rules sum to be exactly one
;;        chucks if sum of probablities of all rules is greater than one
;;        if so, subtract from all derivation rules the same amount given by the following formula
;;              $gSpace -- grammar space
;;              

(= (normalizeP $gSpace)
    (let*
        (
            ($nt (unique (match $gSpace ($nt $r $i) $nt)))
            ($probSums (sum (collapse (match $gSpace ($nt $r $p $i) $p))))
            ($j (sum (collapse (match $gSpace ($nt $r $p $i) 1))))
            ($diff (rd (/ (- 1 $probSums) $j) 3))
            (($oldProb $newProb $r $i) (match $gSpace ($nt $r $p $i) ($p (rd (+ $p $diff) 3) $r $i)))
            ; ($oldProb (match $grammarSpace ($nt (($rule $prob) $index))))
            (() (println! ("new P  " $newProb)))
            (() (remove-atom $gSpace ($nt $r $oldProb $i)))
        )
        
        (add-atom $gSpace ($nt $r $newProb $i))
    ))

! (get-atoms &grammar)

! (updateProbability &grammar &generation 0 0.05)

! (get-atoms &grammar)

! (normalizeP &grammar)

! (get-atoms &grammar)
