!(register-module! ../../../../metta-moses)

! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:python-helpers)

(= (exprToList $expr)  (py_exprToList $expr))
(= (listToExpr $expr) (py_listToExpr $expr))

!(assertEqual (exprToList (A B C)) (Cons A (Cons B (Cons C Nil))))
!(assertEqual (listToExpr (Cons A (Cons B (Cons C Nil)))) (A B C))
