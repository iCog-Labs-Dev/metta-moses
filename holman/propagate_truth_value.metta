!(register-module! ../../metta-moses-reduction)
!(import! &self metta-moses-reduction:utilities:helper-functions)
!(import! &self metta-moses-reduction:reduction:utils)

(=(propagate-truth-value $exp $truth-value)
    (case $exp(
        (($op $exp1 $exp2)
            (if (== $truth-value False)
                (if (== $op AND)
                    (OR (propagate-truth-value $exp2 (not $truth-value)))
                )
            )
        )

        )
    )
)