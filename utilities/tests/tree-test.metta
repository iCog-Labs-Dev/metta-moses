
!(register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:utilities:general-helpers)

!(bind! tree1 (mkTree (mkNode AND)
                (Cons (mkTree (mkNode A) Nil)
                (Cons (mkTree (mkNode OR)
                        (Cons (mkTree (mkNode B) Nil)
                        (Cons (mkTree (mkNode C) Nil) Nil))) Nil))))
!(bind! tree2 (mkTree (mkNode AND)
            (Cons (mkTree (mkNode A) Nil)
            (Cons (mkTree (mkNode OR)
                    (Cons (mkTree (mkNode B) Nil)
                    (Cons (mkTree (mkNode C) Nil)
                    (Cons (mkNullVex Nil) Nil) ))) Nil))))

! (bind! tree3 (mkTree (mkNode AND)
            (Cons (mkTree (mkNode OR) 
                (Cons (mkTree (mkNode AND)
                    (Cons (mkTree (mkNode OR)
                        (Cons (mkTree (mkNode A) Nil) 
                        (Cons (mkTree (mkNode B) Nil) Nil))) 
                (Cons (mkTree (mkNode OR) 
                       (Cons (mkTree (mkNode C) Nil) 
                       (Cons (mkTree (mkNode D) Nil) Nil))) Nil))) 
                (Cons (mkTree (mkNode D) Nil) Nil))) 
                (Cons (mkTree (mkNode C) Nil) Nil))))

! (bind! tree4 (mkTree (mkNode OR) 
                (Cons (mkTree (mkNode A) Nil) 
                (Cons (mkTree (mkNode AND) 
                        (Cons (mkTree (mkNode A) Nil) 
                        (Cons (mkTree (mkNode B) Nil) Nil))) Nil))))
;; Tree preOrder traversal tests

!(assertEqual (preOrder (mkNullVex Nil)) ())
!(assertEqual (preOrder (mkTree (mkNode A) Nil)) A)
!(assertEqual (preOrder (mkTree (mkNode AND)
                            (Cons (mkTree (mkNode A) Nil) Nil))) (AND A))

!(assertEqual (preOrder (mkTree (mkNode AND)
                            (Cons (mkTree (mkNode A)
                                      (Cons (mkTree (mkNode B) Nil)
                                      (Cons (mkTree (mkNode C) Nil) Nil))) Nil))) (AND (A B C)))

!(assertEqual (preOrder (mkTree (mkNode AND)
                            (Cons (mkTree (mkNode A) Nil)
                            (Cons (mkTree (mkNode B) Nil)
                            (Cons (mkTree (mkNode C) Nil) Nil))))) (AND A B C))

!(assertEqual (preOrder tree1) (AND A (OR B C)))
!(assertEqual (preOrder tree2) (AND A (OR B C)))

(: A Bool)

!(assertEqual (get-type tree1) (Tree Bool))
!(assertEqual (get-type tree2) (Tree Bool))


! (assertEqual (buildTree (AND (OR (AND (OR A B) (OR C D)) D) C)) tree3)
! (assertEqual (buildTree (OR A  (AND A B))) tree4)
