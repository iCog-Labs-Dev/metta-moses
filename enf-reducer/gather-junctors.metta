! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types)
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)

(:gather-junctor (-> Tree Tree))
(=(gather-junctor $treeNode)
    (if (== $treeNode NilNode)
        $treeNode
        (let* (
                ($left (getChild $treeNode L))
                ($right (getChild $treeNode R))
                ($rightNodeType (getNodeType $right))
                ($leftNodeType (getNodeType $left))
                ((TreeNode (Value $valueName $constraint $nodeType) $guardSet $children) $treeNode)
            )
            (if (== $nodeType ROOT)
                (if (not (== $right NilNode))
                    (TreeNode (Value $valueName $constraint AND) $guardSet (Cons $left (Cons (gather-junctor $right) Nil)))
                    $treeNode
                )
                ;;check if the parent node doesn't have leaf nodes 
                (if (and (or (== $nodeType AND) (== $nodeType OR))
                    (not (or (== $leftNodeType LITERAL) (== $rightNodeType LITERAL))))
                    (if (and (== $leftNodeType $nodeType) (== $rightNodeType $nodeType))
                        (TreeNode (Value $valueName $constraint AND) $guardSet 
                                (Cons (gather-junctor $left) (Cons (gather-junctor $right) Nil)))
                        (if (== $leftNodeType $nodeType)
                            (TreeNode (Value $valueName $constraint $nodeType) $guardSet 
                                (Cons (gather-junctor $left) (Cons $right Nil)))
                            (if (== $rightNodeType $nodeType)
                                (TreeNode (Value $valueName $constraint $nodeType) $guardSet
                                    (Cons $left (Cons (gather-junctor $right) Nil))
                                )
                                (prependChild (prependChild (replaceChildren $treeNode Nil) (gather-junctor $right)) (gather-junctor $left))
                            )
                        )  
                    )
                    ;; (let* (
                    ;;            ($left (changeType $left AND))
                    ;;            ($right (changeType $right AND))
                    ;;         )
                    (if (or (== $leftNodeType LITERAL) (== $rightNodeType LITERAL))
                        (if (== $nodeType AND)
                            (if (and (== $leftNodeType LITERAL) (== $rightNodeType LITERAL))
                                (prependToGuardSet (prependToGuardSet $treeNode $left) $right)
                                (if (== $leftNodeType LITERAL)
                                    (prependToGuardSet $treeNode $left)
                                    (prependToGuardSet $treeNode $right)                                   
                                )
                            )
                            (prependToGuardSet (prependToGuardSet $treeNode $left) $right)
                        )
                        (let $newTreeNode (changeType $treeNode AND)
                            (prependToGuardSet $newTreeNode $newTreeNode)
                        )
                    )
                    )
                    ;; )
                )
            )
               
        )
    )



;; (=(gatherJunctorRunner $treeNode)
;;     (gatherJunctors $treeNode NilNode)
;; )
;; (= (checker $treeNode)
;;     (if (== (getNodeType $treeNode) ROOT) True False)
;; )
;; !(checker (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value b True LITERAL) Nil Nil) (Cons (TreeNode (Value c True LITERAL) Nil Nil) Nil))) Nil))) Nil))))



;;;Gather Junctor check
 ;         (TreeNode (Value NilNode False AND)
 ;             (TreeNode (Value Nil False AND)
 ;             (TreeNode (Value NilNode False AND) NilNode NilNode (ConsTree (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) NilList ) NilList) ;this node fulfills the condition
 ;             (TreeNode (Value NilNode False AND) NilNode NilNode NilList NilList)
 ;                 NilList
 ;                 NilList
 ;             )
 ;             NilNode NilList NilList)

;;!(gather-junctor (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value b True LITERAL) Nil Nil) (Cons (TreeNode (Value c True LITERAL) Nil Nil) Nil))) Nil))))
;!(buildTreeWithRoot (OR A (AND Y (OR B (AND C D)))))
;;(propagate-truth-value (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Y False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value C False LITERAL) Nil Nil) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil))) Nil))) Nil))) Nil))))
;;!(gather-junctor (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Y False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value C False LITERAL) Nil Nil) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil))) Nil))) Nil))) Nil))))
!(gather-junctor (TreeNode (Value Nil False ROOT) Nil (Cons NilNode (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Y False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value C False LITERAL) Nil Nil) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil))) Nil))) Nil))) Nil))) Nil))))