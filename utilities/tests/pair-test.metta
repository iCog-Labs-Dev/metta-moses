!(register-module! ../../../metta-moses)

!(import! &self metta-moses:utilities:pair)

;; Pair type tests
!(assertEqual (let $a (mkPair 1 2) (get-type $a)) (Pair Number Number))
!(assertEqual (let $a (mkPair "Hello" 2) (get-type $a)) (Pair String Number))

;; Pair helper function tests
!(assertEqual (first (mkPair 1 2)) 1)
!(assertEqual (second (mkPair 1 2)) 2)
!(assertEqual (first (second (mkPair (mkPair 2 3) 2))) (Error (second (mkPair (mkPair 2 3) 2)) BadType))
