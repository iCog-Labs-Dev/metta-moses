!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)
!(import! &self ../zero-constraint-subsumption)
 
;; Test 01
!(assertEqual (zeroConstraintSubsume (AND (OR (AND A B))) (OR (AND A B))) ((AND (OR (AND A B))) (OR (AND A B)) False)) ;; nothing to collapse: no constant present

;; Test 02
!(assertEqual (zeroConstraintSubsume (AND (OR (AND A B) (OR))) (OR (AND A B) (OR))) ((AND (OR (AND A B))) (OR (AND A B)) true))

;; Test 03
!(assertEqual (zeroConstraintSubsume (AND (OR (AND A B) (A))) (OR (AND A B) (A))) ((AND (OR (AND A B) (A))) (OR (AND A B) (A)) False))

;; Test 04
!(assertEqual (zeroConstraintSubsume (AND (OR (AND A B) A)) (OR (AND A B) A)) ((AND (OR (AND A B) A)) (OR (AND A B) A) false))

;; Test 05
!(assertEqual (zeroConstraintSubsume (AND (OR (AND A B) (OR A B (AND A B C)) (NOT A))) (OR (AND A B) (OR A B (AND A B C)) (NOT A))) ((AND (OR (AND A B) (OR A B (AND A B C)) (NOT A))) (OR (AND A B) (OR A B (AND A B C)) (NOT A)) false))

;; Test 06
!(assertEqual (zeroConstraintSubsume (OR (AND A B)) (AND A B)) ((OR (AND A B)) (AND A B) False))

;; Test 07
!(assertEqual (zeroConstraintSubsume (AND (NOT (AND A B))) (NOT (AND A B))) ((AND (NOT (AND A B))) (NOT (AND A B)) False))

;; Test 08
!(assertEqual (zeroConstraintSubsume (AND (OR A)) (OR A)) ((AND (OR A)) (OR A) False)) ;; ditto, once the nested placeholders are gone

;; Test 09
!(assertEqual (zeroConstraintSubsume (OR (AND (OR) B)) (AND (OR) B)) ((OR (OR)) (OR) True)) ;; a FALSE conjunct falsifies its AND, and false is the OR-identity

;; Test 10: Test case from Holman paper page #43
!(assertEqual (zeroConstraintSubsume (AND (OR C)) (OR C)) ((AND (OR C)) (OR C) False)) ;; ditto

;; Test case for AND node variation of 0Subsume 
;; Test 01
!(assertEqual (zeroConstraintSubsume' (OR A B (AND) (OR A B) F) (AND)) ((AND) (AND) True))

;; Test 02
!(assertEqual (zeroConstraintSubsume' (AND A B (OR) (AND A B) F) (OR)) ((AND A B (OR) (AND A B) F) (OR) False)) ;; a FALSE conjunct is kept, not dropped

;; Test 03
!(assertEqual (zeroConstraintSubsume' (OR A B (AND A) (OR A B) F) (AND A)) ((OR A B (AND A) (OR A B) F) (AND A) False))

;; Test 04
!(assertEqual (zeroConstraintSubsume' (OR A B (AND (OR)) (OR A B) F) (AND (OR))) ((OR A B (AND (OR)) (OR A B) F) (AND (OR)) False))

;; Test 05
!(assertEqual (zeroConstraintSubsume' (OR A B (AND A (OR)) (OR A B) F) (AND A (OR))) ((OR A B (AND A (OR)) (OR A B) F) (AND A (OR)) False))
