( (x1 AND x2 AND ( NOT(x3) OR NOT(x4) OR x5 ) AND (x3 OR (x3 AND x6))) 0R x7 )
NOT(a) AND (b OR c) -->  (NOT((a)) AND (bORc))

(OR
    (AND 
        (OR 
            (NOT x3)
            (NOT x4)
        )
        (OR
            x3
            (AND x3 x6)
        )
    )
    x7
)

(AND
    (NOT a)
    (OR b c)
)