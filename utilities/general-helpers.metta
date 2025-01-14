;; Helper functions that are going to be useful for writing any metta code

(: ~= (-> Atom Atom Bool))
(= (~= $a $b) (not (== $a $b)))

;; INFO: Uncomment for the use of MeTTaLog.
;; (: >= (-> Number Number Bool))
;; (= (>= $a $b) (or (== $a $b) (> $a $b)))

;Function to cocatinate two tuples (A B) (C D) ==> (A B C D)
;(: cocatTuple (-> Expression Expression Expression))
 (= (concatTuple $x $y) (collapse (union (superpose $x) (superpose $y)))) 

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
(: isMember (-> $a $aa Bool))
(= (isMember $x $list)
    (not (== (collapse (intersection (superpose ($x)) (superpose $list))) ()))
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
    ;; (let*
    ;;   (
    ;;     (() (println! ""))
    ;;     (() (println! (==> === Inside findAndReplace === <==)))
    ;;     (() (println! (Parameters ==> Old: $old New: $new List: $list)))
    ;;     (() (println! (Result ==> (collapse (replace $old $new (superpose $list))))))
    ;;     (() (println! ""))
    ;;   )
      (collapse (replace $old $new (superpose $list)))
    ;; )
)

;; A function that behaves like a do while loop.
;; It executes the functions in the given list and returns the last result.
(: until (-> (-> $a Bool) (-> $a $a) $a $a))
(= (until $predicate $function $x) (if ($predicate $x) $x (let $x' ($function $x) (until $predicate $function $x'))))

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
(: filter (-> (-> $a Bool) $a $a))
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

(: isUnit (-> Expression Bool))
(= (isUnit $expr) (== $expr ()))

(: isSingleAtom (-> Expression Bool))
(= (isSingleAtom $expr) (== (cdr-atom $expr) ()))

;; Function to replace a given atom from a space.
(: update-atom (-> Grounded Atom Atom (->)))
(= (update-atom $space $oatom $natom) (let $_ (remove-atom $space $oatom) (add-atom $space $natom)))

;; Return the maximum of two numbers.
(= (max $x $y) (if (< $x $y) $y $x))

;; A function to return a tuple of numbers from natural to a given number.
;; $x is the upperbound
;; $acc is the lowerbound wrapped with an atom.
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

;; Finds length of a tuple

(= (len $expr)
    (if (== $expr ())
        0
        (let $tail (cdr-atom $expr)
            (+ 1 (len $tail))
        )
    )
)

;; ++ apends $expr to $new recursively 
;; How it works
;;          1st checks if the parent expression is empty. If it is, just return ($new) if $new is literal $new and $new otherwise
;;          2nd gets the head and tail
;;          3rd see if the $tail == (). If so, append the first to $new taking into consideration the nature of $new
;;          if tail is not empty call ++ function recursively appending last element to $new and working back to the first element 
(= (++ $expr $new)
    (if (== $expr ())
        (if (isLiteral $new) ($new) $new)
        (let* 
            (
                ($first (car-atom $expr))
                ($tail (cdr-atom $expr))
            )
            (if (== $tail ())
                (if (isLiteral $new)
                    (cons-atom $first ($new))
                    (cons-atom $first $new)
                )
                (let $carry (++ $tail $new)
                    (cons-atom $first $carry)
                )))))

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

(= (isLiteral $a)
    (if (or (== (get-metatype $a) Grounded) (== (get-metatype $a) Symbol))
        True
        (if (== (car-atom $a) NOT)
            True
            False )))

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