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
;; Action: The function returns an empty expression if applied, else it returns the POA.
;;            It also a boolean value corresponding to whether the transformation function
;;            is applied or not.
;;         Returning an empty expression corresponds to deleting the POA.
;; Example: input: POA ==> (AND E D), commandSet ==> (C D)
;;        : output: ()
;;(: oneConstraintSubsume (-> Expression Expression (Expression Bool)))
(= (oneConstraintSubsume $exp $commandSet)
   (let*
      (
        ($head (car-atom $exp))
        ($tail (cdr-atom $exp))
      )
      (case $head
        (
          (OR ($exp False))
          (NOT ($exp False))
          (AND
            (let*
              (
                ($guardSet (getGuardSet $exp))
                ($common (collapse (intersection (superpose $guardSet) (superpose $commandSet))))
              )
              (if (== $common ()) ($exp False) (() True))
            )
          )
          ($else ($exp False))
        )
      )
   )
)
