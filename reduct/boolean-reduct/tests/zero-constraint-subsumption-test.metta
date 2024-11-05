! (register-module! ../../../../metta-moses) 

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:zero-constraint-subsumption)
 
;; Test 01
! (assertEqualToResult (zeroConstraintSubsume (AND (OR (AND A B) (AND))) (OR (AND A B) (AND))) (((AND) () True)))

;; Test 02
! (assertEqualToResult (zeroConstraintSubsume (AND (OR (AND A B) (OR))) (OR (AND A B) (OR))) (((AND) () True)))

;; Test 03
! (assertEqualToResult (zeroConstraintSubsume (AND (OR (AND A B) (A))) (OR (AND A B) (A))) (((AND (OR (AND A B) (A))) (OR (AND A B) (A)) False)))

;; Test 04
! (assertEqualToResult (zeroConstraintSubsume (AND (OR (AND A B) A)) (OR (AND A B) A)) (((AND (OR (AND A B) A)) (OR (AND A B) A) False)))

;; Test 05
! (assertEqualToResult (zeroConstraintSubsume (AND (OR (AND A B) (OR A B (AND A B C)) (NOT A))) (OR (AND A B) (OR A B (AND A B C)) (NOT A))) (((AND (OR (AND A B) (OR A B (AND A B C)) (NOT A))) (OR (AND A B) (OR A B (AND A B C)) (NOT A)) False)))

;; Test 06
! (assertEqualToResult (zeroConstraintSubsume (OR (AND A B)) (AND A B)) (((OR (AND A B)) (AND A B) False)))

;; Test 07
! (assertEqualToResult (zeroConstraintSubsume (AND (NOT (AND A B))) (NOT (AND A B))) (((AND (NOT (AND A B))) (NOT (AND A B)) False)))

;; Test 08
! (assertEqualToResult (zeroConstraintSubsume (AND (OR (OR (AND) A) (AND))) (OR (OR (AND) A) (AND))) (((AND) () True)))

;; Test 09
! (assertEqualToResult (zeroConstraintSubsume (OR (AND (OR) (OR (AND) B))) (AND (OR) (OR (AND) B))) (((OR (AND (OR) (OR (AND) B))) (AND (OR) (OR (AND) B)) False)))

;; Test 10: Test case from Holman paper page #43
! (assertEqualToResult (zeroConstraintSubsume (AND (OR C (AND))) (OR C (AND))) (((AND) () True)))
