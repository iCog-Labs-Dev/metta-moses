(= (zeroConstraintSubsume $expOriginal $expRecursive)
(if (== $expRecursive ()) $expOriginal 
(let*
(
    ($head (car-atom $expRecursive))
    ($tail (cdr-atom $expRecursive))
    ($headType (get-metatype $head))
    ($headHasNoChild (not (nodeHasChildExp $head)))
)
(if (== $head AND) $expOriginal
    (if (== $head NOT) $expOriginal 
     (if (== $head OR) (zeroConstraintSubsume $expOriginal $tail)
      (if (and (== (getGuardSetExp $head $head ()) ()) $headHasNoChild)
         ()
         (zeroConstraintSubsume $expOriginal $tail)
      ) 
     )
    )    
)
)
)
)