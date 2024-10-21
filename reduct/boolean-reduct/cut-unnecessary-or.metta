;a function which implements the Cut-Unnecessary-OR Transformation
;POA: Any OR node
;If the POA has only 1 child, orCut returns the child's guardSet and children to the POA's parent
;EX: (OR (AND A (OR C D))) -> ( (A) (A (OR C D)) )
(= (orCut $exp)  
    (let*
        (
            ($op (car-atom $exp))
            ($children (cdr-atom $exp))
            ($child (car-atom $children)) 
            ($restChildren (cdr-atom $children))  
            ($grandChildren (if (== (get-metatype $child) Symbol) () (cdr-atom $child)))  
        )
        (case $op
        (
            (AND $exp)
            (NOT $exp)
            (OR (if (== $restChildren ()) $grandChildren $exp))
        )
        )           
    )
)