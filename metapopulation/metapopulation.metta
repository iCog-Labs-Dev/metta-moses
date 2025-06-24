;; importing constants -- a suitable value for each of these has to be determined based on experiment
; ! (bind! MIN-POOL-SIZE 250) ;; this is copied from the c++ implementation -- XXX a values that works best for the current implementation should be found by experrimentation??
; ! (bind! COMP-TEMP 6.0)
; ! (bind! CAP-COEF 50)

;; python int casting function
! (bind! int (py-atom "int"))

;; Exemplar type
(: Exemplar (-> $a Type))
(: mkExemplar (-> (Tree $a) DemeId Cscore BehavioralScore (Exemplar $a)))

;; resizeMetapop -- resizes the metapopulation based on 
;;      $nToKeep     -- the number of the top most exemplars which are exempt from removal
;;      $minPoolSize -- protects the metapopulation against excessive trimming
;;      $compTemp    -- used to calculate the range of scores that are likely to be preserved by the selection process
;;      $capCoef     -- use to balance the number of individuals in the metapopulation by balancing population size so that it neither blows out the RAM or lacks enough variety -- may not even be necessary
;;      $genCount    -- used with $capCoef in the determination of max pop allowed given the above contstraints
(: resizeMetapop (-> (OS (Exemplar $a)) Number Number Number Number Number (OS (Exemplar $a))))
(= (resizeMetapop (ConsOS $exemplar $rest) $nToKeep $minPoolSize $compTemp $capCoef $genCount)
    (let ($size $capSize) ((OS.length (ConsOS $exmplar $rest)) (int (capSize $capCoef $genCount))) ;; bind two variables with two function calls 
        (if (<= $size $minPoolSize)
            (ConsOS $exemplar $rest)            
            (let (mkExemplar $tree $demeId $cScore $bScore) $exemplar ;; exemplar with the best score
            (chain (getPenScore $cScore) $topScore
                (chain (- $topScore (usefulScoreRange $compTemp)) $worstScore
                    (chain (getBetterCandidates (ConsOS $exemplar $rest) $worstScore) $reducedMetapop
                        (chain (OS.length $reducedMetapop) $popSize
                            (if (<= $popSize $capSize) 
                                $reducedMetapop
                                (cullAtRandom $reducedMetapop $nToKeep (- $popSize $capSize)))))))))))

;; compute useful range 
(: usefulScoreRange (-> Number Number))
(= (usefulScoreRange $compTemp) (/ (* $compTemp 30.0) 100.0))

;; calculates cap size based on number of generations -- must be recomuted based on actual data in the new implementation
;; for the time being implement the C++ code as it
(: capSize (-> Number Number Number))
(= (capSize $capCoef $genCount)
    (* (* $capCoef (+ $genCount 250)) (+ 1 (* 2 (pow-math EXP (/ (* -1 $genCount) 500))))))

;; getBetterCandidates -- returns all the memmbers whose score are greater than or equal to a predetermined worst score
(: getBetterCandidates (-> (OS (Exemplar $a)) Number (OS (Exemplar $a))))
(= (getBetterCandidates NilOS $score) NilOS)
(= (getBetterCandidates (ConsOS $exemplar $rest) $worstScore)
    (let (mkExemplar $tree $demeId $cScore $bScore) $exemplar
            (chain (getPenScore $cScore) $penScore
        
                (if (>= $penScore $worstScore)
                    (ConsOS $exemplar (getBetterCandidates $rest $worstScore))
                    NilOS))))

;; cullAtRandom -- maintains the top N exemplars and removes candidates that are in the list with worse scores by chance
;; gives a certain chance for poor candidates to survive
(: cullAtRandom (-> (OS (Exemplar $a)) Number Number (OS (Exemplar $a))))
(= (cullAtRandom (ConsOS $exemplar $rest) $offset $nToRemove)
    (if (> $nToRemove 0)
        (chain (OS.length (ConsOS $exemplar $rest)) $popSize
            (chain (random-int &rng $offset $popSize) $index 
                (chain (OS.removeByIdx (ConsOS $exemplar $rest) $index) $newPop
                    (cullAtRandom $newPop $offset (- $nToRemove 1)))))
        (ConsOS $exemplar $rest))) 

;; Compares two exemplars based on their Cscores, returning L if the first is less, E if equal, or G if greater.
;; Params:
;;   (Exemplar $a): First exemplar 
;;   (Exemplar $a): Second exemplar 
;; Return: L (less), E (equal), or G (greater)
(: compareExemplar (-> (Exemplar $a) (Exemplar $a) Atom))
(= (compareExemplar 
        (mkExemplar $tree1 $demeId1 $cscore1 $bscr1)
        (mkExemplar $tree2 $demeId2 $cscore2 $bscr2))
   (if (cScore< $cscore1 $cscore2) L
       (if (cScore== $cscore1 $cscore2) E G)))

;; Extract BScore from Exemplar
;; Params:
;;   (Exemplar $a): exemplar 
;; Return: $bscore
(: getExemplarBScore (-> (Exemplar $a) BehavioralScore))
(= (getExemplarBScore (mkExemplar $tree $demeId $cscore $bscore)) $bscore)

;; Extract PenScore from Exemplar
;; Params:
;;   (Exemplar $a): exemplar 
;; Return: $penScore
(: getExemplarPenScore (-> (Exemplar $a) Number))
(= (getExemplarPenScore (mkExemplar $tree $demeId $cscore $bscore)) (getPenScore $cscore))

;; Extract Cscore from Exemplar
;; Params:
;;   (Exemplar $a): exemplar 
;; Return: $cscore
(: getExemplarCscore (-> (Exemplar $a) Cscore))
(= (getExemplarCscore (mkExemplar $tree $demeId $cscore $bscore)) $cscore)

;; Extract Tree from Exemplar
;; Params:
;;   (Exemplar $a): exemplar 
;; Return: $tree
(: getExemplarTree (-> (Exemplar $a) (Tree $a)))
(= (getExemplarTree (mkExemplar $tree $demeId $cscore $bscore)) $tree)

