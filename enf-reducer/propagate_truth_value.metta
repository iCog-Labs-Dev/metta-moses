! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types)
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)


(: propagateTruthValue (-> Tree Bool Tree))
(= (propagateTruthValue $tree $truthValueArg)
    (if (== (isTreeWellFormed $tree) True)
            (let* (
                    ($right (getChild $tree R))
                    ($left (getChild $tree L))
                    ($nodeType (getNodeType $tree))
                    ((TreeNode $nodeValue $guardSet $children) $tree)
                )(if (== $nodeType ROOT)
                    (if (not (== $right NilNode))
                        (replaceChild $tree (propagateTruthValue $right $truthValueArg) R)
                        $tree
                    )
                    (if (== $nodeType NOT)
                       (propagateTruthValue $right (not $truthValueArg))
                       (let
                          (Value $valueName $truthValue $_)
                          $nodeValue
                          (if (or (== $nodeType OR) (== $nodeType AND))
                                (if (== False $truthValueArg)
                                        (let
                                          $updatedTree
                                          (if (== $nodeType AND)
                                                (changeType $tree OR)
                                                (changeType $tree AND)
                                          )
                                          (let* (
                                                  ($leftNotNil (not (== $left NilNode)))
                                                  ($rightNotNil (not (== $right NilNode)))
                                              )
                                              (if (and $leftNotNil $rightNotNil)
                                                  (replaceChild (replaceChild $updatedTree (propagateTruthValue $left $truthValueArg) L) (propagateTruthValue $right $truthValueArg) R)
                                                  $updatedTree
                                              )
                                          )
                                        )
                                        (replaceChild (replaceChild $tree (propagateTruthValue $left $truthValueArg) L) (propagateTruthValue $right $truthValueArg) R)
                                )
                               (TreeNode (Value $valueName $truthValueArg $nodeType) $guardSet $children)
                          )
                       )
                    )
                )
            )
        (Tree isn't well formed)
    )
)

(: isTreeWellFormed (Tree Bool))
(= (isTreeWellFormed $tree)
    (case $tree (
       
            ((TreeNode (Value $value $bool $nodeType) $guardSet $children) True)
            (NilNode True)
            ($else False)
        )
    )
)
;;!(isTreeWellFormed (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a False LITERAL) Nil Nil) (Cons (TreeNode (Value b False LITERAL) Nil Nil) Nil))))
 
;; !(changeTree (buildTree (OR a (AND b c))) (buildTree (AND a (AND b c))))
;; !(replaceChild (buildTree (OR a (AND b c))) (buildTree (AND a (AND b c))) L)
;; !(getNodeType (buildTree (OR a (AND b c))))
;; !(propagateTruthValue (buildTreeWithRoot (OR a (AND b c))) True)
;; !(propagateTruthValue (buildTreeWithRoot (OR a (AND b c))) False)
 !(propagateTruthValue (buildTreeWithRoot (NOT (OR a (AND b c)))) False)
;; !(propagateTruthValue (buildTreeWithRoot (NOT (OR a (AND b c)))) True)
;; !(propagateTruthValue (buildTreeWithRoot (AND a (OR b c))) False)
;; !(propagateTruthValue (buildTreeWithRoot (AND a (OR b c))) True)
;; !(propagateTruthValue (buildTreeWithRoot (NOT (AND a (OR b c)))) True)
;; !(propagateTruthValue (buildTreeWithRoot (NOT (AND a (OR b c)))) False)
!(propagateTruthValue (TreeNode (Value target1 False NOT) Nil (Cons
              (TreeNode (Value Nil False AND) Nil Nil)
              (Cons
                 (TreeNode (Value target1 False OR)  Nil Nil)
                (Cons
                      (TreeNode (Value target2 True AND) Nil Nil)
                      Nil
                 )
          )
  ) ) True)
