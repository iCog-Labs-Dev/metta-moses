! (register-module! ../../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:delete-inconsistent-handle)

;; Testcases

;; Test 01 - for an empty set and literal
! (assertEqualToResult (deleteInconsistentHandle () ()) (()))
! (assertEqualToResult (deleteInconsistentHandle (A) (B C)) ((A)))
! (assertEqualToResult (deleteInconsistentHandle (A) (A B C)) ((A)))
! (assertEqualToResult (deleteInconsistentHandle (A) ((NOT A) B C)) (()))
! (assertEqualToResult (deleteInconsistentHandle (A) (B C (NOT A))) (()))
! (assertEqualToResult (deleteInconsistentHandle A (B C)) (A))

;; Test 02 - for OR and NOT expressions
! (assertEqualToResult (deleteInconsistentHandle (NOT (AND A B)) ()) ((NOT (AND A B))))
! (assertEqualToResult (deleteInconsistentHandle (OR A B (NOT A)) ()) ((OR A B (NOT A))))
! (assertEqualToResult (deleteInconsistentHandle (OR A B) ((NOT A) B)) ((OR A B)))
! (assertEqualToResult (deleteInconsistentHandle (OR (AND A B) (AND A B) (NOT A)) ()) ((OR (AND A B) (AND A B) (NOT A))))

;; Test 03 - for different AND expressions
! (assertEqualToResult (deleteInconsistentHandle (AND) ()) ((AND)))
! (assertEqualToResult (deleteInconsistentHandle (AND (OR A B) (AND A B) A B) ()) ((AND (OR A B) (AND A B) A B)))
! (assertEqualToResult (deleteInconsistentHandle (AND (OR A B) (AND A B) A B) ((NOT B) A C)) (()))
! (assertEqualToResult (deleteInconsistentHandle (AND (NOT A) (NOT B) A) ()) (()))
! (assertEqualToResult (deleteInconsistentHandle (AND (NOT A) (NOT B) C) ()) ((AND (NOT A) (NOT B) C)))
! (assertEqualToResult (deleteInconsistentHandle (AND (NOT A) (NOT B) C) (F B G)) (()))
! (assertEqualToResult (deleteInconsistentHandle (AND A (AND A B) (OR A B) (NOT B)) ()) ((AND A (AND A B) (OR A B) (NOT B))))
! (assertEqualToResult (deleteInconsistentHandle (AND A (AND A B) (OR A B) (NOT B)) (B C E)) (()))
! (assertEqualToResult (deleteInconsistentHandle (AND A (AND A B) (NOT E) (OR A B) (NOT B)) (C E)) (()))
! (assertEqualToResult (deleteInconsistentHandle (AND (AND A B) A) ()) ((AND (AND A B) A)))
! (assertEqualToResult (deleteInconsistentHandle (AND (AND A B) A) ((NOT B))) ((AND (AND A B) A)))
! (assertEqualToResult (deleteInconsistentHandle (AND A B (NOT B)) ()) (()))
! (assertEqualToResult (deleteInconsistentHandle (AND A (NOT B)) (B)) (()))
! (assertEqualToResult (deleteInconsistentHandle (AND A (NOT B)) (A)) ((AND A (NOT B))))
! (assertEqualToResult (deleteInconsistentHandle (AND A (NOT B)) (D F G)) ((AND A (NOT B))))
! (assertEqualToResult (deleteInconsistentHandle (AND A (NOT A) (NOT B)) ()) (()))
! (assertEqualToResult (deleteInconsistentHandle (AND (NOT A) (NOT B)) (C F A G)) (()))
! (assertEqualToResult (deleteInconsistentHandle (AND (NOT A) (NOT B)) (C B F G)) (()))
! (assertEqualToResult (deleteInconsistentHandle (AND (NOT A) (NOT B)) (C B A G)) (()))
! (assertEqualToResult (deleteInconsistentHandle (AND (NOT A) (NOT B) C G) (C B A G)) (()))
