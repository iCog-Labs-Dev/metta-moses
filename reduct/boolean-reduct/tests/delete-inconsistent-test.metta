! (register-module! ../../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:delete-inconsistent-handle)

;; Testcases

;; Test 01 - for an empty set and literal
! (assertEqualToResult (deleteInconsistent ()) ( ()))
! (assertEqualToResult (deleteInconsistent (A)) ( (A)))
! (assertEqualToResult (deleteInconsistent A) ( A))

;; Test 02 - for OR and NOT expressions
! (assertEqualToResult (deleteInconsistent (NOT (AND A B))) ((NOT (AND A B))))
! (assertEqualToResult (deleteInconsistent (OR A B (NOT A))) ((OR A B (NOT A))))
! (assertEqualToResult (deleteInconsistent (OR (AND A B) (AND A B) (NOT A))) ( (OR (AND A B) (AND A B) (NOT A))))

;; Test 03 - for different AND expressions
! (assertEqualToResult (deleteInconsistent (AND)) ( (AND)))
! (assertEqualToResult (deleteInconsistent (AND (OR A B) (AND A B) A B)) ( (AND (OR A B) (AND A B) A B)))
! (assertEqualToResult (deleteInconsistent (AND (NOT A) (NOT B) A)) (()))
! (assertEqualToResult (deleteInconsistent (AND A (AND A B) (OR A B) (NOT B))) ( (AND A (AND A B) (OR A B) (NOT B))))
! (assertEqualToResult (deleteInconsistent (AND (AND A B) A)) ( (AND (AND A B) A)))
! (assertEqualToResult (deleteInconsistent (AND A B (NOT B))) ( ()))
! (assertEqualToResult (deleteInconsistent (AND A (NOT A) (NOT B))) ( ()))
