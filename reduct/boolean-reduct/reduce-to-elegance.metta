;; A function to apply all the 8 transformation functions depending on. The function filters out and applies transformation functions that are only applicable to the POA(Point of application).
;;    The function returns the most up-to-date parent and current nodes while not changing the dominantSet and commandSet as inputs. It will additionally output a boolean to indicate whether at least one transformation has been applied. If this boolean is true, the RTE (reduceToElegance) function may need to be called again until the boolean is false. This is because changes made by some transformation functions can alter the state in such a way that a transformation function, which has already been applied, can be applied again.
;;    The reduceToElegance function can start with an empty dominantSet and commandSet as long as it has a parent with no guardSets, usually an AND node, as an input. This is needed so that the function can compute the dominantSet and commandSet correctly. Otherwise, initial dominantSet and commandSet should be provided.

;; Definitions: Guard set of a POA is the set of literals in the POA.
;;              An AND node N commands every node which is a descendent of N's
;;                parent but which is neither N nor a descendent of N.
;;              A guard set of a POA is the set of literals in the POA.
;;              The command set of a node N is the union of the
;;                guard sets of the AND nodes in the tree which
;;                command N and which have guard sets containing
;;                only one constraint each,
;;               A dominant set of a POA is the set of guardSets of AND nodes found 
;;                on the path from the root to the POA (POA not included).

;; Example: input: parent ==> (AND A (OR (AND (NOT B) C) (AND (NOT B))) (OR (AND (NOT C)) (AND (NOT B) (NOT D)))), 
;;                 current ==> (OR (AND (NOT B) C) (AND (NOT B)))
;;                 dominantSet ==> (A)
;;                 commandSet ==> ()
;;        : output: ((AND A (NOT B) (OR (AND (NOT C)) (AND (NOT B) (NOT D)))) () True)
;; TODO: You need to call the RTE until it's no longer applied in the entry point. 
(: reduceToElegance (-> Expression Expression Expression Expression (Expression Expression Bool)))
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
                      ;; (() (println! (=== Inside RTE AND case ===)))
                      ;; (() (println! (Parameters ==> Parent: $parent Current: $current DominantSet: $dominantSet CommandSet: $commandSet)))
                      ;; (() (println! ""))

                      ($guardSet (getGuardSet $current))
                      ($children (getChildren $current))

                      ;; TODO: Replace the setDifference function with non deterministic functions
                      ($updatedGuardSet (setDifference $guardSet $dominantSet)) ;; Apply Redundant to current
                      ;; TODO: Replace this 1CCS application with the correct logic in it's own function.
                      ($updatedGuardSet' (setDifference $updatedGuardSet $commandSet)) ;; Apply 1-Constraint-Complement-Subtraction
                      ($appliedRedundantOr1CC (or (~= $updatedGuardSet $guardSet) (~= $updatedGuardSet' $updatedGuardSet))) ;; Storing this state to return boolean indicating RTE is applied or not.

                      ($updatedSubExpression (concatTuple $updatedGuardSet' $children))
                      ($updatedCurrent (cons-atom AND $updatedSubExpression))
                      ($updatedParent (findAndReplace $current $updatedCurrent $parent))

                      (($oneSubsumeParent $oneSubsumeCurrent $appliedOneSubsume) (oneConstraintSubsume $updatedParent $updatedCurrent $commandSet)) ;; Apply 1-Subsume.

                      ;; (() (println! (=== RTE AND CASE log ===)))
                      ;; (() (println! (GuardSet: $guardSet Children: $children UpdatedGuardSet: $updatedGuardSet UpdatedGuardSet': $updatedGuardSet')))
                      ;; (() (println! (appliedRedundantOr1CC: $appliedRedundantOr1CC appliedOneSubsume: $appliedOneSubsume)))
                      ;; (() (println! ""))

                      ;; until no transformation is applied
                      ;;    compute dominantSet
                      ;;    deleteInconHandle.
                      ;;    andCut.
                      ;;    apply RTE on children.
                      ;; 0-Subsume Variation
                      (($_ $__ ($updatedParent' $updatedCurrent' $bool))
                         (if $appliedOneSubsume ;; If 1-Subsume is applied Current will be deleted so no need to iterate.
                             ($dominantSet $commandSet ($oneSubsumeParent $oneSubsumeCurrent True))
                             (until transformationsNotApplied applyAndTransformations ($commandSet $dominantSet ($updatedParent $updatedCurrent True)))))

                      ;; (() (println! (FinalResult ==> UpdatedParent': $updatedParent' UpdatedCurrent: $updatedCurrent' AppliedRTE: (any ($appliedRedundantOr1CC $appliedOneSubsume $bool $finalBool)))))
                      ;; (() (println! ""))
                    )
                    ($updatedParent' $updatedCurrent' (any ($appliedRedundantOr1CC $appliedOneSubsume $bool)))
                  )
                )
                (OR
                  (let*
                    (
                     ;; (() (println! (=== Inside RTE OR case ===)))
                     ;; (() (println! (Parameters ==> Parent: $parent Current: $current DominantSet: $dominantSet CommandSet: $commandSet)))

                     (($promoteParent $promoteCurrent $appliedPromote) (promoteCommonConstraints $parent $current)) ;; Apply promote

                     ;; (() (println! (Promote ==> Parent: $promoteParent Current: $current Applied: $appliedPromote)))

                      ;;until no transformation is applied.
                      ;;    compute commandSet
                      ;;    0-Subsume
                      ;;    orCut
                      ;;    apply RTE on children.
                     (($_ $__ ($updatedParent $updatedCurrent $bool)) (until transformationsNotApplied applyOrTransformations ($commandSet $dominantSet ($promoteParent $promoteCurrent True))))

                     (($finalUpdatedParent $finalUpdatedCurrent $finalBool) (zeroConstraintSubsume' $updatedParent $updatedCurrent))

                     ;; (() (println! (=== RTE OR CASE Log ===)))
                     ;; (() (println! (Promote ==> Parent: $promoteParent Current: $promoteCurrent Applied: $appliedPromote)))
                     ;; (() (println! (RTE Result ==> UpdatedParent: $updatedParent UpdatedCurrent: $updatedCurrent AppliedRTE: (any ($bool $appliedPromote)))))
                     ;; (() (println! (Final Result ==> FinalUpdatedParent: $finalUpdatedParent FinalUpdatedCurrent: $finalUpdatedCurrent AppliedRTE: (any ($bool $finalBool $appliedPromote)))))
                     ;; (() (println! ""))

                    )
                    ($finalUpdatedParent $finalUpdatedCurrent (any ($bool $finalBool $appliedPromote)))
                  )
                )
              )
            )
        )
      )
   )
)

;; A helper function to check if a transformation is applied or not given the state of the OR node transformations.
(: transformationsNotApplied (-> (Expression Expression (Expression Expression Bool)) Bool))
(= (transformationsNotApplied ($_ $__ ($parent $current $bool))) (not $bool))

;; A helper function to apply delInconHandle and andCut transformation functions.
;; It will also apply reduce to elegance algorithm on each of the children of the POA.
(: applyAndTransformations (-> (Expression Expression (Expression Expression Bool)) (Expression Expression Bool)))
(= (applyAndTransformations ($commandSet $dominantSet ($parent $current $_)))
   (let*
     (
        ;; (() (println! (=== Inside ApplyAndTransformations ===)))
        ;; (() (println! (Parameters ==> CommandSet: $commandSet DominantSet: $dominantSet Parent: $parent Current: $current)))
        ;; (() (println! ""))

        ($guardSet (getGuardSet $current))
        ($children (getChildren $current))

        ($firstChild (if (~= $children ()) (car-atom $children) ()))
        ($remainingChildren (if (~= $firstChild ()) (cdr-atom $children) ()))

        ($handleSet (collapse (unique (union (superpose $guardSet) (superpose $dominantSet))))) ;; Compute new dominantSet

        (($delInconHandleParent $delInconHandleCurrent $appliedDelInconHandle) (deleteInconsistentHandle $parent $current $handleSet)) ;; Apply deleteInconHandle.

        ;; INFO: Applying andCut here may be a redundant operation. And could be potentially omitted.
        (($andCutParent $andCutCurrent $appliedAndCut) (andCut $delInconHandleParent $delInconHandleCurrent)) ;; Apply andCut

        ;; (() (println! (=== ApplyAndTransformations Log ===)))
        ;; (() (println! (GuardSet: $guardSet Children: $children HandleSet: $handleSet)))
        ;; (() (println! (DelInconHandle ==> Parent: $delInconHandleParent Current: $delInconHandleCurrent appliedDelInconHandle: $appliedDelInconHandle)))
        ;; (() (println! (AndCut ==> Parent: $andCutParent Current: $andCutCurrent appliedAndCut: $appliedAndCut)))
        ;; (() (println! (Children: $children FirstChild: $firstChild RemainingChildren: $remainingChildren)))
        ;; (() (println! ""))
     )
     (if (or $appliedDelInconHandle $appliedAndCut)
         ($commandSet $dominantSet ($andCutParent $andCutCurrent True)) ;; Returning the most up to date state.

         ;; Apply RTE on children
         (let*
           (
              (($commandSet'' $dominantSet'' ($updatedParent $updatedCurrent $appliedRTE))
                (if (~= $children ())
                    (let*
                          (
                            (($dominantSet' $commandSet' ($finalUpdatedParent $finalUpdatedCurrent $bool) ($lastChild $lastRemainingChild)) (until hasNoNextChild applyReduceToEleganceToOr ($commandSet $handleSet ($parent $current False) ($firstChild $remainingChildren))))

                            ;; (() (println! (Applyed reduceToElegance ==> FinalUpdatedParent: $finalUpdatedParent FinalUpdatedCurrent: $finalUpdatedCurrent AppliedRTE: $bool)))

                            ($grandChildren (getChildren $finalUpdatedCurrent))
                            ($firstGrandChild (if (~= $grandChildren ()) (car-atom $grandChildren) ()))
                            ($remainingGChildren (if (~= $firstGrandChild ()) (cdr-atom $grandChildren) ()))

                            ;; (() (println! (Applying OrCut to GrandChildren: $grandChildren)))

                            ;; Apply OrCut to children of the updatedCurrent here.
                            (($finalUpdatedCurrent' $appliedOrCut ($lastGChild $restGChildren)) (until hasNoNextChild applyOrCut ($finalUpdatedCurrent False ($firstGrandChild $remainingGChildren))))
                            ($finalUpdatedParent' (findAndReplace $finalUpdatedCurrent $finalUpdatedCurrent' $finalUpdatedParent))

                            ;; (() (println! (AppliedOrCut: $appliedOrCut FinalUpdatedCurrent': $finalUpdatedCurrent' FinalUpdatedParent': $finalUpdatedParent')))
                            ;; (() (println! (LastChild: $lastChild LastRemainingChild: $lastRemainingChild)))
                          )
                        ($commandSet' $dominantSet' ($finalUpdatedParent' $finalUpdatedCurrent' (or $bool $appliedOrCut)))
                    )
                    ($commandSet $dominantSet ($parent $current False))
                )
              )
              ;; (() (println! (Outside of the If block)))
              ;; (() (println! (UpdatedParent: $updatedParent UpdatedCurrent: $updatedCurrent AppliedRTE: $appliedRTE)))
              ;; (() (println! ""))
           )
           ($commandSet $dominantSet ($updatedParent $updatedCurrent $appliedRTE))
         )
     )
   )
)

;; A helper function to apply reduceToElegance using foldl. It behaves like a lambda function.
;; This function is specific for the AND node case of the reduce to elegance function.
;;($commandSet $dominantSet ($parent $current False) ($firstChild $remainingChildren))
(: applyReduceToEleganceToAnd (-> (Expression Expression (Expression Expression Bool) (Expression Expression)) (Expression Expression (Expression Expression Bool) (Expression Expression))))
(= (applyReduceToEleganceToAnd ($commandSet $dominantSet ($parent $prevCurrent $bool) ($firstChild $remainingChildren)))
   (let*
     (
        ;; (() (println! (=== Inside ApplyReduceToEleganceToAND ===)))
        ;; (() (println! (Parameters ==> CommandSet: $commandSet DominantSet: $dominantSet Parent: $parent PrevCurrent: $prevCurrent Bool: $bool FirstChild: $firstChild RemainingChildren: $remainingChildren)))
        ;; (() (println! ""))

        ($nextChild (if (~= $remainingChildren ()) (car-atom $remainingChildren) ()))
        ($rest (if (~= $remainingChildren ()) (cdr-atom $remainingChildren) ()))


        (($updatedCurrent $updatedChild $appliedRTE) (reduceToElegance $prevCurrent $firstChild $dominantSet $commandSet))
        ($updatedParent (findAndReplace $prevCurrent $updatedCurrent $parent))

        ($updatedChildren (getChildren $updatedCurrent))
        ($resetNextChild (if (~= $updatedChildren ()) (car-atom $updatedChildren) ()))
        ($resetRemainingChildren (if (~= $resetNextChild ()) (cdr-atom $updatedChildren) ()))

        ;; (() (println! (=== ApplyReduceToEleganceToAND Log ===)))
        ;; (() (println! (UpdatedParent: $updatedParent UpdatedCurrent: $updatedCurrent UpdatedChild: $updatedChild AppliedRTE: $appliedRTE)))
        ;; (() (println! (Reset iteration: $appliedRTE)))
        ;; (() (println! ""))
     )

     ;; Resetting is needed only when a transforamtion is applied in this state.
     ;; It shouldn't be influenced by previous iteration.
     (if $appliedRTE
         ($commandSet $dominantSet ($updatedParent $updatedCurrent (or $appliedRTE $bool)) ($resetNextChild $resetRemainingChildren))
         ($commandSet $dominantSet ($updatedParent $updatedCurrent (or $appliedRTE $bool)) ($nextChild $rest))
     )
   )
)



;; A helper function to apply 0Subsume and orCut transformation functions.
;; It will also apply reduce to elegance algorithm on each of the children of the POA.
(: applyOrTransformations (-> (Expression Expression (Expression Expression Bool)) (Expression Expression (Expression Expression Bool))))
(= (applyOrTransformations ($commandSet $dominantSet ($parent $current $_)))
   (let*
     (
        ;; (() (println! (=== Inside ApplyOrTransformations ===)))
        ;; (() (println! (Parameters ==> CommandSet: $commandSet DominantSet: $dominantSet Parent: $parent Current: $current Unused Boolean Value: $_)))
        ;; (() (println! ""))

        (($zeroSubsumeParent $zeroSubsumeCurrent $appliedZeroSubsume) (zeroConstraintSubsume $parent $current)) ;; Apply 0-Subsume
        (($orCutParent $orCutCurrent $appliedOrCut) (orCut $zeroSubsumeParent $zeroSubsumeCurrent)) ;; Apply orCut

        ($children (getChildren $current))
        ($firstChild (if (~= $children ()) (car-atom $children) ()))
        ($remainingChildren (if (~= $firstChild ()) (cdr-atom $children) ()))

        ;; (() (println! (=== ApplyOrTransformations Log ===)))
        ;; (() (println! (0Subsume ==> Parent: $zeroSubsumeParent Current: $zeroSubsumeCurrent Applied: $appliedZeroSubsume)))
        ;; (() (println! (OrCut ==> Parent: $orCutParent Current: $orCutCurrent Applied: $appliedOrCut)))
        ;; (() (println! (Children: $children)))
        ;; (() (println! ""))
     )
     (if (any ($appliedZeroSubsume $appliedZeroSubsume' $appliedOrCut))
         ($commandSet $dominantSet ($orCutParent $orCutCurrent True)) ;; Returning the most up to date state.

         ;; Apply RTE on children until RTE is no longer being applied on any children.
         (let*
           (

             ;; (() (println! (===== Inside ApplyOrTransformations Before Until function ======)))

             (($dominantSet' $commandSet' ($finalUpdatedParent $finalUpdatedCurrent $bool) ($lastChild $rest)) (until hasNoNextChild applyReduceToEleganceToAnd ($commandSet $dominantSet ($parent $current False) ($firstChild $remainingChildren))))

             ;; (() (println! (Inside ApplyOrTransformations After Until function)))
             ;; (() (println! (FinalResult ==> FinalUpdatedParent: $finalUpdatedParent FinalUpdatedCurrent: $finalUpdatedCurrent Applied: $bool)))
             ;; (() (println! ""))
           )
           ($commandSet $dominantSet ($finalUpdatedParent $finalUpdatedCurrent $bool))
         )
     )
   )
)


;; A helper function to apply reduceToElegance to the currentChild and return the nextChild in addtion to the state. It behaves like a lambda function.
;; The implementation of this function has many paramters to make it suitable to use with the already implemented until function.
;; This function is specific for the OR node case of the reduce to elegance function.
(: applyReduceToEleganceToOr (-> (Expression Expression (Expression Expression Bool) (Expression Expression)) (Expression Expression (Expression Expression Bool))))
(= (applyReduceToEleganceToOr ($commandSet $dominantSet ($parent $prevCurrent $bool) ($currentChild $remainingChildren)))
   (if (~= $currentChild ())
       (let*
          (
              ;; (() (println! (=== Inside ApplyReduceToEleganceToOr ===)))
              ;; (() (println! (Parameters ==> CommandSet: $commandSet DominantSet: $dominantSet Parent: $parent PrevCurrent: $prevCurrent Bool: $bool CurrentChild: $currentChild RemainingChildren: $remainingChildren)))
              ;; (() (println! ""))

              ($localCommandSet (localCommandSet $currentChild (getChildren $prevCurrent) (getGuardSet $prevCurrent) $commandSet)) ;; Compute local command set
              ($nextChild (if (~= $remainingChildren ()) (car-atom $remainingChildren) ()))
              ($restChildren (if (~= $nextChild ()) (cdr-atom $remainingChildren) ()))

              (($updatedCurrent $updatedChild $appliedRTE) (reduceToElegance $prevCurrent $currentChild $dominantSet $localCommandSet))
              (($promoteCurrent $promoteChild $appliedPromote) (promoteCommonConstraints $updatedCurrent $updatedChild))

              ;; (() (println! (Applied Promote ==> Current: $promoteCurrent Child: $promoteChild Applied: $appliedPromote)))

              ($grandChildren (getChildren $promoteCurrent))
              ($firstGChild (if (~= $grandChildren ()) (car-atom $grandChildren) ()))
              ($remainingGChildren (if (~= $firstGChild ()) (cdr-atom $grandChildren) ()))

              (($finalUpdatedCurrent $appliedAndCut ($lastChild $rest)) (until hasNoNextChild applyAndCut ($promoteCurrent False ($firstGChild $remainingGChildren))))
              ($finalUpdatedParent (findAndReplace $prevCurrent $finalUpdatedCurrent $parent))

              ;; (() (println! (Applied AndCut==> FinalupdatedCurrent: $finalUpdatedCurrent FinalUpdatedParent: $finalUpdatedParent AppliedAndCut: $appliedAndCut)))

              ($updatedChildren (getChildren $finalUpdatedCurrent))
              ($updatedFirstChild (if (~= $updatedChildren ()) (car-atom $updatedChildren) ()))
              ($updatedRestChildren (if (~= $updatedFirstChild ()) (cdr-atom $updatedChildren) ()))

              ;; The $bool here is useful to determine whether an RTE is applied or not through out the entire iteration.
              ($returnValue ($commandSet $dominantSet ($finalUpdatedParent $finalUpdatedCurrent (any ($appliedRTE $bool $appliedAndCut))) ($nextChild $restChildren)))

              ;; (() (println! (=== ApplyReduceToEleganceToOr Log ===)))
              ;; (() (println! (Children: (getChildren $prevCurrent) GuardSet: (getGuardSet $prevCurrent))))
              ;; (() (println! (NextChild: $nextChild RestChildren: $restChildren)))
              ;; (() (println! (UpdatedCurrent: $updatedCurrent UpdatedChild: $updatedChild AppliedRTE: $appliedRTE)))
              ;; (() (println! (ReturnValue: $returnValue)))
              ;; (() (println! ""))

          )
          ;; Resetting is needed only when a transforamtion is applied in this state.
          ;; It shouldn't be influenced by previous iteration.
          (if (any ($appliedRTE $appliedAndCut))
              ;; Resetting iteration if promote or RTE is applied.
              ($commandSet $dominantSet ($finalUpdatedParent $finalUpdatedCurrent (any ($appliedRTE $bool $appliedAndCut))) ($updatedFirstChild $updatedRestChildren))
              $returnValue
          )
       )
       ($commandSet $dominantSet ($parent $prevCurrent False) (() ()))
   )
)

;;A function to calculate local command set of a given node.
;;Local command set is the union of guardSets of terminal AND nodes.
;;A terminal AND node is a node that has single guard set and no children.
;;  In this implementation, literals are also included in the local command
;;  set since they are equivalent to a terminal and node.
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
              ;; (() (println! (=== Inside LocalCommandSet ===)))
              ;; (() (println! (Parameters ==> Child: $child ParentChildren: $parentChildren ParentGuardSet: $parentGuardSet CommandSet: $commandSet)))
              ;; (() (println! ""))

              ($siblings (if (~= $parentChildren ()) (removeElement ($child) $parentChildren) ()))
              ($filteredGuardSet (if (~= $parentGuardSet ()) (removeElement ($child) $parentGuardSet) ()))
              ($filteredSiblings (if (~= $siblings ()) (collapse (filterTerminalAndNode (superpose $siblings))) ()))
              ($siblingsGuardSet (if (~= $filteredSiblings ()) (collapse (getGuardSetND (superpose $filteredSiblings))) ()))
              ($totalGuardSet (concatTuple $filteredGuardSet $siblingsGuardSet))
              ($localCommandSet (collapse (unique (union (superpose $totalGuardSet) (superpose $commandSet)))))

              ;; (() (println! (=== LocalCommandSet Log ===)))
              ;; (() (println! (Siblings: $siblings)))
              ;; (() (println! (FilteredGuardSet $filteredGuardSet)))
              ;; (() (println! (FilteredSiblings $filteredSiblings)))
              ;; (() (println! (SiblingsGuardSet $siblingsGuardSet)))
              ;; (() (println! (TotalGuardSet: $totalGuardSet)))
              ;; (() (println! (LocalCommandSet: $localCommandSet)))
              ;; (() (println! ""))
            )
            $localCommandSet
          )
        )
     )
   )
)

;; A partial helper function used to filter out a terminal AND node.
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


;; A helper predicate function to be used in the until function. It checks if there is no next child.
;; It could be replace using a lambda function, if it exists.
(: hasNoNextChild (-> (Expression Bool (Expression Expression)) Bool))
(: hasNoNextChild (-> (Expression Expression (Expression Expression Bool) (Expression Expression))))
(= (hasNoNextChild ($parent $bool ($child $remainingChildren))) (== $child ()))
(= (hasNoNextChild ($dominantSet' $commandSet' ($finalUpdatedParent $finalUpdatedCurrent $bool) ($nextChild $remainingChildren))) (== $nextChild ()))
