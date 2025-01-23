!(register-module! ../../../../metta-moses)
!(import! &self metta-moses:optimization:sggp:sggp-algorithm)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:scoring:fitness)

(=(containsThreeVals $tuple)
    (unify $tuple ($x $y $z) True False)
)

!(assignWeight (expr (bop expr expr)) 5)
!(assertEqual (assignWeight (expr (bop expr expr)) 5) (expr (bop expr expr) 5))
!(assertEqual (assignWeight (expr (uop expr)) 4) (expr (uop expr) 4))
!(assertEqual (assignWeight (expr term) 4) (expr term 4))


