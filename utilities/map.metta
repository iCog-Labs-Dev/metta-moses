;; Map Data Structure
(: Map (-> $a Type))
(: NilMap (Map $a))
(: ConsMap (-> $a (Map $a) (Map $a)))

;; insert an element to a Map
(: Map.insert (-> $a (Map $a) (Map $a)))
(= (Map.insert ($key $value) NilMap) (ConsMap ($key $value) NilMap))
(= (Map.insert ($key $value) (ConsMap ($curKey $curVal) $tail))
    (if (== $key $curKey)  (ConsMap ($key $value) $tail)
        (if (< $key $curKey)
            (ConsMap ($key $value) (ConsMap ($curKey $curVal) $tail))
            (ConsMap ($curKey $curVal) (Map.insert ($key $value) $tail)))))

;; Get a value from a Map using index
(: Map.getByKey (-> Number (Map $a) $a))
(= (Map.getByKey $key NilMap) (Error $key "not found"))
(= (Map.getByKey $key (ConsMap ($curKey $curVal) $tail))
    (if (== $key $curKey) $curVal (Map.getByKey $key $tail) ))


;; Check if a key is in the Map
(: Map.contains (-> $a (Map $a) Bool))
(= (Map.contains $key NilMap) False)
(= (Map.contains $key (ConsMap ($curKey $curVal) $tail))
    (if (== $key $curKey) True (Map.contains $key $tail)))

;; Check if a value in a Map 
(: Map.checkValue (-> $a (Map $a) Bool))
(= (Map.checkValue $value NilMap) False)
(= (Map.checkValue $value (ConsMap ($curKey $curVal) $tail))
        (if (== $value $curVal) True (Map.checkValue $value $tail)))



;; Remove a key-value pair from map
(: Map.remove (-> $a (Map $a) (Map $a)))
(= (Map.remove $key NilMap) (Error $key "not found"))
(= (Map.remove $key (ConsMap ($curKey $curVal) $tail)) 
    (if (== $key $curKey) $tail (ConsMap ($curKey $curVal) (Map.remove $key $tail))))

;; Get the length of the map
(: Map.length (-> (Map $a) Number))
(= (Map.length NilMap) 0)
(= (Map.length (ConsMap ($curKey $curVal) $tail)) (+ 1 (Map.length $tail)))
