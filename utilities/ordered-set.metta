;; Ordered set backed by a sorted cons-list.
(: OS (-> $a Type))

;; Insert an element into an ordered set using comparator returning G/E/L.
;; TODO: comparison operators used in the original MOSES implementation works by finding the difference between the scores and 
;;      two exemplars are deemed equal if this difference value is within a certain range which is a samll number
(= (OS.insert $comparator $x ()) ($x))
(= (OS.insert $comparator $new (cons $x $xs))
    (case ($comparator $new $x)
      ((G (cons $new (cons $x $xs)))
       (E (cons $x $xs))
       (L (cons $x (OS.insert $comparator $new $xs))))))

;; Length of an OS
(= (OS.length $os) (size-atom $os))

;; OS.getByIdx -- get by index
(= (OS.getByIdx $idx $os)
   (if (or (< $idx 0) (>= $idx (size-atom $os)))
       (Error 0 "empty set/index out of range")
       (index-atom $os $idx)))

;; OS.takeN -- takes N number of exemplars from the ordered set
(= (OS.takeN $n ()) ())
(= (OS.takeN $n (cons $x $xs))
    (if (<= $n 0)
        ()
        (cons $x (OS.takeN (- $n 1) $xs))))

;; OS.contains -- check if an ordered list contains a particular element
(= (OS.contains $os $el) (is-member $el $os))

;; OS.removeByIdx
(= (OS.removeByIdx () $index) (Error () "empty set/index out of range"))
(= (OS.removeByIdx (cons $x $xs) $index)
    (if (== $index 0)
        $xs
        (chain (OS.removeByIdx $xs (- $index 1)) $res
          (if (== $res ())
              ($x)
              (if-error $res $res (cons $x $res))))))

;; Check if an Exemplar is a member of an ordered set
(= (OS.isMember $exemplar $os) (OS.contains $os $exemplar))

;; Retrieves the first N elements from an ordered set.
(= (OS.getTopN $n ()) (Error () "empty ordered set/ fewer items than required"))
(= (OS.getTopN $n (cons $x $xs))
   (if (== $n 1)
       (cons $x ())
       (chain (OS.getTopN (- $n 1) $xs) $res
          (if-error $res $res (cons $x $res)))))

;; Comparator helpers
(= (genericCompare $atom1 $atom2)
    (if (and (== (get-metatype $atom1) Grounded) (== (get-metatype $atom2) Grounded))
        (case ((< $atom1 $atom2) (== $atom1 $atom2))
            (
                ((True $t) G)
                ((False True) E)
                ((False False) L)
            )
        )
        (if (== $atom1 $atom2)
            E
            (if (== (get-metatype $atom1) Expression)
                (if (== (get-metatype $atom2) Expression)
                    (let* (
                         ($first1 (car-atom $atom1))
                         ($first2 (car-atom $atom2))
                         )
                      (genericCompare $first1 $first2)
                  )
                  L)
                G))))

;; Create OrderedSet of Numbers from start to end-1
(= (OS.range $start $end $acc)
    (if (>= $start $end)
        $acc
        (chain (OS.insert genericCompare $start $acc) $newSet
            (OS.range (+ $start 1) $end $newSet))))

;; Union of two OrderedSets
(= (OS.union () $set2) $set2)
(= (OS.union (cons $head $tail) $set2)
   (chain (OS.insert genericCompare $head $set2) $newSet2
     (OS.union $tail $newSet2)))

;; Difference of two OrderedSets (set1 - set2)
(= (OS.difference () $set2 $result) $result)
(= (OS.difference (cons $head $tail) $set2 $result)
   (if (OS.contains $set2 $head)
       (OS.difference $tail $set2 $result)
       (chain (OS.insert genericCompare $head $result) $newResult
         (OS.difference $tail $set2 $newResult))))

;; Convert OrderedSet to Expression
;; (= (osToExpression $os $acc) (append $os $acc))
(= (osToExpression $os $acc) $os)

;; Convert Expression to OrderedSet
(= (expressionToOS $expr $currentOS) $expr)
