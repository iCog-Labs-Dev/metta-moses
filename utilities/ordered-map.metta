;; ordered Map Data Structure
(: OrderedMap (-> $a Type))
(: NilOrderedMap  (Error (Key: $key not found))(OrderedMap $a))
(: ConsOrderedMap (-> $a (OrderedMap $a) (OrderedMap $a)))

;; add an element to an ordered Map
(: OrderedMap.add (-> $a $b (OrderedMap $a) (OrderedMap $a)))
(= (OrderedMap.add $key $value NilOrderedMap) (ConsOrderedMap ($key $value) NilOrderedMap))
(= (OrderedMap.add $key $value (ConsOrderedMap $head $tail))
   (let $curKey (car-atom $head) 
    (if (== $key $curKey) (Error $key "already exists") 
        (if (< $key $curKey)
            (ConsOrderedMap ($key $value) (ConsOrderedMap $head $tail))
            (ConsOrderedMap $head (OrderedMap.add $key $value $tail))))))

;; Get a value from an ordered map using index
(: OrderedMap.getByKey (-> Number (OrderedMap $a) $a))
(= (OrderedMap.getByKey $key NilOrderedMap) (Error $key "not found"))
(= (OrderedMap.getByKey $key (ConsOrderedMap $head $tail))
    (let $curKey (car-atom $head)
        (if (== $key $curKey) (cdr-atom $head) (OrderedMap.getByKey $key $tail) )))


;; Check if a key is in the ordered map
(: OrderedMap.contains (-> $a (OrderedMap $a) Bool))
(= (OrderedMap.contains $key NilOrderedMap) False)
(= (OrderedMap.contains $key (ConsOrderedMap $head $tail)) 
    (let $curKey (car-atom $head)
        (if (== $key $curKey) True (OrderedMap.contains $key $tail))))

;; Check if a key in an ordered map contains a value 
(: OrderedMap.valueAtKey (-> $key $value (OrderedMap $a) Bool))
(= (OrderedMap.valueAtKey $key $value $OrderedMap)
    (let $curVal ( OrderedMap.getByKey $key $OrderedMap )
        (if (== ($value) $curVal) True False)))

;Replace a value at key in ordered map
(: OrderedMap.replace (-> $key $value (OrderedMap $a) (OrderedMap $a)))
(= (OrderedMap.replace $key $value NilOrderedMap) (Error $key "not found"))
(= (OrderedMap.replace $key $value (ConsOrderedMap $head $tail)) 
    (let $curKey (car-atom $head) 
        (if (== $curKey $key) (ConsOrderedMap ($key $value) $tail) (ConsOrderedMap $head (OrderedMap.replace $key $value $tail)))))


;; Remove a key-value pair in ordered map
(: OrderedMap.remove (-> $key (OrderedMap $a) (OrderedMap $a)))
(= (OrderedMap.remove $key NilOrderedMap) (Error $key "not found"))
(= (OrderedMap.remove $key (ConsOrderedMap $head $tail)) 
    (let $curKey (car-atom $head) 
        (if (== $key $curKey) $tail (ConsOrderedMap $head (OrderedMap.remove $key $tail)))))

(: OrderedMap.length (-> (OrderedMap $a) Number))
(= (OrderedMap.length NilOrderedMap) 0)
(= (OrderedMap.length (ConsOrderedMap $head $tail)) (+ 1 (OrderedMap.length $tail)))
