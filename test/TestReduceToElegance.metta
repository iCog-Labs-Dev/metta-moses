! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types) 
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)
! (import! &self metta-moses-reduction:enf-reducer:RTEHelpers)
! (import! &self metta-moses-reduction:enf-reducer:propagate_truth_value)
! (import! &self metta-moses-reduction:enf-reducer:reduce_to_elegance)

! (import! &self metta-moses-reduction:enf-reducer:postProcessing)
! (import! &self metta-moses-reduction:enf-reducer:reduct)
! (import! &self metta-moses-reduction:enf-reducer:gather-junctors)

; Test for applyAndCut function

; Test 01 - Node with one child and empty guardSet

;(Cons (TreeNode ( Value A True LITERAL) Nil Nil) Nil)
;(Cons (TreeNode ( Value G False LITERAL) Nil Nil) Nil)

;(Cons (TreeNode ( Value O True AND) Nil (Cons (TreeNode ( Value A True LITERAL) Nil Nil) (Cons (TreeNode ( Value B True LITERAL) Nil Nil) Nil))))

;(Cons (TreeNode ( Value K True AND) Nil (Cons (TreeNode ( Value J True OR) Nil (Cons (TreeNode ( Value I True LITERAL) (Cons (TreeNode ( Value G False LITERAL) Nil Nil) Nil) (Cons (TreeNode ( Value H True OR) Nil Nil) Nil)) Nil)) Nil)) )

; ! (applyAndCut (Cons  ))

; applyOrCut
(= (watchtree yes) (TreeNode ( Value O True AND) Nil 
    (Cons (TreeNode ( Value A True LITERAL) Nil Nil) 
        (Cons (TreeNode ( Value B True LITERAL) Nil Nil) Nil)))) 

! (TreeNode ( Value K True AND) Nil 
        (Cons (TreeNode ( Value J True OR) Nil 
            (Cons (TreeNode ( Value I True LITERAL) 
                (Cons (TreeNode ( Value G False LITERAL) Nil Nil) Nil) 
                (Cons (TreeNode ( Value H True OR) Nil Nil) Nil)) Nil)) Nil))

; ! (watchtree yes)

; ! (TreeNode (Value Nil False AND) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value B False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil))

; commandSetIterator




;orSubTreeElegance





;andSubTreeElegance





;iterator






;orSubTreeIterator








;andSubTreeIterator





;reduceToElegance