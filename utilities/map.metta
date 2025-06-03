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

;; An insertion function that also allows map to act as a counter

(: Map.insertCounter (-> $k (Map ($k $v)) (Map ($k $v))))
(= (Map.insertCounter $key NilMap) (ConsMap ($key 1) NilMap))
(= (Map.insertCounter $key (ConsMap ($curKey $curVal) $tail))
    (if (== $key $curKey)
        (ConsMap ($curKey (+ $curVal 1)) $tail)
        (if (< $key $curKey)
            (ConsMap ($key 1) (ConsMap ($curKey $curVal) $tail))
            (ConsMap ($curKey $curVal) (Map.insertCounter $key $tail)))))

;; insert an element to a Map using custom comparison functions (equality $ lessthan)
(: Map.insert (-> ($k $v) (Map ($k $v)) (-> $k $k Bool) (-> $k $k Bool) (Map ($k $v))))
(= (Map.insert ($key $value) NilMap $fEq $fLt) (ConsMap ($key $value) NilMap))
(= (Map.insert ($key $value) (ConsMap ($curKey $curVal) $tail) $fEq $fLt)
    (if ($fEq $key $curKey)  (ConsMap ($key $value) $tail)
        (if ($fLt $key $curKey)
            (ConsMap ($key $value) (ConsMap ($curKey $curVal) $tail))
            (ConsMap ($curKey $curVal) (Map.insert ($key $value) $tail $fEq $fLt)))))

;; Get a value from a Map using key
(: Map.getByKey (-> $k (Map ($k $v)) $v))
(= (Map.getByKey $key NilMap) (Error $key "not found"))
(= (Map.getByKey $key (ConsMap ($curKey $curVal) $tail))
    (if (== $key $curKey) $curVal (Map.getByKey $key $tail) ))

;; Get a pair from a Map using index
(: Map.getByIdx (-> (Map ($k $v)) Number ($k $v)))
(= (Map.getByIdx NilMap $i) (Error NilMap "Index out of bounds"))
(= (Map.getByIdx (ConsMap $x $xs) $i)
   (if (== $i 0)
       $x
       (Map.getByIdx $xs (- $i 1))))

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

;; Get the index of a key value pair given a key
(: Map.find (-> (Map ($k $v)) $k Number))
(= (Map.find NilMap $k) -1)
(= (Map.find (ConsMap ($k $v) $xs) $k')
   (if (== $k $k')
       0
       (chain (Map.find $xs $k'' ) $targetIdx
                      (if (== $targetIdx -1)
                          $targetIdx
                          (+ 1 $targetIdx)))))

!(Map.find (ConsMap ((0) 1) (ConsMap ((1) 2) (ConsMap ((2) 3) NilMap))) (2) )
!(Map.getByIdx (ConsMap ((0) 1) (ConsMap ((1) 2) (ConsMap ((2) 3) NilMap))) 1)

