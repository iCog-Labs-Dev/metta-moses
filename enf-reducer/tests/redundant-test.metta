! (register-module! ../../../metta-moses-reduction) 
! (import! &self metta-moses-reduction:enf-reducer:rte-helpers)
! (import! &self metta-moses-reduction:utilities:general-helper-functions)
! (import! &self metta-moses-reduction:enf-reducer:redundant)


;Testcases

; Test Case 1: Removing redundant constrient
! (assertEqual (removeRedundantConstrient (AND b (OR b c) (NOT a) (OR a (OR b (NOT a))))) (AND b (OR c) (NOT a) (OR a (OR))))
; Test Case 2: Removing redundant constrient
! (assertEqual (removeRedundantConstrient (AND a b (NOT a) (OR c (NOT a) (AND b a)))) (AND a b (NOT a) (OR c (AND))))


; Test Case 1: Remove 'b' from subexpressions
! (assertEqual (removeRedundancyFromSubExpressions b (AND b (AND b c) (NOT a) (OR a (OR b (NOT a))))) (AND b (AND c) (NOT a) (OR a (OR (NOT a)))))

; Test Case 2: Remove 'a' from subexpressions
! (assertEqual  (removeRedundancyFromSubExpressions a (AND a b (NOT a) (OR c (NOT b) (AND b a)))) (AND a b (NOT a) (OR c (NOT b) (AND b))))


; Test Case 1: remove 'b' from expression
! (assertEqual  (removeRedundant b (AND b (AND b c) (NOT a) (OR a (OR b (NOT a)))) ) (AND (AND c) (NOT a) (OR a (OR (NOT a)))))

; Test Case 2: remove 'a' from expression
! (assertEqual  (removeRedundant a (AND a b (NOT a) (OR c (NOT b) (AND b a)))) (AND b (NOT a) (OR c (NOT b) (AND b))))



