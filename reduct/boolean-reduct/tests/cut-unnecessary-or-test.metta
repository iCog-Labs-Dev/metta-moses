! (register-module! ../../../../metta-moses) 
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-or)

;Test 01: OR expressions with one child - orCut will be applied
!(assertEqualToResult 
     (orCut (OR (AND (NOT D)))) 
     ((((NOT D)) True))
)
!(assertEqualToResult
    (orCut (OR A))
    ((() True))
)
!(assertEqualToResult 
     (orCut (OR (AND A B (AND A B)))) 
     (((A B (AND A B)) True))
)
!(assertEqualToResult 
     (orCut (OR (AND A (NOT A) (OR A B )))) 
     (((A (NOT A) (OR A B)) True))
)
!(assertEqualToResult
    (orCut (OR (AND A (OR A (NOT B)))))
    (((A (OR A (NOT B))) True))
)
;Test 02:OR expression with morethan one children - orCut won't be applied
!(assertEqualToResult 
     (orCut (OR A B)) 
     (((OR A B) False))
)
;Test 03: AND and NOT expressions - orCut won't be applied
!(assertEqualToResult
    (orCut (AND (AND A (OR A (NOT B)))))
    (((AND (AND A (OR A (NOT B)))) False))
)
!(assertEqualToResult
    (orCut (NOT (AND A (OR A (NOT B)))))
    (((NOT (AND A (OR A (NOT B)))) False))
)
