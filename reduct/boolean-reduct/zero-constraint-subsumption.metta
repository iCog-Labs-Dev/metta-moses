;a function which implements the 0-Constraint-Subsumption Transformation
(= (zeroConstraintSubsume $expOriginal $expRecursive)
(if (== $expRecursive ()) $expOriginal 
(let*
(
    ($head (car-atom $expRecursive))
    ($tail (cdr-atom $expRecursive))
    ($headType (get-metatype $head))
    ($headHasNoChild (not (nodeHasChildExp $head)))
)
(case $head
(
   (AND $expOriginal)
   (NOT $expOriginal)
   (OR (zeroConstraintSubsume $expOriginal $tail))  ;the POA for this transformation is any OR node
   ($else (if (and (== (getGuardSetExp $head $head ()) ()) $headHasNoChild)
              () ;if any child of the POA has an empty guardSet and no child, it is removed. if not, it's kept.
              (zeroConstraintSubsume $expOriginal $tail)
          ) 
    )
)  
)
)
)
)