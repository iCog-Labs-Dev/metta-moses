;; Ordered set type definition
(: OS (-> $a Type))
(: NilOS (OS $a))
(: ConsOS (-> $a (OS $a) (OS $a)))

;; Insert an element into an ordered set
;; Takes a comparison comparator 
;;      -- comparator returns the result of the comparison in terms of symbol atoms as decribed below
;;      G -- strictly greater than, E -- equal to, L -- strictly lower than
;; TODO: comparison operators used in the original MOSES implementation works by finding the difference between the scores and 
;;      two exemplars are deemed equal if this difference value is within a certain range which is a samll number  
(: OS.insert (-> (-> $a $a Atom) $a (OS $a) (OS $a)))
(= (OS.insert $comparator $x NilOS) (ConsOS $x NilOS))
(= (OS.insert $comparator $new (ConsOS $x $xs))
    
    (case ($comparator $new $x)
        ((G (ConsOS $new (ConsOS $x $xs)))
         (E (ConsOS $x $xs))
         (L (ConsOS $x (OS.insert $comparator $new $xs))))))

;; Length of an OS
(: OS.length (-> (OS $a) Number))
(= (OS.length NilOS) 0)
(= (OS.length (ConsOS $x $xs)) (+ 1 (OS.length $xs)))

;; Get by index
! (bind! INDEX_ERROR "empty set/index out of range")

;; OS.getByIndx -- get by index
(: OS.getByIdx (-> Number (OS $a) $a)) 
(= (OS.getByIdx $idx NilOS) (Error $idx INDEX_ERROR))
(= (OS.getByIdx $idx (ConsOS $x $xs)) 
    (if (== $idx 0)
        $x
        (OS.getByIdx (- $idx 1) $xs)))

;; OS.takeN -- takes N number of exemplars from the oredered set of exemplars
;; this will cull dominated exemplars from the ordered set

(: OS.takeN (-> Number (OS $a) (OS $a)))
(= (OS.takeN $n NilOS) NilOS)
(= (OS.takeN $n (ConsOS $x $xs)) 
    (if (== $n 0)
        NilOS
        (let $t (OS.takeN (- $n 1) $xs) (ConsOS $x $t))))

;; OS.contains -- check is an ordered list contains a particular element
(: OS.contains (-> (OS $a) $a Bool))
(= (OS.contains Nil $el) False)
(= (OS.contains (ConsOS $x $xs) $el)
    (if (== $x $el)
        True
        (OS.contains $xs $el)))

;; removeByIdx
(OS.removeByIdx (-> (OS $a) Number (OS $a)))
(= (OS.removeByIdx NilOS $index) (Error NilOS INDEX_ERROR))
(= (OS.removeByIdx (ConsOS $x $xs) $index)
    (if (== $index 0)
        $xs
        (ConsOS $x (OS.removeByIdx $xs (- $index 1)))))

;; Check if an Exemplar is a member of an ordered set
;; Params:
;;   $exemplar: Exemplar to check
;;   $os: Ordered set (OS Exemplar)
;; Returns:
;;   Bool - True if $exemplar is in $os, False otherwise
(: OS.isMember (-> (Exemplar $a) (OS (Exemplar $a)) Bool))
(= (OS.isMember $exemplar NilOS) False)
(= (OS.isMember $exemplar (ConsOS $x $xs))
   (if (== $exemplar $x)
       True
       (OS.isMember $exemplar $xs)))

; Retrieves the first N elements from an ordered set.
; Params:
;   $n: Number of elements to return.
;   $os: Ordered set of exemplars.
; Return: Ordered set containing the first N elements, or all elements if N exceeds the set size.
(: OS.getTopN (-> Number (OS (Exemplar $a)) (OS (Exemplar $a)))) 
(= (OS.getTopN $n NilOS) NilOS) 
(= (OS.getTopN 0 $os) NilOS) 
(= (OS.getTopN $n (ConsOS $x $xs)) 
   (if (<= $n 1) 
       (ConsOS $x NilOS) 
       (ConsOS $x (OS.getTopN (- $n 1) $xs))))