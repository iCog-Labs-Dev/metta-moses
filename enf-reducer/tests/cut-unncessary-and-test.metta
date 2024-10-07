! (register-module! ../../../metta-moses-reduction) 
! (import! &self metta-moses-reduction:enf-reducer:rte-helpers)
! (import! &self metta-moses-reduction:utilities:general-helper-functions)
! (import! &self metta-moses-reduction:enf-reducer:cut-unnecessary-and)



    ;Test 01
!(assertEqual 
    (AndCut (AND (OR (AND B C) (AND E F))))
    ((AND B C) (AND E F))
)

    ;Test 02
!(assertEqual 
    (AndCut (AND (OR (AND C D) (AND C F))))
    (AND (OR (AND C D) (AND C F)))
)

    ;Test 03
!(assertEqual
    (AndCut (AND (OR (AND B C) (AND E F) (AND G H))))
    ((AND B C) (AND E F) (AND G H))
)

    ;Test 04
!(assertEqual
    (AndCut (AND (OR (AND B C) (AND E F)) (OR (AND G H) (AND I J))))
    (AndCut (AND (OR (AND B C) (AND E F)) (OR (AND G H) (AND I J))))
)

    ;Test 05
!(assertEqual
    (AndCut (AND (OR (AND B C) (AND (NOT E) F))))
    ((AND B C) (AND (NOT E) F))
)

    ;Test 06
!(assertEqual
    (AndCut (AND A D C (OR (AND B C) (AND E F))))
    (AND A D C (OR (AND B C) (AND E F)))
)
    
    ;Test 07
!(assertEqual
    (AndCut (AND A (OR (AND (NOT B) C) (AND E F))))
    (AND A (OR (AND (NOT B) C) (AND E F)))
)
