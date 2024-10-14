! (register-module! ../../../../metta-moses) 
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-or)

!(assertEqualToResult 
     (orCut (OR (AND (NOT D)))) 
     ((((NOT D)) ((NOT D))))
)
!(assertEqualToResult 
     (orCut (OR (AND A B (AND A B)))) 
     (((B A) (A B (AND A B))))
)
!(assertEqualToResult 
     (orCut (OR A B)) 
     ((OR A B))
)
!(assertEqualToResult 
     (orCut (OR (AND A (NOT A) (OR A B )))) 
     ((((NOT A) A) (A (NOT A) (OR A B))))
)
!(assertEqualToResult
    (orCut (OR (AND A (OR A (NOT B)))))
    (((A) (A (OR A (NOT B)))))
)


