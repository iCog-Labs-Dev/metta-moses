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

(= (getchildren $expr $literals $nonLiterals)
    (if (== $expr ())
        ($literals $nonLiterals)
        (let* 
            (   
                ($head (car-atom $expr))
                ($tail (cdr-atom $expr))
                ($isLiteral (or (== (get-metatype $head) Symbol) (unify $head (NOT $_) True False)))
            )
            (if (or (== $head AND) (== $head OR)) 
                (getchildren $tail $literals $nonLiterals)

                (if $isLiteral 
                    (getchildren $tail (concatTuple $literals ($head)) $nonLiterals)
                    (getchildren $tail $literals (concatTuple $nonLiterals ($head)))        
                )
            )
        )
    )
)

(= (getGsetAndChildren $expr) (getchildren $expr () ()))

(= (findIntersection $tuple1 $tuple2)
    (if (== $tuple1 ())
        () 
        (let* 
            (
                ($head (car-atom $tuple1))
                ($tail (cdr-atom $tuple1))
            )
            (if (isMember $tuple2 $head)
                (let $val (findIntersection $tail $tuple2) (cons-atom $head $val))
                (findIntersection $tail $tuple2)
            )
        )
    )
)

(= (findCommonLiterals $literals $children)
    (if (or (== $children ()) (== $literals ())) 
        $literals 
        (let* 
            (
                ($first (car-atom $children)) 
                ($head (car-atom $first)) 
                ($tail (cdr-atom $children)) 
                ($common (findIntersection $literals $head)) 
            )
            (findCommonLiterals $common $tail) 
        )
    )
)

(= (removeCommonLiterals $common $children)
    (if (== $children ()) 
        ()  
        (let* 
            (
                ($head (car-atom $children))  
                ($tail (cdr-atom $children))  
                ($filteredChild (removeElement $common $head)) 
                ($newTail (removeCommonLiterals $common $tail))  
            )
            (cons-atom $filteredChild $newTail)  
        )
    )
)

(= (removeElement $common $child)
    (if (== $child ()) 
        ()  
        (let* 
            (
                ($head (car-atom $child))  
                ($tail (cdr-atom $child))  
                ($newTail (removeElement $common $tail))  
            )
            (if (isMember $common $head)
                $newTail  
                (cons-atom $head $newTail)  
            )
        )
    )
)