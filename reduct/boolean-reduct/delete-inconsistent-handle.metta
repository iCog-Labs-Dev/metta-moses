;; A function to remove a point of application (POA) if its handle set is inconsistent.
;; Definitions: A handle set of a POA is the union of it's dominant set and guard set.
;;              A dominant set of a POA is the set of guardSets of AND nodes found 
;;                on the path from the root to the POA (POA not included).
;;              A guard set of a POA is the set of literals in the POA.
;;              An inconsistent handle is one which contains both a literal
;;                and its negagtion.
;; Preconditions: The point of application (POA) is AND node and
;;                its handle set is inconsistent.
;; Action: The function removes the POA and updates the parent.
;;            It then returns the updated parent, an empty expression and
;;            a boolean value of True if applied.
;; Example: input: POA ==> (AND (NOT A) (OR B C)), dominantSet ==> (A), parent ==> (OR B (AND (NOT A) (OR B C)))
;;        : output: ((OR B) () True)
;; (: deleteInconsistentHandle (-> Expression Expression Expression (Expression Expression Bool)))
(= (deleteInconsistentHandle $parent $current $dominantSet)
    (let*
        (
          ($guardSet (getGuardSet $current))
          ($handleSet (concatTuple $dominantSet $guardSet))
          ($isConsistent (isConsistentExp $handleSet))
        )
        (if $isConsistent ($parent $current False) ((removeElement ($current) $parent) () True)) ;; Remove current from parent.
    )
)


;; A function to check if a given set of literals is consistent or not.
;; Example: input: (A B C), output: True
;;          input: (A B C (NOT A)), output: True
(= (isConsistentExp $handleSet)
    (if (== $handleSet ())
        True
        (let*
          (
            ($pairs (collapse ((superpose $handleSet) (superpose $handleSet))))
            ($result (collapse (areNegations (superpose $pairs)))))
          (if (isMember True $result)
              False
              True
          )
        )
    )
)


;; A helper function that takes a pair of boolean expressions
;;  and checks if one is the negation of the other.
;; Example: input: (A (NOT B)), output: False
;;          input: (A (NOT A)), output: True
;;          input: ((NOT B) B), output: True
(= (areNegations ($a $b))
     (or (== $a (NOT $b)) (== $b (NOT $a)))
)
