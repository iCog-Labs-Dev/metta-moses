;; Helper functions that are going to be useful for writing any metta code
(: ~= (-> Atom Atom Bool))
(= (~= $a $b) (not (== $a $b)))

;; INFO: Uncomment for the use of MeTTaLog.
;; (: >= (-> Number Number Bool))
;; (= (>= $a $b) (or (== $a $b) (> $a $b)))

;Function to cocatinate two tuples (A B) (C D) ==> (A B C D)
;(: cocatTuple (-> Expression Expression Expression))
(= (concatTuple $x $y)
    (union-atom $x $y)
)

(: ++ (-> Expression Expression Expression))
(= (++ $x $y)
   (case ((isSymbol $x) (isSymbol $y))
      (
        ((True True)  ($x $y))
        ((True False) (cons-atom $x $y))
        ((False True) (appendAtom $y $x))
        ((False False)  (foldr cons-atom $y $x)))))

; a helper function to the isConsistentExp function.
; a function which simplifies nested logical negations by reducing them to their simplest form. 
(= (Not $a)
    (if (== (get-metatype $a) Symbol)
        (NOT $a)
        (if (== (get-metatype $a) Expression)
            (case $a
                (
                    ( (NOT $b) (if (== (get-metatype $b) Symbol) $b (Not $b)))
                )
        )
    False
)
)
)

; a helper function to the isConsistentExp function.
; a function which checks if an element is member of a tuple.
(: isZero (-> Number Bool))
(= (isZero $x) (== $x 0))

;; It will return True if greater than 10.
(: greaterThanTen (-> Number Bool))
(= (greaterThanTen $x) (> $x 10))

;; It will decrement the input by 1.
(: decrement (-> Number Number))
(= (decrement $x) (- $x 1))

;; It will increment the input by 1.
(: increment (-> Number Number))
(= (increment $x) (+ $x 1))

;; A function that turns every atom to unit
(: transformToUnit (-> Atom Atom))
(= (transformToUnit $x) ())

(: isMember (-> $a $aa Bool))

(= (isMember $x $list)
    (let $netVal (intersection-atom ($x) $list) (not (== $netVal ())))
)
; This function assumes it receives a set1 and set2 expression as parameters.
; It then removes similar elements found in set2 that already exist in set1.
; The function uses isMember from general helpers functions.

(: setDifference (-> Expression Expression Expression))
(= (setDifference $set1 $set2) 
    (if (== $set1 ()) () ; Base case: return empty set when $set1 is empty
        (let* (
            ($head (car-atom $set1))  ; Extract the head of set1
            ($tail (cdr-atom $set1))  ; Extract the tail of set1
            ($newtail (setDifference $tail $set2))  ; Recursively process the tail
        )
            ; Check if the $head is in set2, if so, skip it

            (if (isMember $head $set2)
                $newtail 
                ; Otherwise, add the head to the new tail, avoiding unnecessary parentheses
                (if (== (get-metatype $newtail) Expression) (cons-atom $head $newtail) $head)  ; Avoid wrapping the head if it's already properly structured
            )
        )
    )
)

;; A helper function for the findAndReplace function.
;; It handles the replacement of a single atom.
(= (replace $old $new $current) (if (== $old $current) $new $current))

;; A function to replace a specific atom
;;    with a new one from a list of atoms.
;; INFO: This function needs to change so that it can preserve the
;;        operator's position when MeTTa version is upgraded.
(= (findAndReplace $old $new $list) 
  (if (== $list ())
   $list 
   (let* ( 
    ($head (car-atom $list)) 
    ($tail (cdr-atom $list)) 
    ($rest (findAndReplace $old $new $tail))
        ) 
  (if (== $head $old) 
    (union-atom ($new) $rest)
    (union-atom ($head) $rest) 

  ) 
)))
;; A function that behaves like a do while loop.
;; It executes the functions in the given list and returns the last result.
;(: until (-> (-> $a Bool) (-> $a $a) $a $a))
(= (until $predicate $function $x) (if ($predicate $x) $x (let $y ($function $x) (until $predicate $function $y))))

;; A foldleft function like the implementation in Haskell.
;; It takes a binary function that expects two atoms and
;;    apply it recursively on a nested atom.
(: foldl (-> (-> $a $b $d) $b $c $d))
(= (foldl $f $acc $tuple)
   (if (== $tuple ())
       $acc
       (let $next (car-atom $tuple) (foldl $f ($f $next $acc) (cdr-atom $tuple)))
   )
)

;; Fold a tuple from right to left
(: foldr (-> (-> $a $b $b) $b $c $d))
(= (foldr $f $i $xs)
   (if (== $xs ())
       $i
       (let* (($h (car-atom $xs))
              ($t (cdr-atom $xs))
              ($ft (foldr $f $i $t)))
         ($f $h $ft))))

;; Apply a given function to every element of a tuple
(: map (-> (-> $a $b) $c $d))
(= (map $f $xs)
   (if (== $xs ())
       ()
       (let* (($h (car-atom $xs))
              ($t (cdr-atom $xs))
              ($fh ($f $h))
              ($ft (map $f $t)))
         (cons-atom $fh $ft))))

;; Function: wrapper
;; Description: This function applies a predicate to an atom and returns the atom if the predicate is true, otherwise returns an empty expression.
;; Parameters:
;;   - $predicate: A function that takes an atom and returns a boolean value.
;;   - $x: The atom to which the predicate is applied.
;; Returns:
;;   - Expression: Returns the atom if the predicate evaluates to true, otherwise returns an empty expression.
(:wrapper (-> (-> $a Bool) $aa $aa))
(= (wrapper $predicate $x) (if (let $bool ($predicate $x) $bool) $x (empty)))

;; Filter function given a predicate
(: filter (-> (-> $a Bool) $aa $a))
(= (filter $predicate $list)
   (wrapper $predicate (superpose $list)))

;; INFO: Uncommnet the following two functions when using MeTTaLog.
;; ;; (:wrapperB (-> (-> $a $b Bool) $a $b $b))
;; (= (wrapperB $predicate $x $y) (if ($predicate $x $y) $y (empty)))
;;
;; (: filterB (-> (-> $a $b Bool) $a $bb $bb))
;; (= (filterB $predicate $x $list)
;;    (wrapperB $predicate $x (superpose $list)))

;; A function to remove all elements found in $common from a $tuple
(= (removeElement $common $tuple)
   (collapse (subtraction (superpose $tuple) (superpose $common))))

;; A function that returns True if any of the input atoms are True and False otherwise
;; Example: input ==> (True True False), output ==> True
;;          input ==> (False False False), output ==> False
;;          input ==> (False True False), output ==> True
(: any (-> Atom Bool))
(= (any $bools) (isMember True $bools))

;; A trick to define `curry` in MeTTa without `lambda`
(: curry (-> (-> $a $b $c) (-> $a (-> $b $c))))
(= (((curry $f) $x) $y) ($f $x $y))

;; Add numbers in an atom list
(= (sum $list) (foldr + 0 $list))

;; Function to count atom occrence in a list of atoms.
(= (count $atom $list)
   (if (== $list ())
        0
        (sum (collapse (if (== $atom (superpose $list)) 1 (empty))))))



(: isSymbol (-> Expression Bool))
(= (isSymbol $expr) (== (get-metatype $expr) Symbol))


(: isUnit (-> Atom Bool))
(= (isUnit $expr) (== $expr ()))

(: isSingleAtom (-> Atom Bool))
(= (isSingleAtom $expr)
    (if (== (isUnit $expr) ()) False
        (if (== (get-metatype $expr) Expression)
            (if (== (size-atom $expr) 1) True False)
            False
        )
    )


)


;; Function to replace a given atom from a space.
(: update-atom (-> Grounded Atom Atom (->)))
(= (update-atom $space $oatom $natom) (let $_ (remove-atom $space $oatom) (add-atom $space $natom)))

;; Function to replace a given atom from a space.
(: appendAtom (-> Atom Atom Atom))
(= (appendAtom $a $atom) (foldr cons-atom ($a) $atom))

;; Return the maximum of two numbers.
(= (max $x $y) (if (< $x $y) $y $x))

;; A function to return a tuple of numbers from natural to a given number.
;; $x is the upperbound
;; $acc is the lowerbound wrapped with as a tuple.
;;    Example: (gen 5 (0)) => (5 4 3 2 1 0)
(= (gen $x $acc)
   (if (== (car-atom $acc) $x)
       $acc
       (let $lastInserted (car-atom $acc) (gen $x (cons-atom (+ 1 $lastInserted) $acc)))))

;; A function to return head and tail of an atom in a tuple.
(= (decons $atom)
   (if (not (or (isSymbol $atom) (isUnit $atom)))
       ((car-atom $atom) (cdr-atom $atom))
       (Error Unit Or Symbol cannot be deconstructed)))

;; Function to create a tuple of tuples given two equal length list of atoms.
(= (zip $a $b)
   (if (or (isSingleAtom $a) (isSingleAtom $b))
       (((car-atom $a) (car-atom $b)))
       (let*
          (
            (($x $xs) (decons $a))
            (($y $ys) (decons $b))
            ($rest (zip $xs $ys))
          )
          (cons-atom ($x $y) $rest)))
)

;; Similar to zip but instead of just creating a tuple of atoms,
;;  it performes an operation of $f on them and returns the resulting list of atoms.
(: zipWith (-> (-> $a $b $c) $d $e $f))
(= (zipWith $f $xs $ys)
   (if (== $xs ())                      ; We assume (arity $xs) == (arity $ys)
       ()
       (let* ((($xs-hd $xs-tl) (decons $xs))
              (($ys-hd $ys-tl) (decons $ys))
              ($head ($f $xs-hd $ys-hd))
              ($tail (zipWith $f $xs-tl $ys-tl)))
         (cons-atom $head $tail))))

;; Finds length of a tuple
(= (len $expr)
    (if (== $expr ())
        0
        (let $tail (cdr-atom $expr)
            (+ 1 (len $tail))
        )
    )
)

;; replaceByIndex replaces an atom at a specific index position with $val -- 0 indexed counting is implied
(: replaceByIndex (-> Expression Number $t Expression))
(= (replaceByIndex $expr $index $new)
    (if (== $expr ())
        $expr
        (let*
            (
                ($first (car-atom $expr))
                ($tail (cdr-atom $expr))
            )
            (if (== $index 0)
                (if (== $tail ())
                    ($new)
                    (cons-atom $new $tail)
                )
                (let $c (replaceByIndex $tail (- $index 1) $new)
                    (cons-atom $first $c)
                )))))

;; Select atom by index and returns 
(= (selectByIndex $expr $index)
    (if (== $expr ())
        (Error (Index out of range) ())
        (if (== $index 0)
            (car-atom $expr)
            (let $tail (cdr-atom $expr)
                (selectByIndex $tail (- $index 1))
            ))))

(= (getNTs $grammarSpace)
    (let $ntSet (collapse 
                    (let $rule (get-atoms $grammarSpace)
                        (car-atom $rule)
                    )
                )
        (collapse (unique (superpose $ntSet)))))


;; TODO: Use zipWith instead
;; compareElemets compares tuples element by element
(= (compareElements $first $second)
    (if (or (== $first ()) (== $second ()))
        ()
        (let*
            (
                ($f (car-atom $first))
                ($ft (cdr-atom $first))
                ($s (car-atom $second))
                ($st (cdr-atom $second))
                ($r  (== $f $s))
                ($c (compareElements $ft $st))
            )
                    (cons-atom $r $c)
                )))
;; Function to empty a space with contents.
(= (clearSpace $space)
   (collapse (let $content (get-atoms $space) (remove-atom $space $content))))

;; Function that merges two sorted lists while keeping them sorted.
(= (merge-sort () $right $cmp) $right)
(= (merge-sort $left () $cmp) $left)

(= (merge-sort $left $right $cmp)
     (let* (
            (($lh $lt) (decons-atom $left))
            (($rh $rt) (decons-atom $right))
            ($res1 (merge-sort $lt $right $cmp))
            ($res2 (merge-sort $left $rt $cmp))
            )
       (if ($cmp $lh $rh)
         (cons-atom $lh $res1)
         (cons-atom $rh $res2)
         )
       )
     )

(: splitAt (-> Number Expression (Atom Atom)))
(= (splitAt $n $list)
   (case ($n $list)
     (
       ((0 $list) (() $list))
       (($_ ()) (() ()))
       (($n $list)
          (let*
             (
               (($x $xs) (decons $list))
               (($left $right) (splitAt (- $n 1) $xs))
             )
             ((cons-atom $x $left) $right)
          )
       )
     )
   )
)

;; Merge sort function.
;; args:
;;   $list: list to be sorted
;;   $key: determines the order of the list. 
;;      Pass dec to sort in decreasing order
;;      Pass () otherwise.
(= (sort $list $key)
   (if (<= (len $list) 1)
       $list
       (let* (
               ($mid (floor-math (/ (len $list) 2)))
               (($left $right) (splitAt $mid $list))
               ($cmp (if (== dec $key) > <=))
             )
             (merge-sort (sort $left $key) (sort $right $key) $cmp)
       )
   )
)

(: repeat (-> Atom Number Atom))
(= (repeat $a $n)
   (if (== $n 0)
       ()
       (let $t (repeat $a (- $n 1)) (cons-atom $a $t))
   )
)

(: take (-> Number Atom Atom))
(= (take $n $a)
    (case ($n $a)
          (
            (($n ()) ())
            ((0 $a) ())
            (($n $a)
              (let*
                (
                  (($h $t) (decons $a))
                  ($r (take (- $n 1) $t)))
                (cons-atom $h $r))))))

(: drop (-> Number Atom Atom))
(= (drop $n $a)
    (case ($n $a)
      (
        (($n ()) ())
        ((0 $a) $a)
        (($n $a)
          (let*
            (
              (($h $t) (decons $a))
              ($r (drop (- $n 1) $t)))
            $r)))))

;;The below are list functions that maximizes utilities
(= (cadr-atom $list)
    (let $tail (cdr-atom $list) (car-atom $tail))
)

(= (caar-atom $list)
    (let $head (car-atom $list) (car-atom $head))
)

(= (cdar-atom $list)
    (let $head (car-atom $list) (cdr-atom $head))
)

(= (cddr-atom $list)
    (let $tail (cdr-atom $list) (cdr-atom $tail))
)


;; Function: swap
;; Description: Swaps the elements at the given indices in a list.
;; Parameters:
;;   - $list: The list in which elements will be swapped.
;;   - $first: The index of the first element.
;;   - $second: The index of the second element.
;; Returns:
;;   - List: A new list with the elements at $first and $second indices swapped.
(= (swap $list $first $second)
    (let*
        (
            ($first-item (index-atom $list $first))
            ($second-item (index-atom $list $second))
            ($replace-first-with-second (replaceByIndex $list $first $second-item))
            ($replace-second-with-first (replaceByIndex $replace-first-with-second $second $first-item))
        )
        $replace-second-with-first
    )
)



;; Function: getSmallestChildIndex
;; Description: Given a list and two indices, returns the index of the smaller value.
;;              If neither index exists in the list, returns an empty expression.
;; Parameters:
;;   - $list: The list to check.
;;   - $left: The first index.
;;   - $right: The second index.
;; Returns: Numeber if indexes exist, () if neither index exists
(= (getSmallestChildIndex $list $left $right)
    (let*
        (
            ($listLength (size-atom $list))
            ($left-item
                (if (>= $left $listLength)
                    ()
                    (index-atom $list $left)
                )
            )
            ($right-item
                (if (>= $right $listLength)
                    ()
                    (index-atom $list $right)
                )
            )
            ($smaller-child
                (if (== (get-type $left-item) Number)
                    (if (== (get-type $right-item) Number)
                        (if (> $left-item $right-item)
                            $right
                            $left
                        )
                        $left
                    )
                    (if (== (get-type $right-item) Number)
                        $right
                        ()
                    )
                )
            )
        )
        $smaller-child
    )
)


;; Function: minHeap
;; Description: Ensures that the node at the given index satisfies the min-heap property.
;;              If the node is greater than the smallest child node, it swaps them recursively
;;              until the node is smaller than its children.
;; Parameters:
;;   - $list: The list representing the heap.
;;   - $index: The index of the node to be adjusted.
;; Returns: the modified list maintaining the min-heap structure from that index upwards.
(= (minHeap $list $index)
    (let*
        (
            ($left (+ 1 (* 2 $index)))
            ($right (+ 2 (* 2 $index)))
            ($indexItem (index-atom $list $index))
            ($smallestChildIndex (getSmallestChildIndex $list $left $right))
            ($smallestChildItem
                (if (== (get-type $smallestChildIndex) Number)
                    (index-atom $list $smallestChildIndex)
                    ()
                )
            )
            ($smaller
                (if (== (get-type $smallestChildItem) Number)
                    (if (> $indexItem $smallestChildItem)
                        $smallestChildIndex
                        $index
                    )
                    $index
                )
            )
        )
        (
            if (== $smaller $index)
                $list
                (let*
                    (
                        ($newList (swap $list $index $smaller))
                    )
                    (minHeap $newList $smaller)
                )
        )
    )
)



;; Function: heapifyItems
;; Description: Converts a list into a min-heap by calling `minHeap` on each parent node,
;;              starting from the last parent node and moving up to the root.
;; Parameters:
;;   - $list: The list to be transformed into a min-heap.
;;   - $index: The index of the current node being heapified.
;; Returns:
;;   - The modified list where all elements satisfy the min-heap property.
(= (heapifyItems $list $index)
    (if (< $index 0)
        $list
        (let $newList (minHeap $list $index)
            (heapifyItems $newList (- $index 1))
        )
    )
)



;; Function: heapify
;; Description: Converts a list into a min-heap by calling `heapifyItems`,
;;              starting from the last parent node.
;; Parameters:
;;   - $list: The list to be transformed into a min-heap.
;; Returns:
;;   - The modified list where all elements satisfy the min-heap property.
(= (heapify $list)
    (let*
        (
            ($listLength (size-atom $list))
        )
        (heapifyItems $list (- (floor-math (/ $listLength 2)) 1))
    )
)



;; Function: parent
;; Description: Computes the parent index of a given node index in a binary heap.
;; Parameters:
;;   - $index: The index of the node whose parent index is to be determined.
;; Returns:
;;   - The parent index of the given node.
(= (parent $index) (floor-math (/ (- $index 1) 2)))



;; Function: isNodeLargerThanParent
;; Description: Checks if the value of a node at a given index is greater than or equal
;;              to the value of its parent node in a binary heap.
;; Parameters:
;;   - $list: The list representing the heap.
;;   - $index: The index of the node to compare with its parent.
;; Returns:
;;   - True if the node's value is greater than or equal to its parent's value,
;;     or if the node is the root. Otherwise, returns False.
(= (isNodeLargerThanParent ($list $index))
    (if (<= $index 0)
        True
        (let*
            (
                ($parent (parent $index))
                ($indexItem (index-atom $list $index))
                ($parentItem (index-atom $list $parent))
            )
            (>= $indexItem $parentItem)
        )
    )
)



;; Function: swapWithParent
;; Description: Swaps the node at a given index with its parent node and returns the swapped list
;;              along with the index of the parent node.
;; Parameters:
;;   - $list: The list representing the heap.
;;   - $index: The index of the node to be swapped with its parent.
;; Returns:
;;   - The swapped list and the parent index after the swap.
(= (swapWithParent ($list $index))
    (let*
        (
            ($parent (parent $index))
            ($swapped (swap $list $parent $index))
        )
        ($swapped $parent)
    )
)



;; Function: heapPush
;; Description: Adds an item to the end of the heap and recursively swaps the new node 
;;              with its parent until the node is larger than its parent, ensuring the heap property.
;; Parameters:
;;   - $list: The list representing the heap.
;;   - $item: The item to be added to the heap.
;; Returns:
;;   - The modified list where the new item has been added and the heap property is maintained.
(= (heapPush $list $item)
    (let*
        (
            ($appendedList (union-atom $list ($item)))
            ($lastIndex (- (size-atom $appendedList) 1))
            (($pushedList $index) (until isNodeLargerThanParent swapWithParent ($appendedList $lastIndex)))
        )
        $pushedList
    )
)



;; Function: heapPop
;; Description: Removes and returns the first item from the heap.
;;              It pops the last item, places it at the 0th index,
;;              and then applies the `minHeap` operation to restore the heap property.
;; Parameters:
;;   - $list: The list representing the heap.
;; Returns:
;;   - The first item removed from the heap and the modified list after the heap property is restored.
(= (heapPop $list)
    (let*
        (
            (($head $rest) (decons-atom $list))
            ($lastIndex (- (size-atom $rest) 1))
            (($splitList $lastItem) (splitAt $lastIndex $rest))
            ($newList (cons-atom (superpose $lastItem) $splitList)) ; superpose to change expression to symbol, (41) -> 41
        )
        (let*
            (
                ($heap (minHeap $newList 0))
            )
            ($head $heap)
        )
    )
)
