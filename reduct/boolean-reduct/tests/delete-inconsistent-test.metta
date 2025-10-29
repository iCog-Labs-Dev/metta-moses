! (register-module! ../../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct/boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct/boolean-reduct:delete-inconsistent-handle)

;; Testcases

;; Test 01 - for an empty set and literal
! (assertEqualToResult (deleteInconsistentHandle (AND) () ()) (((AND) () False)))
! (assertEqualToResult (deleteInconsistentHandle (AND (A)) (A) (B C)) (((AND (A)) (A) False)))
! (assertEqualToResult (deleteInconsistentHandle (AND (A)) (A) (B C)) (((AND (A)) (A) False)))
! (assertEqualToResult (deleteInconsistentHandle (AND (A)) (A) ((NOT A) B C)) (((AND (AND)) (AND) True))) ;; replaces A with AND
! (assertEqualToResult (deleteInconsistentHandle (AND (A)) (A) (B C (NOT A))) (((AND (AND)) (AND) True))) ;; 
! (assertEqualToResult (deleteInconsistentHandle (AND A) A (B C)) (((AND A) A False)))

;; Test 02 - for OR and NOT expressions
! (assertEqualToResult (deleteInconsistentHandle (AND (NOT (AND A B))) (NOT (AND A B)) ()) (((AND (NOT (AND A B))) (NOT (AND A B)) False)))
! (assertEqualToResult (deleteInconsistentHandle (AND (OR A B (NOT A))) (OR A B (NOT A)) ()) (((AND (OR A B (NOT A))) (OR A B (NOT A)) False)))
! (assertEqualToResult (deleteInconsistentHandle (AND (OR A B)) (OR A B) ((NOT A) B)) (((AND (OR A B)) (OR A B) False)))
! (assertEqualToResult (deleteInconsistentHandle (AND (OR (AND A B) (AND A B) (NOT A))) (OR (AND A B) (AND A B) (NOT A)) ()) (((AND (OR (AND A B) (AND A B) (NOT A))) (OR (AND A B) (AND A B) (NOT A)) False)))

;; Test 03 - for different AND expressions
! (assertEqualToResult (deleteInconsistentHandle (OR (AND)) (AND) ()) (((OR (AND)) (AND) False)))
! (assertEqualToResult (deleteInconsistentHandle (OR (AND (OR A B) (AND A B) A B)) (AND (OR A B) (AND A B) A B) ()) (((OR (AND (OR A B) (AND A B) A B)) (AND (OR A B) (AND A B) A B) False)))
! (assertEqualToResult (deleteInconsistentHandle (OR (AND (OR A B) (AND A B) A B)) (AND (OR A B) (AND A B) A B) ((NOT B) A C)) (((OR (AND)) (AND) True))) ;; replaces the entire child of the OR to (AND) 
! (assertEqualToResult (deleteInconsistentHandle (OR (AND (NOT A) (NOT B) A)) (AND (NOT A) (NOT B) A) ()) (((OR (AND)) (AND) True))) ;; same with the above
! (assertEqualToResult (deleteInconsistentHandle (OR A B (AND E A) (AND (NOT A) (NOT B) C)) (AND (NOT A) (NOT B) C) ()) (((OR A B (AND E A) (AND (NOT A) (NOT B) C)) (AND (NOT A) (NOT B) C) False)))
! (assertEqualToResult (deleteInconsistentHandle (OR A B (AND E A) (AND (NOT A) (NOT B) C)) (AND (NOT A) (NOT B) C) (F B G)) (((OR A B (AND E A) (AND)) (AND) True))) ;;
! (assertEqualToResult (deleteInconsistentHandle (OR A B (AND A (AND A B) (OR A B) (NOT B))) (AND A (AND A B) (OR A B) (NOT B)) ()) (((OR A B (AND A (AND A B) (OR A B) (NOT B))) (AND A (AND A B) (OR A B) (NOT B)) False)))
! (assertEqualToResult (deleteInconsistentHandle (OR A B (AND A (AND A B) (OR A B) (NOT B))) (AND A (AND A B) (OR A B) (NOT B)) (B C E)) (((OR A B (AND)) (AND) True)))
! (assertEqualToResult (deleteInconsistentHandle (OR (AND A (AND A B) (NOT E) (OR A B) (NOT B))) (AND A (AND A B) (NOT E) (OR A B) (NOT B)) (C E)) (((OR (AND)) (AND) True)))
! (assertEqualToResult (deleteInconsistentHandle (OR (AND (AND A B) A)) (AND (AND A B) A) ()) (((OR (AND (AND A B) A)) (AND (AND A B) A) False)))
! (assertEqualToResult (deleteInconsistentHandle (OR (AND (AND A B) A)) (AND (AND A B) A) ((NOT B))) (((OR (AND (AND A B) A)) (AND (AND A B) A) False)))
! (assertEqualToResult (deleteInconsistentHandle (OR (AND A B (NOT B))) (AND A B (NOT B)) ()) (((OR (AND)) (AND) True)))
! (assertEqualToResult (deleteInconsistentHandle (OR (AND A (NOT B))) (AND A (NOT B)) (B)) (((OR (AND)) (AND) True)))
! (assertEqualToResult (deleteInconsistentHandle (OR (AND A (NOT B))) (AND A (NOT B)) (A)) (((OR (AND A (NOT B))) (AND A (NOT B)) False)))
! (assertEqualToResult (deleteInconsistentHandle (OR (AND A (NOT B))) (AND A (NOT B)) (D F G)) (((OR (AND A (NOT B))) (AND A (NOT B)) False)))
! (assertEqualToResult (deleteInconsistentHandle (OR (AND A (NOT A) (NOT B))) (AND A (NOT A) (NOT B)) ()) (((OR (AND)) (AND) True)))
! (assertEqualToResult (deleteInconsistentHandle (OR (AND (NOT A) (NOT B))) (AND (NOT A) (NOT B)) (C F A G)) (((OR (AND)) (AND) True)))
! (assertEqualToResult (deleteInconsistentHandle (OR (AND (NOT A) (NOT B))) (AND (NOT A) (NOT B)) (C B F G)) (((OR (AND)) (AND) True)))
! (assertEqualToResult (deleteInconsistentHandle (OR (AND (NOT A) (NOT B))) (AND (NOT A) (NOT B)) (C B A G)) (((OR (AND)) (AND) True)))
! (assertEqualToResult (deleteInconsistentHandle (OR (AND (NOT A) (NOT B) C G)) (AND (NOT A) (NOT B) C G) (C B A G)) (((OR (AND)) (AND) True)))


!(assertEqualToResult (applyDeleteIncons (OR (AND A B (NOT A) B)) (AND A B (NOT A) B) (A)) (((OR (AND)) (AND) True)))
!(assertEqualToResult (applyDeleteIncons (AND (OR (AND A B (NOT A) B))) (OR (AND A B (NOT A) B)) (A)) (((AND (OR (AND))) (OR (AND)) True)))
