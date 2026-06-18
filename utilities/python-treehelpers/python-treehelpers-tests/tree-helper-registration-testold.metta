!(register-module! ../../../../metta-moses)

; ! (import! &self metta-moses:utilities::treeMethods)
! (import! &self metta-moses:utilities:python-treehelpers)


(= (appendchild $tree $id $expr) (py_appendChild $tree $id $expr))
(= (replace $tree $id $expr) (py_replace $tree $id $expr))
(= (getByID $tree $id) (py_getById $tree $id))
(= (insertAbove $tree $id $expr) (py_insertAbove $tree $id $expr))

(= (Tree) (mkTree (mkNode AND) 
                            (cons (mkTree (mkNode A) ()) 
                            (cons (mkTree (mkNode B) ()) 
                            (cons (mkTree (mkNode OR) 
                                (cons (mkTree (mkNode AND) 
                                    (cons (mkTree (mkNode C) ()) ())) 
                                    (cons (mkTree (mkNode D) ()) ()))) ())))) )


; !(assertEqual (appendchild (Tree) 3 (mkTree (mkNode E) ())) (((mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode D) ()) (cons (mkTree (mkNode E) ()) ())))) ())))) (mkNodeId (3 3)))))
; !(assertEqual (replace (Tree) 3 (mkTree (mkNode XOR) ())) (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode XOR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) (cons (mkTree (mkNode D) ()) ()))) ())))))
; !(assertEqual (insertAbove (Tree) (3 1) (mkTree (mkNode XOR) ())) (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode XOR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode C) ()) ())) ())) (cons (mkTree (mkNode D) ()) ()))) ())))))
!(assertEqual (getByID (Tree) 3 ) (mkTree (mkNode C) ()))