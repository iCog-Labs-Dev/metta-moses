!(register-module! ../../../../metta-moses)

; ! (import! &self metta-moses:utilities::treeMethods)
! (import! &self metta-moses:utilities:python-treehelpers)


(= (appendchild $tree $id $expr) (py_appendChild $tree $id $expr))
(= (replace $tree $id $expr) (py_replace $tree $id $expr))
(= (getByID $tree $id) (py_getById $tree $id))
(= (insertAbove $tree $id $expr) (py_insertAbove $tree $id $expr))

(= (Tree) (mkTree (mkNode AND) 
                            (Cons (mkTree (mkNode A) Nil) 
                            (Cons (mkTree (mkNode B) Nil) 
                            (Cons (mkTree (mkNode OR) 
                                (Cons (mkTree (mkNode AND) 
                                    (Cons (mkTree (mkNode C) Nil) Nil)) 
                                    (Cons (mkTree (mkNode D) Nil) Nil))) Nil)))) )


; !(assertEqual (appendchild (Tree) 3 (mkTree (mkNode E) Nil)) (((mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) (Cons (mkTree (mkNode E) Nil) Nil)))) Nil)))) (mkNodeId (3 3)))))
; !(assertEqual (replace (Tree) 3 (mkTree (mkNode XOR) Nil)) (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode XOR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) Nil)))))
; !(assertEqual (insertAbove (Tree) (3 1) (mkTree (mkNode XOR) Nil)) (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode XOR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) Nil)))))
!(assertEqual (getByID (Tree) 3 ) (mkTree (mkNode C) Nil))