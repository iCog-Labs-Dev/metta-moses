(: getSignal (-> Signal Signal))
(= (getSignal $signal) $signal)

(: reduceToElegance (-> Tree (List Tree) (List Tree) (Tree Signal)))
(= (reduceToElegance NilNode $dominantSet $commandSet) (NilNode NONE))
(= (reduceToElegance (TreeNode (Value $value $constraint $type) $guardSet $children) $dominantSet $commandSet) 
  (case $type
    (
      (AND
        (let* 
          (
            ;; Apply Redundant to current
            ($updatedGuardSet (setDifference treeIsMember $guardSet $dominantSet Nil))

            ;; Apply 1-Constraint-Complement-Subtraction
            ($finalGuardSet (setDifference treeIsMember $updatedGuardSet $commandSet Nil))

            ($currentHasNoChild (== (length $children) 0))
            ($currentHasNoGuardSet (== (length $finalGuardSet) 0))
            ($updatedCurrentTree (TreeNode (Value $value $constraint $type) $finalGuardSet $children))
          )
          (if (and $currentHasNoChild $currentHasNoGuardSet)
                ($updatedCurrentTree DISCONNECT)
                (let $resultSet (treeIntersection $finalGuardSet $commandSet)
                    (if (not (== (length $resultSet) 0))
                        ($updatedCurrentTree DELETE)
                        ;; The action defined below is used to simulate the output of the iteractor function call
                        (let $action DISCONNECT 
                          (if (not (== $action NONE))
                            ($updatedCurrentTree $action)

                            ;; Determine if current is a site for 0-Subsumption
                            (if (and (== (length $children) 0) (== (length $finalGuardSet) 0))
                                ($updatedCurrentTree DISCONNECT) 
                                ($updatedCurrentTree KEEP)
                            )
                          )
                        )
                    )
                )
            )
        )
      )
      (OR
        (let $currentTree (TreeNode (Value $value $constraint $type) $guardSet $children)
          (if (> (length $children) 0)
            ;; The action defined below is used to simulate the output of the orSubTreeIterator function call
            (let $action DISCONNECT
              (if (not (== $action NONE))
                  ($currentTree $action)
                  ($currentTree KEEP)
              )
            )
            ($currentTree KEEP)
          )
        )
      )
    )
  )
)
