! (register-module! ../../../../metta-moses) 
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-or)

;Test 01: OR expressions with one child - orCut will be applied
!(assertEqualToResult 
     (orCut (OR (AND (NOT D)))) 
     (((NOT D)))
)
!(assertEqualToResult
    (orCut (OR A))
    (())
)
!(assertEqualToResult 
     (orCut (OR (AND A B (AND A B)))) 
     ((A B (AND A B)))
)
!(assertEqualToResult 
     (orCut (OR (AND A (NOT A) (OR A B )))) 
     ((A (NOT A) (OR A B)))
)
!(assertEqualToResult
    (orCut (OR (AND A (OR A (NOT B)))))
    ((A (OR A (NOT B))))
)
;Test 02:OR expression with morethan one children - orCut won't be applied
!(assertEqualToResult 
     (orCut (OR A B)) 
     ((OR A B))
)
;Test 03: AND and NOT expressions - orCut won't be applied
!(assertEqualToResult
    (orCut (AND (AND A (OR A (NOT B)))))
    ((AND (AND A (OR A (NOT B)))))
)
!(assertEqualToResult
    (orCut (NOT (AND A (OR A (NOT B)))))
    ((NOT (AND A (OR A (NOT B)))))
)