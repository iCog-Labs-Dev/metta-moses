!(register-module! ../../../metta-moses)

!(import! &self metta-moses:representation:instance)
!(import! &self metta-moses:utilities:pair)

;; Instance related type testing
!(assertEqual (let $a (mkInst (Cons 1 (Cons 2 (Cons 3 (Cons 2.0 Nil))))) (get-type $a)) Instance)
!(assertEqual (let $a (mkSInst 3.2 (mkPair (mkInst (Cons 1 (Cons 2 (Cons 3 (Cons 2.0 Nil))))) 3.2)) (get-type $a)) (ScoredInstance Number))
!(assertEqual (let $a (mkSInstSet 3.2 (Cons (mkSInst 3.2 (mkPair (mkInst (Cons 1 (Cons 2 (Cons 3 (Cons 2.0 Nil))))) 3.2)) Nil)) (get-type $a)) (InstanceSet Number))
