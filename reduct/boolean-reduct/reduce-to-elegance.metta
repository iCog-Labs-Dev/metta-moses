;; TODO: Remove the following import statements
! (register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-or)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-and)
! (import! &self metta-moses:reduct:boolean-reduct:delete-inconsistent-handle)
! (import! &self metta-moses:reduct:boolean-reduct:zero-constraint-subsumption)
! (import! &self metta-moses:reduct:boolean-reduct:one-constraint-subsumption)
! (import! &self metta-moses:reduct:boolean-reduct:promote-common-constraints)

;; WARN: Or nodes are thought to have no guardSet in the previous implementation. In this one,
;;    OR nodes have their own guardSet and this could be an issue for the RTE algorithm. One possible solution is
;;    to treat both guardSet and children of OR nodes as children while the other is to refactor all literals into
;;    being inclosed in an AND node during the gather junctor algorithm implementation. The former is easier to implement
;;    but may raise some unfoceable issue in the future while the later has more work to implement but is more robust.

;;RTE should also return a boolean value to indicate any one of the transformations are applied.
(= (reduceToElegance $parent $current $dominantSet $commandSet)
   (case ((get-metatype $current) $current)
        (
          ((Symbol $symbol) ($parent $symbol False))
          ((Expression ()) ($parent $current False))
          ((Expression (NOT A)) ($parent $current False))
          ((Expression $current)
            (case (car-atom $current)
              (
                (AND
                  (let*
                    (
                      ($guardSet (getGuardSet $current))
                      ($children (getChildren $current))

                      ($updatedGuardSet (setDifference $guardSet $dominantSet)) ;; Apply Redundant to current
                      ($updatedGuardSet' (setDifference $updatedGuardSet $commandSet)) ;; Apply 1-Constraint-Complement-Subtraction
                      ($appliedRedundantOr1CC (or (== $updatedGuardSet $guardSet) (== $updatedGuardSet' $updatedGuardSet))) ;; Storing this state to return boolean indicating RTE is applied or not.

                      ($updatedSubExpression (concatTuple $updatedGuardSet' $children))
                      ($updatedCurrent (cons-atom AND $updatedSubExpression))
                      ($updatedParent (findAndReplace $current $updatedCurrent $parent))

                      (($zeroSubsumeParent $zeroSubsumeCurrent $appliedZeroSubsume) (zeroConstraintSubsume' $updatedParent $updatedCurrent)) ;; Apply 0-Subsume AND node variation
                      (($oneSubsumeParent $oneSubsumeCurrent $appliedOneSubsume) (oneConstraintSubsume $zeroSubsumeParent $zeroSubsumeCurrent $commandSet)) ;; Apply 1-Subsume.

                      ;; until no transformation is applied
                      ;;    compute dominantSet
                      ;;    deleteInconHandle.
                      ;;    andCut.
                      ;;    apply RTE on children.
                      ;; 0-Subsume Variation
                      (($_ $__ ($updatedParent' $updatedCurrent' $bool)) (until andTransformationsNotApplied applyAndTransformations ($commandSet $dominantSet ($oneSubsumeParent $oneSubsumeCurrent True))))
                      (($finalUpdatedParent $finalUpdatedCurrent $finalBool) (zeroConstraintSubsume' $updatedParent' $updatedCurrent'))
                    )
                    ($finalUpdatedParent $finalUpdatedCurrent (any ($appliedRedundantOr1CC $appliedZeroSubsume $appliedOneSubsume $bool $finalBool)))
                  )
                )
                (OR
                  (let*
                    (
                     (($promoteParent $promoteCurrent $appliedPromote) (promoteCommonConstraints $parent $current)) ;; Apply promote

                      ;;until no transformation is applied.
                      ;;    compute commandSet
                      ;;    0-Subsume
                      ;;    orCut
                      ;;    apply RTE on children.
                     (($_ $__ ($updatedParent $updatedCurrent $bool)) (until orTransformationsNotApplied applyOrTransformations ($commandSet $dominantSet ($promoteParent $promoteCurrent True))))
                    )
                    ($updatedParent $updatedCurrent (any ($bool $appliedPromote)))
                  )
                )
              )
            )
        )
      )
   )
)

;; A helper function to check if a transformation is applied or not given the state of the AND node transformations.
(: andTransformationsNotApplied (-> (Expression Expression (Expression Expression Bool)) Bool))
(= (andTransformationsNotApplied ($_ $__ ($parent $current $bool))) (not $bool))

;; A helper function to apply delInconHandle and andCut transformation functions.
;; It will also apply reduce to elegance algorithm on each of the children of the POA.
(: applyAndTransformations (-> (Expression Expression (Expression Expression Bool)) (Expression Expression Bool)))
(= (applyAndTransformations ($commandSet $dominantSet ($parent $current $_)))
   (let*
     (
        ($guardSet (getGuardSet $current))
        ($children (getChildren $current))
        ($handleSet (collapse (unique (union (superpose $guardSet) (superpose $dominantSet))))) ;; Compute new dominantSet
        (($delInconHandleParent $delInconHandleCurrent $appliedDelInconHandle) (deleteInconsistentHandle $parent $current $handleSet)) ;; Apply deleteInconHandle.
        (($andCutParent $andCutCurrent $appliedAndCut) (andCut $delInconHandleParent $delInconHandleCurrent)) ;; Apply andCut
     )
     (if (or $appliedDelInconHandle $appliedAndCut)
         ($commandSet $dominantSet ($andCutParent $andCutCurrent True)) ;; Returning the most up to date state.

         ;; Apply RTE on children
         (foldl reduceToElegance ($commandSet $handleSet ($parent $current False)) $children) ;; FIX: Make sure not to change the value of dominantSet  and commandSet
     )
   )
)

;; A helper function to apply reduceToElegance using foldl. It behaves like a lambda function.
;; This function is specific for the AND node case of the reduce to elegance function.
(: applyReduceToEleganceToAnd (-> Expression (Expression Expression (Expression Expression Bool))))
(= (applyReduceToEleganceToAnd $newCurrent ($commandSet $dominantSet ($parent $prevCurrent $bool)))
   ($commandSet $dominantSet (reduceToElegance $parent $newCurrent $dominantSet $commandSet))
)


;; A helper function to check if a transformation is applied or not given the state of the OR node transformations.
(: orTransformationsNotApplied (-> (Expression Expression (Expression Expression Bool) (Expression Expression)) Bool))
(= (orTransformationsNotApplied ($_ $__ ($parent $current $bool) ($currentChild $remainingChildren))) (not $bool))

;; A helper function to apply 0Subsume and orCut transformation functions.
;; It will also apply reduce to elegance algorithm on each of the children of the POA.
;; TODO: Add type definitions
(= (applyOrTransformations ($commandSet $dominantSet ($parent $current $_)))
   (let*
     (
        (($zeroSubsumeParent $zeroSubsumeCurrent $appliedZeroSubsume) (zeroConstraintSubsume $parent $current)) ;; Apply 0-Subsume
        (($orCutParent $orCutCurrent $appliedOrCut) (orCut $zeroSubsumeParent $zeroSubsumeCurrent)) ;; Apply orCut
        ($children (getChildren $current))
        ($firstChild (if (~= $children ()) (car-atom $children) ()))
        ($remainingChildren (if (~= $nextChild ()) (cdr-atom $children) ()))
     )
     (if (or $appliedZeroSubsume $appliedOrCut) 
         ($commandSet $dominantSet ($orCutParent $orCutCurrent True)) ;; Returning the most up to date state.

         ;; Apply RTE on children until RTE is no longer being applied on any children.
         (let ($_ $__ ($finalUpdatedParent $finalUpdatedCurrent $bool) (() ()))
              (until orTransformationsNotApplied applyReduceToEleganceToOr ($commandSet $dominantSet ($parent $current True) ($firstChild $remainingChildren)))
              ($commandSet $dominantSet ($finalUpdatedParent $finalUpdatedCurrent $bool))
         )
     )
   )
)


;; A helper function to apply reduceToElegance to the currentChild and return the nextChild in addtion to the state. It behaves like a lambda function.
;; The implementation of this function has many paramters to make it suitable to use with the already implemented until function.
;; This function is specific for the OR node case of the reduce to elegance function.
;; TODO: Add type definitions
(= (applyReduceToEleganceToOr ($commandSet $dominantSet ($parent $prevCurrent $bool) ($currentChild $remainingChildren)))
   (if (~= $currentChild ())
       (let*
          (
              ($localCommandSet (localCommandSet $currentChild (getChildren $prevCurrent) (getGuardSet $prevCurrent) $commandSet)) ;; Compute local command set
              (() (println! (LocalCommandSet: $localCommandSet)))
              ($nextChild (if (~= $remainingChildren ()) (car-atom $remainingChildren) ()))
              ($restChildren (if (~= $nextChild ()) (cdr-atom $remainingChildren) ()))
          )
          ($commandSet $dominantSet (reduceToElegance $prevCurrent $currentChild $dominantSet $localCommandSet) ($nextChild $restChildren))
          ;; (CommandSet: $commandSet CurrentChild: $currentChild Children: (getChildren $prevCurrent) GuardSet: (getGuardSet $prevCurrent))
       )
       ($commandSet $dominantSet ($parent $prevCurrent False) (() ()))
   )
)

;;A function to calculate local command set of a given node.
;;Local command set is the union of guardSets of AND nodes that have single guard set and no children.
;;A guardSet is a set of literals or negation of literals in an AND nodes.
;;Example: input ==> child: (AND A), 
;;                   parentChildren: ((AND A) (AND B C) (AND D) (AND B C (OR A B)))
;;                   parentGuardSet: (E F G)
;;                   commandSet: (E F)
;;         output ==> (D E F)
(: localCommandSet (-> Expression Expression Expression Expression Expression))
(= (localCommandSet $child $parentChildren $parentGuardSet $commandSet)
   (case ($parentChildren $parentGuardSet)
     (
        ((() ()) $commandSet)
        ($else
          (let*
            (
              ($siblings (if (~= $parentChildren ()) (removeElement ($child) $parentChildren) ()))
              ($filteredGuardSet (if (~= $parentGuardSet ()) (removeElement ($child) $parentGuardSet) ()))
              ($filteredSiblings (if (~= $siblings ()) (collapse (filterTerminalAndNode (superpose $siblings))) ()))
              ($siblingsGuardSet
                  ;; To flatten the guardSet of siblings
                  (if (~= $filteredSiblings ())
                      (collapse
                        (let*
                          (
                              ($siblingGuardSet (collapse (getGuardSet (superpose $filteredSiblings))))
                              ($nDGuardSet (superpose $siblingGuardSet))
                              ($nDGuardSet' (superpose $nDGuardSet))
                          )
                          $nDGuardSet'
                        )
                      )
                      ()
                  )
              )
              ($totalGuardSet (concatTuple $filteredGuardSet $siblingsGuardSet))
              ($localCommandSet (collapse (unique (union (superpose $totalGuardSet) (superpose $commandSet)))))

              (() (println! (=== LocalCommandSet Log ===)))
              (() (println! (Siblings: $siblings)))
              (() (println! (FilteredGuardSet $filteredGuardSet)))
              (() (println! (FilteredSiblins $filteredSiblings)))
              (() (println! (SiblingsGuardSet $siblingsGuardSet)))
              (() (println! (TotalGuardSet: $totalGuardSet)))
              (() (println! (LocalCommandSet: $localCommandSet)))
            )
            $localCommandSet
          )
        )
     )
   )
)

;; A partial helper function to used to filter out a terminal AND node.
;; A terminal AND node is any node that has no child and single guardSet.
;; WARN: This function doesn't work when the following type definition is added on MeTTa version 1.12
;; (: filterTerminalAndNode (-> Expression Expression))
(= (filterTerminalAndNode $node)
   (case $node
     (
        ((AND (NOT $x)) $node)
        ((AND $x) (if (== (get-metatype $x) Symbol) $node (empty)))
        ($else (empty))
     )
   )
)
