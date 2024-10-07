;; Helper functions that are going to be useful for writing any metta code

(: ~= (-> Atom Atom Bool))
(= (~= $a $b) (not (== $a $b)))

;Function to cocatinate two tuples (A B) (C D) ==> (A B C D)
;(: cocatTuple (-> Expression Expression Expression))
 (= (concatTuple $xs $ys)
   (if (== $xs ())
       $ys
       (let* (($head (car-atom $xs)) 
              ($tail (cdr-atom $xs)) 
              ($tailNew (concatTuple $tail $ys)))
         (cons-atom $head $tailNew)
       )
   )
)

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
(= (isMember $x $tuple)
    (if (== $tuple ()) False
        (let*
            (
                ($head (car-atom $tuple))
                ($tail (cdr-atom $tuple))
            )
        (
            if (== $x $head) True (isMember $x $tail)
        )
)
)
)
