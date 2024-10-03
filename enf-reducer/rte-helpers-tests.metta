!(assertEqual (updateGuardSetTree  
   (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value X True LITERAL) Nil Nil) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil)))  
   (TreeNode (Value Z True LITERAL) Nil Nil))
   (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Z True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value X True LITERAL) Nil Nil) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil))))
