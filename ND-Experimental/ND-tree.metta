(= (y) (Tree (1 1) AND False Nil (Tree (2 1) A True)))
(= (y) (Tree (1 1) AND False Nil (Tree (2 2) AND False)))
(= (y) (Tree (2 2) AND False Nil (Tree (3 3) A True)))
(= (y) (Tree (2 2) AND False Nil (Tree (3 4) B True)))

(= (x) (Tree 1 AND False Nil (Tree 2 A True)))
(= (x) (Tree 1 AND False Nil (Tree 2 AND False)))
(= (x) (Tree 2 AND False Nil (Tree 3 A True)))
(= (x) (Tree 2 AND False Nil (Tree 3 B True)))

 ;a function to get the children of a tree at a given level
(= (getChildren $level $tree)
    (unify (Tree $level $value $constraint $guardSet $children) $tree $children (empty)))
 ;testcase
 ;! (getChildren (1 1) (y))

 ;a function to replace the child of a tree at a given level
(= (replaceChild $level $horizId $tree (Tree ($childLevel $childHorizId) $newChildValue $newChildConstraint))
    (unify (Tree ($level $horizId) $value $constraint $guardSet (Tree ($childLevel $childHorizId) $oldChildValue $oldChildConstraint)) $tree
        ( (remove-atom &self (= (y) (Tree ($level $horizId) $value $constraint $guardSet (Tree ($childLevel $childHorizId) $oldChildValue $oldChildConstraint))))
            (add-atom &self (= (y) (Tree ($level $horizId) $value $constraint $guardSet (Tree ($childLevel $childHorizId) $newChildValue $newChildConstraint))))
        )
    (empty)
)
)
 ;testcase
 ;! (replaceChild 1 1 (y) (Tree (2 1) K True))
 ;! (getChildren (1 1) (y))

 ;a function to get the guardSet of a tree
(= (getGuardSet $level $horizId $tree)
    (unify (Tree ($level $horizId) $value $constraint $guardSet $children) $tree $guardSet (empty))
)
 ;testcase
 ;! (getGuardSet 1 (y))

 ;a function to relace the guardSet of a tree at a given level
(= (replaceGuardSet $level $horizId $tree $newGuardSet)
    (unify (Tree ($level $horizId) $value $constraint $guardSet $children)
        $tree
        (Tree ($level $horizId) $value $constraint $newGuardSet $children)
        (empty))
)
 ;testcase
 ;! (replaceGuardSet 1 1 (y) (1 2 3))

 ;a function to get the right or left child of a tree using the horizontal id
(= (isEven $horizId)
    (let $quotient (% $horizId 2) (if (== $quotient 0) $horizId (empty)))
)
(= (isOdd $horizId)
    (let $quotient (% $horizId 2) (if (== $quotient 0) (empty) $horizId))
)
(= (getChild $level $horizId $tree $location)
    (unify (Tree ($level $horizId) $value $constraint $guardSet $children) $tree
        (let*
            (
                ($nextLevel (+ $level 1))
                ($evenHorizId (isEven $horizId))
                ($oddHorizId (isOdd $horizId))
            )
        (case $location
            (
                ("R" (unify (Tree ($level $horizId) $value $constraint $guardSet (Tree ($nextLevel $evenHorizId) $value $constraint)) $tree (Tree ($nextLevel $evenHorizId) $value $constraint) (empty)))
                ("L" (unify (Tree ($level $horizId) $value $constraint $guardSet (Tree ($nextLevel $oddHorizId) $value $constraint)) $tree (Tree ($nextLevel $oddHorizId) $value $constraint) (empty)))
            )      )
)
(empty))
)
 ;testcase
 ;! (getChild 1 1 (y) "L")

 ;a function to change the type of a tree
(= (changeType $level $tree $newType)
    (unify (Tree $level $type $constraint $guardSet $children) $tree (Tree $level $newType $constraint $guardSet $children) (empty))
)
 ;testcase
 ;! (changeType 1 (x) OR)

 ;a function ofcheck if a node is child of a tree
(= (isNodeChild $level $tree $node)
    (unify (Tree $level $type $constraint $guardSet $child) $tree (if (== $node $child) True (empty)) (empty)))
 ;testcase
 ;! (isNodeChild 1 (x) (Tree 2 A True))

 ;a function to prepend a child on a tree
(= (prependChild $level $tree $child )
    (unify (Tree $level $type $constraint $guardSet $children) $tree (add-atom &self (= (x) (Tree $level $type $constraint $guardSet $child))) (empty))
)
 ;testcase
 ;! (prependChild 1 (x) (Tree 2 Z True))
 ;! (getChildren 1 (x))

 ;a function to check if two nodes are equal
(= (isNodeEqual (Tree $id $type $constraint $guardSet $children) (Tree $id2 $type2 $constraint2 $guardSet2 $children2))
    (if (and (== $constraint $constraint2) (and (== $id $id2) (== $type $type2))) True False))
 ;testcase
 ;! (isNodeEqual (Tree (1 1) AND False Nil (Tree (2 1) A True)) (Tree (1 1) AND False Nil (Tree (2 1) A True)))

 ;a function to get the type of a node
(= (getNodeType $node)
    (unify (Tree $id $type $constraint $guardSet $children) $node $type (empty)))
 ;testcase
 ;! (getNodeType (Tree (1 1) AND False Nil (Tree (2 1) A True)))