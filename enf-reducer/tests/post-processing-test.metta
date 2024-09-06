! (register-module! ../../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types) 
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)
! (import! &self metta-moses-reduction:enf-reducer:rte-helpers)
! (import! &self metta-moses-reduction:enf-reducer:propagate-truth-value)
! (import! &self metta-moses-reduction:enf-reducer:reduce-to-elegance)

! (import! &self metta-moses-reduction:enf-reducer:post-processing)
! (import! &self metta-moses-reduction:enf-reducer:reduct)
! (import! &self metta-moses-reduction:enf-reducer:gather-junctors)

!(assertEqual
    (postProcessing 
       (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value B True LITERAL) Nil Nil) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil True OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E True LITERAL) Nil Nil) (Cons (TreeNode (Value F True LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value G True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value H True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E True LITERAL) Nil Nil) (Cons (TreeNode (Value F True LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value G True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value H True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) Nil)))) Nil))
    )
    (nAndAry (C B A (nOrAry ((nAndAry (F E (nOrAry (H G)))) (nAndAry (F E (nOrAry (H G)))) D))))
 )

!(assertEqual
    (postProcessing 
       (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value A False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value B False LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil True OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value E False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B False LITERAL) Nil Nil) Nil) Nil) Nil)))) Nil))
    )
    (nAndAry ((NOT C) (NOT B) (NOT A) (nOrAry ((NOT B) (nAndAry ((NOT B) (NOT A) (nOrAry ((NOT E) (NOT D))))) (NOT A)))))
 )
