;; Ordered multimap backed by a sorted cons-list of key/value pairs.
(: MultiMap (-> ($k $v) Type))

;; insert an element to the Ordered multimap using custom function
(= (MultiMap.insert ($key $value) () $fn) (cons-atom ($key $value) ()))
(= (MultiMap.insert ($key $value) (cons ($curKey $curVal) $tail) $fn)
   (if ($fn $key $curKey)
       (cons-atom ($key $value) (cons-atom ($curKey $curVal) $tail))
       (cons-atom ($curKey $curVal) (MultiMap.insert ($key $value) $tail $fn))))

;; default insert function using <=
(= (MultiMap.insert $newValue $mMap) (MultiMap.insert $newValue $mMap <=))

;; Get the key value pair given an index.
(= (MultiMap.getByIdx $idx ()) (Error () (Can't find $idx)))
(= (MultiMap.getByIdx $idx $mmap) (List.getByIdx $mmap $idx))

;; Get the first found value with the given key from the Ordered multimap using key
(= (MultiMap.findOne $key ()) (Error $key "not found"))
(= (MultiMap.findOne $key (cons ($curKey $curVal) $tail))
    (if (== $key $curKey) $curVal (MultiMap.findOne $key $tail)))

;; Get all found values with the given key from the Ordered multimap using key
(= (MultiMap.findAll $key ()) ())
(= (MultiMap.findAll $key (cons ($curKey $curVal) $tail))
    (if (== $key $curKey)
        (cons-atom $curVal (MultiMap.findAll $key $tail))
        (MultiMap.findAll $key $tail)))

;; Check if a key is in the Ordered multimap
(= (MultiMap.contains $key ()) False)
(= (MultiMap.contains $key (cons ($curKey $curVal) $tail))
    (if (== $key $curKey) True (MultiMap.contains $key $tail)))

;; Check if a value is in the Ordered multimap
(= (MultiMap.checkValue $value ()) False)
(= (MultiMap.checkValue $value (cons ($curKey $curVal) $tail))
   (if (== $value $curVal) True (MultiMap.checkValue $value $tail)))

;; Remove a key-value pair with a given key from the Ordered multimap
(= (MultiMap.removeOne $key ()) (Error $key "not found"))
(= (MultiMap.removeOne $key (cons ($curKey $curVal) $tail))
    (if (== $key $curKey)
        $tail
        (chain (MultiMap.removeOne $key $tail) $res
          (if-error $res $res (cons-atom ($curKey $curVal) $res)))))

;; Remove all key-value pairs with a given key from the Ordered multimap
(= (MultiMap.removeAll $key ()) ())
(= (MultiMap.removeAll $key (cons ($curKey $curVal) $tail))
    (if (== $key $curKey)
        (MultiMap.removeAll $key $tail)
        (cons-atom ($curKey $curVal) (MultiMap.removeAll $key $tail))))

;; Get all the values from the multimap
(= (MultiMap.values $mmap)
   (map-atom $mmap $pair (let ($key $value) $pair $value)))

;; Get all the keys from the multimap
(= (MultiMap.keys $mmap)
   (map-atom $mmap $pair (let ($key $value) $pair $key)))

;; Get all the key value pairs from the multimap
(= (MultiMap.items $mmap) $mmap)

;; Get the length of the Ordered multimap
(= (MultiMap.length $mmap) (size-atom $mmap))

;; Check if an element is found in the Ordered multimap
(= (MultiMap.checkElement $element $mmap)
   (is-member $element $mmap))

;; Check if two multimaps are equal regardless of the order of the elements
(= (MultiMap.equals $mm1 $mm2)
   (and (== (MultiMap.length $mm1) (MultiMap.length $mm2))
        (and (== (subtraction-atom $mm1 $mm2) ())
             (== (subtraction-atom $mm2 $mm1) ()))))
