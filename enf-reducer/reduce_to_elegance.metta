;!(register-module! ../../metta-moses-reduction)
;; !(import! &self metta-moses-reduction:enf-reducer:RTEHelpers)
;; !(import! &self metta-moses-reduction:utilities:tree-helpers)
;; !(import! &self metta-moses-reduction:utilities:list-helpers)
;; !(import! &self metta-moses-reduction:types)
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
          (let () (println! (Inside RTE AND case currentHasNoChild ==> $currentHasNoChild currentHasNoGuardSet ==> $currentHasNoGuardSet finalGuardSet ==> $finalGuardSet commandSet ==> $commandSet))
          (if (and $currentHasNoChild $currentHasNoGuardSet)
                ($updatedCurrentTree DISCONNECT)
                (let $resultSet (treeIntersection $finalGuardSet $commandSet)
                    (if (not (== (length $resultSet) 0))
                        ($updatedCurrentTree DELETE)
                        ;; The action defined below is used to simulate the output of the iteractor function call
                        ;;(let () (println! (inside RTE before iterator updatedCurrentTree ==> $updatedCurrentTree dominantSet ==> $dominantSet commandSet ==> $commandSet))
                        (let ($finTree $action) (iterator $updatedCurrentTree $dominantSet $commandSet)
                          (if (not (== $action NONE))
                            ($finTree $action)

                            ;; Determine if current is a site for 0-Subsumption
                            (if (and (== (length $children) 0) (== (length $finalGuardSet) 0))
                                ($finTree DISCONNECT) 
                                ($finTree KEEP)
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
        (let $currentTree (TreeNode (Value $value $constraint $type) $guardSet $children)
          (let () (println! (Inside RTE Or case))
          (if (> (length $children) 0)
            ;;The action defined below is used to simulate the output of the orSubTreeIterator function call
            (let ($orTree $action) (orSubTreeIterator (headOfChildren $children) (tail $children) $currentTree $dominantSet $commandSet)
              ;;(let () (pritnln!  (This is the orTree ==> $orTree))
                (if (not (== $action NONE))
                    ($orTree $action)
                    ($orTree KEEP)
                )
              ;;)
            )
               ($currentTree KEEP)
            )
            
            
          )
        )
        )
      )
    )
  )



