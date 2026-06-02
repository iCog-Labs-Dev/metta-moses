;; siblingit => Iterate over list of Tree children and build logical knobs for each node
;; Extended to support PRIORITIZED-OR for game strategies
;;params:
;;       $tree: The tree being updated
;;       $childrens: List of children to iterate over.
;;       $parentId: ID of the parent node.
;;       $childNum: Current child number.
;;       $swapedOp: Swapped operator symbol.
;;       $MMap: Multimap to store disc_pec and knobs.
;;       $argLabels: list of argument labels (input variables) from the ITable
;; Return: Updated tree and multimap.
;; (: siblingit (-> (Tree $a) (List (Tree $a)) NodeId Number Symbol (MultiMap ($k $v)) Expression ((Tree $a) (MultiMap ($k $v)))))
(= (siblingit $tree () (mkNodeId $parentId) $childNum $swapedOp $MMap $argLabels) ($tree $MMap))
(= (siblingit $tree (cons $head $tail) (mkNodeId $parentId) $childNum $swapedOp $MMap $argLabels)
(siblingitAt $tree (cons $head $tail) (mkNodeId $parentId) $childNum $swapedOp $MMap $argLabels (mkNodeId $parentId) True))

(= (siblingitAt $tree () (mkNodeId $parentId) $childNum $swapedOp $MMap $argLabels $probeRootId $disable-discprobe) ($tree $MMap))
(= (siblingitAt $tree (cons $head $tail) (mkNodeId $parentId) $childNum $swapedOp $MMap $argLabels $probeRootId $disable-discprobe)
        (let*
             (
                ;; ($_ (println! "siblingit called"))
                ($curId (if (== $parentId (0))
                            ($childNum)
                           (concatT $parentId ($childNum))))
                ((mkTree (mkNode $node) $childern) $head)
                ;; ($_ (println!( "curId: " $curId "node :" $node)))
                ;; ($_ (println!( "head: " $head "tail :" $tail)))
                (($tNew  $mNew) (if (is-member $node (AND OR PRIORITIZED-OR));; only build logical knobs for AND/OR nodes, creating sampleLogicalPerms
                                    (if (== $node PRIORITIZED-OR)
                                        (buildStrategy $tree (mkNodeId $curId) $MMap $argLabels)
                                        (buildLogicalAt $tree $probeRootId (mkNodeId $curId) $MMap $argLabels $disable-discprobe))
                                        (if (== $swapedOp PRIORITIZED-OR)
                                            ;; Game move terminals - no transformation needed
                                            ($tree $MMap)
                                            ;; Boolean logic terminals - insert operator and add knobs
                                           (let  $itree (insertNodeAtPosition $tree (mkNodeId $curId) (mkNode $swapedOp))
                                                  (if (isAnArgument $node)
                                                      (addLogicalKnobsAt $itree $probeRootId (mkNodeId $curId) False $MMap $argLabels $disable-discprobe) ;; INFO: Due to the structure of the pointer in the classic, after adding a knob here, the iteration terminates and goes to the parent node even though there are still other siblings. For now this seemed to be the correct approach so living it as it is, but needs an investigation for later.
                                                      (addLogicalKnobsAt $itree $probeRootId (mkNodeId $curId) True $MMap $argLabels $disable-discprobe))))))
                ;;($_ (println! $tNew))
                (($tailT $tailM) (siblingitAt $tNew $tail (mkNodeId $parentId) (+ $childNum 1) $swapedOp $mNew $argLabels $probeRootId $disable-discprobe))
                
             )
             ($tailT $tailM)))

;; buildLogical => Build logical knobs for a given NodeId and its children
;;params:
;;       $tree: The tree being updated
;;       $nodeId: ID of the node to build logical knobs for.
;;       $MMap: Multimap to store disc_pec and knobs.
;;       $argLabels: list of argument labels (input variables) from the ITable
;; Return: Updated tree and multimap.
;; (: buildLogical (-> (Tree $a) NodeId (MultiMap ($k $v)) Expression ((Tree $a) (MultiMap ($k $v))))) 
(= (buildLogical $tree (mkNodeId $nodeId) $MMap $argLabels)
  (buildLogicalAt $tree (mkNodeId $nodeId) (mkNodeId $nodeId) $MMap $argLabels True))

(= (buildLogical $tree (mkNodeId $nodeId) $MMap $argLabels $disable-discprobe)
  (buildLogicalAt $tree (mkNodeId $nodeId) (mkNodeId $nodeId) $MMap $argLabels $disable-discprobe))

(= (buildLogicalAt $tree $probeRootId (mkNodeId $nodeId) $MMap $argLabels $disable-discprobe)
  (let $subtree (getNodeById $tree (mkNodeId $nodeId))
    (if (== True (isNullVertex $subtree))
        (let $x (println! ("reaching Null Vector ")) ($tree $MMap)) 
        (let*
        (
            ;; ($_ (println! (Started building at: (preOrder $subtree))))
            ;; ($_ (println! ("****************Building logical knobs for NodeId:**************** " $argLabels $nodeId)))
            ((mkTree (mkNode $op) $childrens) $subtree) 
            ($swapped (swapAndOr $op))
            ;; ($_ (println! ("Operator: " $op " swapped to: " $swapped)))
            (($t1 $mp1) (addLogicalKnobsAt $tree $probeRootId (mkNodeId $nodeId) True $MMap $argLabels $disable-discprobe))
            ;; ($_ (println! ("Building logical knobs for NodeId: " $nodeId " with operator: " $op " swapped to: " $swapped)))
            ;; ($_ (println! (Adding knobs to (List.length $childrens) childs)))
            ;; INFO: An attempt to replicate opencog's behavior but limits the quality drastically
            ;; (($sibToIterate $sibToConcat) (if (= $childrens ())
            ;;                                   (() ())
            ;;                                   (let (mkTree (mkNode $x) $grandChildren) (List.head $childrens) 
            ;;                                        (if (and (isAnArgument $x) (= $grandChildren ()))
            ;;                                            ((cons (List.head $childrens) ()) (List.tail $childrens))
            ;;                                            ($childrens ())))))
            ;; ($_ (println! (SibToIterate: $sibToIterate SibToConcat: $sibToConcat)))

            (($updatedTree $updatedMMap) (siblingitAt $t1 $childrens (mkNodeId $nodeId) 1 $swapped $mp1 $argLabels $probeRootId $disable-discprobe))
            ;; (($updatedTree $updatedMMap) (siblingit $t1 $sibToIterate (mkNodeId $nodeId) 1 $swapped $mp1 $argLabels))
            ;; (($childrenUpdatedTree $lastNewId) (eval (List.foldl (|-> ($childToAppend ($treeAcc $newId)) (appendChild $treeAcc (mkNodeId $nodeId) $childToAppend)) ($updatedTree (mkNodeId $nodeId))  $sibToConcat)))
            ;;$append (appendChild $updatedTree $nodeId (mkNode $filp)))                                 ;; this part will add much complexity to the tree, not worth the cost

            (($appendedTree $newId) (appendChild $updatedTree (mkNodeId $nodeId) (mkTree (mkNode $swapped) ())))
            ;; (($appendedTree $newId) (appendChild $childrenUpdatedTree (mkNodeId $nodeId) (mkTree (mkNode $swapped) ())))
            (($lastUpdatedTree $lastMp1) (addLogicalKnobsAt $appendedTree $probeRootId $newId True $updatedMMap $argLabels $disable-discprobe))
        )
            ($lastUpdatedTree $lastMp1)))))
;; buildAction => Build knobs for the action domain (SEQUENTIAL-AND / ACTION-BOOLEAN-IF trees).
;; Mirrors C++ build_knobs::build_action.
;; For SEQUENTIAL-AND nodes: adds one ActionSubtreeKnob with all action permutations,
;;   iterates children to add SimpleActionSubtreeKnobs for existing actions,
;;   and appends an empty SEQUENTIAL-AND node for future expansion.
;; For ACTION-BOOLEAN-IF nodes: recurses into the then/else branches.
;; (: buildAction (-> (Tree $a) NodeId (MultiMap ($k $v)) ((Tree $a) (MultiMap ($k $v)))))
(= (buildAction $tree (mkNodeId $nodeId) $MMap)
   (let $subtree (getNodeById $tree (mkNodeId $nodeId))
       (if (== True (isNullVertex $subtree))
           ($tree $MMap)
           (let (mkTree (mkNode $op) $children) $subtree
               (if (== $op SEQUENTIAL-AND)
                   (let*
                   (
                    ($actions (getAllActions))
                    ($perceptions (getAllPerceptions))
                    ;; Add one ASK at the current SEQUENTIAL-AND node covering all action perms
                    (($t1 $mp1) (addActionKnobs $tree (mkNodeId $nodeId) True $MMap $actions $perceptions))
                    ;; Process existing children: actions get SASKs, nested nodes recurse
                    (($updatedTree $updatedMMap) (buildActionSiblings $t1 $children (mkNodeId $nodeId) 1 $mp1 $actions $perceptions))
                    ;; Append an empty SEQUENTIAL-AND placeholder for future expansions
                    (($appendedTree $newId) (appendChild $updatedTree (mkNodeId $nodeId) (mkTree (mkNode SEQUENTIAL-AND) ())))
                    ;; Add ASK to the empty node with addIfInExemplar=False (mirrors C++ p=80 logic)
                    (($lastTree $lastMp) (addActionKnobs $appendedTree $newId False $updatedMMap $actions $perceptions))
                   )
                   ($lastTree $lastMp))
                   (if (== $op ACTION-BOOLEAN-IF)
                       ;; Skip the condition child (index 0); recurse into then/else branches
                       (let*
                       (
                        ($branchChildren (if (== $children ()) () (List.tail $children)))
                        ($actions (getAllActions))
                        ($perceptions (getAllPerceptions))
                        (($updatedTree $updatedMMap) (buildActionSiblings $tree $branchChildren (mkNodeId $nodeId) 2 $MMap $actions $perceptions))
                       )
                       ($updatedTree $updatedMMap))
                       ;; Unknown action operator: leave unchanged
                       ($tree $MMap)))))))

;; buildActionSiblings => Iterates over children of an action node and builds appropriate knobs.
;; - SEQUENTIAL-AND child  → recurse into buildAction
;; - ACTION-BOOLEAN-IF child → add SASK for the if-node + recurse into its branches
;; - builtin action child  → add SimpleActionSubtreeKnob (SASK)
;; - other                 → skip
;; (: buildActionSiblings (-> (Tree $a) (List (Tree $a)) NodeId Number (MultiMap ($k $v)) Expression Expression ((Tree $a) (MultiMap ($k $v)))))
(= (buildActionSiblings $tree () (mkNodeId $parentId) $childNum $MMap $actions $perceptions)
   ($tree $MMap))
(= (buildActionSiblings $tree (cons $head $tail) (mkNodeId $parentId) $childNum $MMap $actions $perceptions)
   (let*
   (
    ($curId (if (== $parentId (0)) ($childNum) (concatT $parentId ($childNum))))
    ((mkTree (mkNode $node) $nodeChildren) $head)
    (($tNew $mNew)
        (if (== $node SEQUENTIAL-AND)
            (buildAction $tree (mkNodeId $curId) $MMap)
            (if (== $node ACTION-BOOLEAN-IF)
                (let*
                (
                 ;; Add a SASK so the whole if-node can be toggled on/off
                 (($t2 $m2) (addSimpleActionKnobs $tree (mkNodeId $parentId) $head True $MMap))
                 ;; Then recurse into the if-node's branches
                 (($t3 $m3) (buildAction $t2 (mkNodeId $curId) $m2))
                )
                ($t3 $m3))
                (if (is-member $node $actions)
                    ;; Builtin action: add a SASK to allow toggling it off
                    (addSimpleActionKnobs $tree (mkNodeId $parentId) $head True $MMap)
                    ($tree $MMap)))))
    (($tailT $tailM) (buildActionSiblings $tNew $tail (mkNodeId $parentId) (+ $childNum 1) $mNew $actions $perceptions))
   )
   ($tailT $tailM)))

;; buildDiscrete => Build one GDK per node in the tree for a general discrete atom domain.
;; (: buildDiscrete (-> (Tree $a) NodeId (MultiMap ($k $v)) (List Atom) ((Tree $a) (MultiMap ($k $v)))))
(= (buildDiscrete $tree (mkNodeId $nodeId) $MMap $domain)
   (let $subtree (getNodeById $tree (mkNodeId $nodeId))
     (if (or (== True (isNullVertex $subtree)) (== $domain ()))
         ($tree $MMap)
         (let*
         (
             ((mkTree (mkNode $op) $children) $subtree)
             (($t1 $mp1) (addDiscreteKnobs $tree (mkNodeId $nodeId) True $MMap $domain))
             (($updatedTree $updatedMMap) (buildDiscreteSiblings $t1 $children (mkNodeId $nodeId) 1 $mp1 $domain))
         )
         ($updatedTree $updatedMMap)))))

(= (buildDiscreteSiblings $tree () (mkNodeId $parentId) $childNum $MMap $domain) ($tree $MMap))
(= (buildDiscreteSiblings $tree (cons $head $tail) (mkNodeId $parentId) $childNum $MMap $domain)
   (let*
   (
    ($curId (if (== $parentId (0)) ($childNum) (concatT $parentId ($childNum))))
    (($tNew $mNew) (addDiscreteKnobs $tree (mkNodeId $curId) True $MMap $domain))
    (($tailT $tailM) (buildDiscreteSiblings $tNew $tail (mkNodeId $parentId) (+ $childNum 1) $mNew $domain))
   )
   ($tailT $tailM)))

;; buildStrategy => Build strategy knobs for PRIORITIZED-OR nodes
;; (: buildStrategy (-> (Tree $a) NodeId (MultiMap ($k $v)) Expression ((Tree $a) (MultiMap ($k $v)))))
(= (buildStrategy $tree (mkNodeId $nodeId) $MMap $argLabels)
  (let $subtree (getNodeById $tree (mkNodeId $nodeId))
    ;; Safety Check
    (if (== True (isNullVertex $subtree))
        ($tree $MMap) 
        (let*
        (
            ($_ (println! ("****************Building strategy knobs for NodeId:**************** " $argLabels $nodeId)))
            ;; Deconstruct the current node
            ((mkTree (mkNode $op) $children) $subtree) 
            ($_ (println! ("Operator: " $op " (no swapping for game strategies)")))
            ;; Add game knobs to the current PRIORITIZED-OR node
            (($t1 $mp1) (addLogicalKnobs $tree (mkNodeId $nodeId) True $MMap $argLabels))
            ($_ (println! ("Building strategy knobs for NodeId: " $nodeId " with operator: " $op)))
            ;; Process Children using unified sibling iterator with PRIORITIZED-OR (no swapping)
            (($updatedTree $updatedMMap) (siblingit $t1 $children (mkNodeId $nodeId) 1 $op $mp1 $argLabels))
        )
            ($updatedTree $updatedMMap)))))
