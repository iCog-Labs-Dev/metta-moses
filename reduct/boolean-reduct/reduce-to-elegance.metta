! (register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-or)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-and)
! (import! &self metta-moses:reduct:boolean-reduct:delete-inconsistent-handle)
! (import! &self metta-moses:reduct:boolean-reduct:zero-constraint-subsumption)
! (import! &self metta-moses:reduct:boolean-reduct:one-constraint-subsumption)
! (import! &self metta-moses:reduct:boolean-reduct:promote-common-constraints)

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
                      (($_ $__ ($updatedParent' $updatedCurrent' $bool)) (until transformationNotApplied applyAndTransformations ($commandSet $dominantSet ($oneSubsumeParent $oneSubsumeCurrent True))))
                      (($finalUpdatedParent $finalUpdatedCurrent $finalBool) (zeroConstraintSubsume' $updatedParent' $updatedCurrent'))
                    )
                    ($finalUpdatedParent $finalUpdatedCurrent (any ($appliedRedundantOr1CC $appliedZeroSubsume $appliedOneSubsume $bool $finalBool)))
                    ; (finalUpdatedParent': $finalUpdatedParent finalUpdatedCurrent': $finalUpdatedCurrent bool: (any ($appliedRedundantOr1CC $appliedZeroSubsume $appliedOneSubsume $bool $finalBool)))
                  )
                )
                (OR
                  ;;until no transformation is applied.
                  ;;    compute commandSet
                  ;;    promote
                  ;;    0-Subsume
                  ;;    orCut
                  ;;    apply RTE on children.
                  ())
              )
            )
        )
      )
   )
)

;; A helper function to exptract transformation application from
(: transformationNotApplied (-> (Expression Expression (Expression Expression Bool)) Bool))
(= (transformationNotApplied ($_ $__ ($parent $current $bool))) (not $bool))

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
         (foldl reduceToElegance ($commandSet $handleSet ($parent $current False)) $children)
     )
   )
)

;; A helper function to apply reduceToElegance using foldl. It behaves like a lambda function.
(: applyReduceToElegance (-> Expression (Expression Expression (Expression Expression Bool))))
(= (applyReduceToElegance $newCurrent ($commandSet $dominantSet ($parent $prevCurrent $bool)))
   ($commandSet $dominantSet (reduceToElegance $parent $newCurrent $dominantSet $commandSet))
)
