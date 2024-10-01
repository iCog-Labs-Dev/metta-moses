! (register-module! ../../../metta-moses-reduction) 
! (import! &self metta-moses-reduction:enf-reducer:rte-helpers)
! (import! &self metta-moses-reduction:utilities:general-helper-functions)
! (import! &self metta-moses-reduction:enf-reducer:delete-inconsistent-handle)

;Testcases
;Test 01 - for an empty set
 ! (assertEqualToResult (deleteInconsistent ()) ( ()))
 
;Test 02 - for OR and NOT expressions
 ! (assertEqualToResult (deleteInconsistent (NOT (OR A B) (AND A B))) ( (NOT (OR A B) (AND A B))))
 ! (assertEqualToResult (deleteInconsistent (OR A B (not A))) ( (OR A B (not A))))
 ! (assertEqualToResult (deleteInconsistent (OR (AND A B) (AND A B) (not A))) ( (OR (AND A B) (AND A B) (not A))))

;Test 03 - for different AND expressions
 ! (assertEqualToResult (deleteInconsistent (AND (OR A B) (AND A B) A B)) ( (AND (OR A B) (AND A B) A B)))
 ! (assertEqualToResult (deleteInconsistent (AND (not A) (not B) A)) ( ()))
 ! (assertEqualToResult (deleteInconsistent (AND A (AND A B) (OR A B) (not B))) ( (AND A (AND A B) (OR A B) (not B))))
 ! (assertEqualToResult (deleteInconsistent (AND (AND A B) A)) ( (AND (AND A B) A)))
 ! (assertEqualToResult (deleteInconsistent (AND A B (not B))) ( ()))
 ! (assertEqualToResult (deleteInconsistent (AND A (not A) (not B))) ( ()))
