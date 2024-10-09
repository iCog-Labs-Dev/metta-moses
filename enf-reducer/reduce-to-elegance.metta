(: reduceToElegance (-> Tree Tree (List Tree) (List Tree) (Tree Tree Signal)))
(= (reduceToElegance $_ NilNode $dominantSet $commandSet) (NilNode NilNode NONE))
(= (reduceToElegance $parent (TreeNode (Value $value $constraint $type) $guardSet $children) $dominantSet $commandSet) 
  (case $type
    (
      (AND
        (let* 
          (
            ($currentTree (TreeNode (Value $value $constraint $type) $guardSet $children))
            ;; Apply Redundant to current
            ($updatedGuardSet (setDifference treeIsMember $guardSet $dominantSet Nil))

            ;; Apply 1-Constraint-Complement-Subtraction
            ($finalGuardSet (setDifference treeIsMember $updatedGuardSet $commandSet Nil))

            ($currentHasNoChild (== (length $children) 0))
            ($currentHasNoGuardSet (== (length $finalGuardSet) 0))
            ($updatedCurrentTree (TreeNode (Value $value $constraint $type) $finalGuardSet $children))
            ($fstUpdatedParent (replaceChildren $parent (findAndReplace $currentTree $updatedCurrentTree (getChildren $parent))))

            (() (println! (Inside RTE AND case currentHasNoChild ==> $currentHasNoChild currentHasNoGuardSet ==> $currentHasNoGuardSet finalGuardSet ==> $finalGuardSet commandSet ==> $commandSet)))
          )
          (if (and $currentHasNoChild $currentHasNoGuardSet)
              ($fstUpdatedParent $updatedCurrentTree DISCONNECT)
              (let $resultSet (setIntersection treeIsMember $guardSet $commandSet)
                  (if (~= (length $resultSet) 0)
                      ($fstUpdatedParent $updatedCurrentTree DELETE)
                      (let*
                        (
                          ;; (() (println! (inside RTE before iterator updatedCurrentTree ==> $updatedCurrentTree dominantSet ==> $dominantSet commandSet ==> $commandSet)))
                          (($finalUpdatedCurrent $signal) (iterator $updatedCurrentTree $dominantSet $commandSet))
                          ($finalUpdatedParent (replaceChildren $fstUpdatedParent (findAndReplace $updatedCurrentTree $finalUpdatedCurrent (getChildren $fstUpdatedParent))))
                        )
                        (if (~= $signal NONE)
                          ($finalUpdatedParent $finalUpdatedCurrent $signal)

                          ;; Determine if current is a site for 0-Subsumption
                          (if (and (== (length (getChildren $finalUpdatedCurrent)) 0) (== (length $finalGuardSet) 0))
                              ($finalUpdatedParent $finalUpdatedCurrent DISCONNECT) 
                              ($finalUpdatedParent $finalUpdatedCurrent KEEP)
                          )
                        )
                      )
                  )
              )
          )
        )
      )
      (OR
        (let*
          (
            (() (println! (Inside RTE Or case)))

            ($currentTree (TreeNode (Value $value $constraint $type) $guardSet $children))
            ($commonToAllChildren (intersections $children))
          )
          (if (> (length $commonToAllChildren) 0) 
              (let*
                (
                  ($updatedParent (replaceGuardSet $parent ((getGuardSet $parent) ++ $commonToAllChildren)))
                  ($updatedCurrent (replaceChildren $currentTree (mapChild updateGuardSet $commonToAllChildren $children)))
                  ($finalUpdatedParent (replaceChildren $updatedParent (findAndReplace $currentTree $updatedCurrent (getChildren $updatedParent))))
                )
                ($finalUpdatedParent $updatedCurrent RESET)
              )
              (if (> (length $children) 0)
                  (let* 
                    (
                     (($updatedCurrent $signal) (orSubTreeIterator $children $currentTree $dominantSet $commandSet 0))
                     ($finalUpdatedParent (replaceChildren $parent (findAndReplace $currentTree $updatedCurrent (getChildren $parent))))
                    )
                    (if (~= $signal NONE)
                        ($finalUpdatedParent $updatedCurrent $signal)
                        ($finalUpdatedParent $updatedCurrent KEEP)
                    )
                  )
                  ($parent $currentTree KEEP)
              )
          )
        )
      )
    )
  )
)
