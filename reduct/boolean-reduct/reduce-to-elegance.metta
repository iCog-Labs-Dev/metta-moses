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
; (: reduceToElegance (-> Expression Expression Expression Expression (Expression Expression Bool)))
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
                      ;($_ (println! (===Inside RTE AND case===)))
                      ; ($_ (println! (Parameters ==> Parent: $parent Current: $current DominantSet: $dominantSet CommandSet: $commandSet)))
                      ; ; ($_ (println! ""))

                      ($guardSet (eval (getGuardSet $current)))
                      ; ($_ (println! (GuardSet of Current: $guardSet)))
                      ($children (eval (getChildrenExp $current)))
                      ;($_ (println! (Children of Current: $children)))

                      ;; TODO: Replace the setDifference function with non deterministic functions
                      ($updatedGuardSet (eval (setDifference $guardSet $dominantSet))) ;; Apply Redundant to current
                      ;; TODO: Replace this 1CCS application with the correct logic in it's own function.
                      ($updatedGuardSet' (eval (setDifference $updatedGuardSet $commandSet))) ;; Apply 1-Constraint-Complement-Subtraction
                      ($appliedRedundantOr1CC (or (not (== $updatedGuardSet $guardSet)) (not (== $updatedGuardSet' $updatedGuardSet)))) ;; Storing this state to return boolean indicating RTE is applied or not.

                      
                      ($updatedSubExpression (eval (concatTuple $updatedGuardSet' $children)))   
                      ($updatedCurrent (cons-atom AND $updatedSubExpression))
                      ($updatedParent (eval (findAndReplace $current $updatedCurrent $parent)))
                      ; ((($oneSubsumeParent $oneSubsumeCurrent $appliedOneSubsume)) (oneConstraintSubsume $updatedParent $updatedCurrent $commandSet)) ;; Apply 1-Subsume.
                      ($temp (eval (oneConstraintSubsume $updatedParent $updatedCurrent $commandSet))) ;; Apply 1-Subsume.
                      ;($_ (println! (Result: $temp)))
                      (($oneSubsumeParent $oneSubsumeCurrent $appliedOneSubsume) $temp)
                      ; ($_ (println! (===RTE AND CASE Log===)))
                      ; ($_ (println! (GuardSet: $guardSet Children: $children UpdatedGuardSet: $updatedGuardSet UpdatedGuardSetPrime: $updatedGuardSet')))
                      ; ($_ (println! (appliedRedundantOr1CC: $appliedRedundantOr1CC appliedOneSubsume: $appliedOneSubsume)))
                      ; ($_ (println! ""))

                      ;; until no transformation is applied
                      ;;    compute dominantSet
                      ;;    deleteInconHandle.
                      ;;    andCut.
                      ;;    apply RTE on children.
                      ;; 0-Subsume Variation
                      (($unwt3 $unwt2 ($updatedParent' $updatedCurrent' $bool))
                         (if $appliedOneSubsume ;; If 1-Subsume is applied Current will be deleted so no need to iterate.
                             ($dominantSet $commandSet ($oneSubsumeParent $oneSubsumeCurrent True))
                             (eval (until transformationsNotApplied applyAndTransformations ($commandSet $dominantSet ($updatedParent $updatedCurrent True))))))

                      ; ($_ (println! (FinalResult ==> UpdatedParent': $updatedParent' UpdatedCurrent: $updatedCurrent' AppliedRTE: (any ($appliedRedundantOr1CC $appliedOneSubsume $bool)))))
                      ; ($_ (println! (calling 0-Subsume Variation on Parent: $updatedParent' Current: $updatedCurrent')))
                      ($childFromParent (if (== $updatedCurrent' ()) (cdr-atom $updatedParent') $updatedCurrent'))
                      ($zeroCurrent (let $h (car-atom $childFromParent) (if (== (get-metatype $h) Expression) $h $childFromParent)))
                      ; ($_ (println! (zeroCurrent: $zeroCurrent)))
                      (($finalParent $finalCurrent $finalBool) (eval (zeroConstraintSubsume' $updatedParent' $zeroCurrent))) ;; Apply 0-Subsume variation.
                      ($finalCurrent' (if (== $finalCurrent ()) (AND) $finalCurrent))
                      ; ($_ (println! (Final Result ==> FinalParent: $finalParent FinalCurrent: $finalCurrent' AppliedRTE: (eval (any ($appliedRedundantOr1CC $appliedOneSubsume $bool $finalBool))))))
                      ; ($_ (println! ""))
                    )
                    ($finalParent $finalCurrent' (eval (any ($appliedRedundantOr1CC $appliedOneSubsume $bool $finalBool))))
                  )
                )
                (OR
                  (let*
                    (
                      ;  ($_ (println! (===Inside RTE OR case===)))
                      ;  ($_ (println! (Parameters ==> Parent: $parent Current: $current DominantSet: $dominantSet CommandSet: $commandSet)))

                     (($promoteParent $promoteCurrent $appliedPromote) (eval (promoteCommonConstraints $parent $current))) ;; Apply promote
                     
                      ;  ($_ (println! (Promote ==> Parent: $promoteParent Current: $current Applied: $appliedPromote)))

                      ;;until no transformation is applied.
                      ;;    compute commandSet
                      ;;    0-Subsume
                      ;;    orCut
                      ;;    apply RTE on children.
                     (($x $xs ($updatedParent $updatedCurrent $bool)) (eval (until transformationsNotApplied applyOrTransformations ($commandSet $dominantSet ($promoteParent $promoteCurrent True)))))
                     (($finalUpdatedParent $finalUpdatedCurrent $finalBool) (eval (zeroConstraintSubsume' $updatedParent $updatedCurrent)))

                    ; ($_ (println! (===RTE OR CASE Log===)))
                    ; ($_ (println! (Promote ==> Parent: $promoteParent Current: $promoteCurrent Applied: $appliedPromote)))
                    ; ($_ (println! (RTE Result ==> UpdatedParent: $updatedParent UpdatedCurrent: $updatedCurrent AppliedRTE: (any ($bool $appliedPromote)))))
                    ; ($_ (println! (Final Result ==> FinalUpdatedParent: $finalUpdatedParent FinalUpdatedCurrent: $finalUpdatedCurrent AppliedRTE: (any ($bool $finalBool $appliedPromote)))))
                    ;; ($_ (println! ""))

                    )
                    ($finalUpdatedParent $finalUpdatedCurrent (eval (any ($bool $finalBool $appliedPromote))))
                  )
                )
              )
            )
        )
      )
   )
)

;; A helper function to check if a transformation is applied or not given the state of the OR node transformations.
; (: transformationsNotApplied (-> (Expression Expression (Expression Expression Bool)) Bool))
(= (transformationsNotApplied ($dummy $dummy2 ($parent $current $bool))) (not $bool))

;; A helper function to apply delInconHandle and andCut transformation functions.
;; It will also apply reduce to elegance algorithm on each of the children of the POA.
; (: applyAndTransformations (-> (Expression Expression (Expression Expression Bool)) (Expression Expression Bool)))
(= (applyAndTransformations ($commandSet $dominantSet ($parent $current $unwt)))
   (let*
     (
        ; ($_ (println! (===Inside ApplyAndTransformations===)))
        ; ($_ (println! (Parameters ==> CommandSet: $commandSet DominantSet: $dominantSet Parent: $parent Current: $current)))
        ; ($_ (println! ""))

        ($guardSet (eval (getGuardSet $current)))
        ($children (eval (getChildrenExp $current)))
        ; ($_ (println! (GuardSet of Current: $guardSet)))
        ; ($_ (println! (Children of Current: $children)))

        ($firstChild (if (not (== $children ())) (car-atom $children) ()))
        ($remainingChildren (if (not (== $firstChild ())) (cdr-atom $children) ()))

        ($handleSet (unique-atom (union-atom $guardSet $dominantSet))) ;; Compute new dominantSet
        
        ; ($_ (println! ("Parent before Delete:" $parent)))
        (($delInconHandleParent $delInconHandleCurrent $appliedDelInconHandle)  (eval (applyDeleteIncons $parent $current $handleSet))) ;; This handles multi layer nested expressions.
        ; ($_ (println! ("Parent after Delete:" $delInconHandleParent)))

        ;; INFO: Applying andCut here may be a redundant operation. And could be potentially omitted.
        (($andCutParent $andCutCurrent $appliedAndCut) (eval (andCut $delInconHandleParent $delInconHandleCurrent))) ;; Apply andCut

        ; ($_ (println! (===ApplyAndTransformations Log===)))
        ; ($_ (println! (GuardSet: $guardSet Children: $children HandleSet: $handleSet)))
        ; ($_ (println! (DelInconHandle ==> Parent: $delInconHandleParent Current: $delInconHandleCurrent appliedDelInconHandle: $appliedDelInconHandle)))
        ; ($_ (println! (AndCut ==> Parent: $andCutParent Current: $andCutCurrent appliedAndCut: $appliedAndCut)))
        ; ($_ (println! (Children: $children FirstChild: $firstChild RemainingChildren: $remainingChildren)))
        ; ($_ (println! (AppliedDelInconHandle: $appliedDelInconHandle AppliedAndCut: $appliedAndCut)))
        ; ; ($_ (println! ""))
     )
     (if (or $appliedDelInconHandle $appliedAndCut)
         ($commandSet $dominantSet ($andCutParent $andCutCurrent True)) ;; Returning the most up to date state.

         ;; Apply RTE on children
         (let*
           (
              (($commandSet'' $dominantSet'' ($updatedParent $updatedCurrent $appliedRTE))
                (if (not (== $children ()))
                    (let*
                          (
                            ; ($_ (println! (===== Inside ApplyAndTransformations Before Until function ======)))
                            (($dominantSet' $commandSet' ($finalUpdatedParent $finalUpdatedCurrent $bool) ($lastChild $lastRemainingChild)) (eval (until hasNoNextChild applyReduceToEleganceToOr ($commandSet $handleSet ($parent $current False) ($firstChild $remainingChildren)))))

                            ; ($_ (println! ("Applyed reduceToElegance ==> FinalUpdatedParent:" $finalUpdatedParent "FinalUpdatedCurrent: " $finalUpdatedCurrent "AppliedRTE: " $bool)))

                            ($grandChildren (eval (getChildrenExp $finalUpdatedCurrent)))
                            ($firstGrandChild (if (not (== $grandChildren ())) (car-atom $grandChildren) ()))
                            ($remainingGChildren (if (not (== $firstGrandChild ())) (cdr-atom $grandChildren) ()))

                            ; ($_ (println! (Applying OrCut to GrandChildren: $grandChildren)))

                            ;; Apply OrCut to children of the updatedCurrent here.
                            (($finalUpdatedCurrent' $appliedOrCut ($lastGChild $restGChildren)) (eval (until hasNoNextChild applyOrCut ($finalUpdatedCurrent False ($firstGrandChild $remainingGChildren)))))
                            ($finalUpdatedParent' (eval (findAndReplace $finalUpdatedCurrent $finalUpdatedCurrent' $finalUpdatedParent)))

                            ; ($_ (println! (AppliedOrCut: $appliedOrCut FinalUpdatedCurrent': $finalUpdatedCurrent' FinalUpdatedParent': $finalUpdatedParent')))
                            ; ($_ (println! (LastChild: $lastChild LastRemainingChild: $lastRemainingChild)))
                          )
                        ($commandSet' $dominantSet' ($finalUpdatedParent' $finalUpdatedCurrent' (or $bool $appliedOrCut)))
                    )
                    ($commandSet $dominantSet ($parent $current False))
                )
              )
              ; ($_ (println! (Outside of the If block)))
              ; ($_ (println! (UpdatedParent: $updatedParent UpdatedCurrent: $updatedCurrent AppliedRTE: $appliedRTE)))
              ; ($_ (println! ($commandSet'')))
              ; ; ($_ (println! ""))
           )
           (trace! ("commandSet: " $commandSet "DomainSet: " $dominantSet) ($commandSet $dominantSet ($updatedParent $updatedCurrent $appliedRTE)))
         )
     )
   )
)

;; A helper function to apply reduceToElegance using foldl. It behaves like a lambda function.
;; This function is specific for the AND node case of the reduce to elegance function.
;;($commandSet $dominantSet ($parent $current False) ($firstChild $remainingChildren))
; (: applyReduceToEleganceToAnd (-> (Expression Expression (Expression Expression Bool) (Expression Expression)) (Expression Expression (Expression Expression Bool) (Expression Expression))))
(= (applyReduceToEleganceToAnd ($commandSet $dominantSet ($parent $prevCurrent $bool) ($firstChild $remainingChildren)))
   (let*
     (
        ; ($_ (println! (===Inside ApplyReduceToEleganceToAND===)))
        ; ($_ (println! (Parameters ==> CommandSet: $commandSet DominantSet: $dominantSet Parent: $parent PrevCurrent: $prevCurrent Bool: $bool FirstChild: $firstChild RemainingChildren: $remainingChildren)))
        ; ($_ (println! ""))

        ($nextChild (if (not (== $remainingChildren ())) (car-atom $remainingChildren) ()))
        ($rest (if (not (== $remainingChildren ())) (cdr-atom $remainingChildren) ()))


        (($updatedCurrent $updatedChild $appliedRTE) (eval (reduceToElegance $prevCurrent $firstChild $dominantSet $commandSet)))
        ($updatedParent (eval (findAndReplace $prevCurrent $updatedCurrent $parent)))

        ($updatedChildren (eval (getChildrenExp $updatedCurrent)))
        ($resetNextChild (if (not (== $updatedChildren ())) (car-atom $updatedChildren) ()))
        ($resetRemainingChildren (if (not (== $resetNextChild ())) (cdr-atom $updatedChildren) ()))

        ; ($_ (println! (===ApplyReduceToEleganceToAND Log===)))
        ; ($_ (println! (UpdatedParent: $updatedParent UpdatedCurrent: $updatedCurrent UpdatedChild: $updatedChild AppliedRTE: $appliedRTE)))
        ; ($_ (println! (Reset iteration: $appliedRTE)))
        ;; ($_ (println! ""))
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
; (: applyOrTransformations (-> (Expression Expression (Expression Expression Bool)) (Expression Expression (Expression Expression Bool))))
(= (applyOrTransformations ($commandSet $dominantSet ($parent $current $bl)))
   (let*
     (
        ; ($_ (println! (===Inside ApplyOrTransformations===)))
        ; ($_ (println! (Parameters ==> CommandSet: $commandSet DominantSet: $dominantSet Parent: $parent Current: $current Unused Boolean Value: $_)))

        (($zeroSubsumeParent $zeroSubsumeCurrent $appliedZeroSubsume) (eval (zeroConstraintSubsume $parent $current))) ;; Apply 0-Subsume
        (($orCutParent $orCutCurrent $appliedOrCut) (eval (orCut $zeroSubsumeParent $zeroSubsumeCurrent))) ;; Apply orCut



        ($children (eval (getChildrenExp $current)))
        ($firstChild (if (not (== $children ())) (car-atom $children) ()))
        ($remainingChildren (if (not (== $firstChild ())) (cdr-atom $children) ()))

        ; ($_ (println! (===ApplyOrTransformations Log===)))
        ; ($_ (println! (0Subsume ==> Parent: $zeroSubsumeParent Current: $zeroSubsumeCurrent Applied: $appliedZeroSubsume)))
        ; ($_ (println! (OrCut ==> Parent: $orCutParent Current: $orCutCurrent Applied: $appliedOrCut)))
        ; ($_ (println! (Children: $children)))
        ;; ($_ (println! ""))
     )
    ;  (if (any ($appliedZeroSubsume $appliedZeroSubsume' $appliedOrCut)))
     (if (eval (any ($appliedZeroSubsume $appliedOrCut)))
         ($commandSet $dominantSet ($orCutParent $orCutCurrent True)) ;; Returning the most up to date state.

         ;; Apply RTE on children until RTE is no longer being applied on any children.
        (let*
           (

            ;  ($_ (println! (===== Inside ApplyOrTransformations Before Until function ======)))

             (($dominantSet' $commandSet' ($finalUpdatedParent $finalUpdatedCurrent $bool) ($lastChild $rest)) (eval (until hasNoNextChild applyReduceToEleganceToAnd ($commandSet $dominantSet ($parent $current False) ($firstChild $remainingChildren)))))
                
            ;  ($_ (println! ("Inside ApplyOrTransformations After Until function")))
            ;  ($_ (println! ("FinalResult ==> FinalUpdatedParent:" $finalUpdatedParent "FinalUpdatedCurrent:" $finalUpdatedCurrent "Applied:" $bool)))
           )
           ($commandSet $dominantSet ($finalUpdatedParent $finalUpdatedCurrent $bool))
        )
     )
   )
)


;; A helper function to apply reduceToElegance to the currentChild and return the nextChild in addtion to the state. It behaves like a lambda function.
;; The implementation of this function has many paramters to make it suitable to use with the already implemented until function.
;; This function is specific for the OR node case of the reduce to elegance function.
; (: applyReduceToEleganceToOr (-> (Expression Expression (Expression Expression Bool) (Expression Expression)) (Expression Expression (Expression Expression Bool))))
(= (applyReduceToEleganceToOr ($commandSet $dominantSet ($parent $prevCurrent $bool) ($currentChild $remainingChildren)))
   (if (not (== $currentChild ()))
       (let*
          (
             ; ($_ (println! (===Inside ApplyReduceToEleganceToOr===)))
             ; ($_ (println! (Parameters ==> CommandSet: $commandSet DominantSet: $dominantSet Parent: $parent PrevCurrent: $prevCurrent Bool: $bool CurrentChild: $currentChild RemainingChildren: $remainingChildren)))
              ; ($_ (println! ""))

              ($localCommandSet (eval (localCommandSet $currentChild (eval (getChildrenExp $prevCurrent)) (eval (getGuardSet $prevCurrent)) $commandSet))) ;; Compute local command set
              ($nextChild (if (not (== $remainingChildren ())) (car-atom $remainingChildren) ()))
              ($restChildren (if (not (== $nextChild ())) (cdr-atom $remainingChildren) ()))

              (($updatedCurrent $updatedChild $appliedRTE) (eval (reduceToElegance $prevCurrent $currentChild $dominantSet $localCommandSet)))
              (($promoteCurrent $promoteChild $appliedPromote) (eval (promoteCommonConstraints $updatedCurrent $updatedChild)))

              ; ($_ (println! (Applied Promote ==> Current: $promoteCurrent Child: $promoteChild Applied: $appliedPromote)))

              ($grandChildren (eval (getChildrenExp $promoteCurrent)))
              ($firstGChild (if (not (== $grandChildren ())) (car-atom $grandChildren) ()))
              ($remainingGChildren (if (not (== $firstGChild ())) (cdr-atom $grandChildren) ()))

              (($finalUpdatedCurrent $appliedAndCut ($lastChild $rest)) (eval (until hasNoNextChild applyAndCut ($promoteCurrent False ($firstGChild $remainingGChildren)))))
              ($finalUpdatedParent (eval (findAndReplace $prevCurrent $finalUpdatedCurrent $parent)))

              ; ($_ (println! (Applied AndCut==> FinalupdatedCurrent: $finalUpdatedCurrent FinalUpdatedParent: $finalUpdatedParent AppliedAndCut: $appliedAndCut)))

              ($updatedChildren (eval (getChildrenExp $finalUpdatedCurrent)))
              ($updatedFirstChild (if (not (== $updatedChildren ())) (car-atom $updatedChildren) ()))
              ($updatedRestChildren (if (not (== $updatedFirstChild ())) (cdr-atom $updatedChildren) ()))

              ;; The $bool here is useful to determine whether an RTE is applied or not through out the entire iteration.
              ($returnValue ($commandSet $dominantSet ($finalUpdatedParent $finalUpdatedCurrent (eval (any ($appliedRTE $bool $appliedAndCut)))) ($nextChild $restChildren)))

              ; ($_ (println! (===ApplyReduceToEleganceToOr Log===)))
              ; ($_ (println! (Children: (getChildrenExp $prevCurrent) GuardSet: (getGuardSet $prevCurrent))))
              ; ($_ (println! (NextChild: $nextChild RestChildren: $restChildren)))
              ; ($_ (println! (UpdatedCurrent: $updatedCurrent UpdatedChild: $updatedChild AppliedRTE: $appliedRTE)))
              ; ($_ (println! (ReturnValue: $returnValue)))
              ; ($_ (println! ""))

          )
          ;; Resetting is needed only when a transforamtion is applied in this state.
          ;; It shouldn't be influenced by previous iteration.
          (if (eval (any ($appliedRTE $appliedAndCut)))
              ;; Resetting iteration if promote or RTE is applied.
              ($commandSet $dominantSet ($finalUpdatedParent $finalUpdatedCurrent (eval (any ($appliedRTE $bool $appliedAndCut)))) ($updatedFirstChild $updatedRestChildren))
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
; (: localCommandSet (-> Expression Expression Expression Expression Expression))
(= (localCommandSet $child $parentChildren $parentGuardSet $commandSet)
   (case ($parentChildren $parentGuardSet)
     (
        ((() ()) $commandSet)
        ($else
          (let*
            (
              ; ($_ (println! (===Inside LocalCommandSet===)))
              ; ($_ (println! (Parameters ==> Child: $child ParentChildren: $parentChildren ParentGuardSet: $parentGuardSet CommandSet: $commandSet)))
              ;; ($_ (println! ""))

              ($siblings (if (not (== $parentChildren ()))  (eval (removeElement ($child) $parentChildren)) ()))
              ($filteredGuardSet (if (not (== $parentGuardSet ())) (eval (removeElement ($child) $parentGuardSet)) ()))
              ($filteredSiblings (if (not (== $siblings ())) (collapse (eval (filterTerminalAndNode (superpose $siblings)))) ()))
              ($siblingsGuardSet (if (not (== $filteredSiblings ())) (collapse (eval (getGuardSetND (superpose $filteredSiblings)))) ()))
              ($totalGuardSet (eval (concatTuple $filteredGuardSet $siblingsGuardSet)))
              ; ($localCommandSet (collapse (unique (union (superpose $totalGuardSet) (superpose $commandSet)))))
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
        ((AND (NOT $x)) $node)
        ((AND $x) (if (== (get-metatype $x) Symbol) $node (empty)))
        ($else (empty))
     )
   )
)


;; A helper predicate function to be used in the until function. It checks if there is no next child.
;; It could be replace using a lambda function, if it exists.
; (: hasNoNextChild (-> (Expression Bool (Expression Expression)) Bool))
; (: hasNoNextChild (-> (Expression Expression (Expression Expression Bool) (Expression Expression))))
(= (hasNoNextChild ($parent $bool ($child $remainingChildren))) (== $child ()))
(= (hasNoNextChild ($dominantSet' $commandSet' ($finalUpdatedParent $finalUpdatedCurrent $bool) ($nextChild $remainingChildren))) (== $nextChild ()))

; (: reduceNotApplied (-> (Expression Expression Bool) Bool))
(= (reduceNotApplied ($parent $current $applied)) 

  ; (let* (
  ;     ; ($_ (println! (=== Inside ReduceNotApplied ===)))
  ;     ; ($_ (println! (Parameters ==> Parent: $parent Current: $current Applied: $applied)))
  ; ) (not $applied))

  (not $applied)
  )

;; (= (reduce $expr) (trace! (Running reduce with $expr) (let ($parent $__ $applied) (reduceToElegance $expr $expr () ()) (trace! (Result: ($parent $__ $applied)) (if $applied (reduce $parent) $parent)))))
;; (= (reduce $expr) (let ($parent $__ $applied) (reduceToElegance $expr $expr () ()) (trace! (Result: ($parent $__ $applied)) (if $applied (reduce $parent) $parent))))
; (: applyReduce (-> (Expression Expression Bool) (Expression Expression Bool)))
(= (applyReduce ($parent $current $applied))
   (let*
         (
            ($_ (println! (==== Inside ApplyReduce ====)))
            ($_ (println! (Parameters ==> Parent: $parent Current: $current Applied: $applied)))
            
            ($propNotExpr (eval (propagateNot $current)))
            ($gatherJunctorExpr (eval (gatherJunctors $propNotExpr)))
            ($initAdd (eval (addAND $gatherJunctorExpr)))
            ($finalAdd (eval (addAND $initAdd True)))
            ($finalParent (eval (findAndReplace $current $finalAdd $parent)))

           ($_ (println! (==== ApplyReduce Log ====)))
           ($_ (println! (PropNotExpr: $propNotExpr)))
           ($_ (println! (GatherJunctorsResult $gatherJunctorExpr)))
           ($_ (println! (Initial Add: $initAdd)))
           ($_ (println! (FinalAdd Result: $finalAdd)))
           ($_ (println! (FinalParent: $finalParent)))
        )
         (eval (reduceToElegance $finalParent $finalAdd () ()))
         ))
         
(= (reduce-to $expr) 
   (let ($parent $uwnt $uwnt2) (eval (until reduceNotApplied applyReduce ($expr $expr True))) (let $_ (cut) $parent)))
