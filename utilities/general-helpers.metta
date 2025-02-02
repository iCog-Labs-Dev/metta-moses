;; Lenght of a tuple

(= (len $tuple)
    (if (== $tuple ())
        0
        (let $tail (cdr-atom $tuple)
            (+ 1 (len $tail))
        )))
;; non-deterministic definitio of length

(= (length $expr)
    (sum (collapse (let $a (superpose $expr) 1)))
)
(: isSymbol (-> Expression Bool))
(= (isSymbol $expr) (== (get-metatype $expr) Symbol))

(: isUnit (-> Expression Bool))
(= (isUnit $expr) (== $expr ()))

(: isSingleAtom (-> Expression Bool))
(= (isSingleAtom $expr) (== (cdr-atom $expr) ()))

;; Function to replace a given atom from a space.
(: update-atom (-> Grounded Atom Atom (->)))
(= (update-atom $space $oatom $natom) (let $_ (remove-atom $space $oatom) (add-atom $space $natom)))

;; A function to return head and tail of an atom in a tuple.
(= (decons $atom)
   (if (not (or (isSymbol $atom) (isUnit $atom)))
       ((car-atom $atom) (cdr-atom $atom))
       (Error Unit Or Symbol cannot be deconstructed)))

;; Fold a tuple from right to left
(: foldr (-> (-> $a $b $b) $b $c $d))
(= (foldr $f $i $xs)
   (if (== $xs ())
       $i
       (let* (($h (car-atom $xs))
              ($t (cdr-atom $xs))
              ($ft (foldr $f $i $t)))
         ($f $h $ft))))

;; Add numbers in an atom list
(= (sum $list) (foldr + 0 $list))

;; Select atom by index

(= (selectByIndex $expr $index)
    (if (== $expr ())
        (Error (Index out of range) ())
        (if (== $index 0)
            (car-atom $expr)
            (let $tail (cdr-atom $expr)
                (selectByIndex $tail (- $index 1))
            ))))

;; deletes atom by index

(= (deleteAtom $expr $index)
    (if (> $index (- (len $expr) 1))
        (Error (Index out of range) ())
        (if (== $index 0)
            (cdr-atom $expr)
            (let* 
                (
                    (($first $tail) (decons $expr))
                    ($carry (deleteAtom $tail (- $index 1)))
                )
                (cons-atom $first $carry)
            ))))

;; isLiteral -- determines if the given atom is a literal or not
(= (isLiteral $a)
    (if (or (== (get-metatype $a) Grounded) (== (get-metatype $a) Symbol))
        True
        (if (== (car-atom $a) NOT)
            True
            False )))

; a function which checks if an element is member of a tuple.
(: isMember (-> $a $aa Bool))
(= (isMember $x $list)
    (not (== (collapse (intersection (superpose ($x)) (superpose $list))) ()))
)

;; A function that behaves like a do while loop.
;; It executes the functions in the given list and returns the last result.
(: until (-> (-> $a Bool) (-> $a $a) $a $a))
(= (until $predicate $function $x) 
    (if ($predicate $x) 
        $x 
        ($y ($function $x) (until $predicate $function $y))
    ))

;; min finds minimum of two numbers
(: min (-> Number Number Number))
(= (min $x $y) (if (<= $x $y) $x $y))

(= (max $x $y) (if (>= $x $y) $x $y))

;; maxIter -- finds maximum from a tuple of numerals

(= (maxIter $expr)
    (let ($f $t) (decons $expr)
        (if (== $t ())
            $f
            (max $f (maxIter $t))
        )
    )
)

;; prepend -- add an atom to the beginning of an expression

(= (prepend $x $acc)
    (collapse (union (superpose ($x)) (superpose ($acc)))))