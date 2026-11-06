;; General helper functions for MeTTa code.
!(bind! perf_counter (new-state (py-call "time.perf_counter")))
!(py-call (random.seed 0))

(= (round $x)(py-call ("round" $x)))

;; Measures the average execution time of a given expression over multiple runs.
;; Parameters:
;;   $expr: The expression to be evaluated and profiled.
;;   $n: The number of times to execute $expr for timing.
;; Returns:
;;   The average time (rounded to 3 decimal places) taken to evaluate $expr, computed over $n
(= (profile $expr $n)
  (let*
    (
      ($times (profile-helper $expr $n ()))
      ($_ (println! (times: $times)))
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

;; Collect $n run times of $expr into $acc.
(= (profile-helper $expr $n $acc)
  (if (== $n 0)
      $acc
      (let*
          (
            ($pair (profilen $expr))
            ($time (car-atom $pair))
            ($newAcc (cons-atom $time $acc))
            ($next (profile-helper $expr (- $n 1) $newAcc))
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


;; Not-equal test on two atoms.
(= (~= $a $b) (!= $a $b))
;; Concatenate two tuples: (A B) (C D) ==> (A B C D)
;; (: concatTuple (-> Expression Expression Expression))
(= (concatTuple $x $y) (union-atom $x $y))

;; Atom arguments: the two tuples stay unevaluated data.
(: ++ (-> Atom Atom %Undefined%))
(= (++ $x $y)
   (case ((isSymbol $x) (isSymbol $y))
      (
        ((True True)  ($x $y))
        ((True False) (cons-atom $x $y))
        ((False True) (appendAtom $y $x))
        ((False False)  (foldr cons-atom $y $x)))))

;; Return the elements of $set1 that are not in $set2.
;; moses/tests/rte-helpers-fast.pl overrides this function with native Prolog clauses.
;; (: setDifference (-> Expression Expression Expression))
;; The tail is processed before the head test, so variable elements bind in that order.
;; Do not use filter-atom here: it copies $set2 for each element, and a variable
;; element then no longer binds (probe: (setDifference (a b) ($v)) gives () not (a)).
(= (setDifference () $set2) ())
(= (setDifference (cons $head $tail) $set2)
   (let $newTail (setDifference $tail $set2)
     (if (once (is-member $head $set2))
         $newTail
         (cons-atom $head $newTail))))

;; A helper function for the findAndReplace function.
;; It handles the replacement of a single atom.
(= (replace $old $new $current) (if (== $old $current) $new $current))

;; Name:                        isConstant
;; Description:                 The reducer's boolean constants, emitted at the point a rule
;;                              detects a contradiction or a tautology. SYMBOLS, not the grounded
;;                              Bools: (get-metatype true) is Grounded, and getLiterals filters a
;;                              grounded leaf straight back out. Classified as CHILDREN, never
;;                              literals, so they never reach a guard, dominant or command set.
(= (isConstant $exp) (or (== $exp TRUE) (== $exp FALSE)))

;; A function to replace a specific atom
;;    with a new one from a list of atoms.
;; INFO: This function needs to change so that it can preserve the
;;        operator's position when MeTTa version is upgraded.
;; Direct recursion avoids the per-element `replace` dispatch that map-atom
;; introduces. A/B confirmed (mux6): within noise of a native Prolog stub.
(= (findAndReplace $old $new $list)
   ;; EQUALITY, not subset. The old subtraction-atom test only said every element of $old
   ;; also occurs in $list, so replacing (AND B) inside (AND (OR (AND B)) B) replaced THE
   ;; WHOLE PARENT -- harmless while $new was a placeholder, fatal with a real constant.
   ;; It also needs an Expression, yielding NO SOLUTION on a Symbol $old.
   (if (== $old $list)
       $new
       (farReplaceWalk $list $old $new)))

(= (farReplaceWalk () $old $new) ())
(= (farReplaceWalk (cons $h $t) $old $new)
   (if (== $h $old)
       (cons-atom $new (farReplaceWalk $t $old $new))
       (cons-atom $h (farReplaceWalk $t $old $new))))

;; A function that behaves like a do while loop.
;; It executes the functions in the given list and returns the last result.
;; (: until (-> (-> $a Bool) (-> $a $a) $a $a))
(= (until $predicate $function $x)
    (let $isTrue ($predicate $x)
        (if (== $isTrue true)
            $x
            (until $predicate $function ($function $x)))))

;; Left fold. $f takes the element first and the accumulator second: ($f $x $acc).
;; The name is not foldl because PeTTa uses foldl internally (apply.pl).
;; (: foldl-l (-> (-> $a $b $b) $b Expression $b))
(= (foldl-l $f $acc $tuple)
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
       (let* ((($h $t) (decons-atom $xs))
              ($ft (foldr $f $i $t)))
         ($f $h $ft))))

;; Apply a given function to every element of a tuple.
;; Clause-dispatched recursion (NOT map-atom): captured args are threaded
;; as ordinary arguments through Prolog call/1, so a captured var keeps its
;; identity across every element — map-atom's yall lambda copy_terms its
;; captures per element, which severs shared-var identity (see substExp).
;; Overloads thread 1 or 2 captured args before the tuple.
;; (: map (-> (-> $a $b) $c $d))
(= (map $f ()) ())
(= (map $f (cons $h $t))
   (let* (($fh ($f $h))
          ($ft (map $f $t)))
     (cons-atom $fh $ft)))
(= (map $f $a ()) ())
(= (map $f $a (cons $h $t))
   (cons-atom ($f $a $h) (map $f $a $t)))
(= (map $f $a $b ()) ())
(= (map $f $a $b (cons $h $t))
   (cons-atom ($f $a $b $h) (map $f $a $b $t)))

;; Function: wrapper
;; Description: This function applies a predicate to an atom and returns the atom if the predicate is true, otherwise returns an empty expression.
;; Parameters:
;;   - $predicate: A function that takes an atom and returns a boolean value.
;;   - $x: The atom to which the predicate is applied.
;; Returns:
;;   - Expression: Returns the atom if the predicate evaluates to true, otherwise returns an empty expression.
;; (:wrapper (-> (-> $a Bool) $aa $aa))
(= (wrapper $predicate $x) (if (let $bool ($predicate $x) $bool) $x ()))

;; Filter function given a predicate. It returns one solution for each kept element.
;; (: filter (-> (-> $a Bool) $a $a))
(= (filter $predicate $list)
   (wrapper $predicate (superpose $list)))

;; Filter with a two-argument predicate. It returns one solution for each kept element.
;; (:wrapperB (-> (-> $a $b Bool) $a $b $b))
(= (wrapperB $predicate $x $y) (if ($predicate $x $y) $y (empty)))

;; Type for documentation only. Active, it stops the PeTTaV2 load: superpose makes $list concrete.
;; (: filterB (-> (-> $a $b Bool) $a (List $b) $b))
(= (filterB $predicate $x $list)
   (wrapperB $predicate $x (superpose $list)))

;; A function to remove all elements found in $common from a $tuple
(= (removeElement $common $tuple) (subtraction-atom $tuple $common))

;; Return True if any of the input atoms is True, and False otherwise.
;; Example: (True True False) ==> True, (False False False) ==> False
;; (: any (-> Atom Bool))
;; once: is-member gives one solution for each match.
(= (any $bools) (once (is-member True $bools)))

;; Apply a two-argument function to $x and $y.
(= (curry $f $x $y)($f $x $y))

;; Apply a three-argument function to $x, $y and $z.
(= (curry2 $f $x $y $z)($f $x $y $z))

;; Add numbers in an atom list
(= (sum $list) (foldl-atom $list 0 $acc $x (+ $acc $x)))

;; Count the occurrences of an atom in a list of atoms.
(= (count $t $list)(let $r (filter-atom $list $x (== $x $t)) (length $r)))

;; A function to check if a given atom is symbol.
;; (: isSymbol (-> Expression Bool))
(= (isSymbol $expr) (== (get-metatype $expr) Symbol))

;; A function to check if a given atom is expression.
;; (: isExpression (-> Atom Bool))
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
;; (: hasOneAtom (-> Atom Bool))
(= (hasOneAtom $expr) (if (and (== (get-metatype $expr) Expression) (not (isUnit $expr))) (== (cdr-atom $expr) ()) False))

;; Replace a given atom in a space.
;; (: update-atom (-> Grounded Atom Atom (->)))
(= (update-atom $space $oatom $natom) (let $_ (remove-atom $space $oatom) (add-atom $space $natom)))

;; Append an atom to the end of a tuple.
;; (: appendAtom (-> Atom Expression Expression))
(= (appendAtom $a $atom) (foldr cons-atom ($a) $atom))

;; A function to return a tuple of numbers from natural to a given number.
;; $x is the upperbound
;; $acc is the lowerbound wrapped with as a tuple.
;;    Example: (gen 5 (0)) => (5 4 3 2 1 0)
(= (gen $x $acc)
   (if (== (car-atom $acc) $x)
       $acc
       (let $lastInserted (car-atom $acc) (gen $x (cons-atom (+ 1 $lastInserted) $acc)))))

;; Create a tuple of pairs from two lists of equal length.
(= (zip $a $b)
   (if (or (hasOneAtom $a) (hasOneAtom $b))
       (((car-atom $a) (car-atom $b)))
       (let*
          (
            (($x $xs) (decons-atom $a))
            (($y $ys) (decons-atom $b))
            ($rest (zip $xs $ys))
          )
          (cons-atom ($x $y) $rest)))
)

;; Similar to zip but instead of just creating a tuple of atoms,
;;  it applies $f on them and returns the resulting list of atoms.
;; (: zipWith (-> (-> $a $b $c) $d $e $f))
(= (zipWith $f $xs $ys)
   (if (== $xs ())                      ;; We assume (arity $xs) == (arity $ys)
       ()
       (let* ((($xsHead $xsTail) (decons-atom $xs))
              (($ysHead $ysTail) (decons-atom $ys))
              ($head ($f $xsHead $ysHead))
              ($tail (zipWith $f $xsTail $ysTail)))
         (cons-atom $head $tail))))

;; Three-list variant of zipWith. Applies $f to corresponding head triples and
;; returns the resulting tuple. Assumes all three inputs have equal arity.
;; (: zipWith3 (-> (-> $a $b $c $d) $e $f $g $h))
(= (zipWith3 $f $xs $ys $zs)
   (if (== $xs ())
       ()
       (let* ((($xsHead $xsTail) (decons-atom $xs))
              (($ysHead $ysTail) (decons-atom $ys))
              (($zsHead $zsTail) (decons-atom $zs))
              ($head ($f $xsHead $ysHead $zsHead))
              ($tail (zipWith3 $f $xsTail $ysTail $zsTail)))
         (cons-atom $head $tail))))

;; Find the length of a tuple.
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
        (let ($first $tail) (decons-atom $expr)
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
 
;; Select an atom by index, 0-based. An index out of range gives an Error.
;; The guard is necessary: index-atom alone gives zero solutions out of range.
(: indexAtom (-> Atom Number %Undefined%))
(= (indexAtom $expr $index)
    (if (and (>= $index 0) (< $index (size-atom $expr)))
        (index-atom $expr $index)
        (Error description: IndexOutOfRange)))

;; removeAtom -- removes a single atom (the first occurrence) from a tuple
;; (: removeAtom (-> Atom Expression Expression))    

;; Hazard: car-atom on () throws on PeTTaV2, so test for () first.
(= (removeAtom $atom $expr)
    (if (or (== $expr ()) (!= (get-metatype $expr) Expression))
        ()
        (let* (($head (car-atom $expr))
               ($tail (cdr-atom $expr)))
            (if (== $head $atom)
                $tail  ;; Stop at the first match
                (cons-atom $head (removeAtom $atom $tail))))))
;; subtractionAtom -- multiset subtraction: each element of $b removes one
;; occurrence from $expr. The PeTTa built-in subtraction-atom does the same.
(: subtractionAtom (-> Atom Atom %Undefined%))
(= (subtractionAtom $expr $b) (subtraction-atom $expr $b))

;; A function that compares tuples element by element.
(= (compareElements $first $second)
   (zipWith == $first $second)
)

;; DemeSpace accessors. A DemeSpace holds one (mkRep ...), one (mkSInstSet ...)
;; and one (mkDemeId ...).
(= (getDemeRep $demeSpace) (match $demeSpace (mkRep $kbMap $tree) (mkRep $kbMap $tree)))
(= (getDemeId $demeSpace) (match $demeSpace (mkDemeId $id) (mkDemeId $id)))
(= (getDemeInstSet $demeSpace) (match $demeSpace (mkSInstSet $rows) (mkSInstSet $rows)))
(= (getDemeInstances $demeSpace) (match $demeSpace (mkSInstSet $rows) $rows))

;; Replace the stored instance set and return the new rows. The unbound pattern
;; removes whichever set is stored: crossoverFs returns a new set without storing
;; it, so the stored set can differ from the set that the caller holds.
(= (setDemeInstances $demeSpace $rows)
   (let* (($_remove (remove-atom $demeSpace (mkSInstSet $storedRows)))
          ($_add (add-atom $demeSpace (mkSInstSet $rows))))
     $rows))

;; Function to empty a space with contents.
(= (clearSpace $space)
   (collapse (let $content (get-atoms $space) (remove-atom $space $content))))
   
;; Function that merges two sorted lists while keeping them sorted.
(= (merge $xs $ys) (merge $xs $ys <=))
(= (merge $xs $ys $key)
    ;; Hazard: the constant head Args keeps the scrutinee data. A tuple with a
    ;; variable head, ($xs $ys), compiles as a call of $xs on PeTTaV2.
    (case (Args $xs $ys)
          (
            ((Args () $ys) $ys)
            ((Args $xs ()) $xs)
            ((Args $xs $ys)
              (let*
                  (
                    (($x $xss) (decons-atom $xs))
                    (($y $yss) (decons-atom $ys))
                  )
                  (if ($key $x $y)
                      (let $t (merge $xss $ys $key) (cons-atom $x $t))
                      (let $t (merge $xs $yss $key) (cons-atom $y $t))))))))

;; A function to split a list in to two at an index so that everything
;;    until that index without including that index as first tuple and 
;;    the rest as the second.
;; (: splitAt (-> Number Expression (Atom Atom)))
(= (splitAt $n $list)
   ;; Hazard: the constant head Args keeps the scrutinee data. With ($n $list),
   ;; PeTTaV2 types $n as a function and the pattern 0 throws a type mismatch.
   (case (Args $n $list)
     (
       ((Args 0 $list) (() $list))
       ((Args $_ ()) (() ()))
       ((Args $n $list)
          (let*
             (
               ;; (() (println! (Splitting $list at: $n)))
               (($x $xs) (decons-atom $list))
               (($left $right) (splitAt (- $n 1) $xs))
               ;; (() (println! (From splitAt Left: $left Right: $right)))
             )
             ((cons-atom $x $left) $right))))))

;; Merge sort function. Takes length to gain
;;  performance by avoiding recomputation of index.
(= (sortNestedTuple $list reverse) (sort $list (len $list) >=))

(= (sort $list $len) (sort $list $len <=))
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
;; (: selectionSort (-> Expression Number Expression))
(= (selectionSort $list $n) (selectionSort $list $n <))
;; (: selectionSort (-> Expression Number (-> $a $a Bool) Expression))
(= (selectionSort $list $n $op)
    (if (or (== $n 0) (== $list ()))
        $list
     (let* (
        ($cur (selector $list $op))
        ($newList (subtraction-atom $list ($cur)))
        ($rest (selectionSort $newList (- $n 1) $op))
    )
    (cons-atom $cur $rest)
    )))

;; Compare two atoms with $op and return the one that $op prefers.
;;  (: comparator (-> $a $a (-> $a $a Bool) $a))
(= (comparator $x $y $op) (if ($op $x $y) $x $y))

;; Select the atom of $expr that the comparison function $op prefers.
;; (: selector (-> Expression (-> $a $a Bool) $a))
(= (selector $expr $op) (selector $expr (car-atom $expr) $op) )
;; (: selector (-> Expression $a (-> $a $a Bool) $a))
(= (selector $expr $i $op)
   (foldl-atom $expr $i $acc $x (comparator $x $acc $op)))

;; A function to take an atom and repeat it n times.
;; (: repeat (-> Atom Number Atom))
(= (repeat $a $n)
   (if (== $n 0)
       ()
       (let $t (repeat $a (- $n 1)) (cons-atom $a $t))
   )
)

;; take first N elements of a list
;; %Undefined% output: on PeTTaV2 an Atom output returns the body unevaluated.
(: take (-> Number %Undefined% %Undefined%))
(= (take $n ()) ())
(= (take $n (cons $h $t))
   (if (<= $n 0)
       ()
       (let $nextN (- $n 1)
            (cons $h (take $nextN $t)))))

;; A function to remove the first n elements of a tuple
;;   and returns the rest.
;; (: drop (-> Number Atom Atom))
(= (drop $n $a)
    ;; Hazard: the constant head Args keeps the scrutinee data. With ($n $a),
    ;; PeTTaV2 types $n as a function and the pattern 0 throws a type mismatch.
    (case (Args $n $a)
      (
        ((Args $n ()) ())
        ((Args 0 $a) $a)
        ((Args $n $a)
          (let ($h $t) (decons-atom $a)
            (drop (- $n 1) $t))))))

;; isLiteral -- determines if the given atom is a literal or not

(= (isLiteral $a)
    (if (or (== (get-metatype $a) Grounded) (== (get-metatype $a) Symbol))
        True
        (== (car-atom $a) NOT)))

;; minOfTuple -- minimum of tuple of numeric expressions

(= (minOfTuple $expr)
    (let ($f $t) (decons-atom $expr)
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
;; flatten-list -- returns one tuple from a nested tuple of tuple of tuples ...
;; The name is not flatten because Prolog has a flatten predicate.
 (= (flatten-list $exp) (collapse (unNest $exp))) 


;; map` -- a map with a two-argument function: ($f $element $x).

;; (: map` (-> (-> $a $a $b) $a $c $d))
(= (map` $f $x $xs)
   (if (== $xs ())
       ()
       (let* ((($h $t) (decons-atom $xs))
              ($fh ($f $h $x))
              ($ft (map` $f $x $t)))
         (cons-atom $fh $ft))))

;; notMember -- check if a symbol is not a member of the non-terminal set

(= (notMember $symbol $expr) (not (once (is-member $symbol $expr)) ))

;; isValidExp -- to check if the boolean expression produced by genPhen is a valid boolean expression
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
;; (: all (-> Expression Bool))
(= (all $expressions) (not (once (is-member False $expressions))))


;; Name:                        ===
;; Description:                 A helper function to evaluate equality of two expressions ignoring ordering of literal children.
;;                              The grounded equality operator, ==, will return `False` when comparing (AND A B) and (AND B A)
;;                              === returns `True`.
;;                              Used when looking for the POA in the parent's list of children.
(= (=== $x $y)
   (if (or (== (get-metatype $x) Symbol) (== (get-metatype $y) Symbol))
       (== $x $y)
       (let*
            (
                ($a (subtraction-atom $x $y))
                ($b (subtraction-atom $y $x))
            )
            (== (append $a $b) ())
       )))

;; Number comparator: G (greater), E (equal) or L (less).
;; (: compareNum (-> Number Number Atom))
(= (compareNum $num1 $num2)
    (case ((> $num1 $num2) (== $num1 $num2))
        (((True $t) G)
         ((False True) E)
         ((False False) L))))

;; A greater-than-or-equal comparator that takes the numbers out of their type constructors and compares them.
;; ($ctor $x) ($ctor $y) -- (constructor value) pair                
;; (: >>= (-> $a $a Bool))
(= (>>= ($ctor $x) ($ctor $y))(>= $x $y))

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

;; Convert an expression to a list: (A B C) -> (cons A (cons B (cons C ()))).
;; PeTTa lists are expressions, so the result is equal to the input.
(= (exprToList $expr)
    (if (== $expr ())
        ()
        (let ($head $tail) (decons-atom $expr)  (cons $head (exprToList $tail)))
    )
)

;; From a tuple (Pair) return the second element
;; (: second (-> ($a $b) $b))
(= (second ($a $b)) $b)

;; Converts a tuple of pairs into ordered multimap
;; Ex: ((k1 v1) (k2 v2)) -> (cons (k1 v1) (cons (k2 v2) ()))
;; (: expToMMap (-> Expression (MultiMap ($k $v)) (-> $k $k Bool) (MultiMap ($k $v))))
;; The only comparator passed in production is discSpec< (knob-representation.metta),
;; which always returns False, so each insert lands at the tail.
;; So the function is an append (union-atom), and $compFunc is not used.
(= (expToMMap $pairs $map $compFunc) (union-atom $map $pairs))

;; helper function to generate list of numbers ranging from 0 to n
;; (: genList (-> Number Expression))
(= (genList $u) (genList 0 $u))
;;
;; (: genList (-> Number Number Expression))
(= (genList $l $u)
    (if (< $u $l)
        ()
        (let $res (genList $l (- $u 1))
            (append $res ($u)))))

;; swap AND , OR 
;; (: swapAndOr (-> Atom Atom))
(= (swapAndOr $op)
    (case $op
        ((AND OR)
         (OR AND)
         ($else $op))
    )
)

;; (: compose (-> (-> $b $c) (-> $a $b) (-> $a $c)))
;; Function composition: (compose $g $f $x) = ($g ($f $x)).
;; Do not write the head as ((compose $g $f) $x): PeTTa cannot translate it.
(= (compose $g $f $x)($g ($f $x)))

;; approximate equality -- takes the relative magnitude of the numbers into consideration

;; PeTTa binds a constant through a state: read it with get-state.
!(bind! EPSILON (new-state (pow-math 10 -6)))
;; (: isApproxEq (-> Number Number Bool))
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
        (let* ((($head $rest) (decons-atom $expr1))
               ($tail (concatT $rest $expr2)))
            (cons-atom $head $tail))))

;; isnan -- to check if a value is NaN
;; Scores use the symbol nan for NaN. The symbol is not a Number, and
;; isnan-math (-> Number Bool) throws on it on the new PeTTa runtime.
;; Hazard: test nan first in a nested if. `or` is not short-circuit.
;; (: isnan (-> $a Bool))
(= (isnan $x) (if (== $x nan) True (isnan-math $x)))

;; isInf -- check if a number is Inf
;; MeTTaLog represents Inf as 1.0Inf (the value of Python float('inf')).
;; (: isInf (-> $a Bool))
(= (isInf $x) (== $x 1.0Inf))

;; int -- replicates pythons int functionality -- convert floating point numbers into integer
;; uses -- metta's floor-math function
;; (: int (-> Number Number))
(= (int $x) (if (>= $x 0) (floor-math $x) (+ 1 (floor-math $x))))

!(bind! EXP (new-state 2.71828))

;; Pseudo maximum integer (not the real maximum integer).
!(bind! maxInt (new-state (pow-math 2 64)))
;; Random float in [0, 1).
;; (: randomFloat (-> Number))
(= (randomFloat)(py-call ("random.random")))
!(bind! rnd (py-atom random))


;; ============================================================
;; Value comparison: (apply > $x $y), (apply < $x $y), (apply == $x $y)
;; ============================================================
;; apply compares two values through their key-of projection, so a Cscore,
;; a scored instance and an exemplar compare by score. Use it only for
;; value comparisons; collections use the coll.* API below.

;; key-of: project a value into a comparable key.
;; One clause with case, so a value gives one key only.
;; - Cscore -> KPair(penScore, -complexity) with NaN mapped to low sentinel
;; - ScoredInstance/Exemplar variants -> delegate to inner Cscore
;; - Default -> KScalar(x) (works for Number and other simple types)
;; The name is not key because key clashes with a Prolog name in PeTTa.
;; (: key-of (-> $a $k))
(= (key-of $x)
   (case $x
     (
       ;; 5-field Cscore (scoring/cscore.metta)
       ((mkCscore $scor $cpxy $cpxyPen $uniPen $penScore)
        (let $p (if (isnan $penScore) (* -1 (pow-math 10 308)) $penScore)
             (KPair $p (* -1 $cpxy))))
       ((mkSInst (mkPair $inst $score))
         (key-of $score))
       ((mkExemplar $tree $demeId $cscore $bscr)
         (key-of $cscore))
       ($else (KScalar $x))
     )))

(= (apply > $x $y)
   (case ((key-of $x) (key-of $y))
     (
       (((KPair $a1 $b1) (KPair $a2 $b2)) (or (> $a1 $a2) (and (== $a1 $a2) (> $b1 $b2))))
       (((KScalar $kx) (KScalar $ky)) (> $kx $ky))
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
;; Unified collection API (coll.*): one name for each operation on
;; lists, maps, multimaps, ordered sets, ordered multisets and the
;; wrappers mkInst, mkSInstSet, mkBScore and mkDeme.
;; `eval` on a call to a function of another file makes PeTTa resolve it.
;; ============================================================

;; Each coll.* operation below is ONE clause with a case. Separate clauses
;; overlap: a (cons $h $t) head also matches a wrapper such as (mkInst ...),
;; and the List, Map, MultiMap and OS views of a plain list all match it.
;; Each match gave one more solution, and the results did not agree.
;; A plain list uses the List view. Use the Map.* and MultiMap.* functions
;; directly for key-based operations.

;;
;; coll.length — length of supported collections and wrappers
;;
(: coll.length (-> $a Number))
(= (coll.length $coll)
   (case $coll
     ((NilOMS 0)
      ((ConsOMS $x $xs) (+ 1 (coll.length $xs)))
      ((mkInst $list) (coll.length $list))
      ((mkSInstSet $list) (coll.length $list))
      ((mkBScore $list) (coll.length $list))
      ((mkDeme $rep (mkSInstSet $list) $demeId) (coll.length $list))
      ($else (size-atom $coll)))))

;;
;; coll.append — append/insert one element into supported collections
;; A list gets the element at its tail. An OMS inserts it in order.
;;
;; (: coll.append (-> $coll $el $coll))
(= (coll.append $coll $el)
   (case $coll
     ((NilOMS (eval (OMS.insert $el NilOMS)))
      ((ConsOMS $x $xs) (eval (OMS.insert $el $coll)))
      ((mkInst $list)
       (if (== (get-type $el) Number)
           (mkInst (coll.append $list $el))
           (Error $el "Instance.append expects Number")))
      ((mkSInstSet $list) (mkSInstSet (coll.append $list $el)))
      ((mkBScore $list)
       (if (== (get-type $el) Number)
           (mkBScore (coll.append $list $el))
           (Error $el "BScore.append expects Number")))
      ((mkDeme $rep (mkSInstSet $list) $demeId)
       (mkDeme $rep (mkSInstSet (coll.append $list $el)) $demeId))
      ;; cons-atom, not ($el): a variable-headed tuple can be a call.
      ($else (union-atom $coll (cons-atom $el ()))))))

;; coll.insert — alias to coll.append
;; Types for documentation only. Active, they give zero results on PeTTaV1
;; when the length changes: $coll then binds two different tuple types.
;; (: coll.insert (-> $coll $el $coll))
(= (coll.insert $c $el) (coll.append $c $el))

;;
;; coll.remove — remove the first occurrence (by equality)
;; An OMS removes every occurrence (OMS.remove).
;;
;; (: coll.remove (-> $coll $el $coll))
(= (coll.remove $coll $el)
   (case $coll
     ((NilOMS NilOMS)
      ((ConsOMS $x $xs) (eval (OMS.remove $el $coll)))
      ((mkInst $list)
       (if (== (get-type $el) Number)
           (mkInst (coll.remove $list $el))
           (Error $el "Instance.remove expects Number")))
      ((mkSInstSet $list) (mkSInstSet (coll.remove $list $el)))
      ((mkBScore $list)
       (if (== (get-type $el) Number)
           (mkBScore (coll.remove $list $el))
           (Error $el "BScore.remove expects Number")))
      ((mkDeme $rep (mkSInstSet $list) $demeId)
       (mkDeme $rep (mkSInstSet (coll.remove $list $el)) $demeId))
      ;; List.index gives -1 for a missing element; List.removeAtIdx then keeps the list.
      ($else (let $idx (eval (List.index $coll $el))
                  (eval (List.removeAtIdx $coll $idx)))))))

;;
;; coll.contains — membership by equality
;;
;; (: coll.contains (-> $coll $key Bool))
(= (coll.contains $coll $el)
   (case $coll
     ((NilOMS False)
      ((ConsOMS $x $xs) (eval (OMS.contains $el $coll)))
      ((mkInst $list) (coll.contains $list $el))
      ((mkSInstSet $list) (coll.contains $list $el))
      ((mkBScore $list) (coll.contains $list $el))
      ((mkDeme $rep (mkSInstSet $list) $demeId) (coll.contains $list $el))
      ;; is-member gives one solution for each match, so once.
      ($else (once (is-member $el $coll))))))

;;
;; coll.getByIdx — index-based access where supported
;;
;; (: coll.getByIdx (-> $coll Number $el))
(= (coll.getByIdx $coll $i)
   (case $coll
     ((() (Error $i "Index out of range"))
      (NilOMS (Error $i "Index out of range"))
      ((ConsOMS $x $xs) (eval (OMS.getByIdx $i $coll)))
      ((mkInst $list) (coll.getByIdx $list $i))
      ((mkSInstSet $list) (coll.getByIdx $list $i))
      ((mkBScore $list) (coll.getByIdx $list $i))
      ((mkDeme $rep (mkSInstSet $list) $demeId) (coll.getByIdx $list $i))
      ($else (eval (List.getByIdx $coll $i))))))

;;
;; Map/MultiMap key-centric APIs
;; (: coll.keys (-> $map (List $k)))
(= (coll.keys ()) ())
(= (coll.keys (cons $pair $tail)) (eval (Map.keys (cons $pair $tail))))

;; (: coll.values (-> $map (List $v)))
(= (coll.values ()) ())
(= (coll.values (cons $pair $tail)) (eval (Map.values (cons $pair $tail))))

;; (: coll.items (-> $map (List ($k $v))))
(= (coll.items ()) ())
(= (coll.items (cons $pair $tail)) (eval (Map.items (cons $pair $tail))))

;; (: coll.find (-> $map $k Number))
(= (coll.find () $k) -1)
(= (coll.find (cons $pair $tail) $k) (eval (Map.find (cons $pair $tail) $k)))

;; (: coll.getByKey (-> $map $k $v))
(= (coll.getByKey (cons $pair $tail) $k) (eval (Map.getByKey $k (cons $pair $tail))))
(= (coll.getByKey () $k) (Error $k "not found"))

;; (: coll.findOne (-> $mmap $k $v))
(= (coll.findOne (cons $pair $tail) $k) (eval (MultiMap.findOne $k (cons $pair $tail))))
(= (coll.findOne () $k) (Error $k "not found"))

;; (: coll.findAll (-> $mmap $k (List $v)))
(= (coll.findAll (cons $pair $tail) $k) (eval (MultiMap.findAll $k (cons $pair $tail))))
(= (coll.findAll () $k) ())

;;
;; Index-based removal (where supported)
;;
;; Type for documentation only (see coll.insert).
;; (: coll.removeByIdx (-> $coll Number $coll))
(= (coll.removeByIdx $coll $i)
   (case $coll
     ((() (Error "empty/idx out of range"))
      ((mkInst $list) (mkInst (coll.removeByIdx $list $i)))
      ((mkSInstSet $list) (mkSInstSet (coll.removeByIdx $list $i)))
      ((mkBScore $list) (mkBScore (coll.removeByIdx $list $i)))
      ((mkDeme $rep (mkSInstSet $list) $demeId)
       (mkDeme $rep (mkSInstSet (coll.removeByIdx $list $i)) $demeId))
      ($else (eval (List.removeAtIdx $coll $i))))))

;;
;; OS-specific helpers
;;
(: coll.takeN (-> Number $os $os))
(= (coll.takeN $n ()) ())
(= (coll.takeN $n (cons $x $xs)) (eval (OS.takeN $n (cons $x $xs))))

(: coll.getTopN (-> Number $os $os))
(= (coll.getTopN $n ()) (Error () "empty ordered set/ fewer items than required"))
(= (coll.getTopN $n (cons $x $xs)) (eval (OS.getTopN $n (cons $x $xs))))
;; helper function to remove leading zeros from a node id
;; (: updateID (-> ($a $b) ($a $b)))
(= (updateID (mkNodeId $id)) 
    (if (== (car-atom $id) 0)
        (mkNodeId (cdr-atom $id))
        (mkNodeId $id)

    ))


;; A replacement for the MeTTaLog built-in if-decons-expr.
;; It is used to deconstruct an expression into head and tail and then use them in the then expression
;; If the expression is empty, it uses the else expression.
;;(: if-decons-expr-custom (-> Expression %Undefined% %Undefined% Expression Expression %Undefined%))
;; NOTE: the (eval $then) below is load-bearing — $then arrives as an
;; unevaluated expression referencing the caller's $h/$t logic vars, which
;; this clause binds via car/cdr before eval runs it. BUT eval also
;; deep-normalizes the RESULT term, which fires scoring/boolean-ops'
;; AND/OR/NOT clauses on returned tree data. Reduct-path callers that
;; return boolean tree data therefore must NOT use this helper — see the
;; plain-if forms of getGuardSet/getGuardSetND in
;; reduct/boolean-reduct/rte-helpers.metta.
(= (if-decons-expr-custom $list $h $t $then $else)
      (if (or (== $list ()) (!= (get-metatype $list) Expression))
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
;; (: greaterThanTen (-> Number Bool))
(= (greaterThanTen $x) (> $x 10))

;; It will decrement the input by 1.
;; (: decrement (-> Number Number))
(= (decrement $x) (- $x 1))

;; It will increment the input by 1.
;; (: increment (-> Number Number))
(= (increment $x) (+ $x 1))

;; A function that turns every atom to unit
(: transformToUnit (-> %Undefined% %Undefined%))
(= (transformToUnit $x) ())

;; %%%% Hyperon-Experimental compatibility library. %%%%
;; Many of the included functions were considered ad hoc and
;; straightforward to express directly in MeTTa itself:

;;Equality and Reduction
(= (if-equal $A $B $Then $Else)
   (if (== $A $B) $Then $Else))

(= (if-equal2 $A $B $Then $Else)
   (if (== $A $B) $Then $Else))

;; Use test, not assert: test shows the expected and the actual output.
(= (assertEqual $a $b) ( (test $a $b)))

(= (assertAlphaEqual $A $B)
   (assert (=alpha $A $B)))

;; Atom arguments stay unevaluated. Keep this declaration: without it a pattern
;; with a defined head, for example (NOT $x), is evaluated as a call.
;; Same as unify in PeTTa lib_he. On PeTTaV1 the unevaluated type was Expression.
(: unify (-> Atom Atom Atom Atom %Undefined%))
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

(: add-reduct (-> %Undefined% Atom Bool))
(= (add-reduct $space $f)
   (let* (($headbody (cdr-atom $f))
          ($head (car-atom $headbody))
          ($body (cdr-atom $headbody))
          ($bodyreduced (eval $body)))
         (add-atom $space (= $head $bodyreduced))))

;; Error handling
;; Hazard: car-atom on () throws on PeTTaV2 and gives no result on PeTTaV1.
;; So test for a non-empty expression first. () is not an error.
(= (if-error $X $A $B)
    (if (== (get-metatype $X) Expression)
        (if (== $X ())
            $B
            (if (== (car-atom $X) Error) $A $B))
        $B))

(= (return-on-error $result $B)
   (if-error $result
             $result
             $B))

;;Evaluation control
(= (for-each-in-atom $L $f)
   (map-atom $L $f))

(: evalc (-> Atom %Undefined% %Undefined%))
(= (evalc $expression &self)
   (eval $expression))

;;Quoting
(: unquote (-> Atom %Undefined%))
(= (unquote (quote $A))
   (eval $A))

(: noreduce-eq (-> Atom Atom Bool))
(= (noreduce-eq $A $B)
   (== $A $B))

;;Types
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
                ;; Hazard: (superpose $t) needs a one-type List on the new
                ;; runtime and throws on a mixed tuple such as ("Hello" 2).
                ($t2 (map-atom $t $x (get-type $x)))
            )
            (cons $hc $t2)
        )
        (car-atom (reverse (get-type $obj)))
    )
)

;; replicates MeTTaLog's union-atom builtin function, i.e., keeps one copy of items present in both lists
(= (union-atom-set $a $b)
   (let $u (union-atom $a $b) (list_to_set $u)))

;; Returns a random integer (0, 1, or 2) biased toward 0.
;; ~50% chance to return 0, otherwise randomly 1 or 2.
;; (: biasedRandomInt (-> Number))
(= (biasedRandomInt)
   (if (== (py-call (random.randint 0 1)) 0)  ;; 50% chance
       0
       (py-call (random.randint 1 2))))      ;; 1 or 2

;; Custom implementation of the ceiling function
;; Param: $num – the input number (may be fractional)
;; Returns: The smallest integer greater than or equal to $num.
;; (: ceilMath (-> Number Number))
(= (ceilMath $num)
(+ (floor-math $num) (if (> $num (floor-math $num)) 1 0)))

;; Increment a state monad of number
(= (incrementState $state) (incrementState $state 1))
(= (incrementState $state $int) (let $_ (change-state! $state (+ $int (get-state $state))) (get-state $state)))

;; Decrement a state monad of number
(= (decrementState $state) (decrementState $state 1))
(= (decrementState $state $int) (let $_ (change-state! $state (- $int (get-state $state))) (get-state $state)))

;; Reset a state monad to zero.
(= (resetState $state) (change-state! $state 0))

;; Return True when an operator is not in ignoreOps.
;; Existing operators are preserved.
(= (operatorAllowed $op $ignoreOps)
    (not (once (is-member $op $ignoreOps))))