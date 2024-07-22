!(register-module! ../../metta-moses-reduction)
!(import! &self metta-moses-reduction:utilities:helper-functions)
!(import! &self metta-moses-reduction:reduction:utils)

(= (gather-junctors $exp)
    (case $exp(
        (($op $exp1 $exp2)
            (case $exp1(
                    (($op $exp3 $exp4)
                        ($op )
                    )
                )
            )
        )
    )
    )
)