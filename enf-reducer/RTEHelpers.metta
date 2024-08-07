;a funcion to remove a child from a tree's listOfChildren and return an updated tree
(: (-> Tree Tree Tree))
(=(disconnectSubTreeHandler Nil $tree) $tree)
(=(disconnectSubTreeHandler $child Nil) Nil)
(=(disconnectSubTreeHandler $child (TreeNode $nodeValue $guardSet $children))
  (TreeNode 
    $nodeValue 
    $guardSet 
    (compareAndRemoveNode $child $children Nil)
  )
)

;; -----------------------------------
;; -----------------------------------
;; -------- Function that adds the target OR Node's child's
;; -------- guardset to the guardset of its parent, add the 
;; -------- target OR Node's grandchildren to the parent's list of children, 
;; -------- remove target OR Node from it's parent's list of children.
;; -----------------------------------
;; -----------------------------------

(: applyOrCut (-> Tree Tree Tree))
(= (applyOrCut $child $current)(
  if(== (length (getChildren $child)) 1)
    (let* 
      (
        ($grandChild (head (getChildren $child)))
        ($updatedGuardSetTree (replaceGuardSet $current (unionSet (getGuardSet $current) (getGuardSet $grandChild))) )
        ($currentNodeChildren (getChildren $updatedGuardSetTree))
        ($updatedChildrenTree (replaceChildren $updatedGuardSetTree (extend (getChildren $grandChild) $currentNodeChildren)))
        ($finalUpdatedTree (findAndRemoveTree (getChildren $updatedChildrenTree) $grandChild))
      )
        ($finalUpdatedTree)
    )
)
)

