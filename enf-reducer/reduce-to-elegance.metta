;!(register-module! ../../metta-moses-reduction)
;; !(import! &self metta-moses-reduction:enf-reducer:rte-helpers)
;; !(import! &self metta-moses-reduction:utilities:tree-helpers)
;; !(import! &self metta-moses-reduction:utilities:list-helpers)
;; !(import! &self metta-moses-reduction:types)

(: reduceToElegance (-> Tree Tree (List Tree) (List Tree) (Tree Tree Signal)))
(= (reduceToElegance $_ NilNode $dominantSet $commandSet) (NilNode NONE))
(= (reduceToElegance $parent (TreeNode (Value $value $constraint $type) $guardSet $children) $dominantSet $commandSet) 
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
          (let () (println! (Inside RTE AND case currentHasNoChild ==> $currentHasNoChild currentHasNoGuardSet ==> $currentHasNoGuardSet finalGuardSet ==> $finalGuardSet commandSet ==> $commandSet))
          (if (and $currentHasNoChild $currentHasNoGuardSet)
                ($parent $updatedCurrentTree DISCONNECT)
                (let $resultSet (treeIntersection $guardSet $commandSet)
                    (if (~= (length $resultSet) 0)
                        ($parent $updatedCurrentTree DELETE)
                        ;; The action defined below is used to simulate the output of the iteractor function call
                        ;;(let () (println! (inside RTE before iterator updatedCurrentTree ==> $updatedCurrentTree dominantSet ==> $dominantSet commandSet ==> $commandSet))
                        (let ($finalUpdatedCurrent $action) (iterator $updatedCurrentTree $dominantSet $commandSet)
                          (if (~= $action NONE)
                            ($updatedParent $finalUpdatedCurrent $action)

                            ;; Determine if current is a site for 0-Subsumption
                            (if (and (== (length $children) 0) (== (length $finalGuardSet) 0))
                                ($updatedParent $finalUpdatedCurrent DISCONNECT) 
                                ($updatedParent $finalUpdatedCurrent KEEP)
                            )
                          )
                        )
                    ;;)
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
                )
                ($updatedParent $updatedCurrent RESET)
              )
              (if (> (length $children) 0)
                  (let ($updatedParent $updatedCurrent $action) (orSubTreeIterator $children $currentTree $dominantSet $commandSet 0)
                    (if (~= $action NONE)
                        ($updatedParent $updatedCurrent $action)
                        ($updatedParent $updatedCurrent KEEP)
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
