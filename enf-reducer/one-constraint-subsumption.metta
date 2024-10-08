;a function which implements the 1-Constraint-Subsumption Transformation
(= (oneConstraintSubsume $expOriginal $expRecursive $commandSet) 
(let* 
  (
    ($head (car-atom $expRecursive))
    ($tail (cdr-atom $expRecursive))
  )
  (case $head
  (
    (OR $expOriginal)
    (NOT $expOriginal)
    (AND (oneConstraintSubsume $expOriginal $tail $commandSet)) ;the POA of this transformation is any non-root AND node
    ($else (if (isMember $head $commandSet) () $expOriginal)) ;if any constraint of the AND node is found inside the commandSet, the node is removed. if not, it is kept.
  )
  )
  )
)