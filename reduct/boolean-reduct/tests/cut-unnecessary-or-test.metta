!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)
!(import! &self ../cut-unnecessary-or)
!(import! &self ../../../scoring/boolean-ops) ;; mirrors moses.metta: AND/OR/NOT become callable AFTER the reduct compiles

;Test 01: OR expressions with one child - orCut will be applied
!(assertEqual 
     (orCut (quote (AND $B (OR (AND (NOT $D))))) (quote (OR (AND (NOT $D)))))
     (quote ((AND $B (NOT $D)) () True))
)

!(assertEqual
    (orCut (quote (AND $C (OR $A))) (quote (OR $A)))
    (quote ((AND $C $A) () True))
)

!(assertEqual
     (orCut (quote (AND $H (OR (AND $A $B (AND $A $B))) (NOT $E))) (quote (OR (AND $A $B (AND $A $B)))))
     (quote ((AND $H (NOT $E) $A $B (AND $A $B)) () True))
)

!(assertEqual
     (orCut (quote (AND (OR (AND $A (NOT $A) (OR $A $B ))))) (quote (OR (AND $A (NOT $A) (OR $A $B )))))
     (quote ((AND $A (NOT $A) (OR $A $B)) () True))
)

!(assertEqual
    (orCut (quote (AND (OR (AND $A (OR $A (NOT $B)))))) (quote (OR (AND $A (OR $A (NOT $B))))))
    (quote ((AND $A (OR $A (NOT $B))) () True))
)

;Test 02:OR expression with more than one children - orCut won't be applied
!(assertEqual
     (orCut (quote (AND (OR $A $B))) (quote (OR $A $B)))
     (quote ((AND (OR $A $B)) (OR $A $B) False))
)
;Test 03: AND and NOT expressions - orCut won't be applied
!(assertEqual
    (orCut (quote (OR (AND (AND $A (OR $A (NOT $B)))))) (quote (AND (AND $A (OR $A (NOT $B))))))
    (quote ((OR (AND (AND $A (OR $A (NOT $B))))) (AND (AND $A (OR $A (NOT $B)))) False))
)
!(assertEqual
    (orCut (quote (AND (NOT (AND $A (OR $A (NOT $B)))))) (quote (NOT (AND $A (OR $A (NOT $B))))))
    (quote ((AND (NOT (AND $A (OR $A (NOT $B))))) (NOT (AND $A (OR $A (NOT $B)))) False))
)

!(assertEqual (orCut (quote (AND $A $B (OR $C $D))) ()) (quote ((AND $A $B (OR $C $D)) () False)))
