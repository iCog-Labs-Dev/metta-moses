;; A function to remove a point of application (POA) if its handle set is inconsistent.
;; Definitions: A handle set of a POA is the union of it's dominant set and guard set.
;;              A dominant set of a POA is the set of guardSets of AND nodes found 
;;                on the path from the root to the POA (POA not included).
;;              A guard set of a POA is the set of literals in the POA.
;;              An inconsistent handle is one which contains both a literal
;;                and its negagtion.
;; Preconditions: The point of application (POA) is AND node and 
;;                its handle set is inconsistent.
;; Action: The function returns an empty expression if applied, else it returns the POA.
;;         Returning an empty expression corresponds to deleting the POA.
;; Example: input: POA ==> (AND (NOT A) (OR B C)), dominantSet ==> (A)
;;        : output: ()
(= (deleteInconsistent $exp)
    (let*
        (
          ($guardSet (getGuardSetExp $exp))
          ($isConsistent (isConsistentExp $guardSet))
        )
        (if $isConsistent $exp ())
    )
)


;; A function to check if a given set of literals is consistent or not.
;; Example: input: (A B C), output: True
;;          input: (A B C (NOT A)), output: True
(= (isConsistentExp $exp)
    (let $guardSet (getGuardSetExp $exp)
        (if (== $guardSet ())
            True
            (let*
              (
                ($pairs (collapse ( (superpose $guardSet) (superpose $guardSet))))
                ($result (collapse (areNegations (superpose $pairs)))))
              (if (isMember True $result)
                  False
                  True
              )
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
