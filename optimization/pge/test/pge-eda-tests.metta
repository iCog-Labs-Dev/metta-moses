! (register-module! ../../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:scoring:fitness)
! (import! &self metta-moses:optimization:pge:pge-eda)

! (bind! &gram (new-space))
! (bind! &gen (new-space))
! (bind! &cnt (new-space))
! (bind! &pop (new-space))
! (bind! &s (new-space))

;; Add grammar to space

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
                         (term B 1))))

! (add-atom &gen (genotype (1 2 3 4)))
! (add-atom &gen (codon-index 0))

;; Test -- iCount initializes production rule count in space
! (iCount &gram &cnt)

! (assertEqual (sum (collapse (match &cnt ($nt $r $c $i) $c))) 0)

;; Test -- set genotype in space
! (setGenotype PREC L &gen $dummy)
! (assertEqual (let $g (match &gen (genotype $g) $g)
                    (length $g)) L)
;; Test -- create genotype

! (let $g (createGenotype 9 PREC ((py-atom random.random)))  (assertEqual (length $g) L))

! (assertEqual (let $g (createGenotype 10 PREC ((py-atom random.random)))
    (and (<= (maxOfTuple $g) 1) (>= (minOfTuple $g) 0))) True)

;; Test -- iProbs -- initialize grammar with equiprobable production rules

! (iProbs &gram NTS)

! (assertEqual (match &gram (start $r $p $i) $p) 1)
! (assertEqual (match &gram (expr term $p $i) $p) 0.333)
! (assertEqual (match &gram (bop AND $p $i) $p) 0.5)

;; Test -- getRule 

! (assertEqual (getRule start &gram &cnt 0.425 0 0 dummy) expr)
! (assertEqual (getRule expr &gram &cnt 0.212 0 0 dummy) (bop expr expr))
! (assertEqual (getRule expr &gram &cnt 0.421 0 0 dummy) (uop expr))
! (assertEqual (getRule bop &gram &cnt 0.7 0 0 dummy) OR)

;; Test -- prCounter -- updates count of each production rule by one everytime it is called
;;            prCounter was called in the above test cases so it has updated counts of corresponding rules

! (assertEqual (match &cnt (start expr $c $i) $c) 1)
! (assertEqual (match &cnt (expr (bop expr expr) $c $i) $c) 1)
! (assertEqual (match &cnt (expr (uop expr) $c $i) $c) 1)
! (assertEqual (match &cnt (bop OR $c $i) $c) 1)

;; lets add one more count for the `expr` production rule of the start non-terminal

! (prCounter &cnt start expr dummy)

;; the count of expr should be 2 now

! (assertEqual (match &cnt (start expr $c $i) $c) 2)

;; Test -- getCodon
! (assertEqual 
            (let $codon (getCodon &gen dummy) 
                (get-metatype $codon)) Grounded)

! (assertEqual 
            (let $codon (getCodon &gen dummy) 
                (and (>= $codon 0) (<= $codon 1))) True)

;; Test -- updateIndex -- increases codon-index value by one whenever called

! (assertEqual (let () (updateIndex &gen dummy)
    (match &gen (codon-index $i) $i)) 1)

! (assertEqual (let () (updateIndex &gen dummy)
    (match &gen (codon-index $i) $i)) 2)


;; Test -- genPhen -- generate phonotype from genotype

! (assertEqual (let*
                    (
                        ($expr (genPhen &gram &cnt &gen NTS start 11 ((py-atom random.random))))
                        (() (println! $expr))
                    ) 
                    (isValidExp $expr NTS)) True)

;; Test -- getGeno -- retrieve genotype from space

! (assertEqual (let $g (getGeno &gen dummy) (length $g)) L)
! (assertEqual (let $g (getGeno &gen dummy) 
                (and (<= (maxOfTuple $g) 1) (>= (minOfTuple $g) 0))) True)

;; Test -- getCount -- retrieve production rule referal count as one tuple of tuple

! (assertEqual 
                (let*
                    (
                        ($countTuple (getCount &cnt dummy))
                        ($s (superpose $countTuple))
                    )
                    (unify (start expr $c) $s (>= $c 1) (empty) )
                ) True)

;; Test -- rCount -- rests all production rule counts to zero

! (assertEqual
                (let () (rCount &cnt dummy)
                    (sum (collapse (match &cnt ($nt $r $c $i) $c)))
                ) 0)

;; Test -- getCountSum -- retrieve sum of all production rule counts for a non-terminal

! (assertEqual
                (let $c ((start expr 1) (expr (bop expr expr) 2) (expr (uop expr) 3) (expr term 4))
                    (getCountSum $c start)
                ) 1)

! (assertEqual
                (let $c ((start expr 1) (expr (bop expr expr) 2) (expr (uop expr) 3) (expr term 4))
                    (getCountSum $c expr)
                ) 9)


;; Test -- maxOfTuple

!(assertEqual (maxOfTuple (1 2 3 1)) 3)
!(assertEqual (maxOfTuple (3 -2 11 3 1)) 11)

;; Test -- getMaxWithKey

! (assertEqual (getMaxWithKey ((1 A) (5 B) (3 D))) (5 B))
! (assertEqual (getMaxWithKey ((1 A B C) (5 B C D) (3 D E F))) (5 B C D))
! (assertEqual (getMaxWithKey ((1 A B C) (5 B C D) (3 D E F) (6 T H A))) (6 T H A))

;; Test -- updateProbability

! (add-atom &pop 
        (0 0 B () ((start expr 1) (expr (bop expr expr) 0) 
                    (expr (uop expr) 0) (expr term 1)
                    (bop AND 0) (bop OR 0) (uop NOT 0)  
                    (term A 0) (term B 1) )))

! (updateProbability &gram &pop NTS 0 0 0.05)

! (assertEqual
                (
                    (match &gram (start expr $p $i) $p) 
                    (match &gram (expr (bop expr expr) $p $i) $p)
                    (match &gram (expr term $p $i) $p)
                    (match &gram (term B $p $i) $p)
                )
                (1 0.316 0.383 0.55))

;; Test  -- normalizeP --normalizes probability values to 1

! (normalizeP &gram NTS)

! (assertEqual
        (round (sum (collapse (match &gram (expr $r $p $i) $p))) 2) 1)

! (assertEqual
        (round (sum (collapse (match &gram (term $r $p $i) $p))) 2) 1)

;; Test -- addGenBest

! (add-reduct &pop (superpose (
                    (0 0 (AND A B) () ())
                    (0 1 B () ())
                    (1 0 B () ())
                    )))

! (addGenBest 0 &pop &s)
! (assertEqual
    ; (let () (addGenBest 0 &pop &s)
                    (match &s ($s $gId $id $i) ($gId $id $i))
                    (0 0 (AND A B)) )
                    ; )

;; Test    -- getOverallBest

! (add-reduct &s (superpose (
                        (3 1 0 B)
                        (1 2 1 (NOT B))
                    )))

;; considering (3.9 0 0 (AND A B)) has been added in the above step this should be the overall best

! (assertEqual (getOverallBest &s) (3.9 0 0 (AND A B)))

;; Test   -- test main loop

! (let*
     (
        ($space (superpose (&gram &cnt &gen &pop &s)))
        (() (cleanSpace $space))
    ) 
    (empty))

! (add-reduct &gram 
                (superpose 
                        ((start expr 0)
                         (expr (bop expr expr) 0)
                         (expr (uop expr) 1)
                         (expr term 2)
                         (bop AND 0)
                         (bop OR 1)
                         (term A 0)
                         (uop NOT 0)
                         (term B 1))))

! (main &gram &cnt &gen &pop &s start 0 0)

! (assertEqual 
            (let*
                (
                    ($scoredCount (sum (collapse (match &s ($s $gId $id $i) 1))))
                    ($totalPop (sum (collapse (match &pop ($genId $id $i $g $c) 1))))
                )
                ($scoredCount $totalPop)
                ) (G (* E G)))
