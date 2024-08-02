! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types)
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)


;a funcion to remove a child from a tree's listOfChildren and return an updated tree
(=(disconnectSubTreeHandler $child $tree)
 (case ($child $tree)
  (
    (($child (TreeNode $nodeValue $leftChild $rightChild $guardSet $listOfChildren))
     (TreeNode $nodeValue $leftChild $rightChild $guardSet (compareAndRemoveNode $child $listOfChildren NilList))
    )
    ($else ())
  )
 )
)

