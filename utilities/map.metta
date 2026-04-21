;; Map Data Structure backed by a sorted cons-list of key/value pairs.
(: Map (-> ($k $v) Type))

;; An insertion function that also allows map to act as a counter
(= (Map.insertCounter $key ()) (cons-atom ($key 1) ()))
(= (Map.insertCounter $key (cons ($curKey $curVal) $tail))
    (if (== $key $curKey)
        (cons-atom ($curKey (+ $curVal 1)) $tail)
        (if (< $key $curKey)
            (cons-atom ($key 1) (cons-atom ($curKey $curVal) $tail))
            (cons-atom ($curKey $curVal) (Map.insertCounter $key $tail)))))

;; insert an element to a Map using custom comparison functions (equality + less-than)
(= (Map.insert ($key $value) () $fEq $fLt) (cons-atom ($key $value) ()))
(= (Map.insert ($key $value) (cons ($curKey $curVal) $tail) $fEq $fLt)
    (if ($fEq $key $curKey)
        (cons-atom ($key $value) $tail)
        (if ($fLt $key $curKey)
            (cons-atom ($key $value) (cons-atom ($curKey $curVal) $tail))
            (cons-atom ($curKey $curVal) (Map.insert ($key $value) $tail $fEq $fLt)))))

;; insert an element to a Map
(= (Map.insert ($key $value) ()) (cons-atom ($key $value) ()))
(= (Map.insert ($key $value) (cons ($curKey $curVal) $tail))
    (if (== $key $curKey)
        (cons-atom ($key $value) $tail)
        (if (< $key $curKey)
            (cons-atom ($key $value) (cons-atom ($curKey $curVal) $tail))
            (cons-atom ($curKey $curVal) (Map.insert ($key $value) $tail)))))

;; Get a value from a Map using key
(= (Map.getByKey $key ()) (Error $key "not found"))
(= (Map.getByKey $key (cons ($curKey $curVal) $tail))
    (if (== $key $curKey) $curVal (Map.getByKey $key $tail)))

;; Get a pair from a Map using index
(= (Map.getByIdx () $i) (Error () "Index out of bounds"))
(= (Map.getByIdx $map $i)
   (List.getByIdx $map $i))

;; Check if a key is in the Map
(= (Map.contains $key ()) False)
(= (Map.contains $key (cons ($curKey $curVal) $tail))
    (if (== $key $curKey) True (Map.contains $key $tail)))

;; Check if a value is in a Map
(= (Map.checkValue $value ()) False)
(= (Map.checkValue $value (cons ($curKey $curVal) $tail))
   (if (== $value $curVal) True (Map.checkValue $value $tail)))

;; Remove a key-value pair from map
(= (Map.remove $key ()) (Error $key "not found"))
(= (Map.remove $key (cons ($curKey $curVal) $tail))
    (if (== $key $curKey)
        $tail
        (chain (Map.remove $key $tail) $res
          (if-error $res $res (cons-atom ($curKey $curVal) $res)))))

;; Get all the values from the map
(= (Map.values $map)
   (map-atom $map $pair (let ($key $value) $pair $value)))

;; Get all the keys from the map
(= (Map.keys $map)
   (map-atom $map $pair (let ($key $value) $pair $key)))

;; Get all the key value pairs from the map
(= (Map.items $map) $map)

;; Get the length of the map
(= (Map.length $map) (size-atom $map))

;; Get the index of a key value pair given a key
(= (Map.find () $k) -1)
(= (Map.find (cons ($curKey $curVal) $xs) $k')
   (if (== $curKey $k')
       0
       (chain (Map.find $xs $k') $targetIdx
         (if (== $targetIdx -1)
             $targetIdx
             (+ 1 $targetIdx)))))
