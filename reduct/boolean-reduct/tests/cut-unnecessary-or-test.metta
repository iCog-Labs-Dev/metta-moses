! (register-module! ../../../../metta-moses) 
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-or)

;Test 01: OR expressions with one child - orCut will be applied
!(assertEqualToResult 
     (orCut (AND B (OR (AND (NOT D)))) (OR (AND (NOT D))))
     (((AND B (NOT D)) () True))
)

!(assertEqualToResult
    (orCut (AND C (OR A)) (OR A))
    (((AND C A) () True))
)

!(assertEqualToResult
     (orCut (AND H (OR (AND A B (AND A B))) (NOT E)) (OR (AND A B (AND A B))))
     (((AND H (NOT E) A B (AND A B)) () True))
)

!(assertEqualToResult
     (orCut (AND (OR (AND A (NOT A) (OR A B )))) (OR (AND A (NOT A) (OR A B ))))
     (((AND A (NOT A) (OR A B)) () True))
)

!(assertEqualToResult
    (orCut (AND (OR (AND A (OR A (NOT B))))) (OR (AND A (OR A (NOT B)))))
    (((AND A (OR A (NOT B))) () True))
)

;Test 02:OR expression with more than one children - orCut won't be applied
!(assertEqualToResult
     (orCut (AND (OR A B)) (OR A B))
     (((AND (OR A B)) (OR A B) False))
)
;Test 03: AND and NOT expressions - orCut won't be applied
!(assertEqualToResult
    (orCut (OR (AND (AND A (OR A (NOT B))))) (AND (AND A (OR A (NOT B)))))
    (((OR (AND (AND A (OR A (NOT B))))) (AND (AND A (OR A (NOT B)))) False))
)
!(assertEqualToResult
    (orCut (AND (NOT (AND A (OR A (NOT B))))) (NOT (AND A (OR A (NOT B)))))
    (((AND (NOT (AND A (OR A (NOT B))))) (NOT (AND A (OR A (NOT B)))) False))
)

!(assertEqualToResult (orCut (AND A B (OR C D)) ()) (((AND A B (OR C D)) () False)))
