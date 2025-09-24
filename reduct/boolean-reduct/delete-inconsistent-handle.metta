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
        ;   (() (println! (===Inside DeleteInconsistentHandle===)))
        ;   (() (println! (Parameters ==> Parent: $parent Current: $current DominantSet: $dominantSet)))
        ;   (() (println! (GuardSet : $guardSet : HandleSet : $handleSet : IsConsistent : $isConsistent)))
        )
        (if $isConsistent 
              ($parent $current False) 
              ((findAndReplace $current (AND) $parent) (AND) True)) ;; Remove current from parent and return an empty AND.
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

;; This function is used to handle nested current expressions 
(: applyDeleteIncons (-> Expression Expression Expression (Expression Expression Bool)))
(= (applyDeleteIncons $parent $current $dominantSet)
    (let*
        (
            ; (()(println! (=== Inside applyDeleteIncons ===)))
            ; (()(println! (Parameters ==> Parent: $parent Current: $current DominantSet: $dominantSet)))
            (($newParent $newCurrent $applied) (deleteInconsistentHandle $parent $current $dominantSet))
            ($children (getChildrenExp $newCurrent))
            ; (() (println! (Children: $children)))
        )
        (if (== $children ())
            ($newParent $newCurrent $applied)
            ; (deleteInconsistentHandle $parent $current $dominantSet)
            (let*
                (
                    ; (() (println! (Applying DeleteIncons on children...)))
                    (($child $rest) (decons-atom $children))
                    ; (() (println! (Child: $child Rest: $rest)))
                    ($grandChild (getChildrenExp $child))
                    (($UpdatedChildren $unwt $appliedOnChild)
                                        (if (== $grandChild ())
                                          ($child () False)
                                          (let ($h $t) (decons-atom $grandChild)
                                               (applyDeleteIncons $child $h $dominantSet $t $applied True)
                                          )
                                        )
                    )
                    ; (() (println! (UpdatedChildren: $UpdatedChildren)))
                    (($updatedCurrent $updatedchild $appliedOnCurrent) (if (=== $child $UpdatedChildren) (deleteInconsistentHandle $newCurrent $child $dominantSet) ((findAndReplace $child $UpdatedChildren $newCurrent) $UpdatedChildren $appliedOnChild)))
                    ($updatedParent (findAndReplace $newCurrent $updatedCurrent $newParent))
                    ; (()(println! (Updated Parent: $UpdatedParent : UpdatedCurrent: $updatedCurrent Bool: (any $appliedOnCurrent $appliedOnChild $applied) )))
                )
                (applyDeleteIncons $UpdatedParent $updatedCurrent $dominantSet (any ($appliedOnCurrent $appliedOnChild $applied)) $rest)
            )    
        )
    )
)

(: applyDeleteIncons (-> Expression Expression Expression Bool Expression (Expression Expression Bool)))
(= (applyDeleteIncons $parent $current $dominantSet $applied $children)   
    (if (== $children ())
        ($parent $current $applied)
        (let*
          (
            ;   (() (println! (Applying DeleteIncons on children...)))
            ;   (() (println! (Parameters: Parent: $parent : Current: $current : DominantSet: $dominantSet)))
            ;   (() (println! (Children: $children)))
              (($child $rest) (decons-atom $children))
              (($updatedCurrent $_ $bool) (deleteInconsistentHandle $current $child $dominantSet))
              ($updatedParent (findAndReplace $current $updatedCurrent $parent))
            ;   (()(println! (UpdatedParent: $updatedParent : UpdatedCurrent: $updatedCurrent Bool: $bool)))
          )
          (applyDeleteIncons $updatedParent $updatedCurrent $dominantSet $applied $rest)
      )
    )
)

(: applyDeleteIncons (-> Expression Expression Expression Expression Bool Bool (Expression Expression Bool)))
(= (applyDeleteIncons $parent $current $dominantSet $children $appliedToParent $checkingChild)
    (if (== $children ())
        (deleteInconsistentHandle $parent $current $dominantSet)
        (let*
              (
                ;   (() (println! (Applying DeleteIncons on nested children...)))
                ;   (() (println! (Parameters: Parent: $parent : Current: $current : DominantSet: $dominantSet)))
                  (($child $rest) (decons-atom $children))
                  (($updatedCurrent $_ $bool) (deleteInconsistentHandle $current $child $dominantSet))
                  ($updatedParent (findAndReplace $current $updatedCurrent $parent))
                ;   (()(println! (UpdatedParent: $updatedParent : UpdatedCurrent: $updatedCurrent Bool: $bool)))
              )
              (applyDeleteIncons $updatedParent $updatedCurrent $dominantSet $bool $rest)
        ))
)