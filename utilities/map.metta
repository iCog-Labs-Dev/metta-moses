;; Map Data Structure
(: Map (-> ($k $v) Type))
(: NilMap (Map ($k $v)))
(: ConsMap (-> ($k $v) (Map ($k $v)) (Map ($k $v))))

;; insert an element to a Map
(: Map.insert (-> ($k $v) (Map ($k $v)) (Map ($k $v))))
(= (Map.insert ($key $value) NilMap) (ConsMap ($key $value) NilMap))
(= (Map.insert ($key $value) (ConsMap ($curKey $curVal) $tail))
    (if (== $key $curKey)  (ConsMap ($key $value) $tail)
        (if (< $key $curKey)
            (ConsMap ($key $value) (ConsMap ($curKey $curVal) $tail))
            (ConsMap ($curKey $curVal) (Map.insert ($key $value) $tail)))))

;; Get a value from a Map using index
(: Map.getByKey (-> $k (Map ($k $v)) $v))
(= (Map.getByKey $key NilMap) (Error $key "not found"))
(= (Map.getByKey $key (ConsMap ($curKey $curVal) $tail))
    (if (== $key $curKey) $curVal (Map.getByKey $key $tail) ))


;; Check if a key is in the Map
(: Map.contains (-> $k (Map ($k $v)) Bool))
(= (Map.contains $key NilMap) False)
(= (Map.contains $key (ConsMap ($curKey $curVal) $tail))
    (if (== $key $curKey) True (Map.contains $key $tail)))

;; Check if a value in a Map 
(: Map.checkValue (-> $v (Map ($k $v)) Bool))
(= (Map.checkValue $value NilMap) False)
(= (Map.checkValue $value (ConsMap ($curKey $curVal) $tail))
        (if (== $value $curVal) True (Map.checkValue $value $tail)))



;; Remove a key-value pair from map
(: Map.remove (-> $k (Map ($k $v)) (Map ($k $v))))
(= (Map.remove $key NilMap) (Error $key "not found"))
(= (Map.remove $key (ConsMap ($curKey $curVal) $tail)) 
    (if (== $key $curKey) $tail (ConsMap ($curKey $curVal) (Map.remove $key $tail))))

;; Get the all the values from the map
(: Map.values (-> (Map ($k $v)) (List $v)))
(= (Map.values NilMap) Nil)
(= (Map.values (ConsMap ($key $value) $tail))
    (Cons $value (Map.values $tail)))

;; Get the all the keys from the map
(: Map.keys (-> (Map ($k $v)) (List $k)))
(= (Map.keys NilMap) Nil)
(= (Map.keys (ConsMap ($key $value) $tail))
    (Cons $key (Map.keys $tail)))

;; Get the all the key value pairs from the map
(: Map.items (-> (Map ($k $v)) (List ($k $v))))
(= (Map.items NilMap) Nil)
(= (Map.items (ConsMap $pair $tail))
    (Cons $pair (Map.items $tail)))

;; Get the length of the map
(: Map.length (-> (Map ($k $v)) Number))
(= (Map.length NilMap) 0)
(= (Map.length (ConsMap ($curKey $curVal) $tail)) (+ 1 (Map.length $tail)))
