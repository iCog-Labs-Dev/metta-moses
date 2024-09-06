! (register-module! ../../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types) 
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)
! (import! &self metta-moses-reduction:utilities:general-helper-functions)
! (import! &self metta-moses-reduction:enf-reducer:rte-helpers)

! (import! &self metta-moses-reduction:enf-reducer:reduce-to-elegance)
! (import! &self metta-moses-reduction:enf-reducer:reduct)

;; This function is used to perform one single action after getting the input from the `reduceToElegance` function.
;; The function is only used here which is why it's defined here.
(: performReductAction (-> (Tree Tree Signal) Tree))
(= (performReductAction ($parent $child $signal)) 
   (case $signal
      (
        (DELETE
          (replaceChildren $parent (findAndRemoveTree $child (getChildren $parent)))
        )
        (DISCONNECT
          (replaceChildren $parent (findAndRemoveTree $child (getChildren $parent)))
        )
        ($else $parent)
      )
   )
)

;; Test Cases for performReductAction

;; Test  01
!(assertEqual
    (performReductAction ((TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil)) (TreeNode (Value A True LITERAL) Nil Nil) DELETE))
    (TreeNode (Value Nil False AND) Nil Nil)
 )

;; Test  02
!(assertEqual
    (performReductAction ((TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil)) (TreeNode (Value A True LITERAL) Nil Nil) DISCONNECT))
    (TreeNode (Value Nil False AND) Nil Nil)
 )

;; Test  03
!(assertEqual
    (performReductAction ((TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil)) (TreeNode (Value A True LITERAL) Nil Nil) KEEP))
    (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil))
 )

;; Test 04
!(assertEqual
    (performReductAction ((TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil)) (TreeNode (Value A True LITERAL) Nil Nil) RESET))
    (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil))
 )
