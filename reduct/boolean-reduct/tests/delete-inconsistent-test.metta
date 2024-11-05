! (register-module! ../../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:delete-inconsistent-handle)

;; Testcases

;; Test 01 - for an empty set and literal
! (assertEqualToResult (deleteInconsistentHandle () ()) ((() False)))
! (assertEqualToResult (deleteInconsistentHandle (A) (B C)) (((A) False)))
! (assertEqualToResult (deleteInconsistentHandle (A) (A B C)) (((A) False)))
! (assertEqualToResult (deleteInconsistentHandle (A) ((NOT A) B C)) ((() True)))
! (assertEqualToResult (deleteInconsistentHandle (A) (B C (NOT A))) ((() True)))
! (assertEqualToResult (deleteInconsistentHandle A (B C)) ((A False)))

;; Test 02 - for OR and NOT expressions
! (assertEqualToResult (deleteInconsistentHandle (NOT (AND A B)) ()) (((NOT (AND A B)) False)))
! (assertEqualToResult (deleteInconsistentHandle (OR A B (NOT A)) ()) (((OR A B (NOT A)) False)))
! (assertEqualToResult (deleteInconsistentHandle (OR A B) ((NOT A) B)) (((OR A B) False)))
! (assertEqualToResult (deleteInconsistentHandle (OR (AND A B) (AND A B) (NOT A)) ()) (((OR (AND A B) (AND A B) (NOT A)) False)))

;; Test 03 - for different AND expressions
! (assertEqualToResult (deleteInconsistentHandle (AND) ()) (((AND) False)))
! (assertEqualToResult (deleteInconsistentHandle (AND (OR A B) (AND A B) A B) ()) (((AND (OR A B) (AND A B) A B) False)))
! (assertEqualToResult (deleteInconsistentHandle (AND (OR A B) (AND A B) A B) ((NOT B) A C)) ((() True)))
! (assertEqualToResult (deleteInconsistentHandle (AND (NOT A) (NOT B) A) ()) ((() True)))
! (assertEqualToResult (deleteInconsistentHandle (AND (NOT A) (NOT B) C) ()) (((AND (NOT A) (NOT B) C) False)))
! (assertEqualToResult (deleteInconsistentHandle (AND (NOT A) (NOT B) C) (F B G)) ((() True)))
! (assertEqualToResult (deleteInconsistentHandle (AND A (AND A B) (OR A B) (NOT B)) ()) (((AND A (AND A B) (OR A B) (NOT B)) False)))
! (assertEqualToResult (deleteInconsistentHandle (AND A (AND A B) (OR A B) (NOT B)) (B C E)) ((() True)))
! (assertEqualToResult (deleteInconsistentHandle (AND A (AND A B) (NOT E) (OR A B) (NOT B)) (C E)) ((() True)))
! (assertEqualToResult (deleteInconsistentHandle (AND (AND A B) A) ()) (((AND (AND A B) A) False)))
! (assertEqualToResult (deleteInconsistentHandle (AND (AND A B) A) ((NOT B))) (((AND (AND A B) A) False)))
! (assertEqualToResult (deleteInconsistentHandle (AND A B (NOT B)) ()) ((() True)))
! (assertEqualToResult (deleteInconsistentHandle (AND A (NOT B)) (B)) ((() True)))
! (assertEqualToResult (deleteInconsistentHandle (AND A (NOT B)) (A)) (((AND A (NOT B)) False)))
! (assertEqualToResult (deleteInconsistentHandle (AND A (NOT B)) (D F G)) (((AND A (NOT B)) False)))
! (assertEqualToResult (deleteInconsistentHandle (AND A (NOT A) (NOT B)) ()) ((() True)))
! (assertEqualToResult (deleteInconsistentHandle (AND (NOT A) (NOT B)) (C F A G)) ((() True)))
! (assertEqualToResult (deleteInconsistentHandle (AND (NOT A) (NOT B)) (C B F G)) ((() True)))
! (assertEqualToResult (deleteInconsistentHandle (AND (NOT A) (NOT B)) (C B A G)) ((() True)))
! (assertEqualToResult (deleteInconsistentHandle (AND (NOT A) (NOT B) C G) (C B A G)) ((() True)))
