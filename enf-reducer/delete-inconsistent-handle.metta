(= (deleteInconsistent $exp)
    (let*
        (
            ($guardSet (getGuardSetExp $exp $exp ()))
            ($isConsistent (isConsistentExp $guardSet))
        )
    (case $head
        (
            (AND (if $isConsistent $exp ()))
            (OR $exp)
            (NOT $exp)
        )
)
)
)

