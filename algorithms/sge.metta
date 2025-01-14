! (register-module! ../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:utilities:expression-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:one-constraint-complement-subtraction) ;; TODO: This import is temporary. Refactor code inside oncc and remove it.

;; Structured grammatical evolution (SGE)
;; This implementation is based on the research paper: https://link.springer.com/article/10.1007/s10710-015-9262-4

;; Grammar Chosen: Boolean expressions
;; <start> -> <expr>
;; <expr>  -> <bop> <expr> <expr> |
;;            <uop> <expr> |
;;            <term>
;; <bop>   -> AND | OR
;; <uop>   -> NOT

;; TODO: Algorithm to map the grammar to generated probabilistic selection dictionary.
;; TODO: Implement mutation and corssover operators.

;; TODO: Implement a function to call all of the above functions together.
;;       Steps To follow:
;;              - Expand grammar based on depth.
;;              - Calculate non terminal references and maximum number of derivations per rules.
;;              - Generate N number of initial population.
;;              - Until G is reached, repeat the following:
;;                  - Score each population. If solution is found, break.
;;                  - Select two random parents.
;;                  - Crossover the two parents:
;;                      - Randomly generate masking bitstring.
;;                      - Perform the crossover.
;;                  - Mutate the offsprings:
;;                      - Randomly select a position to mutate and generate new value for it.
;;                  - Mutate the parents.
;;                  - Include the top two of previous population, the mutated offspings and mutated parents in next generation.
;;                  - Keep the top K populations for the next generations and replace the rest of the population with new ones.
;;                  - Repeat.


!(bind! &grammar (new-space))
!(bind! &maxDepth 3)
!(bind! &lastIndex (new-state 0))

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

;; !(add-atom &grammar (start (expr op expr) 0))
;; !(add-atom &grammar (start expr 1))
;; !(add-atom &grammar (expr (term op term) 0))
;; !(add-atom &grammar (expr ([ term op term ]) 1))
;; !(add-atom &grammar (term X 0))
;; !(add-atom &grammar (term 0.5 1))
;; !(add-atom &grammar (op plus 0))
;; !(add-atom &grammar (op minus 1))
;; !(add-atom &grammar (op mult 2))
;; !(add-atom &grammar (op div 3))



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

!(bind! &ntCount (new-space))
!(bind! &ntReference (new-space))
!(bind! &countReference (new-space))

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
;; The function maxRefPerProd can return a more than one value corresponding to each 
;;    production rule's maximum reference. There for this functions sums them up.
;;
;; The arguments are:
;;
;; $referenceSpace: The space to store non-terminal references.
;; $refCountSpace: The space to store the count of non-terminal references.
;; $nt: The non-terminal for which the upper bounds are to be calculated.
;;
;; Returns:
;; - The non-terminal and it's upperBound in a tuple.
(= (upperBounds $referenceSpace $refCountSpace $nt) ($nt (sum (collapse (maxRefPerProd $referenceSpace $refCountSpace $nt)))))

;; !(upperBounds &ntReference &countReference (superpose (term expr expr_0 bop uop)))

;; !(get-atoms &ntReference)
;; !(get-atoms &ntCount)
;; !(get-atoms &countReference)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                                                                                                                          ;;;;
;;;;                                                      Generation                                                          ;;;;
;;;;                                                                                                                          ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;; Return count of possible derivation options for a given non terminal.
(= (calculateCN $nt $grammarSpace)
   (sum (collapse (match $grammarSpace ($nt $rhs $i) 1))))

;; Index production rules of a non terminal properly.
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

;; Generate a random genotype given the required informtion.
(= (genCodon $n $ub)
   (if (== $n 1)
       (((py-atom random.randint) 0 $ub))
       (let*
            (
               ($firstRandom ((py-atom random.randint) 0 $ub))
               ($nextRandoms (genCodon (- $n 1) $ub)))
            (cons-atom $firstRandom $nextRandoms))))

;; Generate a random mask given a size.
(= (genMask $n) (genCodon $n 1))

;; recombine creates crossbreeds by taking genetic material from two parents based on binary mask values
;; How it works
;;            Parameters:-  1. $parent1, $parent2 genotype of two parents given as two separate tuples of tuples
;;                          E.g., ((0) (1 0))((1) (1 1)) -- two tuple consisting of genotypes of two parents each containing two gene sequences
;;                                ((0) (1 0) (1 2 0)) ((1) (1 1) (1 1 2)) -- 3 gene sequences for each parent ...
;;                          2. $mask, binary mask of same length as the genotype list, e.g., for the above genotypes possible masks are 
;;                          (0 1) and (0 1 1) repectively. 
;;                          bit 0 -- means the offspring will take genotype material from first parent
;;                          bit 1 -- means the offspring will take genotype material from the other parent
;; Examples
;;                          ! (recombine ((0) (1 0))((1) (1 1)) (0 1)) --> (((0) (1 1)) ((1) (1 0))) -- genes have been swapped at index where the binary mask 1
;;                          ! (recombine ((0) (1 0))((1) (1 1)) (1 0)) --> (((1) (1 0)) ((0) (1 1)))
;;                          ! (recombine ((0) (1 0) (1 2 0)) ((1) (1 1) (1 1 2)) (0 1 1)) --> (((0) (1 1) (1 1 2)) ((1) (1 0) (1 2 0)))
;;                          ! (recombine ((0) (1 0) (1 2 0) (1 1 0 0)) ((1) (1 1) (1 1 2) (0 0 1 1)) (0 1 1 0)) --> (((0) (1 1) (1 1 2) (1 1 0 0)) ((1) (1 0) (1 2 0) (0 0 1 1)))

(= (recombine $parent1 $parent2 $mask)
    (if (== $mask ())
        ($parent1 $parent2)
        (let*
            (
               (($gene1 $restOfP1) (decons $parent1))
               (($gene2 $restOfP2) (decons $parent2))
               (($bit $maskTail) (decons $mask))
               (($c $d) (recombine $restOfP1 $restOfP2 $maskTail))
            )
            (if (== $bit 0)
                ((cons-atom $gene1 $c) (cons-atom $gene2 $d))
                ((cons-atom $gene2 $c) (cons-atom $gene1 $d))
                ))))

;; Mutation agent
;;    Parameteres:-
;;                   1. $genotype -- tuple of tuples each nested tuple containing geneotype information of each non-terminal
;;                   2. $grammarSpace -- metta space where grammar expansion information has been added

;; Explanation:-     the mutation operation is implemented as follows
;;                   A non-terminal is picked randomly from the ntSet. 
;;                   The index used to pick the gene sequence of the non-terminal in genotype tuple
;;                   A gene is selected from this particular gene sequence randomly for mutation 
;;                   The value of the gene is replaced by new gene choosen from the range [0, cN) of that particular non-terminal
;;                   cN represents the number of expansion options of the particular non-terminal
;;                   This implementation doesnt guarantee generation of new genotype material, the mutation rely on pure chance
;;                   and there are two ways in which we could end up with the same genotype material as the one we started with.
;;                   1. If the picked non-terminal's number of expansion options is exaclty one(1), the gene value is 0 and there 
;;                   is no room for generation of new gene material
;;                   2. In the case where the choosen non-terminal has more than one expansion options(cN ≥ 2), the random operator may
;;                   end up picking the same gene in that range as the old one.
;; Examples
;;                  ! (mutate ((0) (1 0 2) (1 1) (0) (0 1)) &grammar)
;;                  -- run 1 -- ((0) (2 0 2) (1 1) (0) (0 1))
;;                  -- run 2 -- ((0) (1 0 2) (1 1) (0) (0 1))
;;                  -- run 3 -- ((0) (1 0 2) (1 0) (0) (0 1))
;;                  -- run 4 -- ((0) (1 0 2) (1 1) (0) (0 1))
;;                  -- run 5 -- ((0) (1 0 2) (0 1) (0) (0 1))

! (bind! rnd (py-atom numpy.random))

(= (mutate $genotype $grammarSpace)
    (let* (
            ($ntSet (getNTs $grammarSpace))
            ($len (len $ntSet))
            ($index ((py-dot rnd randint) $len))
            ($nt (selectByIndex $ntSet $index))
            ($cN (calculateCN $nt $grammarSpace))
            ($geneList (selectByIndex $genotype $index))
            ($geneLen (len $geneList)) ;
            ($geneIndex ((py-dot rnd randint) $geneLen))
            ($newGeneValue ((py-dot rnd randint) $cN))
            ($mutatedGeneList (replaceByIndex $geneList $geneIndex $newGeneValue))
        )
        (replaceByIndex $genotype $index $mutatedGeneList)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                                                                                                                          ;;;;
;;;;                                                      Test cases                                                          ;;;;
;;;;                                                                                                                          ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!(bind! &tempGrammar (new-space))

(= (clearSpace $space)
   (collapse (let $content (get-atoms $space) (remove-atom $space $content))))

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

;; A helper function to clear all atoms from a space

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


;; Preparing grammar for testing the following functions.
!(bind! &expandedGrammar (new-space))

!(add-atom &expandedGrammar (start expr 0))
!(add-atom &expandedGrammar (expr (bop expr_0 expr_0) 0))
!(add-atom &expandedGrammar (expr (uop expr_0) 1))
!(add-atom &expandedGrammar (expr term 2))
!(add-atom &expandedGrammar (expr_0 term 2))
!(add-atom &expandedGrammar (bop AND 0))
!(add-atom &expandedGrammar (bop OR 1))
!(add-atom &expandedGrammar (uop NOT 0))
!(add-atom &expandedGrammar (term X 0))
!(add-atom &expandedGrammar (term Y 1))

;; Test calcTotalNtReference

!(assertEqual (let $_ (calcTotalNtReference &expandedGrammar &ntReference &ntCount expr_0 (collapse (unique (match &expandedGrammar ($lhs $rhs $i) $lhs)))) (=== (collapse (get-atoms &ntCount)) ((term 1)))) True)

!(clearSpace (superpose (&ntReference &ntCount)))

!(assertEqual (let $_ (calcTotalNtReference &expandedGrammar &ntReference &ntCount expr_0 (collapse (unique (match &expandedGrammar ($lhs $rhs $i) $lhs)))) (=== (collapse (get-atoms &ntReference)) ((term expr_0)))) True)

!(clearSpace (superpose (&ntReference &ntCount)))

!(assertEqual (let $_ (calcTotalNtReference &expandedGrammar &ntReference &ntCount expr (collapse (unique (match &expandedGrammar ($lhs $rhs $i) $lhs)))) (=== (collapse (get-atoms &ntCount)) ((bop 1) (expr_0 2) (expr_0 0) (uop 1) (expr_0 1) (term 1)))) True)

!(clearSpace (superpose (&ntReference &ntCount)))

!(assertEqual (let $_ (calcTotalNtReference &expandedGrammar &ntReference &ntCount expr (collapse (unique (match &expandedGrammar ($lhs $rhs $i) $lhs)))) (=== (collapse (get-atoms &ntReference)) ((bop expr) (expr_0 expr) (expr_0 expr) (uop expr) (expr_0 expr) (term expr)))) True)

;; INFO: The above test case's effect on the space is kept intentionally as it will be an input for the countMaxReference test cases.

;; Test countMaxReference
!(assertEqual (let $_ (countMaxReference &ntCount &countReference expr_0 expr) (=== (collapse (get-atoms &countReference)) ((expr_0 expr 2)))) True)

!(clearSpace &countReference)

!(assertEqual (let $_ (countMaxReference &ntCount &countReference expr start) (=== (collapse (get-atoms &countReference)) ((expr start 0)))) True)

!(clearSpace &countReference)

!(assertEqual (let $_ (countMaxReference &ntCount &countReference x start) (=== (collapse (get-atoms &countReference)) ((x start 0)))) True)

!(clearSpace &countReference)

;; Test applyCountMaxReference
!(assertEqual (applyCountMaxReference (&ntCount &countReference expr) (expr expr_0 term)) (expr_0 term))

!(clearSpace &countReference)

!(assertEqual (let $_ (applyCountMaxReference (&ntCount &countReference expr) (expr expr_0 term)) (=== (collapse (get-atoms &countReference)) ((expr expr 0)))) True)

!(clearSpace (superpose (&ntCount &ntReference &countReference)))

;; Test calcMaxNtReference

!(assertEqual (let $_ (calcMaxNtReference &expandedGrammar &ntReference &ntCount &countReference expr) (=== (collapse (get-atoms &ntReference)) ((uop expr) (expr_0 expr) (bop expr) (term expr)))) True)

!(clearSpace (superpose (&ntReference &countReference)))

!(assertEqual (let $_ (calcMaxNtReference &expandedGrammar &ntReference &ntCount &countReference expr) (=== (collapse (get-atoms &countReference)) ((uop expr 1) (term expr 1) (bop expr 1) (expr_0 expr 2)))) True)

!(clearSpace (superpose (&ntReference &countReference)))

!(assertEqual (let $_  (calcMaxNtReference &expandedGrammar &ntReference &ntCount &countReference expr_0) (=== (collapse (get-atoms &ntReference)) ((term expr_0)))) True)

!(clearSpace (superpose (&ntReference &countReference)))

!(assertEqual (let $_  (calcMaxNtReference &expandedGrammar &ntReference &ntCount &countReference expr_0) (=== (collapse (get-atoms &countReference)) ((term expr_0 1)))) True)

!(clearSpace (superpose (&ntReference &countReference)))

!(assertEqual (let $_  (calcMaxNtReference &expandedGrammar &ntReference &ntCount &countReference uop) (=== (collapse (get-atoms &ntReference)) ())) True)

!(assertEqual (let $_  (calcMaxNtReference &expandedGrammar &ntReference &ntCount &countReference uop) (=== (collapse (get-atoms &countReference)) ())) True)

;; Test applyCalcMaxNtReference
!(assertEqual (applyCalcMaxNtReference (&expandedGrammar &ntReference &ntCount &countReference) (expr_0 start expr term uop bop)) (start expr term uop bop))

!(assertEqual (let $_ (applyCalcMaxNtReference (&expandedGrammar &ntReference &ntCount &countReference) (expr_0 start expr term uop bop)) (=== (collapse (get-atoms &ntReference)) ((term expr_0)))) True)

!(clearSpace (superpose (&ntReference &countReference)))

;; INFO: This line here is added because the next test cases depend on a result being present in the spaces defined.
!(until isUnit ((curry applyCalcMaxNtReference) (&expandedGrammar &ntReference &ntCount &countReference)) (collapse (unique (match &expandedGrammar ($nt $rhs $i) $nt))))

;; Test maxRefPerProd
!(assertEqual (maxRefPerProd &ntReference &countReference expr) 1)
!(assertEqual (maxRefPerProd &ntReference &countReference expr_0) 2)
!(assertEqualToResult (maxRefPerProd &ntReference &countReference term) (2 1))

;; Test upperBounds

!(assertEqual (upperBounds &ntReference &countReference expr) (expr 1))
!(assertEqual (upperBounds &ntReference &countReference expr_0) (expr_0 2))
!(assertEqual (upperBounds &ntReference &countReference term) (term 3))

!(clearSpace (superpose (&ntReference &countReference)))

;; Test recombine

! (assertEqual 
    (recombine ((0) (0 1) (0 1 0 1) (0 2 1)) ((1) (1 0) (0 0 0 1) (2 3 1)) (0 0 1 1))
        (((0) (0 1) (0 0 0 1) (2 3 1)) ((1) (1 0) (0 1 0 1) (0 2 1))))

! (assertEqual 
    (recombine ((0) (0 1) (0 1 0 1) (0 2 1)) ((1) (1 0) (0 0 0 1) (2 3 1)) (0 1 0 1))
        (((0) (1 0) (0 1 0 1) (2 3 1)) ((1) (0 1) (0 0 0 1) (0 2 1))))

;; Test mutate

;; confirmMutation 
;;        return true only if the number of changed genes is either 0 or 1
;;        Flattens the two gene lists, original and mutated, so that changes can be compared element by element

(: confirmMutation (-> Expression Expression Bool))
(= (confirmMutation $original $mutated)
    (let*
        (
            ($o_ (foldr ++ () $original))
            ($m_ (foldr ++ () $mutated))
            ($bool (compareElements $o_ $m_))
            ($n (count False $bool))
        )
        (or (== $n 1) (== $n 0))
    )
)

! (assertEqual 
  (confirmMutation ((0) (1 0 1) (1 1) (0) (1 0)) (mutate ((0) (1 0 1) (1 1) (0) (1 0)) &grammar))
    True)
! (assertEqual 
  (confirmMutation ((0) (1 1 1) (1 0) (0) (1 0)) (mutate ((0) (1 1 1) (1 0) (0) (1 0)) &grammar))
    True)