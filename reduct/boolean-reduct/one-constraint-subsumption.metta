;; A function to remove some subsumable selections from the point of application (POA).
;; Definitions: An AND node N commands every node which is a descendent of N's
;;                parent but which is neither N nor a descendent of N.
;;              A guard set of a POA is the set of literals in the POA.
;;              The command set of a node N is the union of the
;;                guard sets of the AND nodes in the tree which
;;                command N and which have guard sets containing
;;                only one constraint each,
;; Preconditions: The point of application (POA) is a non root AND node,
;;                 the POA's guard set contains constraint X and
;;                 the POA is commanded by a terminal AND node COM
;;                 whose guard set consists of the constraint X.
;; Action: The function removes the POA from it's parent if applied, else it returns the POA.
;;            In addition to the POA, this function also returns the updated parent.
;;            It also returns a boolean value corresponding to whether the transformation function
;;            is applied or not.
;; Example: input: POA ==> (AND E D), commandSet ==> (C D), parent ==> (OR (AND E D) C)
;;        : output: ((OR C) () True)
;;(: oneConstraintSubsume (-> Expression Expression Expression (Expression Expression Bool)))
(= (oneConstraintSubsume $parent $current $commandSet)
    ; (() (println! (DEBUG: One constraint inside: $parent $current $commandSet)))
  (trace! (DEBUG: OneconstraintSubsume inside: $parent $current $commandSet) 
  (if-decons-expr $current $head $tail 
    (let*
      (
        ; (() (println! (DEBUG: One constraint output: $parent $current $commandSet)))
        ($head (car-atom $current))
        ; (() (println! (DEBUG: HEad output: $head)))
        ($tail (cdr-atom $current))
      )
      (case $head
        (
          (OR ($parent $current False))
          (NOT ($parent $current False))
          (AND
            (let*
              (
                ($guardSet (getGuardSet $current))
                ; ($common (customIntersection $guardSet $commandSet))
                ($common (collapse (intersection (superpose $guardSet) (superpose $commandSet))))
                ; (() (println! (DEBUG: Common output: $common)))
              )
              (if (== $common ()) ($parent $current False) ((removeElement ($current) $parent) () True)) ;; remove current from parent.
            )
          )
          ($else ($parent $current False))
        )
      )
   )
  ($parent $current False)
  )
)
)
