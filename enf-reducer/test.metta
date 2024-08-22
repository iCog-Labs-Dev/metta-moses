(TreeNode 
    (Value Nil False AND) 
        Nil 
        (Cons 
            (TreeNode (Value Nil False OR) Nil 
                (Cons 
                    (TreeNode (Value Nil False AND) 
                            (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) 
                            (Cons (TreeNode (Value Nil False OR) Nil 
                                (Cons 
                                    (TreeNode (Value Nil False AND) 
                                        (Cons (TreeNode (Value D True LITERAL) Nil Nil) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil)) 
                                    Nil) 
                                        (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) 
                                Nil))
                                ) Nil)) 
                                    (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) 
                                Nil))) 
Nil))
;;!(let (TreeNode $nodeValue $guardSet $children) (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value Y True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value C True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) Nil) Nil))) Nil)) (Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil))) $children)
;; remainingChildren
(Cons (TreeNode (Value Nil True AND) (Cons (TreeNode (Value A True LITERAL) Nil Nil) Nil) Nil) Nil)
;; 