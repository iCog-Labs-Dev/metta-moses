;; Helper functions that are going to be useful for writing any metta code

(: ~= (-> Atom Atom Bool))
(= (~= $a $b) (not (== $a $b)))

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

;; A map function that takes a function and applies 
;;    it on every atom in a given tuple.
(: map (-> (-> $a $b) $c $d))
(= (map $f $tuple)
   (if (== $tuple ())
       ()
       (let*
         (
            ($x (car-atom $tuple))
            ($xs (cdr-atom $tuple))
            ($x' ($f $x))
            ($next (map $f $xs))

            (() (println! (=== Map Log ===)))
            (() (println! (X: $x XS: $xs UpdatedX: $x' Next: $next)))
            (() (println! (UpdatedResult (cons-atom $x' $next))))
         )
         (cons-atom $x' $next)
       )
   )
)

;; A function to remove all elements found in $common from a $tuple
(= (removeElement $common $tuple)
   (collapse (subtraction (superpose $tuple) (superpose $common)))
)

;; A function that returns True if any of the input atoms are True and False otherwise
;; Example: input ==> (True True False), output ==> True
;;          input ==> (False False False), output ==> False
;;          input ==> (False True False), output ==> True
(: any (-> Atom Bool))
(= (any $bools) (isMember True $bools))
