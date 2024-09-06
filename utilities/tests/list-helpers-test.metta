! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types)
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:general-helper-functions)


!(assertEqual (any (Cons False Nil)) False)
!(assertEqual (any (Cons True Nil)) True)
!(assertEqual (any (Cons True(Cons False (Cons True Nil)))) True)

!(assertEqual (all (Cons False Nil)) False)
!(assertEqual (all (Cons True Nil)) True)
!(assertEqual (all (Cons False(Cons True (Cons False Nil)))) False)
!(assertEqual (all (Cons True(Cons True (Cons True Nil)))) True)

!(assertEqual (findAndRemove 1 (Cons 1 (Cons 2 (Cons 3 Nil)))) (Cons 2 (Cons 3 Nil)))
!(assertEqual (findAndRemove 3 (Cons 1 (Cons 2 (Cons 3 Nil)))) (Cons 2 (Cons 3 Nil)))
!(assertEqual (findAndRemove 4 (Cons 1 (Cons 2 (Cons 3 Nil)))) (Cons 1 (Cons 2 (Cons 3 Nil))))

!(assertEqual ((Cons 1 (Cons 2 (Cons 3 Nil))) ++ Nil) ((Cons 1 (Cons 2 (Cons 3 Nil)))))
!(assertEqual (Nil ++ (Cons 1 (Cons 2 (Cons 3 Nil)))) ((Cons 1 (Cons 2 (Cons 3 Nil)))))
!(assertEqual ((Cons 1 (Cons 2 (Cons 3 Nil))) ++ (Cons 4 Nil)) ((Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil))))))
!(assertEqual ((Cons 4 Nil) ++ (Cons 1 (Cons 2 (Cons 3 Nil)))) ((Cons 4 (Cons 1 (Cons 2 (Cons 3 Nil))))))
!(assertEqual ((Cons 1 (Cons 2 (Cons 3 Nil))) ++ (Cons 4 (Cons 3 (Cons 5 (Cons 2 Nil))))) ((Cons 1 (Cons 2 (Cons 3 (Cons 4 (Cons 3 (Cons 5 (Cons 2 Nil)))))))))
