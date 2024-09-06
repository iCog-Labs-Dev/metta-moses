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

;; TreeNodes to be reused. There are literal nodes only defined from a - f both with positive and negative constraint.
;; i.e.,:
      ;; a' means a tree node that has 'NodeType' of 'LITERAL', Value of 'A' and Constraint of 'False'.
      ;; a means a tree node that has 'NodeType' of 'LITERAL', Value of 'A' and Constraint of 'True'.

(: a Tree)
(= (a) (TreeNode (Value A True LITERAL) Nil Nil))
(: b Tree)
(= (b) (TreeNode (Value B True LITERAL) Nil Nil))
(: c Tree)
(= (c) (TreeNode (Value C True LITERAL) Nil Nil))
(: d Tree)
(= (d) (TreeNode (Value D True LITERAL) Nil Nil))
(: e Tree)
(= (e) (TreeNode (Value E True LITERAL) Nil Nil))
(: f Tree)
(= (f) (TreeNode (Value F True LITERAL) Nil Nil))

(: a' Tree)
(= (a') (TreeNode (Value A False LITERAL) Nil Nil))
(: b' Tree)
(= (b') (TreeNode (Value B False LITERAL) Nil Nil))
(: c' Tree)
(= (c') (TreeNode (Value C False LITERAL) Nil Nil))
(: d' Tree)
(= (d') (TreeNode (Value D False LITERAL) Nil Nil))
(: e' Tree)
(= (e') (TreeNode (Value E False LITERAL) Nil Nil))
(: f' Tree)
(= (f') (TreeNode (Value F False LITERAL) Nil Nil))

;; NodeValues that are reused. These are AND and OR node value to be reused
(: And NodeValue)
(= (And) (Value Nil False AND))
(: Or NodeValue)
(= (Or) (Value Nil False OR))

;; Reduce to Elegance Transformation Tests

;; Test 01: Delete inconsistent handle transformation test.
 ;; Output

!(assertEqual
   (performReductAction
      (reduceToElegance 
          (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (a') Nil) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (b) Nil) Nil) (Cons (TreeNode (And) (Cons (c) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (And) (Cons (b) Nil) Nil) Nil))) 
          (TreeNode (And) (Cons (a') Nil) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (b) Nil) Nil) (Cons (TreeNode (And) (Cons (c) Nil) Nil) Nil))) Nil))
          (Cons (a) Nil)
          (Cons (b) Nil)
      ))
   (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (b) Nil) Nil) Nil))
 )



