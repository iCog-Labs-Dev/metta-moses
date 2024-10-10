! (register-module! ../../../../metta-moses) 

! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-and)



;; Test 01
!(assertEqual
    (andCut (AND (OR (AND B C) (AND E F))))
    ((AND B C) (AND E F))
)

;; Test 02
!(assertEqual
    (andCut (AND (OR (AND C D) (AND C F))))
    (AND (OR (AND C D) (AND C F)))
)

;; Test 03
!(assertEqual
    (andCut (AND (OR (AND B C) (AND E F) (AND G H))))
    ((AND B C) (AND E F) (AND G H))
)

;; Test 04
!(assertEqual
    (andCut (AND (OR (AND B C) (AND E F)) (OR (AND G H) (AND I J))))
    (AND (OR (AND B C) (AND E F)) (OR (AND G H) (AND I J)))
)

;; Test 05
!(assertEqual
    (andCut (AND (OR (AND B C) (AND (NOT E) F))))
    ((AND B C) (AND (NOT E) F))
)

;; Test 06
!(assertEqual
    (andCut (AND A D C (OR (AND B C) (AND E F))))
    (AND A D C (OR (AND B C) (AND E F)))
)

;;Test 07
!(assertEqual
    (andCut (AND A (OR (AND (NOT B) C) (AND E F))))
    (AND A (OR (AND (NOT B) C) (AND E F)))
)
