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
;; (: OS.insert (-> (-> $a $a Atom) $a (OS $a) (OS $a)))
(= (OS.insert $comparator $x NilOS) (ConsOS $x NilOS))
(= (OS.insert $comparator $new (ConsOS $x $xs))
    
    (case ($comparator $new $x)
        ((G (ConsOS $new (ConsOS $x $xs)))
         (E (ConsOS $x $xs))
         (L (ConsOS $x (OS.insert $comparator $new $xs))))))

;; Length of an OS
;; (: OS.length (-> (OS $a) Number))
(= (OS.length NilOS) 0)
(= (OS.length (ConsOS $x $xs)) (+ 1 (OS.length $xs)))

;; OS.getByIndx -- get by index
;; (: OS.getByIdx (-> Number (OS $a) $a)) 
(= (OS.getByIdx $idx NilOS) (Error $idx "empty set/index out of range"))
(= (OS.getByIdx $idx (ConsOS $x $xs)) 
    (if (== $idx 0)
        $x
        (OS.getByIdx (- $idx 1) $xs)))

;; OS.takeN -- takes N number of exemplars from the oredered set of exemplars
;; this will cull dominated exemplars from the ordered set

;; (: OS.takeN (-> Number (OS $a) (OS $a)))
(= (OS.takeN $n NilOS) NilOS)
(= (OS.takeN $n (ConsOS $x $xs)) 
    (if (== $n 0)
        NilOS
        (let $t (OS.takeN (- $n 1) $xs) (ConsOS $x $t))))

;; OS.contains -- check is an ordered list contains a particular element
;; (: OS.contains (-> (OS $a) $a Bool))
(= (OS.contains NilOS $el) False)
(= (OS.contains (ConsOS $x $xs) $el)
    (if (== $x $el)
        True
        (OS.contains $xs $el)))

;; OS.removeByIdx 
;; (: OS.removeByIdx (-> (OS $a) Number (OS $a)))
(= (OS.removeByIdx NilOS $index) (Error NilOS "empty set/index out of range"))
(= (OS.removeByIdx (ConsOS $x $xs) $index)
    (if (== $index 0)
        $xs
        (chain (OS.removeByIdx $xs (- $index 1)) $res
        (eval (if-error $res $res (ConsOS $x $res))))))

;; Check if an Exemplar is a member of an ordered set
;; Params:
;;   $exemplar: Exemplar to check
;;   $os: Ordered set (OS Exemplar)
;; Returns:
;;   Bool - True if $exemplar is in $os, False otherwise
;; (: OS.isMember (-> (Exemplar $a) (OS (Exemplar $a)) Bool))
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
;; (: OS.getTopN (-> Number (OS (Exemplar $a)) (OS (Exemplar $a)))) 
(= (OS.getTopN $n NilOS) (Error NilOS "empty ordered set/ fewer items than required")) 
(= (OS.getTopN $n (ConsOS $x $xs))
    (if (== $n 1)
        (ConsOS $x NilOS)
        (chain (OS.getTopN (- $n 1) $xs) $res 
            (eval (if-error $res $res (ConsOS $x $res))))))


;; (: genericCompare (-> Atom Atom Atom))
(= (genericCompare $atom1 $atom2)
    (if (and (== (get-metatype $atom1) Grounded) (== (get-metatype $atom2) Grounded))
        ;; Both are numbers - direct numeric comparison
        (case ((< $atom1 $atom2) (== $atom1 $atom2))
            (
                ((True $t) G)
                ((False True) E)
                ((False False) L)
            )
        )
        ;; At least one is an expression - check equality first
        (if (== $atom1 $atom2)
            E
            ;; For expressions, use lexicographic comparison based on first element
            (if (== (get-metatype $atom1) Expression)
                (if (== (get-metatype $atom2) Expression)
                    ;; Both expressions - compare first elements
                      (let* (
                           ($first1 (car-atom $atom1))
                           ($first2 (car-atom $atom2))
                           )
                        (genericCompare $first1 $first2)
                    )
                    ;; atom1 is expression, atom2 is not - expressions come after atoms
                    L)
                ;; atom1 is not expression but atom2 is - atoms come before expressions  
                G
            )
        )
    )
)

;; Purpose: Create OrderedSet of Numbers from start to end-1
;; Parameters:
;;   $start (Number) → Starting index
;;   $end (Number) → Ending index (exclusive)
;;   $acc (OS Number) → Accumulator OrderedSet
;; Returns: (OS Number) → OrderedSet with range of numbers
;; Example: (OS.range 0 3 NilOS) → (ConsOS 0 (ConsOS 1 (ConsOS 2 NilOS)))
;; (: OS.range (-> Number Number (OS Number) (OS Number)))
(= (OS.range $start $end $acc)
    (if (>= $start $end)
        $acc
        (chain (OS.insert genericCompare $start $acc) $newSet
            (OS.range (+ $start 1) $end $newSet)
        )
    )
) 

;; Purpose: Union of two OrderedSets
;; Parameters:
;;   $set1 (OS Number) → First set
;;   $set2 (OS Number) → Second set
;; Returns: (OS Number) → Union of both sets
;; Example: (OS.union (ConsOS 0 (ConsOS 1 NilOS)) (ConsOS 2 NilOS)) → (ConsOS 0 (ConsOS 1 (ConsOS 2 NilOS)))
;; (: OS.union (-> (OS Number) (OS Number) (OS Number)))
;; (: OS.union (-> (OS Number) (OS Number) (OS Number)))
(= (OS.union NilOS $set2) $set2)
(= (OS.union (ConsOS $head $tail) $set2)
   (chain (OS.insert genericCompare $head $set2) $newSet2
     (OS.union $tail $newSet2)
   )
)

;; Purpose: Difference of two OrderedSets (set1 - set2)
;; Parameters:
;;   $set1 (OS Number) → Set to subtract from
;;   $set2 (OS Number) → Set to subtract
;;   $result (OS Number) → Accumulator for result
;; Returns: (OS Number) → Elements in set1 but not in set2
;; Example: (OS.difference (ConsOS 0 (ConsOS 1 NilOS)) (ConsOS 1 NilOS) NilOS) → (ConsOS 0 NilOS)
;; (: OS.difference (-> (OS Number) (OS Number) (OS Number) (OS Number)))
(= (OS.difference NilOS $set2 $result) $result)
(= (OS.difference (ConsOS $head $tail) $set2 $result)
   (if (OS.contains $set2 $head)
       (OS.difference $tail $set2 $result)
       (chain (OS.insert genericCompare $head $result) $newResult
         (OS.difference $tail $set2 $newResult)
       )
    )
)


;; Purpose: Convert OrderedSet to Expression
;; Parameters:
;;   $os (OS $a) → OrderedSet to convert
;;   $acc (Expression) → Accumulator expression
;; Returns: (Expression) → Expression with OS elements
;; Example: (osToExpression (ConsOS 0 (ConsOS 1 (ConsOS 2 NilOS))) ()) → (0 1 2)
;; (: osToExpression (-> (OS $a) Expression Expression))
(= (osToExpression NilOS $acc) $acc)
(= (osToExpression (ConsOS $head $tail) $acc)
   (let $rest (osToExpression $tail $acc)
     (cons-atom $head $rest)
   )
)


;; Purpose: Convert Expression to OrderedSet
;; Parameters:
;;   $expr (Expression) → Expression to convert
;;   $currentOS (OS $a) → Current OrderedSet being built
;; Returns: (OS $a) → OrderedSet with expression elements
;; Example: (expressionToOS (2 0 1) NilOS) → (ConsOS 0 (ConsOS 1 (ConsOS 2 NilOS)))
;; (: expressionToOS (-> Expression (OS $a) (OS $a)))
(= (expressionToOS $expr $currentOS)
    (if (== $expr ())
        $currentOS
        (let ($head $tail) (decons-atom $expr)
                (chain (OS.insert genericCompare $head $currentOS) $newOS
                    (expressionToOS $tail $newOS)
                )
        )
    )
)