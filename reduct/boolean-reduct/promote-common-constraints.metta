;The transformation identifies constraints that are common to all children of an POA(OR) node and promote them to the parent node's guard set e.g (AND (OR (AND C D) (AND C E))) --> (AND C (OR (AND D) (AND E)))
;(: promoteCommonConstraints (-> Expression Expression))                                                                                          
(= (promoteCommonConstraints $expr)
    (let* 
        (
            (($literals $children) (getGsetAndChildren $expr)) 
            ($childrenLiteral   (collapse (getGuardSet (superpose $children) ())))
            ($shared (findCommon $childrenLiteral))
            ($common (findIntersection $literals $shared))      
        )
        (if (== $common ())
            (() $expr)
            (let*
                ( 
                ($updatedChildren (removeCommonLiterals $common $children))
                ($updatedLiterals (removeElement $common $literals))
                ($newExp (concatTuple $updatedLiterals $updatedChildren ))
                ($res (cons-atom OR $newExp))              
                )
                ($common $res)
            )

        )
       
    )
)


; Helper function to find the intersection between two tuples
(= (findIntersection $lit $common)
    (if (== $lit ())
        $common
        (collapse (intersection (superpose $lit) (superpose $common)))
    )
)

;a function to remove common literals from a nested tuple
(= (removeCommonLiterals $common $tuple)
   ( if (== $tuple ())
        ()
        (collapse (removeElement $common (superpose $tuple)))
   )
)

;a function to remove a common element from a tuple
(= (removeElement $common $tuple) 
   (collapse (subtraction (superpose $tuple)  (superpose $common)))
)
