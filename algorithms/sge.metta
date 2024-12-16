! (register-module! ../../metta-moses)
! (import! &self metta-moses:utilities:general-helpers)

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


;; TODO: Algorithm to expand the grammar based on depth.
;;       Stpes to follow:
;;            - Start with the unique non terminal symbols.
;;            - Decide whether to expand the non terminal or not.
;;                This is done checking if the LHS is present in the RHS.
;;            - If present and depth is greater than 0, duplicate the rule
;;                  and rename the non terminal with the same name but different
;;                  index so that it will be treated as a new non terminal.
;;            - Repeat the above step until the depth is zero. For each iteration,
;;                  the index will be incremented to insure the uniqueness of the non terminal.
;;            - Repeat the above steps for all non terminals.


;; Start with a single non terminal to be expanded and it's corresponding depth.
;; Match all of it's RHS productions.
;; Filter out recursive production rules and non recursive ones and store them in different variables.
;; Until the depth isn't equal to the maximum depth, do the following:
;;    For each recursive rule:
;;        Replace every occurence of the lhs in the rhs with the lhs + depth.
;;        If depth is equal to 0, don't update the lhs in the new production rule.
;;            Add the new production rules; the unchanged lhs, the updated rhs and the non recursive rules.
;;        else, update the lhs to be lhs + (depth - 1)
;;            Add the new production rules; the updated lhs, the updated rhs and the non recursive rules.
;; When maximum depth has been reached, add one other additional rule:
;;      The lhs will be updated to lhs + (maxDepth - 1)
;;      The rhs will be updated as follows:
;;          Every recursive occurence of the lhs will be replaced with the non recursive rule.
;;          This is done in a way that all possible combinations of the non recursive rules
;;            and the lhs occurence is covered. Possible implementation is using a superposed
;;            version of the non recursive rules and then using those in place of the lhs occurence.
;;            This will generate all possible combinations.
;; Do this for all of the non terminals.

;; Function to expand every recursive rule in the grammar according to the depth.
;; FIX: Make sure index's order is sequential.
(= (expandGrammar $maxDepth $grammarSpace)
   (let $nts (unique (match $grammarSpace ($lhs $rhs $i) $lhs))
             (expandRecursiveNT $nts $maxDepth $grammarSpace)))

;; TODO: Add more details for this comment.
;; Function to expand a non terminal with recursive Rhs.
(= (expandRecursiveNT $nt $maxDepth $grammarSpace)
   (let $rRules (collapse (getRecursiveRules $nt $grammarSpace))
        (if (~= $rRules (()))
              (let*
                  (
                    ($nrRules (collapse (unique (getNonRecursiveRules $nt $grammarSpace))))
                    ($updatedNRRules (if (~= $nrRules ()) (collapse (getUpdatedNRRules (superpose $nrRules) $maxDepth)) ()))
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

(= (maxDepthNotReached ($nt $nextDepth $maxDepth $rRules $initialNRRules $grammarSpace)) (>= $nextDepth $maxDepth))

;; Start with a single non terminal to be expanded and it's corresponding depth.
;; Match all of it's RHS productions.
;; Filter out recursive production rules and non recursive ones and store them in different variables.
(= (applyExpandRules ($nt $depth $maxDepth $rRules $initialNRRules $grammarSpace))
   (let $_ (expandRules $depth $rRules $initialNRRules $grammarSpace)
           ($nt (+ $depth 1) $maxDepth $rRules $initialNRRules $grammarSpace)))

;; Given the depth, recursive rules, non recursive rules and the grammar space,
;;    this function will expand the given non terminal's production rules for a single depth.
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

;; Update one rule. The update is to replace every occerence of the lhs in the rhs with a new value of (lhs + depth)
;; It then updates the lhs too based on the depth.
(= (expandRule $depth ($lhs $rhs $i)) ((if (== $depth 0) $lhs ($lhs (- $depth 1))) (map ((curry expandMapHelper) ($depth $lhs)) $rhs) $i))

;; Helper function to be used in the map function of the expandRule function.
;; It takes a target and current non terminal and replaces the non terminal with new value.
(= (expandMapHelper ($depth $targetNT) $currentNT) (if (== $currentNT $targetNT) ($currentNT $depth) $currentNT))

;; Function to remove all recursive of a production rule by replacing the
;;    recursive call of the non terminal with the corresponding non recursive
;;    rules of the lhs.
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

;; Helper Function to search and remove the first recursive occerence of a production rule by replacing the
;;    the non terminal with the corresponding non recursive rules of the lhs.
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

;; Function to update the index of non recursive 
;;   production rules using the global state.
(= (getUpdatedNRRules ($lhs $rhs $i) $maxDepth)
    (let*
        (
          ($newIndex (get-state &lastIndex))
          ($_ (change-state! &lastIndex (+ $newIndex 1)))
          ($newLhs ($lhs (- $maxDepth 1)))
          ;; (() (println! (Index: $newIndex NewRule: (cons-atom $newLhs ($rhs $newIndex)))))
        )
        (cons-atom $newLhs ($rhs $newIndex))))

;; Function to filter out recursive production rules from grammarSpace.
(= (getRecursiveRules $nt $grammarSpace)
    (let*
      (
        ($rhss (collapse (match $grammarSpace ($nt $rhs $i) $rhs)))
        ($rrhss (collapse (filter ((curry isMember) $nt) $rhss)))
        ($ndRrhs (if (~= $rrhss ()) (superpose $rrhss) ())))
      (if (~= $rrhss ())
          (match $grammarSpace ($nt $ndRrhs $i) ($nt $ndRrhs $i))
          ())))

;; Function to filter out non recursive production rules from grammarSpace.
(= (getNonRecursiveRules $nt $grammarSpace)
   (subtraction
          (match $grammarSpace ($nt $rhs $i) ($nt $rhs $i))
          (getRecursiveRules $nt $grammarSpace)))

;; Function: wrapper
;; Description: This function applies a predicate to an atom and returns the atom if the predicate is true, otherwise returns an empty expression.
;; Parameters:
;;   - $predicate: A function that takes an atom and returns a boolean value.
;;   - $x: The atom to which the predicate is applied.
;; Returns:
;;   - Expression: Returns the atom if the predicate evaluates to true, otherwise returns an empty expression.
;; Logic:
;;   - The function uses an `if` construct to evaluate the predicate with the given atom.
;;   - If the predicate returns true, the atom is returned.
;;   - If the predicate returns false, an empty expression is returned.
(:wrapper (-> Atom Atom Expression))
(= (wrapper $predicate $x) (if ($predicate $x) $x (empty)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;; Function: filter
;; Description: This function filters elements of a list based on a given predicate.
;; Parameters:
;;   - $predicate: The predicate function to apply to each element of the list.
;;   - $list: The list of elements to be filtered.
;; Returns:
;;   - List: A new list containing only the elements that satisfy the predicate.
;; Logic:
;;   - The function uses the `wrapper` function to apply the predicate to each element of the list.
;;   - The `superpose` function is used to handle the list elements.

(:filter (-> Atom Expression Expression))
(= (filter $predicate $list) (
   wrapper $predicate (superpose $list))
)

(= (sum $list) (foldr + 0 $list))

;; Function to count atom occrence in a list of atoms.
(= (count $atom $list) (sum (collapse (if (== $atom (superpose $list)) 1 (empty)))))

(= (any $bools) (isMember True $bools))

(= (=== $x $y)
   (if (and (== (get-metatype $x) Symbol) (== (get-metatype $y) Symbol))
       (== $x $y)
       (== (collapse (union (subtraction (superpose $x) (superpose $y)) (subtraction (superpose $y) (superpose $x)))) ())))

;; Apply a given function to every element of a tuple
(: map (-> (-> $a $b) $c $d))
(= (map $f $xs)
   (if (== $xs ())
       ()
       (let* (($h (car-atom $xs))
              ($t (cdr-atom $xs))
              ($fh ($f $h))
              ($ft (map $f $t)))
         (cons-atom $fh $ft))))

;; Fold a tuple from right to left
(: foldr (-> (-> $a $b $b) $b $c $d))
(= (foldr $f $i $xs)
   (if (== $xs ())
       $i
       (let* (($h (car-atom $xs))
              ($t (cdr-atom $xs))
              ($ft (foldr $f $i $t)))
         ($f $h $ft))))

;; A trick to define `curry` in MeTTa without `lambda`
(: curry (-> (-> $a $b $c) (-> $a (-> $b $c))))
(= (((curry $f) $x) $y) ($f $x $y))

;; !(expandRule 0 (expr (bop term expr) 0))
;; !(expandRule 0 (expr (bop term expr) 1))
;; !(expandRule 1 (expr (bop expr expr) 2))
;; ;; !(expandRule 1 (expr (bop expr expr) 3))

;; !(get-atoms &grammar)

;; !(expandRules 0
;;               (collapse (let $rhs (filter ((curry isMember) expr) (collapse (match &grammar (expr $rhs $i) $rhs))) (match &grammar (expr $rhs $i) (expr $rhs $i))))
;;               (collapse (subtraction (match &grammar (expr $rhs $i) (expr $rhs $i)) (let $rhs (filter ((curry isMember) expr) (collapse (match &grammar (expr $rhs $i) $rhs))) (match &grammar (expr $rhs $i) (expr $rhs $i)))))
;;               &grammar)

;; !(get-atoms &grammar)
;; !(expandRules 1
;;               (collapse (getRecursiveRules expr &grammar))
;;               (collapse (getNonRecursiveRules expr &grammar))
;;               &grammar)

;; !(get-atoms &grammar)

;; !(until maxDepthNotReached applyExpandRules (expr 0 2 (collapse (getNonRecursiveRules expr &grammar)) &grammar))

;; !(get-atoms &grammar)

;; !(collapse (generatePermituationTuples 2 (((bop term term) 1) ((uop term) 2))))
;; !(collapse (let ($rule $number) (splitRuleIndexPair (generatePermituationTuples 2 (((bop term term) 1) ((uop term) 2)))) ($rule (+ 1 (sum $number)))))

;; !(removeRFromRule expr (bop expr expr) 1 (collapse (getNonRecursiveRules expr &grammar)) )
;; !(removeRFromRule expr (bop term term) 1 (((uop term) 1) ((bop term term) 2)))
;; !(removeRFromRule expr (bop expr expr) ((uop term) (bop term term)))
;; !(removeRFromRuleHelper expr (bop expr expr) ((uop term) (bop term term)))
;; !(let $result (removeRFromRuleHelper expr (bop expr expr) ((uop term) (bop term term))) (removeRFromRuleHelper expr $result ((uop term) (bop term term))))

;; !(=== A B)
;; !(=== A A)
;; !(=== () (A))
;; !(=== (A) () )
;; !(=== (A B) (A))
;; !(=== (A B) (A B))
;; !(=== (B A) (A B))
;; !(=== (B C D E A) (B C D E A))
;; !(=== (B C D E A) (C D A E B))
;; !(=== (B F D E A) (B C D E A))


;; !(count expr (bop expr expr bop bop expr x y a expr u expr z a))

;; !(sum (1 2 3 4 5 6 7 8 9 10))
;; !(sum (1 1 1 1))
;; !(sum (1))

;; !(expandRecursiveNT expr 3 &grammar)
;; !(get-atoms &grammar)

!(expandGrammar 3 &grammar)

;; !(collapse (unique (getNonRecursiveRules (superpose (expr start uop bop)) &grammar)))

;; !(getRecursiveRules start &grammar)

!(println! (get-atoms &grammar))

;; !(match &grammar ((uop 2) $rhs $i) ((uop 2) $rhs $i))
;; !(match &grammar (uop $rhs $i) (uop $rhs $i))

;; !(match &grammar ((bop $x) $rhs $i) ((bop $x) $rhs $i))
;; !(match &grammar (bop $rhs $i) (bop $rhs $i))

;; !(println! (match &grammar ((expr $x) $rhs $i) ((expr $x) $rhs $i)))

;; !(println! (match &grammar (expr $rhs $i) (expr $rhs $i)))
;; !(println! (match &grammar ((expr 1) $rhs $i) ((expr 1) $rhs $i)))
;; !(println! (match &grammar ((expr 2) $rhs $i) ((expr 2) $rhs $i)))
