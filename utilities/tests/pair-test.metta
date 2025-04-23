!(register-module! ../../../metta-moses)

!(import! &self metta-moses:utilities:pair)

;; Pair type tests
!(assertEqual (let $a (mkPair 1 2) (get-type $a)) (Pair Number Number))
!(assertEqual (let $a (mkPair "Hello" 2) (get-type $a)) (Pair String Number))

;; Pair helper function tests
!(assertEqual (Pair.first (mkPair 1 2)) 1)
!(assertEqual (Pair.second (mkPair 1 2)) 2)
!(assertEqual (Pair.first (Pair.second (mkPair (mkPair 2 3) 2))) (Error (Pair.second (mkPair (mkPair 2 3) 2)) BadType))
