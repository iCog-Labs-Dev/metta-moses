;;;;;;;;;;;;;;;;; LSK Constructor ;;;;;;;;;;;;;;;;;;;;;;;;

;; Creates a Logical Subtree Knob (LSK) for a given tree, target node, and subtree.
;; Params:
;;  $tree: The tree structure where the logical subtree knob will be applied.
;;  $target: The parent node to which the LSK's place holder (null vertex) 
;;           will be added is pointed by the target node.
;;  $subtree: The subtree to be appended.
;; Returns:
;;  $tree 
;;  A LogicalSubtreeKnob (LSK) configured based on the subtree's presence or its appended state.
;; (:logicalSubtreeKnob (-> (Tree $a) NodeId (Tree $a) (Tree $a LogicalSubtreeKnob)))
(= (logicalSubtreeKnob $tree (mkNodeId $target) $subtree)
   (let*
   (
    ($negatedSubtree (insertAbove $subtree (mkNode NOT)))
    ;; ($_ (println! (NegatedSubtree----------------- : $negatedSubtree)))
    ($reducedSubtree (cleanTree $negatedSubtree)  )
    ;; ($_ (println! (ReducedSubtree---------------: $reducedSubtree))) 
    ($childrenOfTarget (getChildrenById $tree (mkNodeId $target)))
   )
   (if (== True (List.contains $subtree $childrenOfTarget))
       (let $idOfSubtree (getSubtreeId $tree (mkNodeId $target) $subtree 0)
           ($tree (mkDiscKnob (mkKnob (updateID $idOfSubtree)) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ()))
       )
       (if (== True (List.contains $reducedSubtree $childrenOfTarget))
           (let $idOfReducedSubtree (getSubtreeId $tree (mkNodeId $target) $reducedSubtree 0)
                ($tree (mkDiscKnob (mkKnob (updateID $idOfReducedSubtree)) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())))
           (let*
           (
            (($nullVexAppendedTree $nullVexId) (appendChild $tree (mkNodeId $target) (mkNullVex ())))
            (($subtreeAppendedTree $subtreeId) (appendChild $nullVexAppendedTree $nullVexId $subtree))
           )
           ($subtreeAppendedTree (mkDiscKnob (mkKnob (updateID $nullVexId)) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))
           )
       )
   )
   )
)
;; strategySubtreeKnob -> Creates Strategy Subtree Knob (SSK) for game moves
;; Params:
;;  $tree: The tree structure where the strategy subtree knob will be applied
;;  $target: The parent node to which the SSK's place holder will be added
;;  $subtree: The subtree to be appended (game move or strategy)
;; Returns: ($tree StrategySubtreeKnob)
;; (: strategySubtreeKnob (-> (Tree $a) NodeId (Tree $a) (Tree $a StrategySubtreeKnob)))
(= (strategySubtreeKnob $tree (mkNodeId $target) $subtree)
   (let $childrenOfTarget (getChildrenById $tree (mkNodeId $target))
       ;; Case 1: Subtree already exists in children
       (if (== True (List.contains $subtree $childrenOfTarget))
           (let $idOfSubtree (getSubtreeId $tree (mkNodeId $target) $subtree 0)
               ;; Create Knob: Multiplicity 2 (0=Absent, 1=Present). Default=1 (Present)
               ($tree (mkDiscKnob (mkKnob (updateID $idOfSubtree)) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ()))
           )
           ;; Case 2: New Subtree (Insert placeholder)
           (let*
               (
                   ;; Insert NullVertex placeholder
                   (($nullVexAppendedTree $nullVexId) (appendChild $tree (mkNodeId $target) (mkNullVex ())))
                   ;; Attach the actual subtree to the placeholder
                   (($subtreeAppendedTree $subtreeId) (appendChild $nullVexAppendedTree $nullVexId $subtree))
               )
               ($subtreeAppendedTree (mkDiscKnob (mkKnob (updateID $nullVexId)) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))
           )
       )
   )
)


;; actionSubtreeKnob: Creates an ActionSubtreeKnob (ASK) for the action domain.
;; Mirrors C++ action_subtree_knob(combo_tree& tr, iterator tgt, vector<combo_tree>& perms).
;; Always inserts a null-vertex placeholder at the target; perms are stored in the ASK object.
;; Setting 0 = absent (null vertex stays), Setting k >= 1 = perms[k-1].
;; Multiplicity = 1 + len(perms).
;; (: actionSubtreeKnob (-> (Tree $a) NodeId (List Tree) ((Tree $a) ActionSubtreeKnob)))
(= (actionSubtreeKnob $tree (mkNodeId $target) $perms)
   (let*
   (
    ($nPerms (List.length $perms))
    ($multiplicity (+ 1 $nPerms))
    (($nullVexAppendedTree $nullVexId) (appendChild $tree (mkNodeId $target) (mkNullVex ())))
   )
   ($nullVexAppendedTree
    (mkASK
     (mkDiscKnob (mkKnob (updateID $nullVexId)) (mkMultip $multiplicity) (mkDiscSpec 0) (mkDiscSpec 0) ())
     $perms))))

;; simpleActionSubtreeKnob: Creates a discrete knob for binary action presence.
;; Semantics normalized to match LSK/SSK: 0=absent, 1=present.
;; Multiplicity = 2.
;; (: simpleActionSubtreeKnob (-> (Tree $a) NodeId (Tree $a) ((Tree $a) DiscreteKnob)))
(= (simpleActionSubtreeKnob $tree (mkNodeId $target) $subtree)
   (let $childrenOfTarget (getChildrenById $tree (mkNodeId $target))
       (if (== True (List.contains $subtree $childrenOfTarget))
           ;; Action already in exemplar: default = 1 (present); inExemplar() = True → may be skipped
           (let $idOfSubtree (getSubtreeId $tree (mkNodeId $target) $subtree 0)
               ($tree (mkDiscKnob (mkKnob (updateID $idOfSubtree)) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ())))
           ;; Action not in exemplar: insert null vertex; default = 0 (absent); inExemplar() = False
           (let*
               (
                   (($nullVexAppendedTree $nullVexId) (appendChild $tree (mkNodeId $target) (mkNullVex ())))
                   (($subtreeAppendedTree $subtreeId) (appendChild $nullVexAppendedTree $nullVexId $subtree))
               )
               ($subtreeAppendedTree (mkDiscKnob (mkKnob (updateID $nullVexId)) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))))))

;; generalDiscreteKnob: Creates a GeneralDiscreteKnob (GDK) for any discrete atom domain.
;; Analogous to actionSubtreeKnob but stores atom symbols (e.g., OR, AND) instead of full trees.
;; Always inserts a null-vertex placeholder at the target; domain atoms are stored in the GDK.
;; Setting 0 = absent (null vertex stays), Setting k >= 1 = domain[k-1] as a leaf node.
;; Multiplicity = 1 + len(domain).
;; (: generalDiscreteKnob (-> (Tree $a) NodeId (List Atom) ((Tree $a) GeneralDiscreteKnob)))
(= (generalDiscreteKnob $tree (mkNodeId $target) $domain)
   (let*
   (
    ($nDomain (List.length $domain))
    ($multiplicity (+ 1 $nDomain))
    (($nullVexAppendedTree $nullVexId) (appendChild $tree (mkNodeId $target) (mkNullVex ())))
   )
   ($nullVexAppendedTree
    (mkGDK
     (mkDiscKnob (mkKnob (updateID $nullVexId)) (mkMultip $multiplicity) (mkDiscSpec 0) (mkDiscSpec 0) ())
     $domain))))

;; Retrieves the node ID from any discrete knob.
;; (: getNodeId (-> DiscreteKnob NodeId))
;; (: getNodeId (-> ActionSubtreeKnob NodeId))
;; (: getNodeId (-> GeneralDiscreteKnob NodeId))
(= (getNodeId (mkDiscKnob (mkKnob $nodeId) $multi $default $current $discSpecList))
   $nodeId)
(= (getNodeId (mkASK (mkDiscKnob (mkKnob $nodeId) $multi $default $current $discSpecList) $perms))
   $nodeId)
(= (getNodeId (mkGDK (mkDiscKnob (mkKnob $nodeId) $multi $default $current $discSpecList) $domain))
   $nodeId)

;; Retrieves the current and default disc specifications from a discrete knob.
;; (: getDiscSpec (-> DiscreteKnob (DiscSpec DiscSpec)))
(= (getDiscSpec (mkDiscKnob (mkKnob $nodeId) $multi $default $current $discSpecList))
    (let ((mkDiscSpec $def) (mkDiscSpec $cur)) ($default $current) ($def $cur)))


;; appendTo dispatcher - routes by multiplicity for bare DiscreteKnob; mkASK and mkGDK have their own handlers.
;; mult=3 → logical-style (absent/present/negated); mult=2 → binary-style (absent/present).
;; (: appendTo (-> (Tree $a) DiscreteKnob (Tree $a) NodeId Number (Tree $a)))
;; (: appendTo (-> (Tree $a) ActionSubtreeKnob (Tree $a) NodeId Number (Tree $a)))
;; (: appendTo (-> (Tree $a) GeneralDiscreteKnob (Tree $a) NodeId Number (Tree $a)))
(= (appendTo $updatedTree (mkDiscKnob $k (mkMultip $m) $c $d $dis) $tree $parentId $setting)
    (if (== $m 3)
        (appendToLSK $updatedTree (mkDiscKnob $k (mkMultip $m) $c $d $dis) $tree $parentId $setting)
        (appendToSSK $updatedTree (mkDiscKnob $k (mkMultip $m) $c $d $dis) $tree $parentId $setting)))
(= (appendTo $updatedTree (mkASK $discKnob $perms) $tree $parentId $d)
    (appendToASK $updatedTree (mkASK $discKnob $perms) $tree $parentId $d))
(= (appendTo $updatedTree (mkGDK $discKnob $domain) $tree $parentId $d)
    (appendToGDK $updatedTree (mkGDK $discKnob $domain) $tree $parentId $d))

    
;; Appends a subtree or a null vertex in place of a logical subtree 
;;  using information from the LSK and a knob setting specified.
;; Params:
;;  $lsk: The logical subtree knob containing information on how the subtree is appended to the original tree.
;;  $tree: An incomplete tree. It will be built using the tree with knobs as a
;;            reference and it may also contain knobs if $d is 0
;;  $parentId: The location where the new node will be added.
;;  $d: The current setting of the knob.
; (: appendToLSK (-> (Tree $a) LogicalSubtreeKnob (Tree $a) NodeId Number (Tree $a)))
(= (appendToLSK $updatedTree $lsk $tree $parentId $d)
    (let*
       (
        ; ($_ (println! (lsk: $lsk)))
        ;; ($_ (println! (ParentId: $parentId)))
        ;; ($_ (println! (D: $d)))
        ((mkNodeId $targetId) (getNodeId $lsk))
        ;; ($newPosition (index-atom $targetId (- (length $targetId) 1)))
        ((mkNodeId $dstId) (if (= (mkNodeId (0)) $parentId) (mkNodeId ()) $parentId))
        ($targetTree (getNodeById  $updatedTree (mkNodeId $targetId)))
        ($newPosition (+ (List.length (getChildren (getNodeById  $tree $parentId))) 1))
        ;; ($_ (println! (newPosition: $newPosition)))
        ;; ($_ (println! (if (== $targetId (1 1 1)) $targetTree NotPrinting)))
        (($subtree $newSrcId) (if (== True (isNullVertex $targetTree))
                        (let (mkNullVex (cons $child ())) $targetTree ($child (mkNodeId (union-atom $targetId (1)))))
                        ($targetTree (mkNodeId $targetId))
                    ))        
        ;; ($_ (println! ("subtree ": $subtree $targetTree)))
        ;; ($_ (println! (CandidateSoFar: (preOrder $tree))))
        ;; ($_ (println! ("subtree ": (getNodeValue $subtree) parentId(OldDstId): $parentId srcId: $newSrcId targetId: $targetId)))
      )
      (if (> $d 2)
          (Error $d "Invalid disc specification:- cannot exceed 2.")
          ;; TODO: Skip multiplicity 0, we don't want to convert the subtree into a null vertex. That will bring weird behavior like nested NullVertex and the like.
          ;;       In addition, this tree is a new candidate tree needed only to be evaluated, why do we need to process null vertexes here? We want to avoid adding any.
          (let ($treeToAppend $newDstId)
                            (case $d
                                (
                                  (2  ((mkTree (mkNode NOT) (cons (mkTree (getNodeValue $subtree) ()) ())) (mkNodeId (union-atom $dstId ($newPosition 1))))) ;; If negated
                                  (1  ((mkTree (getNodeValue $subtree) ()) (mkNodeId (union-atom $dstId ($newPosition))))) ;; If present
                                  (0  ((mkNullVex (cons $subtree ())) $parentId)))) ;; If absent

                            (if (isNullVertex $treeToAppend)
                                ($tree $parentId $parentId)
                                (chain (appendChild $tree $parentId $treeToAppend) $treeChIdPair
                                        ((first $treeChIdPair) $newSrcId (if (== $parentId $newDstId) (second $treeChIdPair) $newDstId)))))))) ;; INFO: Just incase if the append fails and stores the result somewhere else, we need to add a test case here to cmpare between targetNode and appendChild node.

;; appendTo for Strategy Subtree Knobs (SSK) - No negation for game moves
;; Params:
;;  $ssk: The strategy subtree knob containing information on how the subtree is appended
;;  $tree: An incomplete tree to be built
;;  $parentId: The location where the new node will be added
;;  $d: The current setting of the knob (0=Absent, 1=Present)
;; (: appendToSSK (-> (Tree $a) StrategySubtreeKnob (Tree $a) NodeId Number (Tree $a)))
(= (appendToSSK $updatedTree $ssk $tree $parentId $d)
    (let*
       (
        ;; ($_ (println! (lsk: $lsk)))
        ;; ($_ (println! (ParentId: $parentId)))
        ;; ($_ (println! (D: $d)))
        ((mkNodeId $targetId) (getNodeId $ssk))
        ((mkNodeId $dstId) (if (= (mkNodeId (0)) $parentId) (mkNodeId ()) $parentId))
        ;; ($_ (println! (DstId: $dstId)))
        ($targetTree (getNodeById  $updatedTree (mkNodeId $targetId)))
        ($newPosition (+ (List.length (getChildren (getNodeById  $tree $parentId))) 1))
        ;; ($_ (println! (newPosition: $newPosition)))
        ;; ($_ (println! (if (== $targetId (1 1 1)) $targetTree NotPrinting)))
        (($subtree $newSrcId) (if (== True (isNullVertex $targetTree))
                        (let (mkNullVex (cons $child ())) $targetTree ($child (mkNodeId (union-atom $targetId (1)))))
                        ($targetTree (mkNodeId $targetId))
                    ))        
        ;; ($_ (println! ("subtree ": $subtree $targetTree)))
        ;; ($_ (println! (CandidateSoFar: (preOrder $tree))))
        ;; ($_ (println! ("subtree ": (getNodeValue $subtree) parentId(OldDstId): $parentId srcId: $newSrcId targetId: $targetId)))
      )
      (if (> $d 1)
          (Error $d "Invalid disc specification for strategy:- cannot exceed 1.")
          (let ($treeToAppend $newDstId)
                            (case $d
                                (
                                  (1  ((mkTree (getNodeValue $subtree) ()) (mkNodeId (union-atom $dstId ($newPosition))))) ;; If present
                                  (0  ((mkNullVex (cons $subtree ())) $parentId)))) ;; If absent

                            (if (isNullVertex $treeToAppend)
                                ($tree $parentId $parentId)
                                (chain (appendChild $tree $parentId $treeToAppend) $treeChIdPair
                                        ((first $treeChIdPair) $newSrcId (if (== $parentId $newDstId) (second $treeChIdPair) $newDstId))))))))

;; appendToASK - applies an ActionSubtreeKnob setting to build the candidate.
;; Mirrors C++ action_subtree_knob::append_to.
;; Setting 0 = absent (null vertex; nothing appended to candidate).
;; Setting k >= 1 = append perms[k-1] (full tree) as child of parentId.
;; The full perm tree is appended at once; getCandidateRec will not recurse further
;; because the null-vertex placeholder in the exemplar has no children.
;; (: appendToASK (-> (Tree $a) ActionSubtreeKnob (Tree $a) NodeId Number ((Tree $a) NodeId NodeId)))
(= (appendToASK $updatedTree $ask $tree $parentId $d)
    (let*
       (
        ((mkNodeId $targetId) (getNodeId $ask))
        ((mkASK $discKnob $perms) $ask)
        ($nPerms (List.length $perms))
        ;; newSrcId points to the null-vertex in the exemplar — it has no children → no further recursion
        ($newSrcId (mkNodeId $targetId))
       )
       (if (== $d 0)
           ;; Setting 0: absent — candidate unchanged
           ($tree $parentId $parentId)
           (if (> $d $nPerms)
               (Error $d "Invalid action disc specification: exceeds number of permutations.")
               ;; Setting k: append the full perm tree wholesale to the candidate
               (let $perm (List.getByIdx (- $d 1) $perms)
                    (chain (appendChild $tree $parentId $perm) $treeChIdPair
                           ((first $treeChIdPair) $newSrcId (second $treeChIdPair))))))))

;; appendToGDK - applies a GeneralDiscreteKnob setting to build the candidate.
;; Setting 0 = absent (null vertex; nothing appended to candidate).
;; Setting k >= 1 = append leaf node for domain[k-1] as child of parentId.
;; (: appendToGDK (-> (Tree $a) GeneralDiscreteKnob (Tree $a) NodeId Number ((Tree $a) NodeId NodeId)))
(= (appendToGDK $updatedTree $gdk $tree $parentId $d)
    (let*
       (
        ((mkNodeId $targetId) (getNodeId $gdk))
        ((mkGDK $discKnob $domain) $gdk)
        ($nDomain (List.length $domain))
        ($newSrcId (mkNodeId $targetId))
       )
       (if (== $d 0)
           ($tree $parentId $parentId)
           (if (> $d $nDomain)
               (Error $d "Invalid GDK setting: exceeds domain size.")
               (let $atom (List.getByIdx $domain (- $d 1))
                    (chain (appendChild $tree $parentId (mkTree (mkNode $atom) ())) $treeChIdPair
                           ((first $treeChIdPair) $newSrcId (second $treeChIdPair))))))))

