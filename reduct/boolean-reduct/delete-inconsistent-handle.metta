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
          ($guardSet     (getGuardSet $current))
          ($handleSet    (concatTuple $dominantSet $guardSet))
          ($isConsistent (isConsistentExp $handleSet))
          ; ($_ (println! (===Inside DeleteInconsistentHandle===)))
          ; ($_ (println! (Parameters ==> Parent: $parent Current: $current DominantSet: $dominantSet)))
          ; ($_ (println! (GuardSet : $guardSet : HandleSet : $handleSet : IsConsistent : $isConsistent)))
        )
        (if $isConsistent
              ($parent $current False)
              (if (== $parent $current) ;; If the initial parent itself is in consistent, we don't want to delete it entirely but instead keep a top level AND. This only happens when passing the expression for the first time as $parent and $current will never be equal after that.
                  ((AND) () True)
                  ((subtraction-atom $parent ($current)) () True)
              )) ;; Remove current from parent and return an empty AND.
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
          (if (is-member True $result)
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
; (: applyDeleteIncons (-> Expression Expression Expression (Expression Expression Bool)))
(= (applyDeleteIncons $parent $current $dominantSet)
    (let*
        (
            ; ($_ (println! (==== Inside applyDeleteIncons ====)))
            ; ($_ (println! (Parameters ==> Parent: $parent Current: $current DominantSet: $dominantSet)))
            (($newParent $newCurrent $applied) (deleteInconsistentHandle $parent $current $dominantSet))
            ($children (getChildrenExp $newCurrent))
            ; ($_ (println! (Children: $children)))            
        )
        (if (== $children ())
            ($newParent $newCurrent $applied)
            (let*
                (
                    ; ($_ (println! ("Applying DeleteIncons on children...")))
                    (($child $rest) (decons-atom $children))
                    ; ($_ (println! (Child: $child Rest: $rest)))
                    ($grandChild (getChildrenExp $child))
                    ; ($_ (println! (GrandChild: $grandChild)))
                    (($UpdatedChildren $unwt $appliedOnChild)
                                        (if (== $grandChild ())
                                          ($child () False)
                                          (let ($h $t) (decons-atom $grandChild)
                                               (applyDeleteIncons6 $child $h $dominantSet $t $applied True)
                                          )
                                        )
                    )
                    ; ($_ (println! (UpdatedChildren: $UpdatedChildren)))
                    (($updatedCurrent $updatedchild $appliedOnCurrent) (if (=== $child $UpdatedChildren) (deleteInconsistentHandle $newCurrent $child $dominantSet) ((findAndReplace $child $UpdatedChildren $newCurrent) $UpdatedChildren $appliedOnChild)))
                    ($updatedParent (findAndReplace $newCurrent $updatedCurrent $newParent))
                    ; ($_ (println! (Updated Parent: $updatedParent : UpdatedCurrent: $updatedCurrent Bool: (any $appliedOnCurrent $appliedOnChild $applied) )))
                )
                ; (applyDeleteIncons $updatedParent $updatedCurrent $dominantSet (any ($appliedOnCurrent $appliedOnChild $applied)) $rest)
                (applyDeleteIncons5 $updatedParent $updatedCurrent $dominantSet $appliedOnCurrent $rest)
            )    
        )
    )
)

; (: applyDeleteIncons (-> Expression Expression Expression Bool Expression (Expression Expression Bool)))
(= (applyDeleteIncons5 $parent $current $dominantSet $applied $children)   
    (if (== $children ())
        ($parent $current $applied)
        (let*
          (
              ; ($_ (println! (Applying DeleteIncons on children...)))
              ; ($_ (println! (Parameters: Parent: $parent : Current: $current : DominantSet: $dominantSet)))
              ; ($_ (println! (Children: $children)))
              (($child $rest) (decons-atom $children))
              (($updatedCurrent $_ $bool) (deleteInconsistentHandle $current $child $dominantSet))
              ($updatedParent (findAndReplace $current $updatedCurrent $parent))
              ; ($_ (println! (UpdatedParent: $updatedParent : UpdatedCurrent: $updatedCurrent Bool: $bool)))
          )
          (applyDeleteIncons5 $updatedParent $updatedCurrent $dominantSet $applied $rest)
      )
    )
)

; (: applyDeleteIncons (-> Expression Expression Expression Expression Bool Bool (Expression Expression Bool)))
(= (applyDeleteIncons6 $parent $current $dominantSet $children $appliedToParent $checkingChild)
    (if (== $children ())
        (deleteInconsistentHandle $parent $current $dominantSet)
        (let*
              (
                  ; ($_ (println! (Applying DeleteIncons on nested children...)))
                ;   ($_ (println! (Parameters: Parent: $parent : Current: $current : DominantSet: $dominantSet)))
                  (($child $rest) (decons-atom $children))
                  (($updatedCurrent $_ $bool) (deleteInconsistentHandle $current $child $dominantSet))
                  ($updatedParent (findAndReplace $current $updatedCurrent $parent))
                ; ($_ (println! (UpdatedParent: $updatedParent : UpdatedCurrent: $updatedCurrent Bool: $bool)))
              )
              (applyDeleteIncons5 $updatedParent $updatedCurrent $dominantSet $bool $rest)
        ))
)
