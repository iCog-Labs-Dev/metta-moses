! (register-module! ../../../../metta-moses) 

! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-and)



;; Test 01
!(assertEqual
    (andCut (OR A B (AND (OR (AND B C) (AND E F)))) (AND (OR (AND B C) (AND E F))))
    ((OR A B (AND B C) (AND E F)) () True)
)

;; Test 02
!(assertEqual
    (andCut (OR (AND (OR (AND C D) (AND C F))) A) (AND (OR (AND C D) (AND C F))))
    ((OR (AND (OR (AND C D) (AND C F))) A) (AND (OR (AND C D) (AND C F))) False)
)

;; Test 03
!(assertEqual
    (andCut (OR A (AND (OR (AND B C) (AND E F) (AND G H))) F) (AND (OR (AND B C) (AND E F) (AND G H))))
    ((OR A F (AND B C) (AND E F) (AND G H)) () True)
)

;; Test 04
!(assertEqual
    (andCut (OR (AND (OR (AND B C) (AND E F)) (OR (AND G H) (AND I J)))) (AND (OR (AND B C) (AND E F)) (OR (AND G H) (AND I J))))
    ((OR (AND (OR (AND B C) (AND E F)) (OR (AND G H) (AND I J)))) (AND (OR (AND B C) (AND E F)) (OR (AND G H) (AND I J))) False)
)

;; Test 05
!(assertEqual
    (andCut (OR A (AND (OR (AND B C) (AND (NOT E) F)))) (AND (OR (AND B C) (AND (NOT E) F))))
    ((OR A (AND B C) (AND (NOT E) F)) () True)
)

;; Test 06
!(assertEqual
    (andCut (OR A B (AND A D C (OR (AND B C) (AND E F))) C (NOT D)) (AND A D C (OR (AND B C) (AND E F))))
    ((OR A B (AND A D C (OR (AND B C) (AND E F))) C (NOT D)) (AND A D C (OR (AND B C) (AND E F))) False)
)

;;Test 07
!(assertEqual
    (andCut (OR (AND A (OR (AND (NOT B) C) (AND E F)))) (AND A (OR (AND (NOT B) C) (AND E F))))
    ((OR (AND A (OR (AND (NOT B) C) (AND E F)))) (AND A (OR (AND (NOT B) C) (AND E F))) False)
)

;; Test 08: Test case from Holman paper page 42
!(assertEqual
    (andCut (OR C (AND (OR (AND B D) (NOT E)))) (AND (OR (AND B D) (NOT E))))
    ((OR C (NOT E) (AND B D)) () True)
 )

;; Test 09
!(assertEqual
    (andCut (OR C (AND (OR A E (AND B D) (NOT E)))) (AND (OR A E (AND B D) (NOT E))))
    ((OR C A E (NOT E) (AND B D)) () True)
 )


;; Test 09
!(assertEqual
    (andCut (OR (AND (OR (AND B D) A (NOT E)))) (AND (OR (AND B D) A (NOT E))))
    ((OR A (NOT E) (AND B D)) () True)
 )
