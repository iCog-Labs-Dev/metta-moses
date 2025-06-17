;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Definition of a List data structure with various methods for it. ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;; Removes the element at the specified index from the list.
;; Params:
;;   $list: Input list.
;;   $idx: Non-negative index of element to remove (0-based).
;; Returns:
;;   (List $a) - New list with element at $idx removed, or original list if $idx is invalid.
(: List.removeAtIdx (-> (List $a) Number (List $a)))
(= (List.removeAtIdx Nil $idx) Nil)
(= (List.removeAtIdx (Cons $head $tail) $idx)
   (if (< $idx 0) (Cons $head $tail)
       (if (== $idx 0) $tail
           (Cons $head (List.removeAtIdx $tail (- $idx 1))))))

;; Checks if an element exists in a list.
;; Params:
;;   $elem: Element to search for.
;;   $list: Input list to search in.
;; Returns:
;;   Bool - True if $elem is found in $list, False otherwise.
(: List.isMember (-> $a (List $a) Bool))
(= (List.isMember $elem Nil) False)
(= (List.isMember $elem (Cons $head $tail))
   (if (== $elem $head) True
       (List.isMember $elem $tail)))

;; List.partialSort -- sorts the top n values in a list and leaves the rest unsorted      
(: List.partialSort (-> (-> $a $a Bool) (List $a) Number (List $a) (List $a)))
(= (List.partialSort $comparator (Cons $x $xs) $n $acc)
    (let* (($max (List.max $comparator (Cons $x $xs)))
            ($unsortedList (List.delete $max (Cons $x $xs)))
            ($sortedList (List.append $max $acc)))
                
                (if (== (- $n 1) 0)
                    (List.appendList $unsortedList $sortedList)
                    (List.partialSort $comparator $unsortedList (- $n 1) $sortedList))))

;; Overloading the above partialSort for partial Sorting list of numbers -- decreasing order
(: List.partialSort (-> (List Number) Number (List Number) (List Number)))
(= (List.partialSort $list $n $acc) (List.partialSort >= $list $n $acc))          

;; append a list to a list
(: List.appendList (-> (List $a) (List $a) (List $a)))
(= (List.appendList $a (Cons $x $xs))
    (if (== $xs Nil)
        (Cons $x $a)
        (Cons $x (List.appendList $a $xs))))   

;; deletes the first occurence of an item in the list
(: (List.delete (-> $a (List $a) (List $a))))
(= (List.delete $a Nil) (Error Nil "empty list"))
(= (List.delete $a (Cons $x $xs))
    (if (== $x $a)
        $xs
        (Cons $x (List.delete $a $xs))))        

;; List.takeN -- takes the first N members of a list 
(: List.takeN (-> Number (List $a) (List $a)))
(= (List.takeN $n Nil) Nil)
(= (List.takeN $n (Cons $x $xs)) 
    (if (== $n 0)
        Nil
        (let $t (List.takeN (- $n 1) $xs) (Cons $x $t))))

;; List.takeNFrom -- takes N members starting from given start position position 
(: List.takeNFrom (-> Number Number (List $a) (List $a)))
(= (List.takeNFrom $start $n Nil) Nil)
(= (List.takeNFrom $start $n (Cons $x $xs))
    (if (== $n 0)
        Nil
        (if (== $start 0)
            (List.takeN $n (Cons $x $xs))
            (List.takeNFrom (- $start 1) $n $xs))))

;; Returns True if any element in the list is True, otherwise False.
(: List.any (-> (List Bool) Bool))
(= (List.any Nil) False)
(= (List.any (Cons True $xs)) True)
(= (List.any (Cons False $xs)) (List.any $xs))
