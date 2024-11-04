;; A function to remove some subsumable selecctions from the point of application (POA).
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
;;         Returning an empty expression corresponds to deleting the POA.
;; Example: input: POA ==> (AND E D), commandSet ==> (C D)
;;        : output: ()
(= (oneConstraintSubsume $expOriginal $expRecursive $commandSet)
    (if (== $expRecursive ())
        $expOriginal
        (let*
          (
            ($head (car-atom $expRecursive))
            ($tail (cdr-atom $expRecursive))
          )
          (case $head
            (
              (OR $expOriginal)
              (NOT $expOriginal)
              (AND (oneConstraintSubsume $expOriginal $tail $commandSet)) ;; The POA of this transformation is any non-root AND node
              ($else (if (isMember $head $commandSet) () (oneConstraintSubsume $expOriginal $tail $commandSet))) ;; If any constraint of the AND node is found inside the commandSet, the node is removed. if not, it is kept.
            )
          )
        )
    )
)


