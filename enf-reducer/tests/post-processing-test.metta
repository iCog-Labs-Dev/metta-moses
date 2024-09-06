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
       (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil True OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E False LITERAL) Nil Nil) (Cons (TreeNode (Value F False LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value G False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value H False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value E False LITERAL) Nil Nil) (Cons (TreeNode (Value F False LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value G False LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value H False LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) Nil)))) Nil))
    )
    (nAndArr C B A (nOrArr ((nAndArr F E (nOrArr (H G))) (nAndArr F E (nOrArr (H G))) D)))
 )

!(assertEqual
    (postProcessing 
       (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A false LITERAL) Nil Nil) (Cons (TreeNode (Value B false LITERAL) Nil Nil) (Cons (TreeNode (Value C false LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value A False AND) (Cons (TreeNode (Value A false LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A false LITERAL) Nil Nil) (Cons (TreeNode (Value B false LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value Nil True OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D false LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value E false LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B false LITERAL) Nil Nil) Nil) Nil) Nil)))) Nil))
    )
    (nAndArr C B A (nOrArr (B (nAndArr B A (nOrArr (E D))) A)))
 )
