;; Structured grammatical evolution (SGE)
;; This implementation is based on the research paper: https://link.springer.com/article/10.1007/s10710-015-9262-4

;; Grammar Chosen: Boolean expressions
;; <start> -> <expr>
;; <expr>  -> <bop> <expr> <expr> |
;;            <bop> <term> <expr> |
;;            <bop> <term> <term> |
;;            <uop> <expr> |
;;            <uop> <term>
;; <bop>   -> AND | OR
;; <uop>   -> NOT

;; TODO: Algorithm to calculate non terminal references.
;; TODO: Algorithm to calculate the maximum number of expansions per non terminal.
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

!(add-reduct &grammar (superpose (
  (start expr 0)
  (expr (bop expr expr) 0)
  (expr (uop expr) 1)
  (expr term 2)
  (bop AND 0)
  (bop OR 1)
  (uop NOT 0)

  ;; TODO: Automate insertion.
  (term X 0)
  (term Y 1)
  ))
)


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
;; FIX: Make sure index's order is sequential.
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
        ($updatedRRules (if (~= $rrules (())) (collapse (expandRule $depth (superpose $rrules))) ()))
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
