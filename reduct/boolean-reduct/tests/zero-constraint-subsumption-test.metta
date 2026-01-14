!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)
!(import! &self ../zero-constraint-subsumption)
 
;; Test 01
!(assertEqual (zeroConstraintSubsume (AND (OR (AND A B) (AND))) (OR (AND A B) (AND))) ((AND) () True))

;; Test 02
!(assertEqual (zeroConstraintSubsume (AND (OR (AND A B) (OR))) (OR (AND A B) (OR))) ((AND) () True))

;; Test 03
!(assertEqual (zeroConstraintSubsume (AND (OR (AND A B) (A))) (OR (AND A B) (A))) ((AND (OR (AND A B) (A))) (OR (AND A B) (A)) False))

;; Test 04
!(assertEqual (zeroConstraintSubsume (AND (OR (AND A B) A)) (OR (AND A B) A)) ((AND (OR (AND A B) A)) (OR (AND A B) A) False))

;; Test 05
!(assertEqual (zeroConstraintSubsume (AND (OR (AND A B) (OR A B (AND A B C)) (NOT A))) (OR (AND A B) (OR A B (AND A B C)) (NOT A))) ((AND (OR (AND A B) (OR A B (AND A B C)) (NOT A))) (OR (AND A B) (OR A B (AND A B C)) (NOT A)) False))

;; Test 06
!(assertEqual (zeroConstraintSubsume (OR (AND A B)) (AND A B)) ((OR (AND A B)) (AND A B) False))

;; Test 07
!(assertEqual (zeroConstraintSubsume (AND (NOT (AND A B))) (NOT (AND A B))) ((AND (NOT (AND A B))) (NOT (AND A B)) False))

;; Test 08
!(assertEqual (zeroConstraintSubsume (AND (OR (OR (AND) A) (AND))) (OR (OR (AND) A) (AND))) ((AND) () True))

;; Test 09
!(assertEqual (zeroConstraintSubsume (OR (AND (OR) (OR (AND) B))) (AND (OR) (OR (AND) B))) ((OR (AND (OR) (OR (AND) B))) (AND (OR) (OR (AND) B)) False))

;; Test 10: Test case from Holman paper page #43
!(assertEqual (zeroConstraintSubsume (AND (OR C (AND))) (OR C (AND))) ((AND) () True))

;; Test case for AND node variation of 0Subsume 
;; Test 01
!(assertEqual (zeroConstraintSubsume' (OR A B (AND) (OR A B) F) (AND)) ((AND) (AND) True))

;; Test 02
!(assertEqual (zeroConstraintSubsume' (AND A B (OR) (AND A B) F) (OR)) ((AND A B (AND A B) F) () True))

;; Test 03
!(assertEqual (zeroConstraintSubsume' (OR A B (AND A) (OR A B) F) (AND A)) ((OR A B (AND A) (OR A B) F) (AND A) False))

;; Test 04
!(assertEqual (zeroConstraintSubsume' (OR A B (AND (OR)) (OR A B) F) (AND (OR))) ((OR A B (AND (OR)) (OR A B) F) (AND (OR)) False))

;; Test 05
!(assertEqual (zeroConstraintSubsume' (OR A B (AND A (OR)) (OR A B) F) (AND A (OR))) ((OR A B (AND A (OR)) (OR A B) F) (AND A (OR)) False))
