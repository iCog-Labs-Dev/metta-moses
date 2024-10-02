! (register-module! ../../../metta-moses-reduction)
! (import! &self metta-moses-reduction:utilities:tree-helpers)

!(assertEqual (intersections Nil) Nil )
!(assertEqual (intersections (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) )



