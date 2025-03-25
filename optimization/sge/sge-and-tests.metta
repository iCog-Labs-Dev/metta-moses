! (register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:utilities:expression-helpers)
! (import! &self metta-moses:scoring:fitness)

;; Structured grammatical evolution (SGE)
;; This implementation is based on the research paper: https://link.springer.com/article/10.1007/s10710-015-9262-4

;; Grammar Chosen: Boolean expressions
;; <start> -> <expr>
;; <expr>  -> <bop> <expr> <expr> |
;;            <uop> <expr> |
;;            <term>
;; <bop>   -> AND | OR
;; <uop>   -> NOT

! (bind! rnd (py-atom numpy.random))

!(bind! &grammar (new-space))
!(bind! &maxDepth 3)
!(bind! &lastIndex (new-state 0))
!(bind! &elitism 1)
!(bind! &popSize 3)
!(bind! &tSize 3)
!(bind! &probCrossOver 0.7)
!(bind! &probMutate 0.2)
!(bind! &maxGen 2)

!(add-atom &grammar (start expr 0))
!(add-atom &grammar (expr (bop expr expr) 0))
!(add-atom &grammar (expr (uop expr) 1))
!(add-atom &grammar (expr term 2))
!(add-atom &grammar (bop AND 0))
!(add-atom &grammar (bop OR 1))
!(add-atom &grammar (uop NOT 0))

;; TODO: Automate insertion.
!(add-atom &grammar (term X 0))
!(add-atom &grammar (term Y 1))

;; Truth table for AND
!(bind! &data (new-space))
!(add-reduct &data (superpose (
       (True (X True) (Y True))
       (False (X False) (Y True))
       (False (X True) (Y False))
       (False (X False) (Y False)))))

!(bind! &refSpace (new-space))
!(bind! &countSpace (new-space))
!(bind! &refCountSpace (new-space))
!(bind! &ubSpace (new-space))
!(bind! &resultMap (new-space))

(= (getNts $grammarSpace) (unique (match $grammarSpace ($lhs $rhs $i) $lhs)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                                                                                                                  ;;;;
;;;;                                       Recursive Production Rule expansion                                        ;;;;
;;;;                                                                                                                  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Steps For recursive production rule expansion:
;; 1. Start with a single non-terminal to be expanded and its corresponding depth.
;; 2. Match all of its right-hand side (RHS) productions.
;; 3. Filter out recursive production rules and non-recursive ones and store them in different variables.
;; 4. Until the depth isn't equal to the maximum depth, do the following:
;;    a. For each recursive rule:
;;       i. Replace every occurrence of the lhs in the rhs with the lhs + depth.
;;       ii. If depth is equal to 0, don't update the lhs in the new production rule.
;;           Add the new production rules; the unchanged lhs, the updated rhs, and the non-recursive rules.
;;       iii. Else, update the lhs to be lhs + (depth - 1).
;;           Add the new production rules; the updated lhs, the updated rhs, and the non-recursive rules.
;; 5. When maximum depth has been reached, add one other additional rule:
;;    a. The lhs will be updated to lhs + (maxDepth - 1).
;;    b. The rhs will be updated as follows:
;;       i. Every recursive occurrence of the lhs will be replaced with the non-recursive rule.
;;       ii. This is done in a way that all possible combinations of the non-recursive rules
;;           and the lhs occurrence are covered. Possible implementation is using a superposed
;;           version of the non-recursive rules and then using those in place of the lhs occurrence.
;;           This will generate all possible combinations.
;; 6. Do this for all of the non-terminals.


;; Expand the given grammar up to a specified maximum depth.
;; Expanding a grammar is changing its recursive rules into non recursive ones.
;;
;; The arguments are:
;;
;; $maxDepth: The level of recursion used to expand the grammar.
;; $grammarSpace: The initial grammar space containing non-terminals and their corresponding production rules.
;;
;; Returns:
;; - No usefull result except for some unit / (). The update is done on the elements of the space.
;;
;; Example:
;;     Grammar: S    -> Expr
;;              Expr -> Expr Op Expr | term
;;              Op   -> + | *
;;
;;     Expanded Grammar with depth 2:
;;             S          -> Expr
;;             Expr       -> Expr_lvl_0 Op Expr_lvl_0 | term
;;             Expr_lvl_0 -> Expr_lvl_1 Op Expr_lvl_1 | term
;;             Expr_lvl_1 -> term Op term | term
;;             Op         -> + | *
;; FIX: Remove index from original grammar.
(= (expandGrammar $maxDepth $grammarSpace)
   (let $nts (unique (match $grammarSpace ($lhs $rhs $i) $lhs))
             (expandRecursiveNT $nts $maxDepth $grammarSpace)))


;; Expand a non-terminal with recursive right-hand side (RHS) production rules.
;;
;; The arguments are:
;;
;; $nt: The non-terminal to be expanded.
;; $maxDepth: The maximum recursion to use for the expansion of the non-terminal.
;; $grammarSpace: The grammar space containing production rules.
;;
;; Returns:
;; - No usefull result except for some unit / (). The update is done on the elements of the space.
(= (expandRecursiveNT $nt $maxDepth $grammarSpace)
   (let $rRules (collapse (getRecursiveRules $nt $grammarSpace))
        (if (~= $rRules (()))
              (let*
                  (
                    ($nrRules (collapse (unique (getNonRecursiveRules $nt $grammarSpace))))
                    ($updatedNRRules (if (~= $nrRules ()) (collapse (getUpdatedNRRule (superpose $nrRules) $maxDepth)) ()))
                    ($_ (if (~= $updatedNRRules ()) (collapse (add-reduct $grammarSpace (superpose $updatedNRRules))) ()))
                    ($r (collapse (let $rRule (superpose $rRules) (remove-atom $grammarSpace $rRule))))
                    ;; (() (println! (RRules: $rRules)))

                    ($_' (until maxDepthNotReached applyExpandRules ($nt 0 $maxDepth $rRules $nrRules $grammarSpace)))

                    ($rulePerms (if (~= $nrRules ()) (collapse (let ($lhs $rhs $i) (superpose $rRules) (removeRFromRule $nt $rhs $i $nrRules))) ()))
                    ($lhs ($nt (- $maxDepth 1)))

                    ($updatedRules (if (~= $rulePerms ()) (collapse (let $rules (superpose $rulePerms) (cons-atom $lhs $rules))) ()))
                    ($_''  (collapse (let ($lhs $rhs $i) (superpose $rRules) (remove-atom $grammarSpace ($lhs $rhs $i)))))
                    ($_''' (change-state! &lastIndex 0))
                    ;; (() (println! (State Resetted)))
                    )
                  (if (~= $updatedRules ()) (add-reduct $grammarSpace (superpose $updatedRules)) ()))
              ())))


;; Check if the maximum depth has been reached for a non-terminal expansion.
;; A predicate function to be used in an the until function.
;; Returns True if the maximum depth has been reached, otherwise False.
(= (maxDepthNotReached ($nt $nextDepth $maxDepth $rRules $initialNRRules $grammarSpace)) (>= $nextDepth $maxDepth))

;; An `apply` function for expandRules to be used in the until function.
;; Returns the next state to be used by the until function.
(= (applyExpandRules ($nt $depth $maxDepth $rRules $initialNRRules $grammarSpace))
   (let $_ (expandRules $depth $rRules $initialNRRules $grammarSpace)
           ($nt (+ $depth 1) $maxDepth $rRules $initialNRRules $grammarSpace)))

;; Expand the given non-terminal's production rules for a single depth.
;;
;; The arguments are:
;;
;; $depth: The current depth of the expansion.
;; $rrules: The recursive production rules.
;; $nrrules: The non-recursive production rules.
;; $grammarSpace: The grammar space containing production rules.
;;
;; Returns:
;; - No usefull result except for some unit / (). The update is done on the elements of the space.
(= (expandRules $depth $rrules $nrrules $grammarSpace)
   (let*
      (
        ;; (() (println! (Params: RRules: $rrules NRRules: $nrrules Depth: $depth)))
        ($updatedRRules (if (~= $rrules ()) (collapse (expandRule $depth (superpose $rrules))) ()))
        ($updatedNRRules (if (~= $nrrules ()) (collapse (let ($nrLhs $nrRhs $nrI) (superpose $nrrules) (($nrLhs (- $depth 1)) $nrRhs $nrI))) ()))
        ($_ (if (~= $updatedRRules ()) (collapse (add-reduct $grammarSpace (superpose $updatedRRules))) ())))
      (if (and (~= $depth 0) (~= $updatedNRRules ()))
          (collapse (add-reduct $grammarSpace (superpose $updatedNRRules)))
          ())))

;; Update one rule. The update is to replace every occurrence of the lhs in the rhs with a new value of (lhs + depth).
;; It then updates the lhs too based on the depth.
;;
;; The arguments are:
;;
;; $depth: The current depth of the expansion.
;; $lhs: The left-hand side of the production rule.
;; $rhs: The right-hand side of the production rule.
;; $i: The index of the production rule.
;;
;; Returns:
;; - The updated production rule.
;;
;; Example:
;;    Rule: (expr (bop expr expr) 0)
;;    Depth: 1
;;    UpdtedRule: ((expr 0) (bop (expr 1) (expr 1)) 0)
(= (expandRule $depth ($lhs $rhs $i)) ((if (== $depth 0) $lhs ($lhs (- $depth 1))) (map ((curry expandMapHelper) ($depth $lhs)) $rhs) $i))

;; Helper function to be used in the map function of the expandRule function.
;; It takes a target and current non-terminal and replaces the non-terminal with a new value.
;;
;; The arguments are:
;;
;; $depth: The current depth of the expansion.
;; $targetNT: The target non-terminal to be replaced.
;; $currentNT: The current non-terminal being checked.
;;
;; Returns:
;; - The updated non-terminal.
(= (expandMapHelper ($depth $targetNT) $currentNT) (if (== $currentNT $targetNT) ($currentNT $depth) $currentNT))


;; Function to remove all recursive occurrences of a production rule by replacing the
;; recursive call of the non-terminal with the corresponding non-recursive rules of the lhs.
;;
;; The arguments are:
;;
;; $lhs: The left-hand side of the production rule.
;; $rhs: The right-hand side of the production rule.
;; $i: The index of the production rule.
;; $nrRules: The non-recursive rules of the non terminal.
;;
;; Returns:
;; - The updated right-hand side of the production rule.
;;
;; Example:
;;    $lhs: expr
;;    $rhs: (bop expr expr)
;;    $i: 1
;;    $nrRules: ((expr term 0))
;;    UpdateRule: ((bop term term) 0)
;; TODO: I think this and it's helper function could be written in more optimized way.
(= (removeRFromRule $lhs $rhs $i $nrRules)
   (if (any (collapse (isMember $lhs $rhs)))
       (let*
            (
              (($rule $index) (removeRFromRuleHelper $lhs $rhs $nrRules))
              ($newIndex (get-state &lastIndex))
              ($_ (change-state! &lastIndex (+ $newIndex 1)))
              ($result (removeRFromRule $lhs $rule $newIndex $nrRules))
              ;; (() (println! (Index: $newIndex NewRule: $result)))
            )
            $result)
       ($rhs $i)))

;; Helper function to search and remove the first recursive occurrence of a production rule by replacing the
;; non-terminal with the corresponding non-recursive rules of the lhs.
;;
;; The arguments are:
;;
;; $lhs: The left-hand side of the production rule.
;; $rhs: The right-hand side of the production rule.
;; $nrRules: The non-recursive rules.
;;
;; Returns:
;; - The updated right-hand side of the production rule and the index of the updated rule.
;;
;; Example:
;;    $lhs: expr
;;    $rhs: (bop expr expr)
;;    $nrRules: ((expr term 0))
;;    Updated Rule: ((bop term expr) 0)
(= (removeRFromRuleHelper $lhs $rhs $nrRules)
   (if (~= $rhs ())
       (let*
         (
            ($h (car-atom $rhs))
            ($t (cdr-atom $rhs)))
         (if (== $h $lhs)
           (let*
             (
                (($lhss $rules $index) (superpose $nrRules))
                ($restRhs (cdr-atom $rhs)))
             ((cons-atom $rules $restRhs) $index))
           (let ($fR $fI) (removeRFromRuleHelper $lhs (cdr-atom $rhs) $nrRules) ((cons-atom $h $fR) $fI))))
       ()))

;; Function to update the index of non-recursive production rules using the global state.
;;
;; The arguments are:
;;
;; $lhs: The left-hand side of the production rule.
;; $rhs: The right-hand side of the production rule.
;; $i: The index of the production rule.
;; $maxDepth: The maximum depth allowed for expansion.
;;
;; Returns:
;; - The updated non-recursive production rule.
(= (getUpdatedNRRule ($lhs $rhs $i) $maxDepth)
    (let*
        (
          ($newIndex (get-state &lastIndex))
          ($_ (change-state! &lastIndex (+ $newIndex 1)))
          ($newLhs ($lhs (- $maxDepth 1)))
          ;; (() (println! (Index: $newIndex NewRule: (cons-atom $newLhs ($rhs $newIndex)))))
        )
        (cons-atom $newLhs ($rhs $newIndex))))

;; Function to filter out recursive production rules from the grammar space.
;;
;; The arguments are:
;;
;; $nt: The non-terminal to be checked.
;; $grammarSpace: The grammar space containing production rules.
;;
;; Returns:
;; - The recursive production rules for the given non-terminal.
(= (getRecursiveRules $nt $grammarSpace)
    (let*
      (
        ($rhss (collapse (match $grammarSpace ($nt $rhs $i) $rhs)))
        ($rrhss (collapse (filter ((curry isMember) $nt) $rhss)))
        ;; ($rrhss (collapse (filterB isMember $nt $rhss))) ;; INFO: Use this line instead of the above on MeTTaLog
        ($ndRrhs (if (~= $rrhss ()) (superpose $rrhss) ())))
      (if (~= $rrhss ())
          (match $grammarSpace ($nt $ndRrhs $i) ($nt $ndRrhs $i))
          ())))

;; Function to filter out non-recursive production rules from the grammar space.
;;
;; The arguments are:
;;
;; $nt: The non-terminal to be checked.
;; $grammarSpace: The grammar space containing production rules.
;;
;; Returns:
;; - The non-recursive production rules for the given non-terminal.
(= (getNonRecursiveRules $nt $grammarSpace)
   (subtraction
          (match $grammarSpace ($nt $rhs $i) ($nt $rhs $i))
          (getRecursiveRules $nt $grammarSpace)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                                                                                                                  ;;;;
;;;;                                       Calculate upperbounds for each non terminal                               ;;;;
;;;;                                                                                                                  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Function to apply state to calcMaxNtReference to be compatible for until function.
;;
;; The arguments are:
;;
;; $grammarSpace: The grammar space containing production rules.
;; $referenceSpace: The space to store non-terminal references.
;; $countSpace: The space to store the count of non-terminal references.
;; $refCountSpace: The space to store the maximum count of non-terminal references.
;; $ntSet: The set of all non-terminals in the grammar space.
;;
;; Returns:
;; - No usefull data except unit/().
(= (applyCalcMaxNtReference ($grammarSpace $referenceSpace $countSpace $refCountSpace) $ntSet)
   (let $_ (calcMaxNtReference $grammarSpace $referenceSpace $countSpace $refCountSpace (car-atom $ntSet))
           (cdr-atom $ntSet)
   )
)

;; Calculate the maximum number of non-terminal references of all
;;    non-terminals in the grammar space.
;; The function keeps a unique reference and referer pair between non terminals along the way.
;;
;; The arguments are:
;;
;; $grammarSpace: The grammar space containing production rules.
;; $referenceSpace: The space to store non-terminal references.
;; $countSpace: The space to store the count of non-terminal references.
;; $refCountSpace: The space to store the maximum count of non-terminal references.
;; $nt: The non-terminal to be processed.
;;
;; Returns:
;; - No usefull data except unit/().
;;
;; Example:
;;    Grammar:
;;        S      -> Expr
;;        Expr   -> Bop Expr_0 Expr_0 |
;;                  Uop Expr_0 |
;;                  Term
;;        Expr_0 -> Term
;;        Bop    -> AND | OR
;;        Uop    -> NOT
;;        Term   -> X | Y
;;
;;    $nt: Expr   => Maximum Reference Count: 1. This is because Expr is referenced only once and that is by S.
;;    $nt: Expr_0 => Maximum Reference Count: 2. Expr_0 is referenced only by Expr.
;;
;; If a given non terminal is referenced with more than one non terminal,
;;  then the maximum reference by each non terminal will be stored.
(= (calcMaxNtReference $grammarSpace $referenceSpace $countSpace $refCountSpace $nt)
   (let*
     (
       ($ntSet (collapse (unique (match $grammarSpace ($lhs $rhs $i) $lhs))))

       ($_ (calcTotalNtReference $grammarSpace $referenceSpace $countSpace $nt $ntSet))

       ;; Update the count reference to the new maximum count if possible.
       ($_' (collapse
                 (let*
                     (
                       ($keys (collapse (unique (match $countSpace ($key $count) $key))))
                       ($_ (until isUnit ((curry applyCountMaxReference) ($countSpace $refCountSpace $nt)) $keys))
                     )
                     ()))
       )

       ;; Clearing the count for next state
       ($_'' (collapse (let $countPairs (get-atoms $countSpace) (remove-atom $countSpace $countPairs))))

       ;; Making the reference space unique by ensuring that each non-terminal reference is found only once.
       ($_''' (collapse (let*
                          (
                            ($uniqueRefs (unique (get-atoms $referenceSpace)))
                            (() (remove-atom $referenceSpace $uniqueRefs))
                          )
                          (add-atom $referenceSpace $uniqueRefs)))
       )
     )
     ()
   )
)


;; Calculate the total number of non-terminal references in the grammar space.
;;
;; The arguments are:
;;
;; $grammarSpace: The grammar space containing production rules.
;; $referenceSpace: The space to store non-terminal references.
;; $countSpace: The space to store the count of non-terminal references.
;; $nt: The non-terminal to be processed.
;; $ntSet: The set of all non-terminals in the grammar space.
;;
;; Returns:
;; - No useful result except for some unit / (). The update is done on the elements of the spaces.
;;
;; Example:
;;    Grammar:
;;        S      -> Expr
;;        Expr   -> Bop Expr_0 Expr_0 |
;;                  Uop Expr_0 |
;;                  Term
;;        Expr_0 -> Term
;;        Bop    -> AND | OR
;;        Uop    -> NOT
;;        Term   -> X | Y
;;
;;    $nt: Expr   => Reference Count: 1. This is because Expr is referenced only once and that is by S.
;;    $nt: Expr_0 => Reference Count: 2, 1. Expr_0 is referenced two times by Expr. Hence it will have two counts.
(= (calcTotalNtReference $grammarSpace $referenceSpace $countSpace $nt $ntSet)
   (let*
        (
         ;; Count the number of occurrences of references for each symbol in a given non-terminal's production rule.
         ($_ (collapse
                        (let*
                            (
                              (($nt $rules) ($nt (match $grammarSpace ($nt $rhs $i) $rhs)))
                              (($nt $options) (if (isSymbol $rules) ($nt $rules) ($nt (superpose $rules))))
                              ($_' (if (isMember $options $ntSet)
                                        (let*
                                            (
                                              (() (add-atom $referenceSpace ($options $nt)))
                                              (() (add-atom $countSpace ($rules $options 1)))
                                            )
                                            ())
                                        ()))
                            )
                            ())))
         
         ;; Sum up each individual count to get total count of each non terminal.
         ($_' (collapse
                        (let*
                            (
                              (($nt $rules) ($nt (match $grammarSpace ($nt $rhs $i) $rhs)))
                              (($rules $opts $counts) (match $countSpace ($rules $options $counts) ($rules $options $counts)))
                              (($opt $sum) ($opts (sum (collapse (match $countSpace ($rules $opts $counts) $counts)))))
                              (() (update-atom $countSpace ($rules $opt $counts) ($opt $sum))))
                            ())))) 
        ())
)


;; Function that applies the current state to the countMaxReference
;;    by calling it with the first element of the $rNts.
;; It is used to make the countMaxReference function compatible with until function.
;;
;; The arguments are:
;;
;; $nt: The non-terminal referring the $rNts.
;; $rNts: The referenced non-terminals to be compared.
;; $countSpace: The space to store the count of non-terminal references.
;; $refCountSpace: The space to store the maximum count of non-terminal references.
;;
;; Returns:
;; - The remaining $rNts to be processed.
(= (applyCountMaxReference ($countSpace $refCountSpace $nt) $rNts) (let $_ (countMaxReference $countSpace $refCountSpace (car-atom $rNts) $nt) (cdr-atom $rNts)))


;; Count the maximum reference of a given non terminal.
;;
;; The arguments are:
;;
;; $rNt: The non terminal whose maximum reference is to be counted.
;; $nt: The non-terminal refering $rNt.
;;
;; Returns:
;; - No usefull result other than unit/().
(= (countMaxReference $countSpace $refCountSpace $rNt $nt)
   (let*
      (
        ($count (foldr max 0 (collapse (match $countSpace ($rNt $count) $count))))
        ($oldCount (unify $refCountSpace ($rNt $nt $count) $count 0))
        ($newCount (max $oldCount $count))
      )
      (update-atom $refCountSpace ($rNt $nt $oldCount) ($rNt $nt $newCount)))
)



;; Compute the maximum reference of a given non-terminal by keeping track of the maximum number of references of its referer non-terminal.
;;
;; The arguments are:
;;
;; $referenceSpace: The space to store non-terminal references.
;; $refCountSpace: The space to store the count of non-terminal references.
;; $nt: The non-terminal for which the maximum reference is to be computed.
;;
;; Returns:
;; - The maximum reference count of the given non-terminal. 
;;
;; Example:
;;    Grammar:
;;        S      -> Expr Op Expr | Expr
;;        Expr   -> Term Op Term |
;;                  (Term Op Term)
;;        Op     -> + | - | * | /
;;        Term   -> X | 0.5
;;    $nt: Expr => Max Reference for each production: 2. Since Expr is referenced only in S we have only one result.
;;    $nt: Term => Max Reference for each production: 4. Since Term is referenced only a maximum of two times in Expr.
;;                 Since Expr itself has a Max Reference of 2, the Max Reference becomes 4.
(= (maxRefPerProd $referenceSpace $refCountSpace $nt)
   (if (== $nt start)
      1
      (let*
          (
            ($referer (unify $referenceSpace ($nt $referer) $referer ()))
            ($refUpperBound (if (~= referer ()) (maxRefPerProd $referenceSpace $refCountSpace $referer) 1))
            ($ntMaxExpansion (match $refCountSpace ($nt $referer $count) $count))
          )
          (* $refUpperBound $ntMaxExpansion))
   )
)



;; Sums up all the maximum references of a non-terminal from each production rule.
;; The function maxRefPerProd can return more than one value corresponding to each
;;    production rule's maximum reference. There for this functions sums them up.
;; An upperbound is the maximum length of a codon that is needed to express all possible derivations leading to the non terminal.
;;
;; The arguments are:
;;
;; $referenceSpace: The space to store non-terminal references.
;;    This corresponds to which nonterminal is referenced by which.
;; $refCountSpace: The space to store the cound of how many times 
;;    agiven non terminal is referenced by another.
;; $nt: The non-terminal for which the upper bounds are to be calculated.
;;
;; Returns:
;; - The non-terminal and it's upperBound in a tuple.
(= (upperBounds $referenceSpace $refCountSpace $nt) ($nt (sum (collapse (maxRefPerProd $referenceSpace $refCountSpace $nt)))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                                                                                                                          ;;;;
;;;;                                                      Generation                                                          ;;;;
;;;;                                                                                                                          ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;; Return count of possible derivation options for a given non terminal.
;;
;; The arguments are:
;;
;; $nt: The non-terminal whose possible derivations will be counted
;; $grammarSpace: The space containing the grammar rules.
;;
;; Returns:
;; - The number of possible derivations.
(= (calculateCN $nt $grammarSpace)
   (sum (collapse (match $grammarSpace ($nt $rhs $i) 1))))

;; Index production rules of a non terminal properly.
;; The production rules should have a certain kind of ordering which will be inforced by this function.
;;
;;The argumetns are:
;;
;; $nt: The non-terminal whose production rules will be indexed,
;; $grammarSpace: The space containing the grammar rules.
;;
;; Returns:
;; - No usefull result except unit / ().
(= (indexRules $nt $grammarSpace)
   (let*
      (
        ($cN (calculateCN $nt $grammarSpace))
        ($oldRules (collapse (match $grammarSpace ($nt $rhs $i) ($nt $rhs $i))))
        ($rhss (collapse (match $grammarSpace ($nt $rhs $i) $rhs)))
        ($indices (gen (- $cN 1) (0)))
        ($indexedRules (zip $rhss $indices))
        ($_ (collapse
                (let $ndOldRules (superpose $oldRules)
                     (remove-atom $grammarSpace $ndOldRules))))
        ($_ (collapse
                (let*
                    (
                      ($ndRhs (superpose $indexedRules))
                      ($ndNewRules (cons-atom $nt $ndRhs))
                    )
                    (add-atom $grammarSpace $ndNewRules))))
      )
      ()))

;; Generate a random codon given the required informtion.
;; A codon is a sequence of genes that represent a single non terminal.
;;
;; The arguments are:
;; $n: The length of the codon.
;; $ub: The maximum possible value of a gene.
;;
;; Result:
;; - The function returns a list of numbers
(= (genCodon $n $ub)
   (if (== $n 1)
       (((py-atom random.randint) 0 $ub)) ;; TODO: Change with random-int
       (let*
            (
               ($firstRandom ((py-atom random.randint) 0 $ub))
               ($nextRandoms (genCodon (- $n 1) $ub)))
            (cons-atom $firstRandom $nextRandoms))))

;; Generate a random mask given its target length.
;; A mask is a list of 1s and 0s.
;; The mask will be used in recombination of two parents.
;; Bit 0 means the offspring will take genotype material from first parent
;; Bit 1 means the offspring will take genotype material from the other parent
;;
;; The arguements are:
;; $n: The length of the mask.
;;
;; Result:
;; - A list of 1s and 0s
;;
;; Example:
;;    (genMask 2) => (1 0)
;;    (genMask 3) => (0 1 0)
(= (genMask $n) (genCodon $n 1))


;; Recombine creates crossbreeds by taking genetic material from two parents based on binary mask values
;;
;; The arguments are:
;; $parent1, $parent2 genotype of two parents given as two separate tuples of tuples
;;                          E.g. ((0) (1 0)) ((1) (1 1))
;;                               ((0) (1 0) (1 2 0)) ((1) (1 1) (1 1 2)) -- 3 gene sequences for each parent
;; $mask, binary mask of same length as the genotype list, e.g. for the above genotypes possible masks are
;;                          (0 1) and (0 1 1) repectively.
;;                          - Bit 0 means the offspring will take genotype material from first parent.
;;                          - Bit 1 means the offspring will take genotype material from the other parent.
;;
;; Returns:
;; - Returns two childs from the recombination of the two parents in a tuple.
;; Examples:
;;    (recombine ((0) (1 0)) ((1) (1 1)) (0 1)) => (((0) (1 1)) ((1) (1 0))) -- genes have been swapped at index where the binary mask is 1
;;    (recombine ((0) (1 0)) ((1) (1 1)) (1 0)) => (((1) (1 0)) ((0) (1 1)))
(= (recombine $parent1 $parent2 $mask)
    (if (== $mask ())
        ($parent1 $parent2)
        (let*
            (
               (() (println! (Recombining $parent1 And $parent2 with Mask: $mask)))
               (($gene1 $restOfP1) (decons $parent1))
               (($gene2 $restOfP2) (decons $parent2))
               (($bit $maskTail) (decons $mask))
               (($c $d) (recombine $restOfP1 $restOfP2 $maskTail))
            )
            (if (== $bit 0)
                ((cons-atom $gene1 $c) (cons-atom $gene2 $d))
                ((cons-atom $gene2 $c) (cons-atom $gene1 $d))
                ))))

;; A function to randomly mutate a single gene given a genotype.
;; A non-terminal and it's correspnding codon is randomly picked
;;    from ntSet and genotype respectively.
;; A gene is randomly chosen from the selected codon for mutation,
;;    and its value is replaced by a new gene from the range [0, cN)
;;    where cN is the number of expansion options.
;; Mutation may not generate new genotype material and could result
;;    in the same genotype if the non-terminal has only one expansion option (cN=1) with a gene value of 0.
;;
;; The arguments:
;; $genotype: tuple of tuples each nested tuple(codon) containing gene information of each non-terminal
;; $grammarSpace: space where grammar production information has been added.
;;
;; Returns:
;; - A genotype of same length and order like the first one except for a possibly changed single gene.
;;
;; Examples:
;;    (mutate ((0) (1 0 2) (1 1) (0) (0 1)) &grammar) => ((0) (2 0 2) (1 1) (0) (0 1))
;;    (mutate ((0) (1 0 2) (1 1) (0) (0 1)) &grammar) => ((0) (1 0 2) (1 1) (0) (0 1))
(= (mutate $genotype $nts $grammarSpace $ubSpace)
    (let* (
            (() (println! (Calling mutate with: $genotype)))
            ($len (len $nts))
            ($index ((py-dot rnd randint) $len))

            ($nt (selectByIndex $nts $index))
            (($ub $cN) (match $ubSpace ($nt $ub $cN) ($ub $cN)))

            ($geneList (selectByIndex $genotype $index))
            ($geneIndex ((py-dot rnd randint) $ub))

            ($prevGeneValue (selectByIndex $geneList $geneIndex))
            (() (println! (CN: $cN UB: $ub)))

            (($cN $prevGeneValue $newGeneValue $_) (until applyNotEqual applyRandom ($cN $prevGeneValue $prevGeneValue ((py-atom random.random)))))
            (() (println! (PrevGeneValue: $prevGeneValue NewGeneValue: $newGeneValue)))

            ($mutatedGeneList (replaceByIndex $geneList $geneIndex $newGeneValue))
            (() (println! (GeneList: $geneList NewGeneList: $mutatedGeneList)))
        )
        (replaceByIndex $genotype $index $mutatedGeneList)))

;; A helper function that is used to make the input parameters of
;;    mutate function and the expected input of the until function compatible.
;; WARN: This function gets cached it the generated result is the same as previous and will get stuck in infinte loop. To prevent this, we will just pass a random float everytime to prevent this from happening.
(= (applyRandom ($cN $prevValue $value $rnd)) (let $newValue ((py-dot rnd randint) $cN) (trace! (PrevValue: $prevValue Generated: $newValue) ($cN $prevValue $newValue ((py-atom random.random))))))


;; A helper function used as a predicate in the until function.
(= (applyNotEqual ($cN $prevValue $value $rnd)) (or (~= $prevValue $value) (<= $cN 1)))

;; Generate random genotype given the required spaces and unique key of the individual.
;; A unique key is just the generation number the index of the individual.
;; A genotype is just a collection of codons correpsonding to each of the non terminals.
;;
;; The arguments are:
;; $grammarSpace: The space where all the production rules of the grammar is stored.
;; $referenceSpace: The space to store non-terminal references.
;;    This corresponds to which nonterminal is referenced by which.
;; $refCountSpace: The space to store the cound of how many times
;;    agiven non terminal is referenced by another.
;; $ubSpace: The space where the upperbounds of each non terminal is stored.
;; $resultMap: The space where individual elements of the populations are stored.
;; $g: The current generation number.
;; $p: A unique index to be assigned to the individual.
(= (genGenotype $grammarSpace $referenceSpace $refCountSpace $ubSpace $resultMap ($g $p))
   (let*
        (
          ($_
              (collapse
                  (let*
                      (
                        (($nt $ub $n) (match $ubSpace ($nt $ub $n) ($nt $ub $n)))
                        ($cN (if (== $n 0) (calculateCN $nt $grammarSpace) $n))

                        (() (update-atom $ubSpace ($nt $ub $n) ($nt $ub $cN))) ;; Caching the cN which will be needed later.
                        (($nt $codon) ($nt (genCodon $ub (- $cN 1))))
                      )
                      (add-atom $resultMap (($nt $g $p) $codon))
                  )))
        )
        ()))

;; A function that returns the production rules of a given non terminal in the order of their index.
;; This will be used when crossover and mutation of an individual is needed.
;;
;; The arguments are:
;; $gramarSpace: The space containing the production rules of the grammar.
;; $nt: The non terminal whose production rules are to be ordered.
;; $len: The total number of production rules of the non terminal.
;;
;; Result:
;; - The result will be a tuple of ordered left hand sides (Lhs) of the non terminal.
(= (getOrderedLhs $grammarSpace $nt $len)
   (if (== $len 0)
       ()
       (let*
          (
            ($nextLen (- $len 1))
            ($h (match $grammarSpace ($nt $rhs $nextLen) $rhs))
            ($t (getOrderedLhs $grammarSpace $nt $nextLen))
          )
          (appendAtom $h $t))))

;; A function to retrieve the gentotype of an individual in a predifined order.
;; The individual is represented in the $resultSpace with in a key value
;;    manner without any order. However, this order will be essential when
;;    crossover and mutations are needed.
;; This function will traverse the grammar space starting from the start symbol
;;    until it finishes visiting all the non terminals of the grammarspace while
;;    at the same time retrieving the corresponding codons from the $resultSpace.
;;
;; The arguments are:
;; $grammarSpace: The space containing the production rules of the grammar.
;; $resultSpace: The space containing all the population key value pairs.
;; $nt: The starting non terminal
;; $visited: A list containing the visited non terminals.
;; $lhss: A list containing ordered non terminals from which the next non
;;    terminal will be selected.
;; $acc: A list containing the ordered codons of the individual.
;; $g: The current generation number.
;; $p: The unique index of the individual in the population.
;;
;; Result:
;; - The function returns a tuple of the codon and it's corresponding 
;;     non terminal order respectively in a tuple.
;; TODO: Try optimizing using reference space instead.
(= (getOrderedGenoType $grammarSpace $resultSpace $nt $visited $lhss $acc ($g $p))
   (case ((isMember $nt $visited) (isUnit $lhss) (isMember $nt (collapse (getNts $grammarSpace))))
      (
        ((True True $_) $acc)
        ((True False $_) (getOrderedGenoType $grammarSpace $resultSpace (car-atom $lhss) $visited (cdr-atom $lhss) $acc ($g $p)))
        (($_ $__ False) (getOrderedGenoType $grammarSpace $resultSpace (car-atom $lhss) $visited (cdr-atom $lhss) $acc ($g $p)))
        (($_ $__ True)
            (let*
              (
                ;; (() (println! (Inside get ordered genotype)))
                ;; (() (println! (Value for key: ($nt $g $p) (match $resultSpace (($nt $g $p) $codon) $codon))))
                ($codon (unify $resultSpace (($nt $g $p) ($codon $ph $s)) $codon (match $resultSpace (($nt $g $p) $codon) $codon)))
                ($visited' (cons-atom $nt $visited))
                ($acc' (cons-atom $codon $acc))

                ($len (sum (collapse (match $grammarSpace ($nt $rhs $i) 1))))
                ($oLhs (getOrderedLhs $grammarSpace $nt $len))
                ($flatLhs (foldr ++ () $oLhs))
                ($lhss' (++ $lhss $flatLhs))

                (($h $t) (decons $lhss'))
              )
              (if (=== $visited' (collapse (getNts $grammarSpace)))
                  ($acc' $visited')
                  (getOrderedGenoType $grammarSpace $resultSpace $h $visited' $t $acc' ($g $p)))))
      ))
)

;; A function to check if a given expression is a production rule or not.
;;
;; The arguments are:
;; $expr: The expression to be checked.
;;
;; Result:
;; - Returns boolean.
;;
;; Example:
;;     Grammar: S    -> Expr
;;              (start expr)
;;              (expr ((expr 0) Op (expr 0)))
;;              (expr term)
;;              ((expr 0) term)
;;              (Op +)
;;              (Op *)
;;     For the grammar representation above:
;;             - The expression (expr 0) is a non terminal
;;             - The expression ((expr 0) Op (expr 0)) is a sub rule.
(= (isSubRule $expr)
    (case $expr
        (
          (($nt $d) (~= (get-type $d) Number))
          ($else (not (isSymbol $expr))))))

;; A function that takes the resultMap space where genotypes are
;;    stored and generate a phenotype.
;; A phenotype is a boolean expression represented by a given genotype.
;;
;; The arguments are:
;; $resultMap: The space where individual elements of the populations are stored.
;; $grammarSpace: The space containing the production rules of the grammar.
;; $acc: An accumulator to store the boolean expressions generted so far.
;; $expr: The list of production rules to visit in order from left to right. 
;;    For the first call, it should be the start symbol.
;; $g: The generation number of the individual.
;; $p: The unique index of the individual in the population.
;;
;; Result:
;; - A boolean expression.
(= (genPhenotype $resultMap $grammarSpace $acc $expr ($g $p))
   (if (isUnit $expr)
       $acc
       (let ($currentNt $nextExpr) (decons $expr)
            (if (not (isSubRule $currentNt))
                (let*
                    (
                      ($is (match $resultMap (($currentNt $g $p) $i)
                                  (unify $i ($i' $phenotype $score)
                                          (if (isExpression $i') $i' $i) ;; If $i' isn't an expression, then the unify is just matching over numbers of the codon.
                                          $i
                                  )))
                      (($x $xs) (decons $is))

                      ($nextProd (match $grammarSpace ($currentNt $rhs $x) $rhs))
                      ($nextNt (if (isSymbol $nextProd) $nextProd (car-atom $nextProd)))
                      (() (update-atom $resultMap (($currentNt $g $p) $is) (($currentNt $g $p) $xs)))
                    )
                    (if (isMember $nextNt (collapse (getNts $grammarSpace)))
                        (genPhenotype $resultMap $grammarSpace $acc (cons-atom $nextProd $nextExpr) ($g $p))
                        (genPhenotype $resultMap $grammarSpace (appendAtom $nextProd $acc) $nextExpr ($g $p))
                    )
                )
                (let*
                    (
                      ($t (genPhenotype $resultMap $grammarSpace () $currentNt ($g $p)))
                      ($acc' (appendAtom $t $acc))
                    )
                    (genPhenotype $resultMap $grammarSpace $acc' $nextExpr ($g $p)))
            )
       )
   )
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                                                                                                                          ;;;;
;;;;                                                      Main loop                                                           ;;;;
;;;;                                                                                                                          ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; A function to generate the initial population for the algorithm.
;; The elements are going to be stored in a space as key and value pairs.
;; Key is going to be a tuple of non terminal, generation number and index.
;; Value is going to be the genotype only but could contain the phoentype 
;;    and score as the individual is evaluated.
;;
;; The arguments are:
;; $grammarSpace: The space containing the production rules of the grammar.
;; $refSpace: The space to store non-terminal references.
;;    This corresponds to which nonterminal is referenced by which.
;; $refCountSpace: The space to store the cound of how many times 
;;    agiven non terminal is referenced by another.
;; $resultMap: The space where individual elements of the populations are stored.
;; $ubSpace: The space where the upperbounds of each non terminal is stored.
;; $g: The initial generation number
;; $p: The size the population.
;;
;; Result:
;; - Returns no usefull result. But the result of the function is stored in the $resultMap space.
(= (initPopulation $grammarSpace $refSpace $refCountSpace $ubSpace $resultMap ($g $p))
    (collapse
      (let*
        (
          ($indexes (gen (- $p 1) (0)))
          ($i (superpose $indexes))
          ($_ (genGenotype $grammarSpace $refSpace $refCountSpace $ubSpace $resultMap ($g $i)))
        )
        ())))

;; A function that gives score to all the unscored individuals in the given populations.
;; The function does so by using non deterministic evaluation of the individuals.
;;
;; The arguments are:
;; $population: List of individuals to be scored.
;; $fitnessFunction: Scoring function to be used.
;; $data: Input data to be used in the scoring function.
;; $lr: Learning rate for the scoring function.
;; $resultMap: The space where the population is stored.
;;    Needed by other functions called by it.
;; $grammarSpace: The space containing the production rules of the grammar.
;; $startNt: The start symbol, or non terminal.
;;
;; Result:
;; - Returns the updated value of populations with their corresponding phenotype and score.
;;
;; The returned elements of the population are corresponding only to the entry of the start non terminal.
;;    This is because the other non terminals of a given individual from the population will have the same
;;    phenotype and score. This is true because a single individual represents a single boolean expression.
;;    By limiting the evaluation to the start non terminal symbol, we can avoid unnecessary computation.
(= (evaluate $population $fitnessFunction $data $lr $resultMap $grammarSpace $startNt)
   (collapse
     (let*
        (
          (() (println! ""))
          ((($startNt $g $p) $genotype) (superpose $population))
          ($isScored (unify $genotype ($genotype' $phenotype $score) (isExpression $genotype') False)) ;; If is not expression, it is just unifying on the number of the codon.
        )
        (if $isScored
            (($startNt $g $p) $genotype)
            (let*
                (
                  ($result (genPhenotype $resultMap $grammarSpace () ($startNt) ($g $p)))
                  ;; (() (println! (Result: $result)))
                  ($phenotype (car-atom $result))
                  ($score ($fitnessFunction $phenotype $data $lr))
                  ;; (() (println! (Phenotype: $phenotype Data: $data LR: $lr Score: $score)))
                )
                (($startNt $g $p) ($genotype $phenotype $score)))))))

;; Function to compare population based on fitness.
;; It will be used as a key while sorting a population.
(= (comparePop
      ($key1 ($genotype1 $phenotype1 $score1))
      ($key2 ($genotype2 $phenotype2 $score2))) 
    (>= $score1 $score2))

;; Tournament selection of an element from population.
;;
;; The arguments are:
;; $population: The population to select from.
;; $startNt: The start symbol of the grammar.
;; $g: The generation number.
;; $len: The size of the population.
;; $size: The number of elements to be selected.
;;
;;Returns:
;;  - A single individual from the population.
;;
;; The returned individual of the population is only the entry of the start non terminal.
;;    This is because the other non terminals of a given individual from the population will have the same
;;    phenotype and score so selecting this entry will correspond to selecting the whole entry.
(= (tournament $population $startNt $g $len $size)
   (let*
      (
        ($indexes (repeat ((py-atom random.randint) 0 (- $len 1)) $size))
        ($selected (collapse (let ($i (($startNt $g $i) $pop)) ((superpose $indexes) (superpose $population)) (($startNt $g $i) $pop))))
        ($sorted (sort $selected $size comparePop))
      )
      (car-atom $sorted)
    ))

;; A function to integrate the whole SGE algorithm.
;; This function:
;;    - Expands the grammar based on given depth to remove recursive production rules.
;;    - Properly indexes of the production rules of each non terminals.
;;    - Computes the upperBounds of each non terminals and store them in a space.
;;    - Initializes the first generation of the population.
;;    - Call the main loop of the evolution algorithm.
;;
;; The arguments are:
;; $grammarSpace: The space containing the production rules of the grammar.
;; $dataSpace: The space that contains the dataset used for the scoring.
;; $refSpace: The space used to store the non terminal references.
;; $countSpace: The space to be used to store the number of times a
;;    given non terminal is referenced.
;; $refCountSpace: The space to be used to store the number of times
;;    a given non terminal is referenced by another non terminal.
;; $ubSpace: The space to be used to store the upperBounds of each non terminal.
;; $resultMap: The space to be used to store the population.
;; $elitism: The number of elite individuals to be kept in each generation.
;; $popSize: The size of the population.
;; $tSize: The number of individuals to be considered in the tournament selection.
;; $probCrossOver: Crossover probability.
;; $probMutate: Mutation probability.
;; $maxGen: Maximum number of generations to evolve to.
;; $maxDepth: Maximum depth to expand the grammar to.
;;
;; Returns:
;; - No usefull result except the update done in the spaces.
(= (evolve $grammarSpace $dataSpace $refSpace $countSpace $refCountSpace $ubSpace $resultMap $elitism $popSize $tSize $probCrossOver $probMutate $maxGen $maxDepth)
   (let*
      (
        ;; Representation Building: Expanding recursive rules
        ($_ (collapse (expandGrammar $maxDepth $grammarSpace)))
        (() (println! (Expanded Grammar (collapse (getNts $grammarSpace)))))

        ;; Index Production rules
        ($_' (collapse (indexRules (getNts $grammarSpace) $grammarSpace)))
        (() (println! (Finished Indexing production rules)))

        ;; Representation Building: Counting Max Reference
        ($_''' (until isUnit ((curry applyCalcMaxNtReference) ($grammarSpace $refSpace $countSpace $refCountSpace)) (collapse (unique (match $grammarSpace ($nt $rhs $i) $nt)))))
        (() (println! (Finished counting Max Reference: (collapse (get-atoms &refCountSpace)))))

        ;; Calculating upperbounds.
        ($_''  (collapse (let ($nt $ub) (upperBounds $refSpace $refCountSpace (getNts $grammarSpace)) (add-atom $ubSpace ($nt $ub 0))))) ;; 0 corresponds to the cN which will be filled later.
        (() (println! (All UpperBounds Added: (=== (collapse (getNts $grammarSpace)) (collapse (match $ubSpace ($nt $u $cn) $nt))) Added For: (collapse (match $ubSpace ($nt $u $cn) $nt)))))

        ;; Initializing first generation of populations
        ($__ (initPopulation $grammarSpace $refSpace $refCountSpace $ubSpace $resultMap (0 $popSize)))

        ;; (() (println! (Generated population: (collapse (get-atoms $resultMap)))))

        ;; Main Loop
        ($__' (until maxGenReached applyRunGeneration (($grammarSpace $ubSpace $dataSpace $resultMap $elitism $popSize $tSize $probCrossOver $probMutate) 0 $maxGen)))

        (() (println! (Finished Running Generations)))
       )
      ()
   )
)

;; Predicate function to be used in the until function of the evolve function.
(= (maxGenReached ($constants $nextGen $maxGen)) (>= $nextGen $maxGen))

;; Apply the runGeneration function. 
;; Used to make the function compatible with until function.
(= (applyRunGeneration (($grammarSpace $ubSpace $dataSpace $resultMap $elitism $popSize $tSize $probCrossOver $probMutate) $g $maxGen))
      (let $_ (runGeneration $grammarSpace $ubSpace $dataSpace $resultMap $g $elitism $popSize $tSize $probCrossOver $probMutate)
              (($grammarSpace $ubSpace $dataSpace $resultMap $elitism $popSize $tSize $probCrossOver $probMutate) (+ $g 1) $maxGen)))

;; Function to update the index of a single population element.
(= (updatePopIndex (($nt $g $i) $popValue) $newI) (($nt $g $newI) $popValue))

;; Function to run the evolution for a single generation.
;; It performs all the necessary steps for a single evolution:
;;      - Scores the given populations.
;;      - Pick the elits from the scored population.
;;      - Generates new population by crossover and mutation.
;;      - Indexes the individuals properly.
;;      - Also make necessary updates.
;;
;;The arguments are:
;;$grammarSpace: The space containing the production rules of the grammar.
;;$ubSpace: The space where the upperbounds of each non terminal is stored.
;;$dataSpace: The space that contains the dataset used for the scoring.
;;$resultMap: The space where individual elements of the populations are stored.
;;$g: The generation number running.
;;$elitism: The number of elite individuals to be kept in each generation.
;;$popSize: The size of the population.
;;$tSize: The number of individuals to be considered in the tournament selection.
;;$probCrossOver: Crossover probability.
;;$probMutate: Mutation probability.
;;
;;Returns:
;;- The new populations generated in a tuple.
;;
;;Since most of the functions used here don't perform the necessary updates on their own,
;;   and some even return parital entries of a given individual, this function performs 
;;   the necessary updates correctly.
(= (runGeneration $grammarSpace $ubSpace $dataSpace $resultMap $g $elitism $popSize $tSize $probCrossOver $probMutate)
    (let*
        (
          ($startNt start)
          (() (println! (Running Generation: $g)))
          ($population (collapse (get-atoms $resultMap)))

          (() (println! (Initial Population: $population)))
          ($data (collapse (get-atoms $dataSpace)))

          ($scoredPop (evaluate $population penalizedFitness $data 0.1 $resultMap $grammarSpace $startNt))
          (() (println! (ScoredPop: $scoredPop)))

          ($sortedPop (sort $scoredPop $popSize comparePop))
          (($elite $indexes $eIndex) (collapse (superpose (
                                                    (take $elitism $sortedPop)
                                                    (gen (- $popSize 1) ($elitism))
                                                    (gen (- $elitism 1) (0))
                                                  ))))

          (() (println! ""))
          (() (println! (SortedPop: $sortedPop)))
          (() (println! (Elits: $elite)))
          (() (println! (Indexes: $indexes ElitIndex: $eIndex)))
          (() (println! ""))

          ;; Updating the individuals with their corresponding phenotype and score of it's individuals.
          ($__' (collapse
                    (let*
                        (
                          ((($startNt $g $p) ($codon $phenotype $score)) (superpose $scoredPop))
                          ((($nt $g $p) $oldValue) (superpose $population))
                          ((($nt $g $p) $iValue) (get-atoms $resultMap))

                          (() (println! (Updating Atom: (($nt $g $p) $oldValue) With (($nt $g $p) ($oldValue $phenotype $score)))))
                        )
                        (unify $oldValue ($oldCodon $oldPheno $oldScore)
                                (if (isExpression $oldCodon)
                                    (update-atom $resultMap (($nt $g $p) $iValue) (($nt $g $p) ($oldCodon $oldPheno $score)))
                                    (update-atom $resultMap (($nt $g $p) $iValue) (($nt $g $p) ($oldValue $phenotype $score))))
                                (update-atom $resultMap (($nt $g $p) $iValue) (($nt $g $p) ($oldValue $phenotype $score))))
                    )))

          ;; For debugging only.
          ($updatedScore (collapse (let $score (subtraction (match $resultMap (($nt $g $p) ($geno $pheno $score)) (($nt $g $p) ($geno $pheno $score))) (superpose $scoredPop)))))
          (() (println! (Space updated for Score: (~= $updatedScore ()))))

          ;; Getting the total entries of individuals.
          ($totalScoredPop (collapse (get-atoms $resultMap)))
          ($elitIndices (collapse (let (($nt $generation $i) $value) (superpose $elite) $i)))
          ($totalElits (collapse (let $i (superpose $elitIndices) (match $resultMap (($nt $generation $i) $value) (($nt $generation $i) $value)))))

          ;; Recalculating indexes of the paritala entries elite population.
          ($elitPop (zipWith updatePopIndex $elite $eIndex))

          ;; Retrieving the rest of the entries corresponding to the indexed elite population.
          ($totalUpdatedElits (collapse (let*
                                            (
                                              ((($startNt $g $p) ($c $ph $sc)) (superpose $elitPop))
                                              ((($nt $g $p') ($c' $ph $sc)) (superpose $totalElits))
                                              (() (println! (Updating ($nt $g $p')'s index with $p)))
                                            )
                                            (($nt $g $p) ($c' $ph $sc)))))
          (() (println! (ElitPop: $elitPop)))

          (() (println! (TotalElits: $totalElits with Indexes: $elitIndices)))
          (() (println! (TotalUpdatedElits: $totalUpdatedElits)))
          (() (println! (TotalScoredPop: $totalScoredPop)))
          (() (println! ""))

          ;; Generating new elements of the population non deterministically for next generation.
          ($newPop (collapse (let*
                                (
                                  ($i (superpose $indexes))
                                  ($newP (getNewPop $totalScoredPop $startNt $g $popSize $tSize $probCrossOver $probMutate $grammarSpace $ubSpace $resultMap $i))
                                  (() (println! (NewP After GetNewPop: $newP)))
                                  ($flatP (superpose $newP))
                                )
                                $flatP)))


          (() (println! ""))
          (() (println! (NewPop: $newPop)))

          ($totalPop (collapse (union (superpose $totalUpdatedElits) (superpose $newPop))))
          (() (println! (TotalPop: $totalPop)))


          (() (println! ""))
          ($nextG (+ $g 1))

          ;; Updating the population space with the next set of individuals to consider.
          (() (println! ""))
          ($__'' (collapse
                    (let $spaceContent (get-atoms $resultMap)
                         (remove-atom $resultMap $spaceContent))))
          ($__''' (collapse
                    (let (($nt $gen $p) $newValue) (superpose $totalPop)
                         (add-atom $resultMap (($nt $nextG $p) $newValue)))))

          ;; For debugging only.
          ($updated (~= () (collapse (match $resultMap (($nt ($nextG $p) $value) (($nt $g $p) ($geno $pheno $score))) (superpose $scoredPop)))))
          (() (println! (Space updated: (~= $updated ()))))
        )
        $totalPop))


;; Generate a single element of the new population.
;; This function applies tournament selection, crossover 
;;    and mutation to generate a new individual.
;;
;; The arguments are:
;; $pop: The total population.
;; $startNt: The start symbol of the grammar.
;; $g: The generation number.
;; $tSize: The number of individuals to be considered in the tournament selection.
;; $probCrossOver: Crossover probability.
;; $probMutate: Mutation probability.
;; $gramarSpace: The space containing the production rules of the grammar.
;; $ubSpace: The space where the upperbounds of each non terminal is stored.
;; $resultSpace: The space where individual elements of the populations are stored.
;; $newIndex: The new index for the generated population.
;;
;; Result:
;; - Returns the new individual.
(= (getNewPop $pop $startNt $g $popSize $tSize $probCrossOver $probMutate $grammarSpace $ubSpace $resultSpace $newIndex)
   (trace! (Running GetNewPop with Pop: $pop)
    (if (< ((py-atom random.random)) $probCrossOver)
            (let*
                (
                  (() (println! ""))
                  (() (println! (Crossing over with $probCrossOver)))
                  (() (println! (Pop: $pop Popsize: $popSize)))

                  ;; Selecting parents using tournament selection.
                  (
                    (
                      (($nt1 $g1 $p1) ($c1 $py1 $s1))
                      (($nt2 $g2 $p2) ($c2 $py2 $s2)))
                    (collapse (superpose
                                (
                                    (tournament $pop $startNt $g $popSize $tSize)
                                    (tournament $pop $startNt $g $popSize $tSize)))))

                  (() (println! (Finished Tournament selection)))
                  (() (println! (Selected 1: (($nt1 $g1 $p1) ($c1 $py1 $s1)))))
                  (() (println! (Selected 2: (($nt2 $g2 $p2) ($c2 $py2 $s2)))))

                  ;; Ordering genotype of the selected parents.
                  ((($oc1 $nts) ($oc2 $nts))
                    (collapse (superpose
                                (
                                  (getOrderedGenoType $grammarSpace $resultSpace $startNt () () () ($g1 $p1))
                                  (getOrderedGenoType $grammarSpace $resultSpace $startNt () () () ($g2 $p2))))))

                  (() (println! (Finished ordering genotype)))

                  ($mask (genMask (sum (collapse (let $_ (getNts $grammarSpace) 1)))))
                  (($ch1 $ch2) (recombine $oc1 $oc2 $mask))

                  ($c (if (> ((py-atom random.random)) 0.5) $ch1 $ch2)) ;; Pick randomly one of the parents to be included in the next population.

                  (() (println! (Picked child: $c)))

                  ($c' (if (< ((py-atom random.random)) $probMutate) (mutate $c $nts $grammarSpace $ubSpace) $c))

                  (() (println! (Mutated child: $c')))

                  ($ntCodonPair (zip $nts $c'))
                  ($newPop (collapse (let ($nt $codon) (superpose $ntCodonPair) (($nt $g $newIndex) $codon))))

                  (() (println! (NewPop in gen new population: $newPop)))
                )
                $newPop)
            (let (($nt1 $g1 $p) ($c $py $s)) (tournament $pop $startNt $g $popSize $tSize)
                (if (< ((py-atom random.random)) $probMutate)
                    (let*
                        (
                          (() (println! ""))
                          (() (println! (Mutating with $probMutate)))
                          (() (println! (Pop: $pop Popsize: $popSize)))

                          ;; For some reason, the function runs faster when called in superpose on MeTTa version 0.1.12
                          (($oc $nts) (superpose ((getOrderedGenoType $grammarSpace $resultSpace $startNt () () () ($g1 $p)))))

                          (() (println! (Finished ordering genotype)))

                          ($mc (mutate $oc $nts $grammarSpace $ubSpace))

                          (() (println! (Mutated $oc to $mc)))

                          ($ntCodonPair (zip $nts $mc))
                          ($newPop (collapse (let ($nt1' $codon) (superpose $ntCodonPair) (($nt1' $g1 $newIndex) $codon))))

                          (() (println! (New pop in gen new population: $newPop)))
                        )
                        $newPop)
                    (trace! (Returning the population: ((($nt1 $g1 $p) ($c $py $s))) with no operation)
                            (collapse (let (($nt $g1 $p) ($c' $py $s)) (superpose $pop) (($nt $g1 $newIndex) ($c' $py $s))))
                            ))))
                    ;; (collapse (let*
                    ;;     (
                    ;;        (() (println! (Selected: (($nt2 $g1 $p) ($c $py $s)))))
                    ;;        (() (println! (Total Population: $pop)))
                    ;;        ((($nt $g1 $p) ($c' $py $s)) (superpose $pop))
                    ;;        (() (println! (Returning Population: (($nt $g1 $newIndex) ($c' $py $s)))))
                    ;;     )
                    ;;     (($nt $g1 $newIndex) ($c' $py $s)))))))

   )
)

;; Params: (evolve $grammarSpace $dataSpace $refSpace $countSpace $refCountSpace $resultMap $elitism $popSize $tSize $probCrossOver $probMutate $maxGen $maxDepth)
;; !(evolve &grammar &data &refSpace &countSpace &refCountSpace &ubSpace &resultMap &elitism &popSize &tSize &probCrossOver &probMutate &maxGen &maxDepth)
;; !(println! (get-atoms &resultMap))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                                                                                                                          ;;;;
;;;;                                                      Test cases                                                          ;;;;
;;;;                                                                                                                          ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Preparing grammar for testing the following functions.
!(bind! &expandedGrammar (new-space))
!(bind! &ntCount (new-space))
!(bind! &ntReference (new-space))
!(bind! &countReference (new-space))
!(bind! &tempGrammar (new-space))
!(bind! &testGrammar (new-space))
!(bind! &resultSpace (new-space))
!(bind! &upperBoundTest (new-space))

!(add-atom &expandedGrammar (start expr 0))
!(add-atom &expandedGrammar (expr (bop (expr 0) (expr 0)) 0))
!(add-atom &expandedGrammar (expr (uop (expr 0)) 1))
!(add-atom &expandedGrammar (expr term 2))
!(add-atom &expandedGrammar ((expr 0) term 0))
!(add-atom &expandedGrammar (bop AND 0))
!(add-atom &expandedGrammar (bop OR 1))
!(add-atom &expandedGrammar (uop NOT 0))
!(add-atom &expandedGrammar (term X 0))
!(add-atom &expandedGrammar (term Y 1))

!(add-atom &testGrammar (start expr 0))
!(add-atom &testGrammar (expr (bop (expr 0) (expr 0)) 0))
!(add-atom &testGrammar (expr (uop (expr 0)) 1))
!(add-atom &testGrammar (expr term 2))
!(add-atom &testGrammar ((expr 0) term 0))
!(add-atom &testGrammar (bop AND 0))
!(add-atom &testGrammar (bop OR 1))
!(add-atom &testGrammar (uop NOT 0))
!(add-atom &testGrammar (term X 0))
!(add-atom &testGrammar (term Y 1))

!(add-atom &upperBoundTest (start 1 1))
!(add-atom &upperBoundTest (expr 1 3))
!(add-atom &upperBoundTest ((expr 0) 2 1))
!(add-atom &upperBoundTest (bop 1 2))
!(add-atom &upperBoundTest (uop 1 1))
!(add-atom &upperBoundTest (term 3 2))


;; Helper function to add intial atoms into space
(= (populateSpace $space)
   (let*
      (
        (() (add-atom &tempGrammar (start expr 0)))
        (() (add-atom &tempGrammar (expr (uop expr) 0)))
        (() (add-atom &tempGrammar (expr term 1)))
        (() (add-atom &tempGrammar (uop AND 0))))
      ()))

(= (get-rules $space) (match $space ($lhs $rhs $i) ($lhs $rhs)))

!(assertEqualToResult (let () (populateSpace &tempGrammar) (get-atoms &tempGrammar)) ((start expr 0) (expr (uop expr) 0) (expr term 1) (uop AND 0)))
!(assertEqual (let $_ (clearSpace &tempGrammar) (match &tempGrammar $x $x)) (empty))

;; Test getUpdatedNRRule
!(assertEqual (let*
   (
      ($prevIndex (get-state &lastIndex))
      ($updatedRule (getUpdatedNRRule (expr (bop term term) 0) 3))
      ($newIndex (get-state &lastIndex)))
   ($updatedRule (== $newIndex (+ 1 $prevIndex)))) (((expr 2) (bop term term) 0) True))

!(change-state! &lastIndex 0)

!(populateSpace &tempGrammar)
;; Test getRecursiveRules

!(assertEqual (getRecursiveRules start &tempGrammar) ())
!(assertEqual (getRecursiveRules uop &tempGrammar ) ())
!(assertEqual (getRecursiveRules expr &tempGrammar) (expr (uop expr) 0))
!(assertEqual (getRecursiveRules AND &tempGrammar) (empty))

;; Test getNonRecursiveRules

!(assertEqual (getNonRecursiveRules start &tempGrammar) (start expr 0))
!(assertEqual (getNonRecursiveRules uop &tempGrammar) (uop AND 0))
!(assertEqual (getNonRecursiveRules expr &tempGrammar) (expr term 1))
!(assertEqual (getNonRecursiveRules AND &tempGrammar) (empty))

;; Test expandMapHelper

!(assertEqual (expandMapHelper (1 expr) start) start)
!(assertEqual (expandMapHelper (4 expr) expr) (expr 4))
!(assertEqual (expandMapHelper (3 uop) expr) expr)
!(assertEqual (expandMapHelper (2 uop) uop) (uop 2))

;; Test expandRule

!(assertEqual (expandRule 0 (expr (bop term expr) 0)) (expr (bop term (expr 0)) 0))
!(assertEqual (expandRule 0 (expr (bop term expr) 1)) (expr (bop term (expr 0)) 1))
!(assertEqual (expandRule 1 (expr (bop expr expr) 2)) ((expr 0) (bop (expr 1) (expr 1)) 2))
!(assertEqual (expandRule 1 (expr (bop expr expr) 3)) ((expr 0) (bop (expr 1) (expr 1)) 3))
!(assertEqual (expandRule 3 (expr (bop term expr) 0)) ((expr 2) (bop term (expr 3)) 0))
!(assertEqual (expandRule 3 (expr (bop term expr) 1)) ((expr 2) (bop term (expr 3)) 1))
!(assertEqual (expandRule 3 (expr (bop expr expr) 2)) ((expr 2) (bop (expr 3) (expr 3)) 2))
!(assertEqual (expandRule 3 (expr (bop expr expr) 3)) ((expr 2) (bop (expr 3) (expr 3)) 3))

;; Test expandRules

!(assertEqual
   (===
      (let $_
        (expandRules 1
            (collapse (getRecursiveRules expr &tempGrammar))
            (collapse (getNonRecursiveRules expr &tempGrammar))
            &tempGrammar)
        (collapse (get-atoms &tempGrammar)))
      ((start expr 0) (expr (uop expr) 0) (expr term 1) (uop AND 0) ((expr 0) (uop (expr 1)) 0) ((expr 0) term 1))
   )
   True)

!(clearSpace &tempGrammar)
!(populateSpace &tempGrammar)

;; Test maxDepthNotReached

!(assertEqual (maxDepthNotReached (expr 2 3 () () &tempGrammar)) False)
!(assertEqual (maxDepthNotReached (expr 3 3 () () &tempGrammar)) True)
!(assertEqual (maxDepthNotReached (expr 4 3 () () &tempGrammar)) True)

;; Test applyExpandRules
!(assertEqual
   (let $nextState
        (applyExpandRules (expr 2 3 (collapse (getRecursiveRules expr &tempGrammar)) (collapse (getNonRecursiveRules expr &tempGrammar)) &tempGrammar))
        ($nextState (collapse (get-atoms &tempGrammar))))
   ((expr 3 3 ((expr (uop expr) 0)) ((expr term 1)) &tempGrammar) ((start expr 0) (expr (uop expr) 0) (expr term 1) (uop AND 0) ((expr 1) (uop (expr 2)) 0) ((expr 1) term 1))))

!(clearSpace &tempGrammar)
!(populateSpace &tempGrammar)

!(assertEqual
   (let $nextState
        (applyExpandRules (start 2 3 (collapse (getRecursiveRules start &tempGrammar)) (collapse (getNonRecursiveRules start &tempGrammar)) &tempGrammar))
        ($nextState (collapse (get-atoms &tempGrammar))))
   ((start 3 3 (()) ((start expr 0)) &tempGrammar) ((start expr 0) (expr (uop expr) 0) (expr term 1) (uop AND 0) (expandRule 2 ()) ((start 1) expr 0))))

!(clearSpace &tempGrammar)
!(populateSpace &tempGrammar)

!(assertEqual
   (let $nextState (applyExpandRules (uop 2 3 (collapse (getRecursiveRules uop &tempGrammar)) (collapse (getNonRecursiveRules uop &tempGrammar)) &tempGrammar)) ($nextState (collapse (get-atoms &tempGrammar))))
   ((uop 3 3 (()) ((uop AND 0)) &tempGrammar) ((start expr 0) (expr (uop expr) 0) (expr term 1) (uop AND 0) (expandRule 2 ()) ((uop 1) AND 0))))

!(clearSpace &tempGrammar)
!(populateSpace &tempGrammar)

;; Test removeRFromRule

!(assertEqual
   (removeRFromRule expr (uop expr) 2 (collapse (getNonRecursiveRules expr &tempGrammar)))
   ((uop term) 0))
!(assertEqual
   (removeRFromRule expr (bop term term) 1 ((expr (uop term) 1) (expr (bop term term) 2)))
   ((bop term term) 1))

!(assertEqual
   (===
      (collapse (removeRFromRule expr (bop expr expr) 2 ((expr (uop term) 1) (expr (bop term term) 2))))
      (((bop (uop term) (uop term)) 2) ((bop (uop term) (bop term term)) 3) ((bop (bop term term) (uop term)) 5) ((bop (bop term term) (bop term term)) 6)))
   True)


;; Test removeRFromRuleHelper

!(assertEqual
   (===
      (collapse (removeRFromRuleHelper expr (bop expr expr) ((expr (uop term) 0) (expr (bop term term) 1))))
      (((bop (uop term) expr) 0) ((bop (bop term term) expr) 1)))
   True)
!(assertEqual
   (===
      (collapse (let ($rhs $i) (removeRFromRuleHelper expr (bop expr expr) ((expr (uop term) 0) (expr (bop term term) 1))) (removeRFromRuleHelper expr $rhs ((expr (uop term) 0) (expr (bop term term) 1)))))
      (((bop (uop term) (uop term)) 0) ((bop (uop term) (bop term term)) 1) ((bop (bop term term) (uop term)) 0) ((bop (bop term term) (bop term term)) 1)))
   True)

;; Test expandRecursiveNT

!(clearSpace &tempGrammar)
!(populateSpace &tempGrammar)

!(assertEqual
  (===
      (collapse (let $_ (expandRecursiveNT expr 3 &tempGrammar) (get-rules &tempGrammar)))
      ((start expr) (expr (uop (expr 0))) (expr term) (uop AND) ((expr 2) term) ((expr 0) (uop (expr 1))) ((expr 0) term) ((expr 1) (uop (expr 2))) ((expr 1) term) ((expr 2) (uop term))))
  True)

!(clearSpace &tempGrammar)
!(populateSpace &tempGrammar)

!(assertEqual
  (===
      (let $_ (expandRecursiveNT expr 2 &tempGrammar) (collapse (get-rules &tempGrammar)))
      ((start expr) (expr (uop (expr 0))) (expr term) (uop AND) ((expr 1) term) ((expr 0) (uop (expr 1))) ((expr 0) term) ((expr 1) (uop term))))
  True)

!(clearSpace &tempGrammar)
!(populateSpace &tempGrammar)


!(assertEqual
  (===
      (let $_ (expandRecursiveNT expr 1 &tempGrammar) (collapse (get-rules &tempGrammar)))
      ((start expr) (expr (uop (expr 0))) (expr term) (uop AND) ((expr 0) term) ((expr 0) (uop term))))
  True)

!(clearSpace &tempGrammar)
!(populateSpace &tempGrammar)

;; Test expandGrammar

!(assertEqual
    (===
        (let $_ (collapse (expandGrammar 3 &tempGrammar)) (collapse (get-rules &tempGrammar)))
        ((start expr) (expr (uop (expr 0))) (expr term) (uop AND) ((expr 2) term) ((expr 0) (uop (expr 1))) ((expr 0) term) ((expr 1) (uop (expr 2))) ((expr 1) term) ((expr 2) (uop term))))
    True)

!(clearSpace &tempGrammar)
!(populateSpace &tempGrammar)

!(assertEqual
    (===
        (let $_ (collapse (expandGrammar 2 &tempGrammar)) (collapse (get-rules &tempGrammar)))
        (((expr 1) (uop term)) ((expr 0) (uop (expr 1))) ((expr 1) term) ((expr 0) term) (expr (uop (expr 0))) (expr term) (uop AND) (start expr)))
    True)


;; Test calcTotalNtReference

!(assertEqual (let $_ (calcTotalNtReference &expandedGrammar &ntReference &ntCount (expr 0) (collapse (unique (match &expandedGrammar ($lhs $rhs $i) $lhs)))) (=== (collapse (get-atoms &ntCount)) ((term 1)))) True)

!(clearSpace (superpose (&ntReference &ntCount)))

!(assertEqual (let $_ (calcTotalNtReference &expandedGrammar &ntReference &ntCount (expr 0) (collapse (unique (match &expandedGrammar ($lhs $rhs $i) $lhs)))) (=== (collapse (get-atoms &ntReference)) ((term (expr 0))))) True)

!(clearSpace (superpose (&ntReference &ntCount)))

!(assertEqual (let $_ (calcTotalNtReference &expandedGrammar &ntReference &ntCount expr (collapse (unique (match &expandedGrammar ($lhs $rhs $i) $lhs)))) (=== (collapse (get-atoms &ntCount)) ((bop 1) ((expr 0) 2) ((expr 0) 0) (uop 1) ((expr 0) 1) (term 1)))) True)

!(clearSpace (superpose (&ntReference &ntCount)))

!(assertEqual (let $_ (calcTotalNtReference &expandedGrammar &ntReference &ntCount expr (collapse (unique (match &expandedGrammar ($lhs $rhs $i) $lhs)))) (=== (collapse (get-atoms &ntReference)) ((bop expr) ((expr 0) expr) ((expr 0) expr) (uop expr) ((expr 0) expr) (term expr)))) True)

;; INFO: The above test case's effect on the space is kept intentionally as it will be an input for the countMaxReference test cases.

;; Test countMaxReference
!(assertEqual (let $_ (collapse (countMaxReference &ntCount &countReference (expr 0) expr)) (=== (collapse (get-atoms &countReference)) (((expr 0) expr 2)))) True) ;; INFO: The countMaxReference function wrapped in let returns non deterministic result but works fine when called directly.
!(clearSpace &countReference)

!(assertEqual (let $_ (collapse (countMaxReference &ntCount &countReference expr start)) (=== (collapse (get-atoms &countReference)) ((expr start 0)))) True)

!(clearSpace &countReference)

!(assertEqual (let $_ (collapse (countMaxReference &ntCount &countReference x start)) (=== (collapse (get-atoms &countReference)) ((x start 0)))) True)

!(clearSpace &countReference)

;; Test applyCountMaxReference

!(assertEqual (unique (applyCountMaxReference (&ntCount &countReference expr) (expr (expr 0) term))) ((expr 0) term)) ;; INFO: Fails for the same reason as the above countMaxReference being wrapped in a let.

!(clearSpace &countReference)

!(assertEqual (let $_ (collapse (applyCountMaxReference (&ntCount &countReference expr) (expr (expr 0) term))) (=== (collapse (get-atoms &countReference)) ((expr expr 0)))) True)

!(clearSpace (superpose (&ntCount &ntReference &countReference)))

;; Test calcMaxNtReference

!(assertEqual (let $_ (calcMaxNtReference &expandedGrammar &ntReference &ntCount &countReference expr) (=== (collapse (get-atoms &ntReference)) ((uop expr) ((expr 0) expr) (bop expr) (term expr)))) True)

!(clearSpace (superpose (&ntReference &countReference)))

!(assertEqual (let $_ (calcMaxNtReference &expandedGrammar &ntReference &ntCount &countReference expr) (=== (collapse (get-atoms &countReference)) ((uop expr 1) (term expr 1) (bop expr 1) ((expr 0) expr 2)))) True)

!(clearSpace (superpose (&ntReference &countReference)))

!(assertEqual (let $_  (calcMaxNtReference &expandedGrammar &ntReference &ntCount &countReference (expr 0)) (=== (collapse (get-atoms &ntReference)) ((term (expr 0))))) True)

!(clearSpace (superpose (&ntReference &countReference)))

!(assertEqual (let $_  (calcMaxNtReference &expandedGrammar &ntReference &ntCount &countReference (expr 0)) (=== (collapse (get-atoms &countReference)) ((term (expr 0) 1)))) True)

!(clearSpace (superpose (&ntReference &countReference)))

!(assertEqual (let $_  (calcMaxNtReference &expandedGrammar &ntReference &ntCount &countReference uop) (=== (collapse (get-atoms &ntReference)) ())) True)

!(assertEqual (let $_  (calcMaxNtReference &expandedGrammar &ntReference &ntCount &countReference uop) (=== (collapse (get-atoms &countReference)) ())) True)

;; Test applyCalcMaxNtReference
!(assertEqual (applyCalcMaxNtReference (&expandedGrammar &ntReference &ntCount &countReference) ((expr 0) start expr term uop bop)) (start expr term uop bop))

!(assertEqual (let $_ (applyCalcMaxNtReference (&expandedGrammar &ntReference &ntCount &countReference) ((expr 0) start expr term uop bop)) (=== (collapse (get-atoms &ntReference)) ((term (expr 0))))) True)

!(clearSpace (superpose (&ntReference &countReference)))

;; INFO: This line here is added because the next test cases depend on a result being present in the spaces defined.
!(until isUnit ((curry applyCalcMaxNtReference) (&expandedGrammar &ntReference &ntCount &countReference)) (collapse (unique (match &expandedGrammar ($nt $rhs $i) $nt))))

;; Test maxRefPerProd
!(assertEqual (maxRefPerProd &ntReference &countReference expr) 1)
!(assertEqual (maxRefPerProd &ntReference &countReference (expr 0)) 2)
!(assertEqualToResult (maxRefPerProd &ntReference &countReference term) (2 1))

;; Test upperBounds

!(assertEqual (upperBounds &ntReference &countReference expr) (expr 1))
!(assertEqual (upperBounds &ntReference &countReference (expr 0)) ((expr 0) 2))
!(assertEqual (upperBounds &ntReference &countReference term) (term 3))

!(clearSpace (superpose (&ntReference &countReference)))

;; Test recombine

! (assertEqual
    (recombine ((0) (0 1) (0 1 0 1) (0 2 1)) ((1) (1 0) (0 0 0 1) (2 3 1)) (0 0 1 1))
        (((0) (0 1) (0 0 0 1) (2 3 1)) ((1) (1 0) (0 1 0 1) (0 2 1))))

! (assertEqual
    (recombine ((0) (0 1) (0 1 0 1) (0 2 1)) ((1) (1 0) (0 0 0 1) (2 3 1)) (0 1 0 1))
        (((0) (1 0) (0 1 0 1) (2 3 1)) ((1) (0 1) (0 0 0 1) (0 2 1))))

;; Test calculateCN

!(assertEqual (calculateCN expr &expandedGrammar) 3)
!(assertEqual (calculateCN (expr 0) &expandedGrammar) 1)
!(assertEqual (calculateCN noNt &expandedGrammar) 0)

;; Test genGenotype

(= (isNumber $expr) (== (get-metatype $expr) Grounded))

!(assertEqualToResult (let $_ (genGenotype &expandedGrammar &ntReference &countReference &upperBoundTest &resultSpace (0 2)) (match &resultSpace (($nt 0 2) $codon) $nt)) (start expr (expr 0) bop uop term))
!(assertEqualToResult (let*
                         (
                           ($codon (collapse (match &resultSpace (($nt 0 2) $codon) $codon)))
                           ($boolean (collapse
                                       (let*
                                           (
                                             ($c (superpose $codon))
                                             ($gene (superpose $c))
                                           )
                                       (isNumber $gene))))
                         )
                         (isMember False $boolean)) (False))

;; Test index rules
!(assertEqualToResult (let $_ (indexRules start &expandedGrammar) (match &expandedGrammar (start $lhs $i) $i)) (0))
!(assertEqualToResult (let $_ (indexRules expr &expandedGrammar) (match &expandedGrammar (expr $lhs $i) $i)) (0 1 2))
!(assertEqualToResult (let $_ (indexRules (expr 0) &expandedGrammar) (match &expandedGrammar ((expr 0) $lhs $i) $i)) (0))
!(assertEqualToResult (let $_ (indexRules term &expandedGrammar) (match &expandedGrammar (term $lhs $i) $i)) (1 0))
!(assertEqualToResult (let $_ (indexRules bop &expandedGrammar) (match &expandedGrammar (bop $lhs $i) $i)) (1 0))
!(assertEqualToResult (let $_ (indexRules uop &expandedGrammar) (match &expandedGrammar (uop $lhs $i) $i)) (0))

;; Test ordered left hand sides
!(assertEqual (getOrderedLhs &testGrammar expr 3) ((bop (expr 0) (expr 0)) (uop (expr 0)) term))
!(assertEqual (getOrderedLhs &testGrammar start 1) (expr))

;; Test ordered genotype
!(clearSpace &resultSpace)

!(add-reduct &resultSpace (superpose ((((expr 0) 0 2) (0 0)) ((expr 0 2) (2)) ((term 0 2) (1 0 1)) ((uop 0 2) (0)) ((bop 0 2) (1)) ((start 0 2) (0))))) ;; Y
!(add-reduct &resultSpace (superpose ((((expr 0) 0 1) (0 0)) ((start 0 1) (0)) ((uop 0 1) (0)) ((expr 0 1) (0)) ((bop 0 1) (1)) ((term 0 1) (1 1 1))))) ;; (OR Y Y)
!(add-reduct &resultSpace (superpose ((((expr 0) 0 0) (0 0)) ((expr 0 0) (0)) ((term 0 0) (0 1 0)) ((uop 0 0) (0)) ((start 0 0) (0)) ((bop 0 0) (0))))) ;; (AND X Y)
!(add-reduct &resultSpace (superpose ((((expr 0) 0 3) (0 0)) ((expr 0 3) (1)) ((term 0 3) (1 1 1)) ((bop 0 3) (1)) ((start 0 3) (0)) ((uop 0 3) (0))))) ;; (NOT Y)


!(assertEqual (getOrderedGenoType &testGrammar &resultSpace start () () () (0 2)) ((1 (0) (0 0) (1) (2) (0)) (term uop (expr 0) bop expr start)))

;; Test isSubRule
!(assertEqual (isSubRule (bop term term)) True)
!(assertEqual (isSubRule (expr 0)) False)
!(assertEqual (isSubRule A) False)

;; Test generate phenotype
!(assertEqual (genPhenotype &resultSpace &testGrammar () (start) (0 2)) (Y))
!(assertEqual (genPhenotype &resultSpace &testGrammar () (start) (0 1)) ((OR Y Y)))
!(assertEqual (genPhenotype &resultSpace &testGrammar () (start) (0 0)) ((AND X Y)))
!(assertEqual (genPhenotype &resultSpace &testGrammar () (start) (0 3)) ((NOT Y)))

;; Test evaluate

!(clearSpace &resultSpace)

!(add-reduct &resultSpace (superpose ((((expr 0) 0 2) (0 0)) ((expr 0 2) (2)) ((term 0 2) (1 0 1)) ((uop 0 2) (0)) ((bop 0 2) (1)) ((start 0 2) (0))))) ;; Y
!(add-reduct &resultSpace (superpose ((((expr 0) 0 1) (0 0)) ((start 0 1) (0)) ((uop 0 1) (0)) ((expr 0 1) (0)) ((bop 0 1) (1)) ((term 0 1) (1 1 1))))) ;; (OR Y Y)
!(add-reduct &resultSpace (superpose ((((expr 0) 0 0) (0 0)) ((expr 0 0) (0)) ((term 0 0) (0 1 0)) ((uop 0 0) (0)) ((start 0 0) (0)) ((bop 0 0) (0))))) ;; (AND X Y)
!(add-reduct &resultSpace (superpose ((((expr 0) 0 3) (0 0)) ((expr 0 3) (1)) ((term 0 3) (1 1 1)) ((bop 0 3) (1)) ((start 0 3) (0)) ((uop 0 3) (0))))) ;; (NOT Y)

(= (testScore $x $y $z) 50)

!(assertEqualToResult
    (let $result (evaluate (collapse (get-atoms &resultSpace)) testScore () 0.1 &resultSpace &testGrammar start)
                 (superpose $result))
                 (((start 0 2) ((0) Y 50)) ((start 0 1) ((0) (OR Y Y) 50)) ((start 0 0) ((0) (AND X Y) 50)) ((start 0 3) ((0) (NOT Y) 50))))

;; Test comparePop

!(assertEqual (comparePop ((expr 1 2) ((0) Y 50)) ((start 1 2) ((0) (OR Y Y) 50))) True)
!(assertEqual (comparePop (((expr 0) 2 2) ((0) Y 40)) ((expr 2 2) ((0) (OR Y Y) 50))) False)
!(assertEqual (comparePop ((term 0 2) ((0) Y 50)) (((expr 0) 2 2) ((0) (OR Y Y) 60))) False)
!(assertEqual (comparePop (((expr 0) 2 2) ((0) (OR Y Y) 60)) ((term 0 2) ((0) Y 50))) True)


;; Test mutate

;; confirmMutation
;;        return true only if the number of changed genes is either 0 or 1
;;        Flattens the two gene lists, original and mutated, so that changes can be compared element by element

(: confirmMutation (-> Expression Expression Bool))
(= (confirmMutation $original $mutated)
    (~= (collapse (subtraction (superpose $original) (superpose $mutated))) ())
)

!(clearSpace &upperBoundTest)

!(add-atom &upperBoundTest (start 1 2))
!(add-atom &upperBoundTest (expr 1 3))
!(add-atom &upperBoundTest ((expr 0) 2 2))
!(add-atom &upperBoundTest (bop 1 2))
!(add-atom &upperBoundTest (uop 1 2))
!(add-atom &upperBoundTest (term 3 2))

!(assertEqual
  (confirmMutation ((0) (0 0) (1) (1 0 1) (1) (0)) (mutate ((0) (0 0) (1) (1 0 1) (1) (0)) (collapse (getNts &expandedGrammar)) &expandedGrammar &upperBoundTest))
  True)
!(assertEqual
    (confirmMutation ((0) (0 0) (0) (0 0 0) (0) (0)) (mutate ((0) (0 0) (0) (0 0 0) (0) (0)) (collapse (getNts &expandedGrammar)) &expandedGrammar &upperBoundTest))
  True)

;; Test evolution

(= (testEvolve $grammar $dataSpace $refSpace $countSpace $refCountSpace $ubSpace $resultSpace $elite $popSize $tSize $pCross $pMutate $maxGen $maxDepth)
   (let*
      (
        (() (evolve $grammar $dataSpace $refSpace $countSpace $refCountSpace $ubSpace $resultSpace $elite $popSize $tSize $pCross $pMutate $maxGen $maxDepth))
        ($result (collapse (get-atoms &resultSpace)))

        (() (println! (Result: $result)))

        ($nts (collapse (unique (let (($nt $g $i) $value) (superpose $result) $nt))))
        ($ntSize (sum (collapse (let $nt (superpose $nts) 1))))
        ($size (/ (sum (collapse (let (($nt $g $i) $value) (superpose $result) 1))) $ntSize))
        ($eliteSize (/ (sum (collapse (let (($nt $g $i) ($codon $py $score)) (superpose $result) (if (isExpression $codon) 1 (empty))))) $ntSize))
        ($ntsEqual (=== $nts (collapse (getNts $grammar))))
      )
      ($ntsEqual $size $eliteSize)
   )
)

!(clearSpace (superpose (&resultSpace &upperBoundTest)))

!(assertEqual
   (let ($ntsEqual $size $eliteSize) (testEvolve &expandedGrammar &data &ntReference &countSpace &countReference &upperBoundTest &resultSpace 1 3 2 0.0 0.0 1 2)
        ($ntsEqual $size $eliteSize))
   (True 3 3))

!(clearSpace (superpose (&ntReference &countReference &resultSpace &upperBoundTest)))

!(assertEqual
   (let ($ntsEqual $size $eliteSize) (testEvolve &expandedGrammar &data &ntReference &countSpace &countReference &upperBoundTest &resultSpace 1 3 2 1.0 0.0 1 2)
        ($ntsEqual $size $eliteSize))
   (True 3 1))

!(clearSpace (superpose (&ntReference &countReference &resultSpace &upperBoundTest)))

!(assertEqual
  (let ($ntsEqual $size $eliteSize) (testEvolve &expandedGrammar &data &ntReference &countSpace &countReference &upperBoundTest &resultSpace 1 3 2 0.0 1.0 1 2)
       ($ntsEqual $size $eliteSize))
  (True 3 1))

!(clearSpace (superpose (&ntReference &countReference &resultSpace &upperBoundTest)))

!(assertEqual
   (let ($ntsEqual $size $eliteSize) (testEvolve &expandedGrammar &data &ntReference &countSpace &countReference &upperBoundTest &resultSpace 1 3 2 0.7 0.2 2 2)
        ($ntsEqual $size (and (>= $eliteSize 1) (<= $eliteSize 3))))
   (True 3 True))
