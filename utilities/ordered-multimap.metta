;; Ordered multimap Data Structure
(: OMM (-> ($k $v) Type))
(: NilOMM (OMM ($k $v)))
(: ConsOMM (-> ($k $v) (OMM ($k $v)) (OMM ($k $v))))

;; insert an element to the Ordered multimap
(: OMM.insert (-> ($k $v) (OMM ($k $v)) (OMM ($k $v))))
(= (OMM.insert ($key $value) NilOMM) (ConsOMM ($key $value) NilOMM))
(= (OMM.insert ($key $value) (ConsOMM ($curKey $curVal) $tail))
        (if (<= $key $curKey)
            (ConsOMM ($key $value) (ConsOMM ($curKey $curVal) $tail))
            (ConsOMM ($curKey $curVal) (OMM.insert ($key $value) $tail))))

;; Get the first found value with the given key from the Ordered multimap using key
(: OMM.findOne (-> $k (OMM ($k $v)) $v))
(= (OMM.findOne $key NilOMM) (Error $key "not found"))
(= (OMM.findOne $key (ConsOMM ($curKey $curVal) $tail))
    (if (== $key $curKey) $curVal (OMM.findOne $key $tail) ))

;; Get all found values with the given key from the Ordered multimap using key
(: OMM.findAll (-> $k (OMM ($k $v)) Expression))
(= (OMM.findAll $key NilOMM) ())
(= (OMM.findAll $key (ConsOMM ($curKey $curVal) $tail)) 
    (if (== $key $curKey)
        (let $rest (OMM.findAll $key $tail) (cons-atom $curVal $rest)) 
        (OMM.findAll $key $tail)))

;; Check if a key is in the Ordered multimap
(: OMM.contains (-> $k (OMM ($k $v)) Bool))
(= (OMM.contains $key NilOMM) False)
(= (OMM.contains $key (ConsOMM ($curKey $curVal) $tail))
    (if (== $key $curKey) True (OMM.contains $key $tail)))

;; Check if a value in the Ordered multimap 
(: OMM.checkValue (-> $v (OMM ($k $v)) Bool))
(= (OMM.checkValue $value NilOMM) False)
(= (OMM.checkValue $value (ConsOMM ($curKey $curVal) $tail))
        (if (== $value $curVal) True (OMM.checkValue $value $tail)))


;; Remove a key-value pair with a given key from the Ordered multimap
(: OMM.removeOne (-> $k (OMM ($k $v)) (OMM ($k $v))))
(= (OMM.removeOne $key NilOMM) (Error $key "not found"))
(= (OMM.removeOne $key (ConsOMM ($curKey $curVal) $tail)) 
    (if (== $key $curKey) $tail (ConsOMM ($curKey $curVal) (OMM.removeOne $key $tail))))

;; Remove all key-value pair with a given key from the Ordered multimap
(: OMM.removeAll (-> $k (OMM ($k $v)) (OMM ($k $v))))
(= (OMM.removeAll $key NilOMM) NilOMM)
(= (OMM.removeAll $key (ConsOMM ($curKey $curVal) $tail)) 
    (if (== $key $curKey) (OMM.removeAll $key $tail) (ConsOMM ($curKey $curVal) (OMM.removeAll $key $tail))))
    
;; Get the length of the Ordered multimap
(: OMM.length (-> (OMM ($k $v)) Number))
(= (OMM.length NilOMM) 0)
(= (OMM.length (ConsOMM ($curKey $curVal) $tail)) (+ 1 (OMM.length $tail)))

