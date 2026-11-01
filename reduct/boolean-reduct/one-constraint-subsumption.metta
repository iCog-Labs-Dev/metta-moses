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
    ;; Constants are inert: car-atom over a Symbol yields no solution, a silent failure.
    (if (or (== $current ()) (or (isConstant $current) (isConstant $parent)))
      ($parent $current False)
      
        
          (let*
            (
              ;; ($_ (println! (===Inside OneConstraintSubsume===)))
              ; ($_ (println! (Parent: $parent Current: $current CommandSet: $commandSet)))
              ($head (car-atom $current))
              ($tail (cdr-atom $current))
              ; ($_ (println! (Head : $head : Tail : $tail)))  
            )
            (case $head
          
              (
                (OR ($parent $current False))
                (NOT ($parent $current False))
                (AND
                  (let*
                    (
                      ($guardSet (getGuardSet $current))
                      ($common (intersection-atom $guardSet $commandSet))
                    )
                    (if (== $common ())
                        ;; (trace! (Parent: $parent : Current : $current)
                                ($parent $current False)
                        ;; )
                        ;; 1-Subsume is ABSORPTION, not a truth: classic returns Delete on a
                        ;; non-empty intersection with the command set (logical_rules.cc:653).
                        ;; Reading it as TRUE makes (OR (AND A B) A B) true where the answer
                        ;; is A v B -- measured at -49 trees. The TRUE case is 0-Subsume, at
                        ;; :652, where the guard set is EMPTIED.
((removeElement ($current) $parent) () True)) ;; remove current from parent.
                  )
                )
                ($else ($parent $current False))
              )
            )
        )

      
))

