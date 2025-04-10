;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Definition of a List data structure with various methods for it. ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(: List (-> $a Type))
(: Nil (List $a))
(: Cons (-> $a (List $a) (List $a)))



;; Fold a tuple from right to left
(: List.foldr (-> (-> $a $b $b) $b (List $a) $b))
(= (List.foldr $f $i Nil) $i)
(= (List.foldr $f $i (Cons $h $t)) ($f $h (List.foldr $f $i $t)))

;; Define List.sum
(: List.sum (-> (List Number) Number))
(= (List.sum $xs) (List.foldr + 0 $xs))


(: List.append (-> $a (List $a) (List $a)))
(= (List.append $val Nil) (Cons $val Nil))
(= (List.append $val (Cons $head $tail)) (Cons $head (List.append $val $tail)))

;; Get an element by index from a list
(: List.getByIdx (-> (List $a) Number $a))
(= (List.getByIdx Nil $idx) (Error (Index out of range)))
(= (List.getByIdx (Cons $head $tail) $idx) (if (== $idx 0 ) $head (List.getByIdx $tail (- $idx 1))) )

;; Insert an element to a presumably sorted list, remains sorted.
(: List.insert (-> $a (List $a) (List $a)))
(= (List.insert $x Nil) (Cons $x Nil))
(= (List.insert $x (Cons $head $tail))
   (if (< $x $head)
       (Cons $x (Cons $head $tail))
       (Cons $head (List.insert $x $tail))))

;; Sort a List in ascending order
(: List.sort (-> (List $a) (List $a)))
(= (List.sort Nil) Nil)
(= (List.sort (Cons $head $tail)) (List.insert $head (List.sort $tail)))

;; helper function to find the length of the list
(: List.length (-> (List $a) Number))
(= (List.length Nil) 0)
(= (List.length (Cons $head $tail)) (+ 1 (List.length $tail)))

;; Map a function over a list
(: List.map (-> (-> $a $b) (List $a) (List $b)))
(= (List.map $f Nil) Nil)
(= (List.map $f (Cons $x $xs)) (Cons ($f $x) (List.map $f $xs)))

;; Filter a list based on a predicate.
(: List.filter (-> (-> $a Bool) (List $a) (List $a)))
(= (List.filter $p Nil) Nil)
(= (List.filter $p (Cons $x $xs)) (if ($p $x) (Cons $x (List.filter $p $xs)) (List.filter $p $xs)))

;; Convert a list to an expression.
(: List.listToExpr (-> (List $a) Expression))
(= (List.listToExpr Nil) ())
(= (List.listToExpr (Cons $x $xs)) (let $t (List.listToExpr $xs) (cons-atom $x $t)))

;; defining List.max function with a comparator that compares non-numerical type values
(: List.max (-> (-> $a $a Bool) (List $a) $a))
(= (List.max $comparator Nil) Nil)
(= (List.max $comparator (Cons $x $xs))
    (if (== $xs Nil)
        $x
         (let (Cons $t $u) $xs
            (if ($comparator $x $t)
                (List.max $comparator (Cons $x $u))
                (List.max $comparator $xs)))))

;; Overloading the above List.max with the built in >= comparison operator for operation on List of numbers
(: List.max (-> (List $a) $a))
(= (List.max (Cons $x $xs)) (List.max >= (Cons $x $xs)))

;; Checks if an element is member of a list
(: List.isMember (-> $a (List $a) Bool))
(= (List.isMember $a Nil) False)
(= (List.isMember $a (Cons $head $tail)) (if (== $a $head) True (List.isMember $a $tail)))

; Replaces an element at a specific index with another element
(: List.replaceAt (-> (List $a) Number $a (List $a)))
(= (List.replaceAt Nil $n $elem) Nil)
(= (List.replaceAt (Cons $head $tail) $n $elem) 
   (if (== $n 0) (Cons $elem $tail) (Cons $head (List.replaceAt $tail (- $n 1) $elem))))  

