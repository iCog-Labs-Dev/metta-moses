(: Pair (-> $a $b Type))
(: mkPair (-> $a $b (Pair $a $b)))

(: first (-> (Pair $a $b) $a))
(= (first (mkPair $a $b)) $a)

(: second (-> (Pair $a $b) $b))
(= (second (mkPair $a $b)) $b)

