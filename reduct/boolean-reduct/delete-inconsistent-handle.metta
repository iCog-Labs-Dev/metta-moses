 ; a function which implements the Delete-Inconsistent-Handle Transformation
(= (deleteInconsistent $exp)
    (let*
        (
            ($guardSet (getGuardSetExpression $exp))
            ($isConsistent (isConsistentExp $guardSet))
        )
    (if $isConsistent $exp ())
)
)
