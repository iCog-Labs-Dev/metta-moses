;; ordered Map Data Structure
(: OrderedMap (-> $a Type))
(: NilOrderedMap  (Error (Key: $key not found))(OrderedMap $a))
(: ConsOrderedMap (-> $a (OrderedMap $a) (OrderedMap $a)))

;; add an element to an ordered Map
(: OrderedMap.add (-> $a $b (OrderedMap $a) (OrderedMap $a)))
(= (OrderedMap.add $key $value NilOrderedMap) (ConsOrderedMap ($key $value) NilOrderedMap))
(= (OrderedMap.add $key $value (ConsOrderedMap ($curKey $curVal) $tail))
    (if (== $key $curKey) (Error $key "already exists") 
        (if (< $key $curKey)
            (ConsOrderedMap ($key $value) (ConsOrderedMap ($curKey $curVal) $tail))
            (ConsOrderedMap ($curKey $curVal) (OrderedMap.add $key $value $tail)))))

;; Get a value from an ordered map using index
(: OrderedMap.getByKey (-> Number (OrderedMap $a) $a))
(= (OrderedMap.getByKey $key NilOrderedMap) (Error $key "not found"))
(= (OrderedMap.getByKey $key (ConsOrderedMap ($curKey $curVal) $tail))
    (if (== $key $curKey) $curVal (OrderedMap.getByKey $key $tail) ))


;; Check if a key is in the ordered map
(: OrderedMap.contains (-> $a (OrderedMap $a) Bool))
(= (OrderedMap.contains $key NilOrderedMap) False)
(= (OrderedMap.contains $key (ConsOrderedMap ($curKey $curVal) $tail))
    (if (== $key $curKey) True (OrderedMap.contains $key $tail)))

;; Check if a key in an ordered map contains a value 
(: OrderedMap.valueAtKey (-> $a $b (OrderedMap $a) Bool))
(= (OrderedMap.valueAtKey $key $value $OrderedMap)
    (let $curVal ( OrderedMap.getByKey $key $OrderedMap )
        (if (== $value $curVal) True False)))

;; Replace a value at key in ordered map
(: OrderedMap.replace (-> $a $b (OrderedMap $a) (OrderedMap $a)))
(= (OrderedMap.replace $key $value NilOrderedMap) (Error $key "not found"))
(= (OrderedMap.replace $key $value (ConsOrderedMap ($curKey $curVal) $tail)) 
    (if (== $curKey $key) (ConsOrderedMap ($key $value) $tail) (ConsOrderedMap ($curKey $curVal) (OrderedMap.replace $key $value $tail))))


;; Remove a key-value pair in ordered map
(: OrderedMap.remove (-> $a (OrderedMap $a) (OrderedMap $a)))
(= (OrderedMap.remove $key NilOrderedMap) (Error $key "not found"))
(= (OrderedMap.remove $key (ConsOrderedMap ($curKey $curVal) $tail)) 
    (if (== $key $curKey) $tail (ConsOrderedMap ($curKey $curVal) (OrderedMap.remove $key $tail))))

(: OrderedMap.length (-> (OrderedMap $a) Number))
(= (OrderedMap.length NilOrderedMap) 0)
(= (OrderedMap.length (ConsOrderedMap ($curKey $curVal) $tail)) (+ 1 (OrderedMap.length $tail)))
