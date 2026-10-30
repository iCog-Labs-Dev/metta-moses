;; reduceToElegance applies the RTE transformations at one point of application (POA).
;; It returns (parent current applied): the updated parent, the updated current node and
;; True when at least one transformation was applied. The caller repeats the call until
;; it returns False, because one transformation can make another one applicable again.
;; The dominantSet and commandSet can start empty when the parent has no guard set
;; (usually an AND root). Otherwise, give the initial sets.

;; Definitions: The guard set of a POA is the set of literals in the POA.
;;              An AND node N commands every node which is a descendant of N's
;;                parent but which is neither N nor a descendant of N.
;;              The command set of a node N is the union of the
;;                guard sets of the AND nodes in the tree which
;;                command N and which have guard sets containing
;;                only one constraint each.
;;              The dominant set of a POA is the set of guard sets of AND nodes found
;;                on the path from the root to the POA (POA not included).

;; Example: input: parent ==> (AND A (OR (AND (NOT B) C) (AND (NOT B))) (OR (AND (NOT C)) (AND (NOT B) (NOT D)))), 
;;                 current ==> (OR (AND (NOT B) C) (AND (NOT B)))
;;                 dominantSet ==> (A)
;;                 commandSet ==> ()
;;        : output: ((AND A (NOT B) (OR (AND (NOT C)) (AND (NOT B) (NOT D)))) () True)
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
                      ;; ($_ (println! ""))
                      ;; ($_ (println! (===Inside RTE AND case===)))
                      ;; ($_ (println! (Parameters ==> Parent: $parent Current: $current DominantSet: $dominantSet CommandSet: $commandSet)))
                      ;; ($_ (println! ""))

                      ($guardSet (getGuardSet $current))
                      ;; ($_ (println! (GuardSet of Current: $guardSet)))
                      ($children (getChildrenExp $current))
                      ;; ($_ (println! (Children of Current: $children)))

                      ;; TODO: Replace the setDifference function with non deterministic functions
                      ($updatedGuardSet (setDifference $guardSet $dominantSet)) ;; Apply Redundant to current
                      ;; Subtract the NEGATED command set: 1CC erases literals whose negation is commanded.
                      ;; Raw subtraction does 1-Subsume's job instead, and leaves the guard set disjoint
                      ;; from the command set so oneConstraintSubsume can never fire. (logical_rules.cc:642)
                      ($updatedGuardSet' (setDifference $updatedGuardSet (invertLiterals $commandSet))) ;; Apply 1-Constraint-Complement-Subtraction
                      ($appliedRedundantOr1CC (or (!= $updatedGuardSet $guardSet) (!= $updatedGuardSet' $updatedGuardSet))) ;; Storing this state to return boolean indicating RTE is applied or not.

                      
                      ($updatedSubExpression (concatTuple $updatedGuardSet' $children))   
                      ;; DELIBERATELY still an empty (AND) rather than TRUE. Measured over the 1159-tree
                      ;; differential, emitting TRUE here costs a semantic tree (1158 -> 1157) to buy 80
                      ;; syntactic matches, and four ways of propagating it measure IDENTICAL -- the loss
                      ;; is intrinsic to this position (the RTE walkers do not always pass a genuine
                      ;; parent/child pair), not to the mechanism. The placeholder cleanup unlinks the
                      ;; empty (AND), which is the correct identity behaviour in an AND parent. See PR #509.
                      ($updatedCurrent (cons-atom AND $updatedSubExpression))
                      ($updatedParent (findAndReplace $current $updatedCurrent $parent))
                      ($temp (oneConstraintSubsume $updatedParent $updatedCurrent $commandSet)) ;; Apply 1-Subsume.
                      ;; ($_ (println! (Result: $temp)))
                      (($oneSubsumeParent $oneSubsumeCurrent $appliedOneSubsume) $temp)
                      ;; ($_ (println! (===RTE AND CASE Log===)))
                      ;; ($_ (println! (GuardSet: $guardSet Children: $children UpdatedGuardSet: $updatedGuardSet UpdatedGuardSetPrime: $updatedGuardSet')))
                      ;; ($_ (println! (appliedRedundantOr1CC: $appliedRedundantOr1CC appliedOneSubsume: $appliedOneSubsume)))
                      ;; ($_ (println! ""))

                      ;; until no transformation is applied
                      ;;    compute dominantSet
                      ;;    deleteInconHandle.
                      ;;    andCut.
                      ;;    apply RTE on children.
                      ;; 0-Subsume Variation
                      ;; ($_ (println! (UpdatedParent: $updatedParent UpdatedCurrent: $updatedCurrent)))
                      (($_commandSet $_dominantSet ($updatedParent' $updatedCurrent' $bool))
                         (if $appliedOneSubsume ;; If 1-Subsume is applied Current will be deleted so no need to iterate.
                             ($dominantSet $commandSet ($oneSubsumeParent $oneSubsumeCurrent True))
                             (until transformationsNotApplied applyAndTransformations ($commandSet $dominantSet ($updatedParent $updatedCurrent True)))))

                      ;; ($_ (println! (FinalResult ==> UpdatedParent': $updatedParent' UpdatedCurrent: $updatedCurrent' AppliedRTE: (any ($appliedRedundantOr1CC $appliedOneSubsume $bool)))))
                      ;; ($_ (println! (calling 0-Subsume Variation on Parent: $updatedParent' Current: $updatedCurrent')))
                      ;; Fishes a replacement "current" out of the parent's tail when the POA was deleted.
                      ;; A constant parent has no tail: cdr-atom on a Symbol yields no solution, which
                      ;; would silently take the whole reduction with it.
                      ($childFromParent (if (isConstant $updatedParent')
                                            ()
                                            (if (== $updatedCurrent' ()) (cdr-atom $updatedParent') $updatedCurrent')))
                      ;; car-atom on a Symbol yields no solution: pass a constant straight through.
                      ($zeroCurrent (if (or (== $childFromParent ()) (!= (get-metatype $childFromParent) Expression))
                                        $childFromParent
                                        (let $h (car-atom $childFromParent)
                                             (if (== (get-metatype $h) Expression) $h $childFromParent))))
                      ;; ($_ (println! (zeroCurrent: $current --> $zeroCurrent)))
                      (($finalParent $finalCurrent $finalBool) (zeroConstraintSubsumeEmptyNode $updatedParent' $zeroCurrent)) ;; Apply 0-Subsume variation.
                      ;; Bare (AND) is data only because this file loads before scoring/boolean-ops.
                      ($finalCurrent' (if (== $finalCurrent ()) (AND) $finalCurrent))
                      ;; ($_ (println! (Final Result ==> FinalParent: $parent --> $finalParent FinalCurrent: $current --> $finalCurrent' AppliedRTE: (any ($appliedRedundantOr1CC $appliedOneSubsume $bool $finalBool)))))
                      ;; ($_ (println! ""))
                    )
                    ($finalParent $finalCurrent' (any ($appliedRedundantOr1CC $appliedOneSubsume $bool $finalBool)))
                  )
                )
                (OR
                  (let*
                    (
                      ;; ($_ (println! ""))
                      ;; ($_ (println! (===Inside RTE OR case===)))
                      ;; ($_ (println! (Parameters ==> Parent: $parent Current: $current DominantSet: $dominantSet CommandSet: $commandSet)))

                     (($promoteParent $promoteCurrent $appliedPromote) (promoteCommonConstraints $parent $current)) ;; Apply promote
                     
                      ;; ($_ (println! (Promote ==> Parent: $promoteParent Current: $current Applied: $appliedPromote)))

                      ;;until no transformation is applied.
                      ;;    compute commandSet
                      ;;    0-Subsume
                      ;;    orCut
                      ;;    apply RTE on children.
                     (($_orCommandSet $_orDominantSet ($updatedParent $updatedCurrent $bool)) (until transformationsNotApplied applyOrTransformations ($commandSet $dominantSet ($promoteParent $promoteCurrent True))))
                     (($finalUpdatedParent $finalUpdatedCurrent $finalBool) (zeroConstraintSubsumeEmptyNode $updatedParent $updatedCurrent))

                    ;; ($_ (println! (===RTE OR CASE Log===)))
                    ;; ($_ (println! (Promote ==> Parent: $promoteParent Current: $promoteCurrent Applied: $appliedPromote)))
                    ;; ($_ (println! (RTE Result ==> UpdatedParent: $updatedParent UpdatedCurrent: $updatedCurrent AppliedRTE: (any ($bool $appliedPromote)))))
                    ;; ($_ (println! (Final Result ==> FinalUpdatedParent: $finalUpdatedParent FinalUpdatedCurrent: $finalUpdatedCurrent AppliedRTE: (any ($bool $finalBool $appliedPromote)))))
                    ;; ($_ (println! ""))

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

;; The stop predicate of the `until` loops over applyAndTransformations and applyOrTransformations.
(= (transformationsNotApplied ($_commandSet $_dominantSet ($_parent $_current $bool))) (not $bool))

;; A helper function to apply delInconHandle and andCut transformation functions.
;; It will also apply reduce to elegance algorithm on each of the children of the POA.
(= (applyAndTransformations ($commandSet $dominantSet ($parent $current $unwt)))
   (let*
     (
        ;; ($_ (println! (===Inside ApplyAndTransformations===)))
        ;; ($_ (println! (Parameters ==> CommandSet: $commandSet DominantSet: $dominantSet Parent: $parent Current: $current)))
        ;; ($_ (println! ""))

        ($guardSet (getGuardSet $current))
        ($children (getChildrenExp $current))
        ;; ($_ (println! (GuardSet of Current: $guardSet)))
        ;; ($_ (println! (Children of Current: $children)))

        (($firstChild $remainingChildren) (if (== $children ()) (() ()) (decons-atom $children)))

        ($handleSet (unique-atom (union-atom $guardSet $dominantSet))) ;; Compute new dominantSet
        
        ;; ($_ (println! ("Parent before Delete:" $parent Current: $current)))
        (($delInconHandleParent $delInconHandleCurrent $appliedDelInconHandle)  (applyDeleteIncons $parent $current $handleSet)) ;; This handles multi layer nested expressions.
        ;; ($_ (println! ("Parent after Delete:" $delInconHandleParent Current: $delInconHandleCurrent)))

        (($andCutParent $andCutCurrent $appliedAndCut) (andCut $delInconHandleParent $delInconHandleCurrent)) ;; Apply andCut

        ;; ($_ (println! (===ApplyAndTransformations Log===)))
        ;; ($_ (println! (GuardSet: $guardSet Children: $children HandleSet: $handleSet)))
        ;; ($_ (println! (DelInconHandle ==> Parent: $delInconHandleParent Current: $delInconHandleCurrent appliedDelInconHandle: $appliedDelInconHandle)))
        ;; ($_ (println! (AndCut ==> Parent: $andCutParent Current: $andCutCurrent appliedAndCut: $appliedAndCut)))
        ;; ($_ (println! (Children: $children FirstChild: $firstChild RemainingChildren: $remainingChildren)))
        ;; ($_ (println! (AppliedDelInconHandle: $appliedDelInconHandle AppliedAndCut: $appliedAndCut)))
        ;; ($_ (println! ""))
     )
     (if (or $appliedDelInconHandle $appliedAndCut)
         ($commandSet $dominantSet ($andCutParent $andCutCurrent True)) ;; Returning the most up to date state.

         ;; Apply RTE on children
         (let*
           (
              (($commandSet'' $dominantSet'' ($updatedParent $updatedCurrent $appliedRTE))
                (if (!= $children ())
                    (let*
                          (
                            ;; ($_ (println! (===== Inside ApplyAndTransformations Before Until function ======)))
                            (($dominantSet' $commandSet' ($finalUpdatedParent $finalUpdatedCurrent $bool) ($lastChild $lastRemainingChild)) (until hasNoNextChild applyReduceToEleganceToOr ($commandSet $handleSet ($parent $current False) ($firstChild $remainingChildren))))

                            ;; ($_ (println! ("Applyed reduceToElegance ==> FinalUpdatedParent:" $finalUpdatedParent "FinalUpdatedCurrent: " $finalUpdatedCurrent "AppliedRTE: " $bool)))

                            ($grandChildren (getChildrenExp $finalUpdatedCurrent))
                            (($firstGrandChild $remainingGChildren) (if (== $grandChildren ()) (() ()) (decons-atom $grandChildren)))

                            ;; ($_ (println! (Applying OrCut to GrandChildren: $grandChildren)))

                            ;; Apply OrCut to children of the updatedCurrent here.
                            (($finalUpdatedCurrent' $appliedOrCut ($lastGChild $restGChildren)) (until hasNoNextChild applyOrCut ($finalUpdatedCurrent False ($firstGrandChild $remainingGChildren))))
                            ($finalUpdatedParent' (findAndReplace $finalUpdatedCurrent $finalUpdatedCurrent' $finalUpdatedParent))

                            ;; ($_ (println! (AppliedOrCut: $appliedOrCut FinalUpdatedCurrent': $finalUpdatedCurrent' FinalUpdatedParent': $finalUpdatedParent')))
                            ;; ($_ (println! (LastChild: $lastChild LastRemainingChild: $lastRemainingChild)))
                          )
                        ($commandSet' $dominantSet' ($finalUpdatedParent' $finalUpdatedCurrent' (or $bool $appliedOrCut)))
                    )
                    ($commandSet $dominantSet ($parent $current False))
                )
              )
              ;; ($_ (println! (Outside of the If block)))
              ;; ($_ (println! (UpdatedParent: $updatedParent UpdatedCurrent: $updatedCurrent AppliedRTE: $appliedRTE)))
              ;; ($_ (println! ($commandSet'')))
              ;; ($_ (println! ""))
              ;; ($_ (println! ("commandSet: " $commandSet "DomainSet: " $dominantSet)))
           )
           ($commandSet $dominantSet ($updatedParent $updatedCurrent $appliedRTE))
         )
     )
   )
)

;; The `until` step that applies reduceToElegance to each child of an OR node in turn.
;; The children are AND nodes, hence the name.
;;($commandSet $dominantSet ($parent $current False) ($firstChild $remainingChildren))
(= (applyReduceToEleganceToAnd ($commandSet $dominantSet ($parent $prevCurrent $bool) ($firstChild $remainingChildren)))
   (let*
     (
        ;; ($_ (println! (===Inside ApplyReduceToEleganceToAND===)))
        ;; ($_ (println! (Parameters ==> CommandSet: $commandSet DominantSet: $dominantSet Parent: $parent PrevCurrent: $prevCurrent Bool: $bool FirstChild: $firstChild RemainingChildren: $remainingChildren)))
        ;; ($_ (println! ""))

        (($nextChild $rest) (if (== $remainingChildren ()) (() ()) (decons-atom $remainingChildren)))


        ;; Every OTHER single-constraint alternative of this OR commands $firstChild, for this
        ;; child only -- bare ones in the OR's literals, terminal ANDs in its children.
        ;; Classic builds the same per-child set in reduce_or (logical_rules.cc:806).
        ($localCommandSet (localCommandSet $firstChild (getChildrenExp $prevCurrent) (getLiterals $prevCurrent) $commandSet))

        (($updatedCurrent $updatedChild $appliedRTE) (reduceToElegance $prevCurrent $firstChild $dominantSet $localCommandSet))
        ($updatedParent (findAndReplace $prevCurrent $updatedCurrent $parent))

        ($updatedChildren (getChildrenExp $updatedCurrent))
        (($resetNextChild $resetRemainingChildren) (if (== $updatedChildren ()) (() ()) (decons-atom $updatedChildren)))

        ;; ($_ (println! (===ApplyReduceToEleganceToAND Log===)))
        ;; ($_ (println! (UpdatedParent: $updatedParent UpdatedCurrent: $updatedCurrent UpdatedChild: $updatedChild AppliedRTE: $appliedRTE)))
        ;; ($_ (println! (Reset iteration: $appliedRTE)))
        ;; ($_ (println! ""))
     )

     ;; Resetting is needed only when a transformation is applied in this state.
     ;; It shouldn't be influenced by previous iteration.
     (let $next (if $appliedRTE ($resetNextChild $resetRemainingChildren) ($nextChild $rest))
       ($commandSet $dominantSet ($updatedParent $updatedCurrent (or $appliedRTE $bool)) $next))
   )
)



;; A helper function to apply 0Subsume and orCut transformation functions.
;; It will also apply reduce to elegance algorithm on each of the children of the POA.
(= (applyOrTransformations ($commandSet $dominantSet ($parent $current $bl)))
   (let*
     (
        ;; ($_ (println! (===Inside ApplyOrTransformations===)))
        ;; ($_ (println! (Parameters ==> CommandSet: $commandSet DominantSet: $dominantSet Parent: $parent Current: $current Unused Boolean Value: $_)))

        (($zeroSubsumeParent $zeroSubsumeCurrent $appliedZeroSubsume) (zeroConstraintSubsume $parent $current)) ;; Apply 0-Subsume
        (($orCutParent $orCutCurrent $appliedOrCut) (orCut $zeroSubsumeParent $zeroSubsumeCurrent)) ;; Apply orCut



        ($children (getChildrenExp $current))
        (($firstChild $remainingChildren) (if (== $children ()) (() ()) (decons-atom $children)))

        ;; ($_ (println! (===ApplyOrTransformations Log===)))
        ;; ($_ (println! (0Subsume ==> Parent: $zeroSubsumeParent Current: $zeroSubsumeCurrent Applied: $appliedZeroSubsume)))
        ;; ($_ (println! (OrCut ==> Parent: $orCutParent Current: $orCutCurrent Applied: $appliedOrCut)))
        ;; ($_ (println! (Children: $children)))
        ;; ($_ (println! ""))
     )
     (if (any ($appliedZeroSubsume $appliedOrCut))
         ($commandSet $dominantSet ($orCutParent $orCutCurrent True)) ;; Returning the most up to date state.

         ;; Apply RTE on children until RTE is no longer being applied on any children.
        (let*
           (

            ;; ($_ (println! (===== Inside ApplyOrTransformations Before Until function ======)))

             (($dominantSet' $commandSet' ($finalUpdatedParent $finalUpdatedCurrent $bool) ($lastChild $rest)) (until hasNoNextChild applyReduceToEleganceToAnd ($commandSet $dominantSet ($parent $current False) ($firstChild $remainingChildren))))
                
            ;; ($_ (println! ("Inside ApplyOrTransformations After Until function")))
            ;; ($_ (println! ("FinalResult ==> FinalUpdatedParent:" $finalUpdatedParent "FinalUpdatedCurrent:" $finalUpdatedCurrent "Applied:" $bool)))
           )
           ($commandSet $dominantSet ($finalUpdatedParent $finalUpdatedCurrent $bool))
        )
     )
   )
)


;; The `until` step that applies reduceToElegance to each child of an AND node in turn.
;; It returns the state and the next child. The children are OR nodes, hence the name.
(= (applyReduceToEleganceToOr ($commandSet $dominantSet ($parent $prevCurrent $bool) ($currentChild $remainingChildren)))
   (if (!= $currentChild ())
       (let*
          (
             ;; ($_ (println! (===Inside ApplyReduceToEleganceToOr===)))
             ;; ($_ (println! (Parameters ==> CommandSet: $commandSet DominantSet: $dominantSet Parent: $parent PrevCurrent: $prevCurrent Bool: $bool CurrentChild: $currentChild RemainingChildren: $remainingChildren)))
             ;; ($_ (println! ""))

              ;; An AND's guard set DOMINATES its children, it does not command them: it is already
              ;; in $dominantSet, and feeding it here would erase a contradiction instead of letting
              ;; deleteInconsistentHandle delete the branch. (logical_rules.cc:715)
              ($localCommandSet (localCommandSet $currentChild (getChildrenExp $prevCurrent) () $commandSet)) ;; Compute local command set
              (($nextChild $restChildren) (if (== $remainingChildren ()) (() ()) (decons-atom $remainingChildren)))

              (($updatedCurrent $updatedChild $appliedRTE) (reduceToElegance $prevCurrent $currentChild $dominantSet $localCommandSet))
              (($promoteCurrent $promoteChild $appliedPromote) (promoteCommonConstraints $updatedCurrent $updatedChild))

              ;; ($_ (println! (Applied Promote ==> Current: $promoteCurrent Child: $promoteChild Applied: $appliedPromote)))

              ($grandChildren (getChildrenExp $promoteCurrent))
              (($firstGChild $remainingGChildren) (if (== $grandChildren ()) (() ()) (decons-atom $grandChildren)))

              (($finalUpdatedCurrent $appliedAndCut ($lastChild $rest)) (until hasNoNextChild applyAndCut ($promoteCurrent False ($firstGChild $remainingGChildren))))
              ($finalUpdatedParent (findAndReplace $prevCurrent $finalUpdatedCurrent $parent))

              ;; ($_ (println! (Applied AndCut==> FinalupdatedCurrent: $finalUpdatedCurrent FinalUpdatedParent: $finalUpdatedParent AppliedAndCut: $appliedAndCut)))

              ($updatedChildren (getChildrenExp $finalUpdatedCurrent))
              (($updatedFirstChild $updatedRestChildren) (if (== $updatedChildren ()) (() ()) (decons-atom $updatedChildren)))

              ;; $bool tells whether an RTE was applied anywhere in the whole iteration.
              ($applied (any ($appliedRTE $bool $appliedAndCut)))

              ;; ($_ (println! (===ApplyReduceToEleganceToOr Log===)))
              ;; ($_ (println! (Children: (getChildrenExp $prevCurrent) GuardSet: (getGuardSet $prevCurrent))))
              ;; ($_ (println! (NextChild: $nextChild RestChildren: $restChildren)))
              ;; ($_ (println! (UpdatedCurrent: $updatedCurrent UpdatedChild: $updatedChild AppliedRTE: $appliedRTE)))
              ;; ($_ (println! (ReturnValue: $returnValue)))
              ;; ($_ (println! ""))

          )
          ;; Resetting is needed only when a transformation is applied in this state.
          ;; It shouldn't be influenced by previous iteration.
          (let $next (if (any ($appliedRTE $appliedAndCut))
                         ($updatedFirstChild $updatedRestChildren)
                         ($nextChild $restChildren))
            ($commandSet $dominantSet ($finalUpdatedParent $finalUpdatedCurrent $applied) $next))
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
(= (localCommandSet $child $parentChildren $parentGuardSet $commandSet)
   (case ($parentChildren $parentGuardSet)
     (
        ((() ()) $commandSet)
        ($else
          (let*
            (
              ;; ($_ (println! (===Inside LocalCommandSet===)))
              ;; ($_ (println! (Parameters ==> Child: $child ParentChildren: $parentChildren ParentGuardSet: $parentGuardSet CommandSet: $commandSet)))
              ;; ($_ (println! ""))

              ;; removeElement, filter-atom and map-atom map () to ().
              ($siblings (removeElement ($child) $parentChildren))
              ($filteredGuardSet (removeElement ($child) $parentGuardSet))
              ($filteredSiblings (filter-atom $siblings filterTerminalAndNode))
              ($siblingsGuardSet (map-atom $filteredSiblings $fSib (getGuardSetND $fSib)))
              ($totalGuardSet (concatTuple $filteredGuardSet $siblingsGuardSet))
              ($localCommandSet (unique-atom (union-atom $totalGuardSet $commandSet)))
              

              ;; ($_ (println! (=== LocalCommandSet Log ===)))
              ;; ($_ (println! (Siblings: $siblings)))
              ;; ($_ (println! (FilteredGuardSet $filteredGuardSet)))
              ;; ($_ (println! (FilteredSiblings $filteredSiblings)))
              ;; ($_ (println! (SiblingsGuardSet $siblingsGuardSet)))
              ;; ($_ (println! (TotalGuardSet: $totalGuardSet)))
              ;; ($_ (println! (LocalCommandSet: $localCommandSet)))
              ;; ($_ (println! ""))
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
        ((AND (NOT $x)) True)
        ((AND $x) (== (get-metatype $x) Symbol))
        ($else False)
     )
   )
)


;; The stop predicate of the child loops: True when no next child is left.
;; The 3-tuple clause serves the applyOrCut and applyAndCut loops. The 4-tuple clause
;; serves the applyReduceToEleganceToOr and applyReduceToEleganceToAnd loops.
(= (hasNoNextChild ($parent $bool ($child $remainingChildren))) (== $child ()))
(= (hasNoNextChild ($dominantSet' $commandSet' ($finalUpdatedParent $finalUpdatedCurrent $bool) ($nextChild $remainingChildren))) (== $nextChild ()))

(= (reduceNotApplied ($parent $current $applied)) 

  ;; ($_ (println! (=== Inside ReduceNotApplied ===)))
  ;; ($_ (println! (Parameters ==> Parent: $parent Current: $current Applied: $applied)))

  (not $applied)
  )

(= (applyReduce ($parent $current $applied))
   ;; A constant is already elegant; re-normalising would wrap it as (AND FALSE) for nothing.
   ;; Bare (OR) is data only because this file loads before scoring/boolean-ops.
   (if (isConstant $current)
       ($current $current False)
   (if (== $current (OR))
       ((OR) (OR) False)
   (let*
         (
            ;; ($_ (println! (==== Inside ApplyReduce ====)))
            ;; ($_ (println! (Parameters ==> Parent: $parent Current: $current Applied: $applied)))
            
            ($propNotExpr (propagateNot $current))
            ($gatherJunctorExpr (gatherJunctors $propNotExpr))
            ($initAdd (addAND $gatherJunctorExpr))
            ($wrappedAdd (addAND $initAdd True))
            ;; Must follow addAND: its wrapping is what creates most duplicates, and
            ;; (OR (AND B) B) -> (OR (AND B) (AND B)) desynchronises the OR walker.
            ($finalAdd (dedupSiblings $wrappedAdd))
            ($finalParent (findAndReplace $current $finalAdd $parent))

           ;; ($_ (println! (==== ApplyReduce Log ====)))
           ;; ($_ (println! (PropNotExpr: $propNotExpr)))
           ;; ($_ (println! (GatherJunctorsResult $gatherJunctorExpr)))
           ;; ($_ (println! (Initial Add: $initAdd)))
           ;; ($_ (println! (FinalAdd Result: $finalAdd)))
           ;; ($_ (println! (FinalParent: $finalParent)))
        )
         ;; Propagate the constants this round created. A transformation only ever sees
         ;; ($parent $current), so a constant that cannot collapse upward from where it was
         ;; emitted needs this whole-tree pass. $rteApplied passes through: this is cleanup.
         (let ($rteParent $rteCurrent $rteApplied) (reduceToElegance $finalParent $finalAdd () ())
              ((applyConstantLaws $rteParent) (applyConstantLaws $rteCurrent) $rteApplied))
         ))))

;; Unwraps the single-literal AND nodes that addAND made: (AND A) -> A, (AND (NOT A)) -> (NOT A).
;; The (AND $x)/(NOT $y) patterns and the bare (AND $rest) build are data only because
;; this file loads before scoring/boolean-ops.
(= (removeAndNodesFromGuards $expr)
   (if (== (get-metatype $expr) Symbol)
       $expr
       (if (= $expr (AND $x))
           (if (or (= $x (NOT $y)) (== (get-metatype $x) Symbol))
               $x
               (let $rest (removeAndNodesFromGuards $x) (AND $rest))
           )
           (let* ((($head $rest) (decons-atom $expr))
                  ($updatedRest (map-atom $rest $exp (removeAndNodesFromGuards $exp))))
             (cons-atom $head $updatedRest))
         )
     )
)
         
(= (reduce-to $expr)
   (let*
     (
      (($parent $_current $_applied) (until reduceNotApplied applyReduce ($expr $expr True)))
      (($newParent $_newCurrent $_newApplied) (applyReduce ($parent $parent True))) ;; Try one more time in case it is still reducible
     )
     (if (== $newParent $parent)
         (removeAndNodesFromGuards $parent)
         (reduce-to $newParent))))

