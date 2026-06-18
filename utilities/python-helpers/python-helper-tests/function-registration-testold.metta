!(register-module! ../../../../metta-moses)

! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:python-helpers)

(= (exprToList $expr)  (py_exprToList $expr))
(= (listToExpr $expr) (py_listToExpr $expr))

!(assertEqual (exprToList (A B C)) (cons A (cons B (cons C ()))))
!(assertEqual (listToExpr (cons A (cons B (cons C ())))) (A B C))
