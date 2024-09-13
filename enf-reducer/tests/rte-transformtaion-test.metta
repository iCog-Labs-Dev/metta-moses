! (register-module! ../../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types) 
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)
! (import! &self metta-moses-reduction:utilities:general-helper-functions)
! (import! &self metta-moses-reduction:enf-reducer:rte-helpers)

! (import! &self metta-moses-reduction:enf-reducer:reduce-to-elegance)
! (import! &self metta-moses-reduction:enf-reducer:reduct)

! (import! &self metta-moses-reduction:enf-reducer:tests:test-treenodes)

;; This function is used to perform one single action after getting the input from the `reduceToElegance` function.
;; The function is only used here which is why it's defined here.
(: performReductAction (-> (Tree Tree Signal) Tree))
(= (performReductAction ($parent $child $signal)) 
   (case $signal
      (
        (DELETE
          (replaceChildren $parent (findAndRemove $child (getChildren $parent)))
        )
        (DISCONNECT
          (replaceChildren $parent (findAndRemove $child (getChildren $parent)))
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

;; Test 05
!(assertEqual 
    (performReductAction ((TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) DELETE))
    (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (b) Nil) Nil) Nil))
)


;; Reduce to Elegance Transformation Tests

;; Test 01: Delete inconsistent handle transformation test.

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


;; Test 02: Promote Common Constraint transformation test.

!(assertEqual
    (performReductAction
      (reduceToElegance
        (TreeNode (And) (Cons (a) Nil) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (b') (Cons (c) Nil)) Nil) (Cons (TreeNode (And) (Cons (b') Nil) Nil) Nil))) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (b') (Cons (d') Nil)) Nil) (Cons (TreeNode (And) (Cons (c') Nil) Nil) Nil))) Nil)))
        (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (b') (Cons (c) Nil)) Nil) (Cons (TreeNode (And) (Cons (b') Nil) Nil) Nil)))
        (Cons (a) (Cons (b') Nil))
        Nil
      ))
      (TreeNode (And) (Cons (a) (Cons (b') Nil)) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (c) Nil) Nil) (Cons (TreeNode (And) Nil Nil) Nil))) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (b') (Cons (d') Nil)) Nil) (Cons (TreeNode (And) (Cons (c') Nil) Nil) Nil))) Nil)))
)

;; Test 03: Subtract Redundant Constraint transformation test.
!(assertEqual
    (performReductAction
      (reduceToElegance
        (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (a) (Cons (c) (Cons (d') Nil))) Nil) (Cons (TreeNode (And) (Cons (a) Nil) Nil) Nil)))
        (TreeNode (And) (Cons (a) (Cons (c) (Cons (d') Nil))) Nil)
        (Cons (b') (Cons (c) (Cons (a) Nil)))
        (Cons (a) (Cons (e') Nil))
    ))
   (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (a) Nil) Nil) Nil))
 )


;; Test 04: Cut Unnecessary OR transformation test.

!(assertEqual
   (performReductAction 
      (reduceToElegance 
        (TreeNode (And) (Cons (b) Nil) (Cons (TreeNode(Or) Nil (Cons (TreeNode (And) (Cons (d') Nil) Nil) Nil)) Nil))
        (TreeNode(Or) Nil (Cons (TreeNode (And) (Cons (d') Nil) Nil) Nil))
        (Cons (a) (Cons (b) (Cons (d') Nil)))
        Nil
      )
   )
   (TreeNode (And) (Cons (b) (Cons (d') Nil)) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) Nil Nil) Nil)) Nil))
 )

;; Test 05: Cut Unnecessary AND transformation test.

!(assertEqual
   (performReductAction
     (reduceToElegance
        (TreeNode (Or) Nil (Cons (TreeNode (And) Nil (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (b) (Cons (d) Nil)) Nil) (Cons (TreeNode (And) (Cons (e') Nil) Nil) Nil))) Nil)) (Cons (TreeNode (And) (Cons (c) Nil) Nil) Nil)))
       (TreeNode (And) Nil (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (b) (Cons (d) Nil)) Nil) (Cons (TreeNode (And) (Cons (e') Nil) Nil) Nil))) Nil))
       (Cons (a) Nil)
       (Cons (c) Nil)
     )
   )
  (TreeNode (Or) Nil (Cons (TreeNode (And) Nil (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (b) (Cons (d) Nil)) Nil) (Cons (TreeNode (And) (Cons (e') Nil) Nil) Nil))) Nil)) (Cons (TreeNode (And) (Cons (c) Nil) Nil) Nil)))
 )

;; Test 06: Zero Constraint Subsumption Transformation test.

!(assertEqual
  (performReductAction
    (reduceToElegance
      (TreeNode (And) (Cons (a) Nil) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (a) Nil) Nil) (Cons (TreeNode (And) (Cons (b') Nil) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (e) Nil) Nil) (Cons (TreeNode (And) (Cons (f) Nil) Nil) Nil))) Nil) ) Nil))) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (c) Nil) Nil) (Cons (TreeNode (And) Nil Nil) Nil))) Nil)))
      (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (c) Nil) Nil) (Cons (TreeNode (And) Nil Nil) Nil)))
      (Cons (a) Nil)
      Nil
    )
  )
  (TreeNode (And) (Cons (a) Nil) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (a) Nil) Nil) (Cons (TreeNode (And) (Cons (b') Nil) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (e) Nil) Nil) (Cons (TreeNode (And) (Cons (f) Nil) Nil) Nil))) Nil)) Nil))) Nil))

)


;; Test 07: One Constraint Subsumption Transformation test.

!(assertEqual
  (performReductAction
    (reduceToElegance
      (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (e) (Cons (d) Nil)) Nil) (Cons (TreeNode (And) (Cons (c) Nil) Nil) Nil)))
      (TreeNode (And) (Cons (e) (Cons (d) Nil)) Nil)
      (Cons (a) (Cons (b) Nil))
      (Cons (c) (Cons (d) Nil))
    )
  )
  (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (c) Nil) Nil) Nil))
)


;; Test 08: One constraint complement subtraction transformation test.

!(assertEqual
  (performReductAction
    (reduceToElegance
      (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (b) (Cons (c) Nil)) Nil) (Cons (TreeNode (And) (Cons (d) Nil) Nil) Nil)))
      (TreeNode (And) (Cons (b) (Cons (c) Nil)) Nil)
      (Cons (a) (Cons (b) Nil))
      (Cons (d) Nil)
    )
  )
  (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (c) Nil) Nil) (Cons (TreeNode (And) (Cons (d) Nil) Nil) Nil)))
)
