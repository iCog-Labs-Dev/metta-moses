;; ordered map Data Structure
(: map (-> $a Type))
(: NilMap (Map $k $v))
(: ConsMap ...)
(: Consmap (-> $a (map $a) (map $a)))

;; add an element to an ordered map
(: map.add (-> $a $b (map $a) (map $a)))
(= (map.add $key $value Nilmap) (Consmap ($key $value) Nilmap))
(= (map.add $key $value (Consmap ($curKey $curVal) $tail))
    (if (== $key $curKey) (Error $key "already exists") 
        (if (< $key $curKey)
            (Consmap ($key $value) (Consmap ($curKey $curVal) $tail))
            (Consmap ($curKey $curVal) (map.add $key $value $tail)))))

;; Get a value from an ordered map using index
(: map.getByKey (-> Number (map $a) $a))
(= (map.getByKey $key Nilmap) (Error $key "not found"))
(= (map.getByKey $key (Consmap ($curKey $curVal) $tail))
    (if (== $key $curKey) $curVal (map.getByKey $key $tail) ))


;; Check if a key is in the ordered map
(: map.contains (-> $a (map $a) Bool))
(= (map.contains $key Nilmap) False)
(= (map.contains $key (Consmap ($curKey $curVal) $tail))
    (if (== $key $curKey) True (map.contains $key $tail)))

;; Check if a key in an ordered map contains a value 
(: map.valueAtKey (-> $a $b (map $a) Bool))
(= (map.valueAtKey $key $value $map)
    (let $curVal ( map.getByKey $key $map )
        (if (== $value $curVal) True False)))

;; Replace a value at key in ordered map
(: map.replace (-> $a $b (map $a) (map $a)))
(= (map.replace $key $value Nilmap) (Error $key "not found"))
(= (map.replace $key $value (Consmap ($curKey $curVal) $tail)) 
    (if (== $curKey $key) (Consmap ($key $value) $tail) (Consmap ($curKey $curVal) (map.replace $key $value $tail))))


;; Remove a key-value pair in ordered map
(: map.remove (-> $a (map $a) (map $a)))
(= (map.remove $key Nilmap) (Error $key "not found"))
(= (map.remove $key (Consmap ($curKey $curVal) $tail)) 
    (if (== $key $curKey) $tail (Consmap ($curKey $curVal) (map.remove $key $tail))))

(: map.length (-> (map $a) Number))
(= (map.length Nilmap) 0)
(= (map.length (Consmap ($curKey $curVal) $tail)) (+ 1 (map.length $tail)))
