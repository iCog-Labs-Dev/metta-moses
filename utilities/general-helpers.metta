;; Helper functions that are going to be useful for writing any metta code

(: ~= (-> Atom Atom Bool))
(= (~= $a $b) (not (== $a $b)))

;Function to cocatinate two tuples (A B) (C D) ==> (A B C D)
(: concatTuple (-> Expression Expression Expression))
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
