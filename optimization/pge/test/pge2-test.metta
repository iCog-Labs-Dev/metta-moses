! (register-module! ../../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:scoring:fitness)
! (import! &self metta-moses:optimization:pge:pge2)

! (bind! &gram (new-space))
! (bind! &gen (new-space))
! (bind! &cnt (new-space))
! (bind! &sc (new-space))
! (bind! &bt (new-space))



! (add-reduct &gram 
                (superpose 
                        ((start expr 0)
                         (expr (bop expr expr) 0)
                         (expr (uop expr) 1)
                         (expr term 2)
                         (bop AND 0)
                         (bop OR 1)
                         (uop NOT 0)
                         (term A 0)
                         (term B 1)
                         (term C 2))))

! (match &gram ($nt $r $i) (add-atom &cnt ($nt $r 0.0 $i)))
! (assertEqual (sum (collapse (match &cnt ($nt $r $c $i) $c))) 0)

;; Test -- createGenotype -- creates genotype with random values
; ! (assertEqual (length (createGenotype 10 PREC)) 10)


;; Test -- initializePop initializes population with random genotypes

! (initializePop &gen 2)

! (assertEqual (sum (collapse (match &gen $x 1))) 2)



; ;; Test -- iProbs -- initialize grammar with equiprobable production rules
! (iProbs &gram)

! (assertEqual (match &gram (start $r $p $i) $p) 1)
! (assertEqual (match &gram (start $r $p $i) $p) 1)
! (assertEqual (match &gram (expr term $p $i) $p) 0.333)
! (assertEqual (match &gram (bop AND $p $i) $p) 0.5)


;; Test -- getRule

! (assertEqual (getRule start &gram &cnt 0.425 0 0 False) expr)
! (assertEqual (getRule expr &gram &cnt 0.212 0 0 False) (bop expr expr))
! (assertEqual (getRule expr &gram &cnt 0.421 0 0 False) (uop expr))
! (assertEqual (getRule bop &gram &cnt 0.7 0 0 False) OR)


! (assertEqual (match &cnt (start expr $c $i) $c) 0)
! (assertEqual (match &cnt (expr (bop expr expr) $c $i) $c) 0)
! (assertEqual (match &cnt (expr (uop expr) $c $i) $c) 0)
! (assertEqual (match &cnt (bop OR $c $i) $c) 0)


;; Test -- prCounter -- updates count of each production rule by one everytime it is called
;;            prCounter was called in the above test cases so it has updated counts of corresponding rules

;; lets add one more count for the `expr` production rule of the start non-terminal


! (prCounter &cnt start expr)

;; the count of expr should be 1 now

! (assertEqual (match &cnt (start expr $c $i) $c) 1)

;; Test -- getCodon
! (assertEqual
            (getCodon (0.52 0.43 0.53 0.89 0.12 0.34 0.56 0.78 0.23) 4)
            0.12)

! (assertEqual
            (getCodon (0.021 0.981 0.36 0.402 0.24 0.475 0.319 0.229 0.536) 2) 
                  0.36)


; ;; Test -- genPhen -- generate phonotype from genotype

! (assertEqual (let*
                    (
                        ($expr (genPhen &gram &cnt (0.021 0.981 0.36 0.402 0.24 0.475 0.319 0.229 0.536) NTS start 11 0 False))
                        (() (println! $expr))
                    ) 
                    (isValidExp $expr NTS)) True)

;


;; Test -- rCount -- rests all production rule counts to zero

! (assertEqual
                (let $x (resetCount &cnt)
                    (sum (collapse (match &cnt ($nt $r $c $i) $c)))
                ) 0)



;; Test -- updateProbability
! (prCounter &cnt start expr)
! (prCounter &cnt expr (bop expr expr))
! (prCounter &cnt expr term)
! (prCounter &cnt term B)

! (updateProbability &gram &cnt lambda)

! (assertEqual
                (
                    (match &gram (start expr $p $i) $p) 
                    (match &gram (expr (bop expr expr) $p $i) $p)
                    (match &gram (expr term $p $i) $p)
                    (match &gram (term B $p $i) $p)
                )
                (1 0.383 0.383 0.433))                 

;; Test  -- normalizeP --normalizes probability values to 1

! (normalizeP &gram)
! (assertEqual (sum (collapse(match &gram (expr $r $p $idx) $p))) 1)
! (assertEqual (sum (collapse(match &gram (bop $r $p $idx) $p))) 1)
! (assertEqual (sum (collapse(match &gram (uop $r $p $idx) $p))) 1)
! (assertEqual (sum (collapse(match &gram (term $r $p $idx) $p))) 1)



;; Test -- getOverallBest -- returns the best scored expression

;; adding an intial best individual 
! (add-reduct &bt (3.9 (AND A B) (0.56 0.45 0.67 .23)))

;; updating the best individual with a new individual

! (updateOverallBest &bt (3.9 (AND A B) (0.56 0.45 0.67 .23)) (4 A (0.76 0.23 0.45 0.66)) )

! (assertEqual (match &bt ($s $e $sc) ($s $e $sc)) (4 A (0.76 0.23 0.45 0.66)))

;; Testing varition operators

;; Test -- mutation -- mutates the genotype

! (assertEqual 
            
            (let $a (mutate (0.56 0.45 0.67 .23) 0.1) (len $a)
            ) 4)

;; Test -- crossover -- crosses over two genotypes

! (assertEqual
            (let $a (crossover (0.56 0.45 0.67 .23) (0.76 0.23 0.45 0.66) 0.5) (len $a)
            ) 4)

