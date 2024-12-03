! (register-module! ../../metta-moses)
! (import! &self metta-moses:utilities:general-helpers)

;; Structured grammatical evolution (SGE)
;; This implementation is based on the research paper: https://link.springer.com/article/10.1007/s10710-015-9262-4

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

!(add-reduct &grammar (superpose (
  ;; (start expr 0)
  (expr (bop expr expr) 0)
  (expr (bop term expr) 1)
  (expr (bop term term) 2)
  (expr (uop expr) 3)
  (expr (uop term) 4)
  (bop AND 0)
  (bop OR 1)
  (uop NOT 0)
  (uop (uop term) 1)
  (term X 0)
  (term Y 1)))
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


(= (expandRule $depth $lhs $grammarSpace)
   (let*
      (
        ($rhs (collapse (match $grammarSpace ($lhs $rhs $i) $rhs)))
        ($rrhs (collapse (filter ((curry isMember) $lhs) $rhs)))
        (($oneRhs $i) (rhsIndexPair (superpose $rrhs) $grammarSpace))
        ($newRhs ((map ((curry updateRule) ($depth expr)) $oneRhs) $i))
        ($oldRules ($lhs $oneRhs $i))
        ($newRules (cons-atom ($lhs $depth) $newRhs))
        (() (add-reduct $grammarSpace $newRules))
        (() (remove-atom $grammarSpace $oldRules))
        ) ;; Filtered Recursive RHS
      ()))

;; Helper function to be used in the map function of updating a rule.
;; It takes a target and current non terminal and replaces the non terminal with new value.
(= (updateRule ($depth $targetNT) $currentNT) (if (== $currentNT $targetNT) ($currentNT $depth) $currentNT))

(= (rhsIndexPair $rhs $grammarSpace) ($rhs (match $grammarSpace ($lhs $rhs $i) $i)))

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

;; A trick to define `curry` in MeTTa without `lambda`
(: curry (-> (-> $a $b $c) (-> $a (-> $b $c))))
(= (((curry $f) $x) $y) ($f $x $y))

;; !(((curry isMember) H) (A B H))
;; !(filter ((curry isMember) H) ((A B) (A B) (A H)))
!(get-atoms &grammar)
!(expandRule 0 (superpose (expr uop bop start)) &grammar)
!(get-atoms &grammar)
;; !(updateRule (0 expr) expr)
;; !(map ((curry updateRule) (0 expr)) (bop expr expr))
