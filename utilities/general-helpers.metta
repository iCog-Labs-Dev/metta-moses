;; Helper functions that are going to be useful for writing any metta code
!(bind! perf_counter (new-state (py-call "time.perf_counter")))
!(py-call (random.seed 0))

(= (round $x)(py-call ("round" $x)))    ;; python method calling is py-call unlike py-atom in mettalog 

;; Measures the average execution time of a given expression over multiple runs.
;; Parameters:
;;   $expr: The expression to be evaluated and profiled.
;;   $n: The number of times to execute $expr for timing.
;; Returns:
;;   The average time (rounded to 3 decimal places) taken to evaluate $expr, computed over $n

; main entry point — user only calls this
(= (profile $expr $n)
  (let*
    (
      ($times (profile-helper $expr $n ()))
      (() (println! (times: $times)))
      ($avg (average $times))
      ($avgR (round $avg 3))
    )
    $avgR
  ))
(= (profilen $expr)
  (let*
    (
      ($start_time (perf_counter))
      ($result (eval $expr))
      ($end_time (perf_counter))
      ($elapsed_time (- $end_time $start_time))
    )
    (cons-atom $elapsed_time $result)
  ))

; internal recursive accumulation
(= (profile-helper $expr $n $acc)
  (if (== $n 0)
      $acc
      (let*
          (
            ($pair (profilen $expr))
            ($time (car-atom $pair))
            ($new-acc (cons-atom $time $acc))
            ($next (profile-helper $expr (- $n 1) $new-acc))
          )
          $next
      )))



(= (average $lst)
    (let*
        (
            ($total (sum $lst))
            ($count (size-atom $lst))
        )
        (if (== $count 0)
            0
            (/ $total $count)
        )
    )
)


;; (: != (-> Atom Atom Bool)) Fix Type not working in petta
(= (~= $a $b) (not (== $a $b)))
;Function to cocatinate two tuples (A B) (C D) ==> (A B C D)
;; (: concatTuple (-> Expression Expression Expression))

(= (concatTuple $x $y) (union-atom $x $y)) ;; This should work when run after activating the virtual env

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
                ))
    False )))

; a helper function to the isConsistentExp function.
; a function which checks if an element is member of a tuple.
;; (: isMember (-> $a $aa Bool)) ;; this function can be replace by its exact same builtin petta function is-member
;; (= (isMember $x $list)
;;     (not (== (collapse (intersection (superpose ($x)) (superpose $list))) ()))
;; )

; This function assumes it receives a set1 and set2 expression as parameters.
; It then removes similar elements found in set2 that already exist in set1.
; The function uses isMember from general helpers functions.

; (: setDifference (-> Expression Expression Expression))
(= (setDifference $set1 $set2) 
    (if (== $set1 ()) () ; Base case: return empty set when $set1 is empty
        (let* (
            ($head (car-atom $set1))  ; Extract the head of set1
            ($tail (cdr-atom $set1))  ; Extract the tail of set1
            ($newtail (setDifference $tail $set2))  ; Recursively process the tail
        )
            ; Check if the $head is in set2, if so, skip it

            (if (is-member $head $set2)
                $newtail 
                ; Otherwise, add the head to the new tail, avoiding unnecessary parentheses
                (if (== (get-metatype $newtail) Expression) (cons-atom $head $newtail) $head)  ; Avoid wrapping the head if it's already properly structured
            ))))

;; A helper function for the findAndReplace function.
;; It handles the replacement of a single atom.
(= (replace $old $new $current) (if (== $old $current) $new $current))

;; A function to replace a specific atom
;;    with a new one from a list of atoms.
;; INFO: This function needs to change so that it can preserve the
;;        operator's position when MeTTa version is upgraded.
(= (findAndReplace $old $new $list) ;; FIX: No longer working on version 0.2.3
    ; (let*
    ;   (
    ;     ($log (println! ""))
    ;     ($log' (println! (==> === Inside findAndReplace === <==)))
    ;     ($log'' (println! (Parameters ==> Old: $old New: $new List: $list)))
    ;     ($log''' (println! (Result ==> (collapse (replace $old $new (superpose $list))))))
    ;     ($log'''' (println! ""))
    ;   )
      (if (== () (subtraction-atom $old $list)) 
        $new
      (collapse (eval (replace $old $new (superpose $list)))))
    ; )
)

;; A function that behaves like a do while loop.
;; It executes the functions in the given list and returns the last result.
;; (: until (-> (-> $a Bool) (-> $a $a) $a $a))
(= (until $predicate $function $x) 
    (let* ( 
        ; (() (println! (Inside until with function: $function ...)))
        ($isTrue (eval ($predicate $x)))
        ; (() (println! (Predicate result: $isTrue)))
        ; ($x' ($function $x))
        ($x' (if (== $isTrue true) ("Predicate True Skipping Function Application") ($function $x)))
        ; (() (println! (Function result: $x')))
    )
    (if (== $isTrue true)
        $x
        (eval (until $predicate $function $x')))
    ))
;; A foldleft function like the implementation in Haskell.
;; It takes a binary function that expects two atoms and
;;    apply it recursively on a nested atom.
; (: foldl (-> (-> $a $b $d) $b $c $d))
(= (foldl-l $f $acc $tuple) ;;this renaming is naming conflict with static procedure foldl with petta compiler internally in apply.pl
   (if (== $tuple ())
       $acc
       (let $next (car-atom $tuple) (foldl-l $f ($f $next $acc) (cdr-atom $tuple)))
   )
)

;; Fold a tuple from right to left
;; (: foldr (-> (-> $a $b $b) $b $c $d))
(= (foldr $f $i $xs)
   (if (== $xs ())
       $i
       (let* (($h (car-atom $xs))
              ($t (cdr-atom $xs))
              ($ft (foldr $f $i $t)))
         ($f $h $ft))))

;; Apply a given function to every element of a tuple
;; (: map (-> (-> $a $b) $c $d))
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
; (:wrapper (-> (-> $a Bool) $aa $aa))
(= (wrapper $predicate $x) (if (let $bool ($predicate $x) $bool) $x ()))

;; Filter function given a predicate ;; FIX: No longer working on version 0.2.3
; (: filter (-> (-> $a Bool) $a $a))
(= (filter $predicate $list)
   (wrapper $predicate (superpose $list)))

;; INFO: Uncommnet the following two functions when using MeTTaLog.
;; (:wrapperB (-> (-> $a $b Bool) $a $b $b))
(= (wrapperB $predicate $x $y) (if ($predicate $x $y) $y (empty)))

(: filterB (-> (-> $a $b Bool) $a $bb $bb))
(= (filterB $predicate $x $list)
   (wrapperB $predicate $x (superpose $list)))

;; A function to remove all elements found in $common from a $tuple
(= (removeElement $common $tuple)
   (collapse  (subtraction (superpose $tuple) (superpose $common))))

; ;; A function that returns True if any of the input atoms are True and False otherwise
; ;; Example: input ==> (True True False), output ==> True
; ;;          input ==> (False False False), output ==> False
; ;;          input ==> (False True False), output ==> True
; (: any (-> Atom Bool))
(= (any $bools) (is-member True $bools))

;; Fix curry is not working in petta 
;; ;; A trick to define `curry` in MeTTa without `lambda`
;; (: curry (-> (-> $a $b $c) (-> $a (-> $b $c))))
(= (curry $f $x $y)($f $x $y))
;;
;; ;; ;; A trick to define `curry2` in MeTTa without `lambda`
;; ;; (: curry2 (-> (-> $a $b $c $d) (-> $a (-> $b $c $d))))
(= (curry2 $f $x $y $z)($f $x $y $z))

;;
; ;; Add numbers in an atom list
(= (sum $list) (foldl-atom $list 0 $acc $x (+ $acc $x)))

;; Function to count atom occrence in a list of atoms.
(= (count $t $list)(let $r (filter-atom $list $x (== $x $t)) (length $r)))

;; A function to check if a given atom is symbol.
; (: isSymbol (-> Expression Bool))
(= (isSymbol $expr) (== (get-metatype $expr) Symbol))

;; A function to check if a given atom is expression.
; (: isExpression (-> Atom Bool))
(= (isExpression $expr) (== (get-metatype $expr) Expression))

;; A function to check if a given atom is unit or empty tuple.
;; (: isUnit (-> Atom Bool))
(= (isUnit $expr) (== $expr ()))

;; (: isEven (-> Number Bool))
(= (isEven $x) (== (% $x 2) 0))

(: isOdd (-> Number Bool))
(= (isOdd $x) (not (isEven $x)))

;; A function to check if a given atom is an expression 
;;   with has one atom in it.
; (: hasOneAtom (-> Atom Bool)) ;; FIX: No longer working on version 0.2.3
(= (hasOneAtom $expr) (if (and (== (get-metatype $expr) Expression) (not (isUnit $expr))) (== (cdr-atom $expr) ()) False))

;; Function to replace a given atom from a space ;; FIX: No longer working on version 0.2.3
;; (: update-atom (-> Grounded Atom Atom (->)))
(= (update-atom $space $oatom $natom) (let $_ (remove-atom $space $oatom) (add-atom $space $natom)))

;; Function to replace a given atom from a space. ;; FIX: No longer working on version 0.2.3
;; (: appendAtom (-> Atom Atom Atom))
(= (appendAtom $a $atom) (foldr cons-atom ($a) $atom))

; ;; Return the maximum of two numbers.; this may raise a conflict with petta's builtin max function
; (= (max $x $y) (if (< $x $y) $y $x))

;; A function to return a tuple of numbers from natural to a given number.
;; $x is the upperbound
;; $acc is the lowerbound wrapped with as a tuple.
;;    Example: (gen 5 (0)) => (5 4 3 2 1 0) ;; FIX: No longer working on version 0.2.3
(= (gen $x $acc)
   (if (== (car-atom $acc) $x)
       $acc
       (let $lastInserted (car-atom $acc) (gen $x (cons-atom (+ 1 $lastInserted) $acc)))))

; ; ;; A function to return head and tail of an atom in a tuple. ; this also raise error for petta also has builtin decons function
; (= (decons $atom)
;    (if (not (or (isSymbol $atom) (isUnit $atom)))
;        ((car-atom $atom) (cdr-atom $atom))
;        (Error Unit Or Symbol cannot be deconstructed)))

;; Function to create a tuple of tuples given two equal length list of atoms. ;; FIX: No longer working on version 0.2.3
(= (zip $a $b)
   (if (or (hasOneAtom $a) (hasOneAtom $b))
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
;; (: zipWith (-> (-> $a $b $c) $d $e $f))
(= (zipWith $f $xs $ys)
   (if (== $xs ())                      ; We assume (arity $xs) == (arity $ys)
       ()
       (let* ((($xs-hd $xs-tl) (decons $xs))
              (($ys-hd $ys-tl) (decons $ys))
              ($head ($f $xs-hd $ys-hd))
              ($tail (zipWith $f $xs-tl $ys-tl)))
         (cons-atom $head $tail))))

;; Finds length of a tuple ;; FIX: No longer working on version 0.2.3
(= (len $expr)
    (if (== $expr ()) ;; FIX: return Error if symbol
        0
        (let $tail (cdr-atom $expr)
            (+ 1 (len $tail))
        )))

;; A function to replace an atom at a specific index position with $val -- 0 indexed counting is implied
;; (: replaceByIndex (-> Expression Number $t Expression))
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
 
;; XXX -- Reimplementation of the above function as indexAtom
(: indexAtom (-> Expression Number Atom))
(= (indexAtom $expr $index)
    (function 
        (eval (if-equal $expr ()
            (return (Error description: IndexOutOfRange))
            (eval (if-decons-expr-custom $expr $h $t
                (eval (if-equal $index 0
                    (return $h)
                    (return (indexAtom $t (- $index 1)))))
                (return Empty)))))))   
            
;; removeAtom -- removes a single atom (the first occurrunce) from a tuple                                
;; (: removeAtom (-> Atom Expression Expression))    

(= (removeAtom $atom $expr)
        (eval (if-decons-expr-custom $expr $head $tail
            (eval (if-equal $head $atom
                    $tail  ; Stop at first match
                (chain (removeAtom $atom $tail) $rest
                    (cons-atom $head $rest))))
        ())))
;; subtractionAtom -- replicates behaviour of MeTTa's subtraction-atom in mettalog
(: subtractionAtom (-> Expression Expression Expression))
(= (subtractionAtom $expr $b)
    (if-decons-expr-custom $b $head $tail
        (chain (removeAtom $head $expr) $newexpr
            (subtractionAtom $newexpr $tail))
        $expr))

;; TODO: Use zipWith instead
;; A function that compares tuples element by element.
(= (compareElements $first $second)
   (zipWith == $first $second)
)

;; Function to empty a space with contents.
(= (clearSpace $space)
   (collapse (let $content (get-atoms $space) (remove-atom $space $content))))
   
;; Function that merges two sorted lists while keeping them sorted.
(= (merge $xs $ys) (merge $xs $ys <=))
(= (merge $xs $ys $key)
    (case ($xs $ys)
          (
            ((() $ys) $ys)
            (($xs ()) $xs)
            (($xs $ys)
              (let*
                  (
                    (($x $xss) (decons $xs))
                    (($y $yss) (decons $ys))
                  )
                  (if ($key $x $y)
                      (let $t (merge $xss $ys $key) (cons-atom $x $t))
                      (let $t (merge $xs $yss $key) (cons-atom $y $t))))))))

;; A function to split a list in to two at an index so that everything
;;    until that index without including that index as first tuple and 
;;    the rest as the second.
;; (: splitAt (-> Number Expression (Atom Atom)))
(= (splitAt $n $list)
   (case ($n $list)
     (
       ((0 $list) (() $list))
       (($_ ()) (() ()))
       (($n $list)
          (let*
             (
               ;; (() (println! (Splitting $list at: $n)))
               (($x $xs) (decons $list))
               (($left $right) (splitAt (- $n 1) $xs))
               ;; (() (println! (From splitAt Left: $left Right: $right)))
             )
             ((cons-atom $x $left) $right))))))

;; Merge sort function. Takes length to gain 
;;  performance by avoiding recomputation of index.
(= (sortNestedTuple $list reverse) (sort $list (len $list) >=))

(= (sort $list $len) (sort $list $len <=)) ;; FIX: No longer working on version 0.2.3
(= (sort $list $len $key)
   (if (or (isUnit $list) (hasOneAtom $list))
       $list
       (let* (
                ;; (() (println! (Sorting $list len: $len)))
                ($halfL ((py-atom math.floor) (/ $len 2)))
                (($left $right) (splitAt $halfL $list))
                ;; (() (println! (From sort Left: $left Right: $right)))
             )
             (merge (sort $left $halfL $key) (sort $right (- $len $halfL) $key) $key))))

;; function to partially sort the smallest $n Atoms from an expression
; (: selectionSort (-> Expression Number Expression))
(= (selectionSort $list $n) (selectionSort $list $n <))
; (: selectionSort (-> Expression Number (-> $a $a Bool) Expression))
(= (selectionSort $list $n $op)
    (if (or (== $n 0) (== $list ()))
        $list
     (let* (
        ($initial (car-atom $list))
        ($cur (selector $list $initial $op))
        ($newList (subtraction-atom $list ($cur))) ;since the subtractionAtom (the custom one) isn't working now but this subtraction-atom does same thing.
        ($rest (selectionSort $newList (- $n 1) $op))
    )
    (cons-atom $cur $rest)
    )))

;; Helper function that compare two Atoms based on $op and return the one
;;  (: comparator (-> $a $a (-> $a $a Bool) $a))
(= (comparator $x $y $op) (if ($op $x $y) $x $y))

;; Helper function that select one atom from the $expr based on the comparation function $op
; (: selector (-> Expression (-> $a $a Bool) $a))
(= (selector $expr $op) (selector $expr (car-atom $expr) $op) )
; (: selector (-> Expression $a (-> $a $a Bool) $a))
;;for the petta foldl-atom doesn't works for nested list(lists or expression inside list) a custom method re-implemented for the selector helper.
(= (selector $expr $i $op)
(if (== $expr ())
     $i
     (let*  (
             ($head (car-atom $expr))
             ($tail (cdr-atom $expr))
              ($result (comparator $head $i $op))
            )
          (selector $tail $result $op))
)
)

;; A function to take an atom and repeat it n times.
;; (: repeat (-> Atom Number Atom))
(= (repeat $a $n)
   (if (== $n 0)
       ()
       (let $t (repeat $a (- $n 1)) (cons-atom $a $t))
   )
)

;; (: take (-> Number Atom Atom))
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

;; A function to remove the frist n elements of a tuple 
;;   and returns the rest.
;; (: drop (-> Number Atom Atom))
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

;; (= (length $expr)
;;     (sum (collapse (let $a (superpose $expr) 1)))
;; )
;; isLiteral -- determines if the given atom is a literal or not

(= (isLiteral $a)
    (if (or (== (get-metatype $a) Grounded) (== (get-metatype $a) Symbol))
        True
        (if (== (car-atom $a) NOT)
            True
            False )))

;; minOfTuple -- minimum of tuple of numeric expressions

(= (minOfTuple $expr)
    (let ($f $t) (decons $expr)
        (if (== $t ())
            $f
            (min $f (minOfTuple $t))
        )))
;; unNest -- extracts elements from nested expressions 

(= (unNest $exp)
    (let $el (superpose $exp)
        (if (isLiteral $el)
            $el
            (unNest $el))))
; flatten-list -- returns one tuple from a nested tuple of tuple of tuples ...
; flatten renamed for fixing naming conflict in translation time from petta to prolog. flatten-list
 (= (flatten-list $exp) (collapse (unNest $exp))) 


;; (= (min $x $y) (if (<= $x $y) $x $y))

; ;; maxOfTuple -- finds maximum of tuple of numbers

; ; (= (maxOfTuple $expr)
; ;     (let*
; ;         (
; ;             ($f (car-atom $expr))
; ;             ($t (cdr-atom $expr)))

; ;         (if (== $t ())
; ;             $f
; ;             (max $f (maxOfTuple $t)))))


;; Add numbers in an atom list
; (= (sum $list) (foldr + 0 $list))
; (= (sum $list)
;     (if (== $list ())
;; ;         0
;         (let*
;             (
;                 ($f (car-atom $list))
;                 ($t (cdr-atom $list))
;             )
;             (if (== $t ())
;                 $f
;                 (+ $f (sum $t)) ))))

; (= (getmaxWithKey $tuple)
;     (let $max 
;         (collapse 
;             (let*
;                 (
;                     ($t (superpose $tuple))
;                     ($maxKey (let $keys (collapse (let $el (superpose $tuple) (car-atom $el))) (maxOfTuple $keys)))
;                     ; (() (println! (maxxx $maxKey)))
;                 ) 
;                 (unify $t ($maxKey $genId $iId $i) ($maxKey $genId $iId $i) (empty))))
;         (car-atom $max)))

;; map` -- a modified map functinality with, i.e., a map that takes a function which has two inputs

;; (: map` (-> (-> $a $a $b) $a $c $d))
(= (map` $f $x $xs)
   (if (== $xs ())
       ()
       (let* (($h (car-atom $xs))
              ($t (cdr-atom $xs))
              ($fh ($f $h $x))
              ($ft (map` $f $x $t)))
         (cons-atom $fh $ft))))

;; notNt -- check if a symbol is not a member of the non-terminal set

(= (notMember $symbol $expr) (not (is-member $symbol $expr)))

;; isValidExp -- to check if the boolean expression produced by genPhen is a valid bolean expression
;;          $exp -- an expression which is being checked for validity
;;          $parent -- an expression against which the check is being made -- set of non-terminals in this case.

(= (isValidExp $exp $parent)
    (if (== (get-metatype $exp) Symbol)
        (notMember $exp $parent)
        (let*
            (
                ($f (flatten-list $exp))
                ($t (map` notMember $parent $f))
            ) 
            (all $t)
        )))
;; This function adds list to space
(= (addListToSpace $space $list)
    (add-reduct $space $list)
)

;; a function that checks that all of the expressions are true.
; (: all (-> Expression Bool))
(= (all $expressions) (if (is-member False $expressions) False True))


;; Name:                        ===
;; Description:                 A helper function to evaluate equality of two expressions ignoring ordering of litral children.
;;                              The grounded equality operator, ==, will return `False` when comparing (AND A B) and (AND B A)
;;                              === returns `True`.
;;                              Used when looking for the POA in the parent's list of children.
(= (=== $x $y)
   (if (and (== (get-metatype $x) Symbol) (== (get-metatype $y) Symbol))
       (== $x $y)
       (let*
            (
                ($a (collapse (subtraction (superpose $x) (superpose $y))))
                ($b (collapse (subtraction (superpose $y) (superpose $x))))
            )
            (== (union-atom $a $b) ())
       )))

;; Number compartor
;; (: compareNum (-> Number Number Atom))
(= (compareNum $num1 $num2)
    (case ((> $num1 $num2) (== $num1 $num2))
        (((True $t) G)
         ((False True) E)
         ((False False) L))))

;; an equal to or grearter than comparator that is resopnsible for deconstructing numerical values from the type constructor and compare them 
;; ($ctor $x) ($ctor $y) -- (constructor value) pair                
;; (: >>= (-> $a $a Bool))
(= (>>= ($ctor $x) ($ctor $y))(>= $x $y));; List.Sum for any (List $a) $a of (typeConstructor Number) type
;;
;; the following is defined in list-methods.metta as well
; (: List.sum (-> (-> $a $a $a) (List $a) $a))
; (= (List.sum $adder Nil) Nil)
; (= (List.sum $adder (Cons $x $xs))
;     (if (== $xs Nil)
;         $x
;         (let $c (List.sum $adder $xs)
;             ($adder $x $c))))

; ; ;; overloading the above function to work with list of numbers
; ; (: List.sum (-> (List $a) $a))
; (= (List.sum $list) (List.sum + $list))

;; A function to take any two types which have the same constructor and add them.
;;   params: ($ctor $a): The first argument with a constructor $ctor
;;           ($ctor $b): The second argument with the same constructor as the first
;;   returns: Sum of the types if they both contain numbers
;;            An error if they can't be added together
;; (: add (-> $a $a $a))
(= (add ($ctor $a) ($ctor $b))
     (if (== (get-type $a) Number)
            ($ctor (+ $a $b))
            (Error ($a or $b) "One of the argument is not a number")))

;; wrapping the built-in ininf-math with custom function because the return type is not bool, it is number
;; using the type-cast function 
;; obsolete in mettalong for now
; (: isInf (-> Number Bool))
; (= (isInf $x) (type-cast (isinf-math $x) Bool &self))

;; A trick to define composition function.
;; Takes a function and returns another function
;; applying the two functions in sequence.
;; (: . (-> (-> $b $c) (-> $a $b) (-> $a $c)))
;; (= ((. $g $f) $x) ($g ($f $x)));in petta . is internally used by Prolog for building lists and dicts and what it does is the same for compose function.

;; Convert an expression to a list   e.g (A B C) -> (Cons A (Cons B (Cons C Nil)))
(= (exprToList $expr)
    (if (== $expr ())
        Nil
        (let ($head $tail) (decons-atom $expr)  (Cons $head (exprToList $tail)))
    )
)

;; From a tuple (Pair) return the first element
; (: first (-> ($a $b) $a))
(= (first ($a $b)) $a)

;; From a tuple (Pair) return the second element
; (: second (-> ($a $b) $b))
(= (second ($a $b)) $b)

;; Converts a tuple of pairs into ordered multimap
;; Ex: ((k1 v1) (k2 v2)) -> (ConsMMap (k1 v1) (ConsMMap (k2 v2) NilMMap))
;; (: expToMMap (-> Expression (MultiMap ($k $v)) (-> $k $k Bool) (MultiMap ($k $v))))
(= (expToMMap () $map $compFunc) NilMMap)
(= (expToMMap $tuple $map $compFunc)
(let*
(
    (($head $tail) (decons-atom $tuple))
    ($updatedMap (eval (MultiMap.insert $head $map $compFunc)))

)
(if (== $tail ()) $updatedMap (eval (expToMMap $tail $updatedMap $compFunc)))))

;; A trick function to make chain reduce when using union-atom
;; This is causing infinite loop in some cases. use the direct union-atom instead.
; (: (-> unionAtom (-> Expression Expression Expression)))
; (= (unionAtom $x $y) (union-atom $x $y))
; (= (unionAtom $a $b)
;     (if-decons-expr-custom $a $head $tail
;         ; (trace! ("Done With chain") 
;         (chain (unionAtom $tail $b) $rest
;             (cons-atom $head $rest))
;             ; )
;         $b)
; )

;; helper function to generate list of numbers ranging from 0 to n
;; (: genList (-> Number Expression))
(= (genList $u) (genList 0 $u))
;;
; (: genList (-> Number Number Expression))
(= (genList $l $u)
    (if (< $u $l)
        ()
        (let $res (genList $l (- $u 1))
            (cons-atom $u $res) )))

;; swap AND , OR 
; (: swapAndOr (-> Atom Atom))
(= (swapAndOr $op)
    (case $op
        ((AND OR)
         (OR AND)
         ($else $op))
    )
)

; (: compose (-> (-> $b $c) (-> $a $b) (-> $a $c)))
; The previous `compose` definition  extra parentheses, which caused parsing issues during PeTTa-to-Prolog translation.
; After removing them, the function now works smoothly and remains compatible with previous calling styles.
(= (compose $g $f $x)($g ($f $x)))

;; approximate equality -- takes the relative magnitude of the numbers into consideration

!(bind! EPSILON (new-state (pow-math 10 -6))) ;in petta to bind some constant like this we need to do it by new-state function and  to retrieve get-state function
; (: isApproxEq (-> Number Number Bool))
(= (isApproxEq $x $y)
    (let $diff (abs-math (- $x $y))
        (if (< $diff (get-state EPSILON))
            True
            (let $amp (abs-math (+ $x $y))
                (<= $diff (* (get-state EPSILON) $amp))))))
;; A function to concatenate two expressions.
(= (concatT $expr1 $expr2)
    (if (== $expr1 ())
        $expr2
        (let*
            (
            ($head (car-atom $expr1))
            ($tail (concatT (cdr-atom $expr1) $expr2))
            )
            (cons-atom $head $tail)
        )
        

    )
)

;; isnan -- to check if a value is NaN
;; it happens that the NaN representation in mettalog is the weird 1.5NaN
;; you will see this when binig "Not a Number" from pythons "float('nan')" 1.5NaN is what it returns
;; needed because using using the direct python binding appears to cause issue with git workflow
;; (: isnan (-> $a Bool))
(= (isnan $x) (== $x 1.5NaN))

;; isInf -- check if a number if Inf
;; the same applies to this weid looking 1.0Inf thing - it is what you get when you bind (py-atom "float ('inf')") in mettalog and the followingn function works 
;; (: isInf (-> $a Bool))
(= (isInf $x) (== $x 1.0Inf))

;; int -- replicates pythons int functionality -- convert floating point numbers into integer
;; uses -- metta's floor-math function
;; (: int (-> Number Number))
(= (int $x) (if (>= $x 0) (floor-math $x) (+ 1 (floor-math $x))))

!(bind! EXP (new-state 2.71828))

; ;; random float  -- fake rnd number [0 1]
!(bind! maxInt (new-state (pow-math 2 64))) ;; pseudo max integer not really the max integer that can be represented 
;; the idea is to divide a random int taken from 0 upto this number by this number
;; (: randomFloat (-> Number))
(= (randomFloat)(py-call ("random.random")))
!(bind! rnd (py-atom random))


;; ============================================================
;; Apply Function — restricted to value comparisons only
;; ============================================================
;;
;; Guidance for team:
;; - Use apply strictly for value comparisons that require domain semantics
;;   (e.g., Cscore-aware ordering/equality).
;; - DO NOT use apply for collection operations (length, contains, append, remove, etc.).
;;   Use the unified coll.* API instead to avoid non-deterministic matches.
;;
;; Supported usage examples:
;;   (apply >= cscore1 cscore2)
;;   (apply < cscore1 cscore2)
;;   (apply == cscore1 cscore2)
;;
;; Fix apply type is not working in PeTTa 
;; (: apply (-> (-> $a $b $c) $d $e))

;; ------------------------------------------------------------
;; Generic projection and comparators to support reusable apply (comparisons only)
;; ------------------------------------------------------------

;; key: project a value into a comparable key
;; Deterministic single-clause definition to avoid multiple matches.
;; - Cscore -> KPair(penScore, -complexity) with NaN mapped to low sentinel
;; - ScoredInstance/Exemplar variants -> delegate to inner Cscore
;; - Default -> KScalar(x) (works for Number and other simple types)
; (: key-of (-> $a $k)) ;; NOTE: Renamed from 'key' to 'key-of' for PeTTa compatibility. builtin function naming conflict with internal compilation in prolog
(= (key-of $x)
   (case $x
     (
       ;; 5-field Cscore (scoring/cscore.metta)
       ((mkCscore $scor $cpxy $cpxyPen $uniPen $penScore)
        (let $p (if (isnan-math $penScore) (* -1 (pow-math 10 308)) $penScore)
             (KPair $p (* -1 $cpxy))))
       ((mkSInst (mkPair $inst $score))
         (key-of $score))
       ((mkExemplar $tree $demeId $cscore $bscr)
         (key-of $cscore))
       ($else (KScalar $x))
     )))

;; Compare in apply by shape; no collection support here

;; ============================================================
;; No collection operations via apply — use coll.* instead

;; ============================================================
;; Basic Type Operations (Direct Application)
;; ============================================================

;; Generic comparison via key-projection and comparators
(= (apply >= $x $y)
   (case ((key-of $x) (key-of $y))
     (
       (((KPair $a1 $b1) (KPair $a2 $b2)) (or (> $a1 $a2) (and (== $a1 $a2) (>= $b1 $b2))))
       (((KScalar $kx) (KScalar $ky)) (>= $kx $ky))
     )))

(= (apply < $x $y)
   (case ((key-of $x) (key-of $y))
     (
       (((KPair $a1 $b1) (KPair $a2 $b2)) (or (< $a1 $a2) (and (== $a1 $a2) (< $b1 $b2))))
       (((KScalar $kx) (KScalar $ky)) (< $kx $ky))
     )))

(= (apply == $x $y)
   (case ((key-of $x) (key-of $y))
     (
       (((KPair $a1 $b1) (KPair $a2 $b2)) (and (isApproxEq $a1 $a2) (isApproxEq $b1 $b2)))
       (((KScalar $kx) (KScalar $ky)) (== $kx $ky))
     )))

;; ============================================================
;; Unified collection API (no overloading, explicit dispatch)
;; ============================================================

;;
;; coll.length — length of supported collections and wrappers
;;
(: coll.length (-> $a Number))

;; Added `eval` to ensure internal functions from other files are properly resolved during parsing.
;; Without it, PeTTa only executes functions defined in the current file and skips external ones.

;; List ADT — constructor-specific to avoid ambiguous matches
(= (coll.length Nil) 0)
(= (coll.length (Cons $h $t)) (eval (List.length (Cons $h $t))))

;; Map — constructor-specific
(= (coll.length NilMap) 0)
(= (coll.length (ConsMap $pair $tail)) (eval (Map.length (ConsMap $pair $tail))))

;; MultiMap — constructor-specific
(= (coll.length NilMMap) 0)
(= (coll.length (ConsMMap $pair $tail)) (eval (MultiMap.length (ConsMMap $pair $tail))))

;; Ordered Set — constructor-specific
(= (coll.length NilOS) 0)
(= (coll.length (ConsOS $x $xs)) (eval (OS.length (ConsOS $x $xs))))

;; Ordered Multiset — constructor-specific
(= (coll.length NilOMS) 0)
(= (coll.length (ConsOMS $x $xs)) (eval (OMS.length (ConsOMS $x $xs))))

;; Wrappers -> delegate to inner lists
(= (coll.length (mkInst $list)) (coll.length $list))
(= (coll.length (mkSInstSet $list)) (coll.length $list))
(= (coll.length (mkBScore $list)) (coll.length $list))
(= (coll.length (mkDeme $rep (mkSInstSet $instList) $demeId)) (coll.length $instList))

;;
;; coll.append — append/insert one element into supported collections
;;
; (: coll.append (-> $coll $el $coll))

;; List ADT (append to tail)
(= (coll.append Nil $el) (Cons $el Nil))
(= (coll.append (Cons $h $t) $el) (Cons $h (coll.append $t $el)))

;; Instance — append Number to underlying list
(= (coll.append (mkInst $list) $el)
   (if (== (get-type $el) Number)
       (mkInst (coll.append $list $el))
       (Error $el "Instance.append expects Number")))

;; InstanceSet — append ScoredInstance to underlying list
(= (coll.append (mkSInstSet $list) $el)
   (mkSInstSet (coll.append $list $el)))

;; BehavioralScore — append Number
(= (coll.append (mkBScore $list) $el)
   (if (== (get-type $el) Number)
       (mkBScore (coll.append $list $el))
       (Error $el "BScore.append expects Number")))

;; Map — insert pair ($k $v) (constructor-specific)
(= (coll.append NilMap ($k $v)) (eval (Map.insert ($k $v) NilMap)))
(= (coll.append (ConsMap $pair $tail) ($k $v)) (eval (Map.insert ($k $v) (ConsMap $pair $tail))))

;; MultiMap — insert pair ($k $v) (constructor-specific)
;; Added `eval` to ensure internal functions from other files are properly resolved during parsing.
;; Without it, PeTTa only executes functions defined in the current file and skips external ones.
(= (coll.append NilMMap ($k $v)) (eval (MultiMap.insert ($k $v) NilMMap)))
(= (coll.append (ConsMMap $pair $tail) ($k $v)) (eval (MultiMap.insert ($k $v) (ConsMMap $pair $tail))))

;; Ordered Multiset — insert element
(= (coll.append NilOMS $el) (eval (OMS.insert $el NilOMS)))
(= (coll.append (ConsOMS $x $xs) $el) (eval (OMS.insert $el (ConsOMS $x $xs))))

;; Ordered Set — requires comparator; cannot infer here
(= (coll.append NilOS $el) (Error (NilOS $el) "Use OS.insert with comparator"))
(= (coll.append (ConsOS $x $xs) $el) (Error ((ConsOS $x $xs) $el) "Use OS.insert with comparator"))

;; Deme — append ScoredInstance to its InstanceSet
(= (coll.append (mkDeme $rep (mkSInstSet $list) $demeId) $el)
   (mkDeme $rep (mkSInstSet (coll.append $list $el)) $demeId))

;; coll.insert — alias to coll.append
(: coll.insert (-> $coll $el $coll))
(= (coll.insert $c $el) (coll.append $c $el))

;;
;; coll.remove — remove one occurrence (by equality) or by key where applicable
;;
(: coll.remove (-> $coll $el $coll))

;; List ADT — remove first occurrence
(= (coll.remove Nil $el) Nil)
(= (coll.remove (Cons $h $t) $el)
   (if (== $h $el) $t (Cons $h (coll.remove $t $el))))

;; Instance — remove first occurrence of Number
(= (coll.remove (mkInst $list) $el)
   (if (== (get-type $el) Number)
       (mkInst (coll.remove $list $el))
       (Error $el "Instance.remove expects Number")))

;; InstanceSet — remove first occurrence of element
(= (coll.remove (mkSInstSet $list) $el)
   (mkSInstSet (coll.remove $list $el)))

;; BehavioralScore — remove first occurrence of Number
(= (coll.remove (mkBScore $list) $el)
   (if (== (get-type $el) Number)
       (mkBScore (coll.remove $list $el))
       (Error $el "BScore.remove expects Number")))

;; Map — remove by key; if pair given, use its key (constructor-specific)
;; Added `eval` to ensure internal functions from other files are properly resolved during parsing.
;; Without it, PeTTa only executes functions defined in the current file and skips external ones.

(= (coll.remove NilMap ($k $v)) NilMap)
(= (coll.remove (ConsMap $pair $tail) ($k $v)) (eval (Map.remove $k (ConsMap $pair $tail))))
(= (coll.remove NilMap $k) NilMap)
(= (coll.remove (ConsMap $pair $tail) $k) (eval (Map.remove $k (ConsMap $pair $tail))))

;; MultiMap — remove by key; if pair given, remove one; if key given, remove all
(= (coll.remove NilMMap ($k $v)) NilMMap)
(= (coll.remove (ConsMMap $pair $tail) ($k $v)) (eval (MultiMap.removeOne $k (ConsMMap $pair $tail))))
(= (coll.remove NilMMap $k) NilMMap)
(= (coll.remove (ConsMMap $pair $tail) $k) (eval (MultiMap.removeAll $k (ConsMMap $pair $tail))))

;; Ordered Multiset — remove one occurrence (constructor-specific)
(= (coll.remove NilOMS $el) NilOMS)
(= (coll.remove (ConsOMS $x $xs) $el) (eval (OMS.remove $el (ConsOMS $x $xs))))

;; Ordered Set — remove first matching element
(= (coll.remove NilOS $el) NilOS)
(= (coll.remove (ConsOS $x $xs) $el)
   (if (== $x $el) $xs (ConsOS $x (coll.remove $xs $el))))

;; Deme — remove one ScoredInstance from its InstanceSet
(= (coll.remove (mkDeme $rep (mkSInstSet $list) $demeId) $el)
   (mkDeme $rep (mkSInstSet (coll.remove $list $el)) $demeId))

;;
;; coll.contains — membership/lookup presence
;;
; (: coll.contains (-> $coll $key Bool))

;; List — linear search
(= (coll.contains Nil $el) False)
(= (coll.contains (Cons $h $t) $el) (if (== $h $el) True (coll.contains $t $el)))

;; Map / MultiMap / OS / OMS — delegate
;; Added `eval` to ensure internal functions from other files are properly resolved during parsing.
;; Without it, PeTTa only executes functions defined in the current file and skips external ones.

(= (coll.contains NilMap $key) False)
(= (coll.contains (ConsMap $pair $tail) $key) (eval (Map.contains $key (ConsMap $pair $tail))))
(= (coll.contains NilMMap $key) False)
(= (coll.contains (ConsMMap $pair $tail) $key) (eval (MultiMap.contains $key (ConsMMap $pair $tail))))
(= (coll.contains NilOS $el) False)
(= (coll.contains (ConsOS $x $xs) $el) (eval (OS.contains (ConsOS $x $xs) $el)))
(= (coll.contains NilOMS $el) False)
(= (coll.contains (ConsOMS $x $xs) $el) (eval (OMS.contains $el (ConsOMS $x $xs))))

;; Wrappers — delegate to inner lists
(= (coll.contains (mkInst $list) $el) (coll.contains $list $el))
(= (coll.contains (mkSInstSet $list) $el) (coll.contains $list $el))
(= (coll.contains (mkBScore $list) $el) (coll.contains $list $el))
(= (coll.contains (mkDeme $rep (mkSInstSet $instList) $demeId) $el) (coll.contains $instList $el))

;;
;; coll.getByIdx — index-based access where supported
;;
; (: coll.getByIdx (-> $coll Number $el))

;; List — from List methods
(= (coll.getByIdx (Cons $h $t) $i) (eval (List.getByIdx (Cons $h $t) $i)))
(= (coll.getByIdx Nil $i) (Error $i "Index out of range"))

;; Map / MultiMap — pair access
(= (coll.getByIdx (ConsMap $pair $tail) $i) (Map.getByIdx (ConsMap $pair $tail) $i))
(= (coll.getByIdx NilMap $i) (Error $i "Index out of range"))
(= (coll.getByIdx (ConsMMap $pair $tail) $i) (MultiMap.getByIdx $i (ConsMMap $pair $tail)))
(= (coll.getByIdx NilMMap $i) (Error $i "Index out of range"))

;; OS / OMS — delegate
(= (coll.getByIdx (ConsOS $x $xs) $i) (eval (OS.getByIdx $i (ConsOS $x $xs))))
(= (coll.getByIdx NilOS $i) (Error $i "Index out of range"))
(= (coll.getByIdx (ConsOMS $x $xs) $i) (eval (OMS.getByIdx $i (ConsOMS $x $xs))))
(= (coll.getByIdx NilOMS $i) (Error $i "Index out of range"))

;; Wrappers — delegate to inner lists
(= (coll.getByIdx (mkInst $list) $i) (coll.getByIdx $list $i))
(= (coll.getByIdx (mkSInstSet $list) $i) (coll.getByIdx $list $i))
(= (coll.getByIdx (mkBScore $list) $i) (coll.getByIdx $list $i))
(= (coll.getByIdx (mkDeme $rep (mkSInstSet $instList) $demeId) $i) (coll.getByIdx $instList $i))

;;
;; Map/MultiMap key-centric APIs
;; Added `eval` to ensure internal functions from other files are properly resolved during parsing.
;; Without it, PeTTa only executes functions defined in the current file and skips external ones.

; (: coll.keys (-> $map (List $k)))
(= (coll.keys NilMap) Nil)
(= (coll.keys (ConsMap $pair $tail)) (eval (Map.keys (ConsMap $pair $tail))))

; (: coll.values (-> $map (List $v)))
(= (coll.values NilMap) Nil)
(= (coll.values (ConsMap $pair $tail)) (eval (Map.values (ConsMap $pair $tail))))

; (: coll.items (-> $map (List ($k $v))))
(= (coll.items NilMap) Nil)
(= (coll.items (ConsMap $pair $tail)) (eval (Map.items (ConsMap $pair $tail))))

; (: coll.find (-> $map $k Number))
(= (coll.find NilMap $k) -1)
(= (coll.find (ConsMap $pair $tail) $k) (eval (Map.find (ConsMap $pair $tail) $k)))

; (: coll.getByKey (-> $map $k $v))
(= (coll.getByKey (ConsMap $pair $tail) $k) (eval (Map.getByKey $k (ConsMap $pair $tail))))
(= (coll.getByKey NilMap $k) (Error $k "not found"))

; (: coll.findOne (-> $mmap $k $v))
(= (coll.findOne (ConsMMap $pair $tail) $k) (eval (MultiMap.findOne $k (ConsMMap $pair $tail))))
(= (coll.findOne NilMMap $k) (Error $k "not found"))

; (: coll.findAll (-> $mmap $k (List $v)))
(= (coll.findAll (ConsMMap $pair $tail) $k) (eval (MultiMap.findAll $k (ConsMMap $pair $tail))))
(= (coll.findAll NilMMap $k) Nil)

;;
;; Index-based removal (where supported)
;;
(: coll.removeByIdx (-> $coll Number $coll))

;; List — via List.removeAtIdx
(= (coll.removeByIdx (Cons $h $t) $i) (eval (List.removeAtIdx (Cons $h $t) $i)))
(= (coll.removeByIdx Nil $i) (Error "empty/idx out of range"))

;; OS — direct
(= (coll.removeByIdx (ConsOS $x $xs) $i) (eval (OS.removeByIdx (ConsOS $x $xs) $i)))
(= (coll.removeByIdx NilOS $i) (Error "empty/idx out of range"))

;; Deme/InstanceSet/BehavioralScore/Instance — delegate to inner lists
(= (coll.removeByIdx (mkInst $list) $i) (mkInst (coll.removeByIdx $list $i)))
(= (coll.removeByIdx (mkSInstSet $list) $i) (mkSInstSet (coll.removeByIdx $list $i)))
(= (coll.removeByIdx (mkBScore $list) $i) (mkBScore (coll.removeByIdx $list $i)))
(= (coll.removeByIdx (mkDeme $rep (mkSInstSet $list) $demeId) $i) (mkDeme $rep (mkSInstSet (coll.removeByIdx $list $i)) $demeId))

;;
;; OS-specific helpers
;;
(: coll.takeN (-> Number $os $os))
(= (coll.takeN $n NilOS) NilOS)
(= (coll.takeN $n (ConsOS $x $xs)) (eval (OS.takeN $n (ConsOS $x $xs))))

(: coll.getTopN (-> Number $os $os))
(= (coll.getTopN $n NilOS) (Error NilOS "empty ordered set/ fewer items than required"))
(= (coll.getTopN $n (ConsOS $x $xs)) (eval (OS.getTopN $n (ConsOS $x $xs))))
;; helper function to remove leading zeros from a node id
; (: updateID (-> ($a $b) ($a $b)))
(= (updateID (mkNodeId $id)) 
    (if (== (car-atom $id) 0)
        (mkNodeId (cdr-atom $id))
        (mkNodeId $id)

    ))


; this is to replace the built-in if-decons-expr which will depricate in future on mettalog
; it is used to deconstruct an expression into head and tail and then use them in the then expression
; if the expression is empty it will use the else expression
;;(: if-decons-expr-custom (-> Expression %Undefined% %Undefined% Expression Expression %Undefined%))
(= (if-decons-expr-custom $list $h $t $then $else)
      (if (or (== $list ()) (not (== (get-metatype $list) Expression)))
            $else
            (let* (
                  ($h (car-atom $list))
                  ($t (cdr-atom $list))
                  )
                (eval $then)
            )
            ))

;; It returns True only if the input is zero.
(: isZero (-> Number Bool))
(= (isZero $x) (== $x 0))

;; It will return True if greater than 10.
; (: greaterThanTen (-> Number Bool))
(= (greaterThanTen $x) (> $x 10))

;; It will decrement the input by 1.
; (: decrement (-> Number Number))
(= (decrement $x) (- $x 1))

;; It will increment the input by 1.
; (: increment (-> Number Number))
(= (increment $x) (+ $x 1))

;; A function that turns every atom to unit
(: transformToUnit (-> Atom Atom))
(= (transformToUnit $x) ())

; %%%% Hyperon-Experimental compatibility library. %%%%
; Many of the included functions were considered ad hoc and
; straightforward to express directly in MeTTa itself:

;Equality and Reduction
(= (if-equal $A $B $Then $Else)
   (if (== $A $B) $Then $Else))

(= (if-equal2 $A $B $Then $Else)
   (if (== $A $B) $Then $Else))

(= (assertEqual $a $b)( (test $a $b))) ;;unlike assert function test function shows the expected and got output so this may be better for debuging simply.

(= (assertAlphaEqual $A $B)
   (assert (=alpha $A $B)))

; (: unify (-> Expression Expression Expression Expression %Undefined%))
(= (unify $space $pattern $then $else)
   (if (is-space $space)
       (let $temp (cut)
            (case (match $space $pattern $pattern)
                  (($pattern $then)
                   (Empty $else)))) (empty)))

(= (unify $a $b $then $else)
   (if (= $a $b)
       (eval $then)
       (eval $else)))

(: add-reduct (-> %Undefined% Expression Bool))
(= (add-reduct $space $f)
   (let* (($headbody (cdr-atom $f))
          ($head (car-atom $headbody))
          ($body (cdr-atom $headbody))
          ($bodyreduced (eval $body)))
         (add-atom $space (= $head $bodyreduced))))

;Error Handling
; (= (if-error $X $A $B)
;    (if (== (car-atom $X) Error) 
;        $A $B))

(= (if-error $X $A $B)
    (if (or (== (get-metatype $X) Grounded) (== (get-metatype $X) Symbol))
        $B
        (if (== (car-atom $X) Error) 
            $A $B)))       

(= (return-on-error $result $B)
   (if-error $result
             $result
             $B))

;Evaluation control
(= (for-each-in-atom $L $f)
   (map-atom $L $f))

(: evalc (-> Expression %Undefined% %Undefined%))
(= (evalc $expression &self)
   (eval $expression))

;Quoting
(: unquote (-> Expression %Undefined%))
(= (unquote (quote $A))
   (eval $A))

(: noreduce-eq (-> Expression Expression Bool))
(= (noreduce-eq $A $B)
   (== $A $B))

;Types
(= (is-function (-> $A $B)) (let $temp (cut) True))
(= (is-function $X) False)

(= (get-type-space &self $x)
   (get-type $x))

(= (match-types $A $B $Then $Else)
   (if (== $A $B) $Then $Else))

(= (match-type-or $value $type1 $type2)
   (match-types $type1 $type2 True $value))

;; This helper function is intended for custom type constructors and functions
(= (get-type-reduce $obj)
    (if (is-expr $obj)
        (let*
            (
                (($h $t) (decons-atom $obj))
                ($constructor (car-atom (reverse (get-type $h))))
                ($hc (car-atom $constructor))
                ($t2 (collapse (get-type (superpose $t))))
            )
            (cons $hc $t2)
        )
        (car-atom (reverse (get-type $obj)))
    )
)

;; replicates MeTTaLog's union-atom builtin function, i.e., keeps one copy of items present in both lists
(= (union-atom-set $a $b)
   (if (= $b ())
        $a
        (let $b-new 
            (collapse 
                (let $bs (superpose $b) 
                                    (if (is-member $bs $a)
                                        (empty)
                                        $bs))) 
            (union-atom $a $b-new))))

; Returns a random integer (0, 1, or 2) biased toward 0.
; ~50% chance to return 0, otherwise randomly 1 or 2.
;; (: biasedRandomInt (-> Number))
(= (biasedRandomInt)
   (if (== (random-int 0 2) 0)  ; 50% chance
       0
       (random-int 1 3)))      ; 1 or 2

; Custom implementation of the ceiling function
; Param: $num – the input number (may be fractional)
; Returns: The smallest integer greater than or equal to $num.
; (: ceilMath (-> Number Number))
(= (ceilMath $num)
(+ (floor-math $num) (if (> $num (floor-math $num)) 1 0)))
