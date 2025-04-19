;; Ordered multimap Data Structure
(: MultiMap (-> ($k $v) Type))
(: NilMMap (MultiMap ($k $v)))
(: ConsMMap (-> ($k $v) (MultiMap ($k $v)) (MultiMap ($k $v))))

;; default insert function that insert an element to the Ordered MultiMap using <=.
(: MultiMap.insert (-> ($k $v) (MultiMap ($k $v)) (MultiMap ($k $v))))
(= (MultiMap.insert $newValue $mMap) (MultiMap.insert $newValue $mMap <=))

;; insert an element to the Ordered multimap using custum function
(: MultiMap.insert (-> ($k $v) (MultiMap ($k $v)) (-> $k $k Bool) (MultiMap ($k $v))))
(= (MultiMap.insert ($key $value) NilMMap $fn) (ConsMMap ($key $value) NilMMap))
(= (MultiMap.insert ($key $value) (ConsMMap ($curKey $curVal) $tail) $fn)
        (if ($fn $key $curKey)
            (ConsMMap ($key $value) (ConsMMap ($curKey $curVal) $tail))
            (ConsMMap ($curKey $curVal) (MultiMap.insert ($key $value) $tail $fn))))

;; Get the first found value with the given key from the Ordered multimap using key
(: MultiMap.findOne (-> $k (MultiMap ($k $v)) $v))
(= (MultiMap.findOne $key NilMMap) (Error $key "not found"))
(= (MultiMap.findOne $key (ConsMMap ($curKey $curVal) $tail))
    (if (== $key $curKey) $curVal (MultiMap.findOne $key $tail) ))

;; Get all found values with the given key from the Ordered multimap using key
(: MultiMap.findAll (-> $k (MultiMap ($k $v)) (List $v)))
(= (MultiMap.findAll $key NilMMap) Nil)
(= (MultiMap.findAll $key (ConsMMap ($curKey $curVal) $tail)) 
    (if (== $key $curKey)
        (Cons $curVal (MultiMap.findAll $key $tail))
        (MultiMap.findAll $key $tail)))

;; Check if a key is in the Ordered multimap
(: MultiMap.contains (-> $k (MultiMap ($k $v)) Bool))
(= (MultiMap.contains $key NilMMap) False)
(= (MultiMap.contains $key (ConsMMap ($curKey $curVal) $tail))
    (if (== $key $curKey) True (MultiMap.contains $key $tail)))

;; Check if a value in the Ordered multimap 
(: MultiMap.checkValue (-> $v (MultiMap ($k $v)) Bool))
(= (MultiMap.checkValue $value NilMMap) False)
(= (MultiMap.checkValue $value (ConsMMap ($curKey $curVal) $tail))
        (if (== $value $curVal) True (MultiMap.checkValue $value $tail)))


;; Remove a key-value pair with a given key from the Ordered multimap
(: MultiMap.removeOne (-> $k (MultiMap ($k $v)) (MultiMap ($k $v))))
(= (MultiMap.removeOne $key NilMMap) (Error $key "not found"))
(= (MultiMap.removeOne $key (ConsMMap ($curKey $curVal) $tail)) 
    (if (== $key $curKey) $tail (ConsMMap ($curKey $curVal) (MultiMap.removeOne $key $tail))))

;; Remove all key-value pair with a given key from the Ordered multimap
(: MultiMap.removeAll (-> $k (MultiMap ($k $v)) (MultiMap ($k $v))))
(= (MultiMap.removeAll $key NilMMap) NilMMap)
(= (MultiMap.removeAll $key (ConsMMap ($curKey $curVal) $tail)) 
    (if (== $key $curKey) (MultiMap.removeAll $key $tail) (ConsMMap ($curKey $curVal) (MultiMap.removeAll $key $tail))))


;; Get the all the values from the map
(: MultiMap.values (-> (MultiMap ($v $v)) Expression))
(= (MultiMap.values NilMMap) ())
(= (MultiMap.values (ConsMultiMap ($key $value) $tail))
    (let $rest (MultiMap.values $tail) (cons-atom $value $rest)))

;; Get the all the keys from the MultiMap
(: MultiMap.keys (-> (MultiMap ($v $v)) Expression))
(= (MultiMap.keys NilMMap) ())
(= (MultiMap.keys (ConsMultiMap ($key $value) $tail))
    (let $rest (MultiMap.keys $tail) (cons-atom $key $rest)))

;; Get the all the key value pairs from the MultiMap
(: MultiMap.items (-> (MultiMap ($v $v)) Expression))
(= (MultiMap.items NilMMap) ())
(= (MultiMap.items (ConsMultiMap $pair $tail))
    (let $rest (MultiMap.items $tail) (cons-atom $pair $rest)))


;; Get the length of the Ordered multimap
(: MultiMap.length (-> (MultiMap ($k $v)) Number))
(= (MultiMap.length NilMMap) 0)
(= (MultiMap.length (ConsMMap ($curKey $curVal) $tail)) (+ 1 (MultiMap.length $tail)))

