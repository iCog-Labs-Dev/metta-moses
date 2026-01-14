!(import! &self ../pair)
!(import! &self ../general-helpers)

;; Pair type tests
!(assertEqual (let $a (mkPair 1 2) (get-type-reduce $a)) (Pair Number Number))
!(assertEqual (let $a (mkPair "Hello" 2) (get-type-reduce $a)) (Pair String Number))

;; Pair helper function tests
!(assertEqual (Pair.first (mkPair 1 2)) 1)
!(assertEqual (Pair.second (mkPair 1 2)) 2)


;; works in mettalog with no type checking
;!(assertEqual (Pair.first (Pair.second (mkPair (mkPair 2 3) 2))) (Pair.first 2)) returns nothing

!(assertEqual (Pair.first (Pair.first (mkPair (mkPair 2 3) 2))) 2)