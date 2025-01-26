!(register-module! ../../../../metta-moses)
!(import! &self metta-moses:optimization:sggp:sggp-algorithm)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:scoring:fitness)
;; !(bind! pow (py-atom pow))

(=(containsThreeVals $tuple)
    (unify $tuple ($x $y $z) True False)
)

;; Tests for assign weights
!(assertEqual (assignWeight (expr (bop expr expr)) 5) (expr (bop expr expr) 5))
!(assertEqual (assignWeight (expr (uop expr)) 4) (expr (uop expr) 4))
!(assertEqual (assignWeight (expr term) 4) (expr term 4))
;; !(initializeGrammarSpace &grammarSpace)
!(assertEqual (updateWeight (expr (bop expr expr) 4) 0.5 5 inc) (expr (bop expr expr) (* 4 (pow (+ 1 0.5) 5))))
;; Tests for extracting parents
!(assertEqual (extractParent (expr (bop expr expr))) expr)
!(assertEqual (extractParent (expr (bop expr expr) 5)) expr)




