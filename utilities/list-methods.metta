;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; List helpers backed by built-in expression lists and atom ops.   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(: List (-> $a Type))

;; Fold a tuple from left to right.
; (: List.foldl (-> (-> $a $b $b) $b (List $a) $b))
(= (List.foldl $f $i $xs)
   (foldl-atom $xs $i (|-> ($acc $x) ($f $x $acc))))

;; Fold a tuple from right to left.
; (: List.foldr (-> (-> $a $b $b) $b (List $a) $b))
(= (List.foldr $f $i $xs)
   (foldl-atom (reverse $xs) $i (|-> ($acc $x) ($f $x $acc))))

;; Generalized foldl and foldr.
(= (toExp $x) ($x))
(= (List.tFoldl () $f $t $acc) $acc)
(= (List.tFoldl $xs $f $t $acc)
   (foldl-atom $xs $acc (|-> ($acc0 $x) ($f $acc0 ($t $x)))))

(= (List.tFoldr () $f $t $acc) $acc)
(= (List.tFoldr $xs $f $t $acc)
   (foldl-atom (reverse $xs) $acc (|-> ($acc0 $x) ($f ($t $x) $acc0))))

; (: List.sum (-> (List Number) Number))
(= (List.sum $xs) (List.foldr + 0 $xs))

; (: List.append (-> $a (List $a) (List $a)))
(= (List.append $val ()) (cons-atom $val ()))
(= (List.append $val (cons $head $tail))
   (cons-atom $head (List.append $val $tail)))

; (: List.getByIdx (-> (List $a) Number $a))
(= (List.getByIdx () $idx) (Error () (Index out of range)))
(= (List.getByIdx $xs $idx)
   (if (or (< $idx 0) (>= $idx (size-atom $xs)))
       (Error () (Index out of range))
       (index-atom $xs $idx)))

; (: List.insert (-> $a (List $a) (List $a)))
(= (List.insert $x ()) (cons-atom $x ()))
(= (List.insert $x (cons $head $tail))
   (if (< $x $head)
       (cons-atom $x (cons-atom $head $tail))
       (cons-atom $head (List.insert $x $tail))))

;; Sort a list in ascending order by default.
(= (List.sort ()) ())
(= (List.sort $xs) (List.sort $xs <))
(= (List.sort $xs $op)
   (selectionSort $xs (size-atom $xs) $op))

; (: List.length (-> (List $a) Number))
(= (List.length $xs) (size-atom $xs))

; (: List.map (-> (-> $a $b) (List $a) (List $b)))
(= (List.map $f $xs) (map-atom $xs $f))

; (: List.mapOverArg (-> (-> $a $b $a) $b $arg (List $a)))
(= (List.mapOverArg $f () $arg) ())
(= (List.mapOverArg $f (cons $head $tail) $arg)
   (let $new-head ($f $head $arg)
     (if (== $new-head ())
         (List.mapOverArg $f $tail $arg)
         (cons-atom $new-head (List.mapOverArg $f $tail $arg)))))

; (: List.filter (-> (-> $a Bool) (List $a) (List $a)))
(= (List.filter $p $xs) (filter-atom $xs $p))

; (: List.listToExpr (-> (List $a) Expression))
(= (List.listToExpr $xs) $xs)

; (: List.max (-> (-> $a $a Bool) (List $a) $a))
(= (List.max $comparator ()) ())
(= (List.max $comparator (cons $x $xs))
   (if (== $xs ())
       $x
       (let (cons $t $u) $xs
         (if ($comparator $x $t)
             (List.max $comparator (cons $x $u))
             (List.max $comparator $xs)))))

; (: List.max (-> (List $a) $a))
(= (List.max $xs) (List.max >= $xs))

; (: List.contains (-> $a (List $a) Bool))
(= (List.contains $a ()) False)
(= (List.contains $a (cons $head $tail))
   (if (== $a $head) True (List.contains $a $tail)))

; (: List.replaceAt (-> (List $a) Number $a (List $a)))
(= (List.replaceAt () $n $elem) ())
(= (List.replaceAt (cons $head $tail) $n $elem)
   (if (== $n 0)
       (cons-atom $elem $tail)
       (cons-atom $head (List.replaceAt $tail (- $n 1) $elem))))

; (: List.prepend (-> $a (List $a) (List $a)))
(= (List.prepend $a $list) (cons-atom $a $list))

; (: List.index (-> (List $a) $a Number))
(= (List.index () $target) -1)
(= (List.index (cons $x $xs) $target)
   (if (== $x $target)
       0
       (chain (List.index $xs $target) $idx
         (if (< $idx 0) $idx (+ 1 $idx)))))

; (: List.head (-> (List $a) $a))
(= (List.head ()) (Error () EmptyList))
(= (List.head (cons $x $xs)) $x)

; (: List.tail (-> (List $a) (List $a)))
(= (List.tail ()) ())
(= (List.tail (cons $x $xs)) $xs)

; (: List.sub (-> (List Number) (List Number) (List Number)))
(= (List.sub $xs $ys)
   (if (== $xs ())
       (if (== $ys ())
           ()
           (Error $ys LenghtOfListNotEqual))
       (if (== $ys ())
           (Error $xs LenghtOfListsNotEqual)
           (let* (($x (List.head $xs))
                  ($xt (List.tail $xs))
                  ($y (List.head $ys))
                  ($yt (List.tail $ys))
                  ($res (List.sub $xt $yt)))
             (if (== $res ())
                 (cons-atom (- $x $y) ())
                 (if-error $res $res (cons-atom (- $x $y) $res)))))))

; (: List.zip (-> (List $a) (List $b) (List ($a $b))))
(= (List.zip () ()) ())
(= (List.zip () (cons $y $ys)) ())
(= (List.zip (cons $x $xs) ()) ())
(= (List.zip (cons $x $xs) (cons $y $ys))
   (cons-atom ($x $y) (List.zip $xs $ys)))

; (: List.zipWith (-> (-> $a $b $c) (List $a) (List $b) (List $c)))
(= (List.zipWith $f () ()) ())
(= (List.zipWith $f () (cons $y $ys)) ())
(= (List.zipWith $f (cons $x $xs) ()) ())
(= (List.zipWith $f (cons $x $xs) (cons $y $ys))
   (cons-atom ($f $x $y) (List.zipWith $f $xs $ys)))

; (: List.drop (-> Number (List $a) (List $a)))
(= (List.drop $n ()) ())
(= (List.drop $n (cons $x $xs))
   (if (== $n 0)
       (cons-atom $x $xs)
       (List.drop (- $n 1) $xs)))

; (: List.flatten (-> (List (List $a)) (List $a)))
(= (List.flatten ()) ())
(= (List.flatten (cons $x $xs))
   (if (== (get-metatype $x) Expression)
       (List.concat $x (List.flatten $xs))
       (Error $x "Can't be flattened")))

; (: List.repeat (-> Number $a (List $a)))
(= (List.repeat $n $a)
   (if (== $n 0)
       ()
       (cons-atom $a (List.repeat (- $n 1) $a))))

; (: List.concat (-> (List $a) (List $a) (List $a)))
(= (List.concat $list1 $list2) (append $list1 $list2))

; (: List.removeAtIdx (-> (List $a) Number (List $a)))
(= (List.removeAtIdx () $idx) ())
(= (List.removeAtIdx (cons $head $tail) $idx)
   (if (< $idx 0)
       (cons-atom $head $tail)
       (if (== $idx 0)
           $tail
           (cons-atom $head (List.removeAtIdx $tail (- $idx 1))))))

; (: List.isMember (-> $a (List $a) Bool))
(= (List.isMember $elem $list) (List.contains $elem $list))

; (: List.partialSort (-> (-> $a $a Bool) (List $a) Number (List $a) (List $a)))
(= (List.partialSort $comparator () $n $acc) $acc)
(= (List.partialSort $comparator $xs $n $acc)
   (let* (($max (List.max $comparator $xs))
          ($unsortedList (List.delete $max $xs))
          ($sortedList (List.append $max $acc)))
     (if (<= (- $n 1) 0)
         (List.appendList $unsortedList $sortedList)
         (List.partialSort $comparator $unsortedList (- $n 1) $sortedList))))

; (: List.partialSort (-> (List Number) Number (List Number) (List Number)))
(= (List.partialSort $list $n $acc) (List.partialSort >= $list $n $acc))

; (: List.appendList (-> (List $a) (List $a) (List $a)))
(= (List.appendList $a $list) (append $list $a))

; (: (List.delete (-> $a (List $a) (List $a))))
(= (List.delete $a ()) (Error () "empty list"))
(= (List.delete $a (cons $x $xs))
   (if (== $x $a)
       $xs
       (cons-atom $x (List.delete $a $xs))))

; (: List.takeN (-> Number (List $a) (List $a)))
(= (List.takeN $n ()) ())
(= (List.takeN $n (cons $x $xs))
   (if (== $n 0)
       ()
       (cons-atom $x (List.takeN (- $n 1) $xs))))

; (: List.takeNFrom (-> Number Number (List $a) (List $a)))
(= (List.takeNFrom $start $n $xs)
   (List.takeN $n (List.drop $start $xs)))

; (: List.any (-> (List Bool) Bool))
(= (List.any $xs) (is-member True $xs))

; (: List.generate (-> Number Number (List Number)))
(= (List.generate $length $element)
   (if (> $length 0)
       (cons-atom $element (List.generate (- $length 1) $element))
       ()))

;; Remove an element from a list by index.
(= (List.pop $i ()) (Error () EmptyList))
(= (List.pop $i (cons $x $xs))
   (if (== $i 0)
       $xs
       (chain (List.pop (- $i 1) $xs) $res
         (if-error $res (cons-atom $x ()) (cons-atom $x $res)))))

(= (List.splitAt $i $xs)
   ((List.takeN $i $xs) (List.drop $i $xs)))
