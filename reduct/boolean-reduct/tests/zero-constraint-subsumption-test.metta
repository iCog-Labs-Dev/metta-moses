!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)
!(import! &self ../zero-constraint-subsumption)
!(import! &self ../../../scoring/boolean-ops) ;; mirrors moses.metta: AND/OR/NOT become callable AFTER the reduct compiles
 
;; Test 01
!(assertEqual (zeroConstraintSubsume (quote (AND (OR (AND $A $B) (AND)))) (quote (OR (AND $A $B) (AND)))) (quote ((AND (OR (AND $A $B))) (OR (AND $A $B)) true)))

;; Test 02
!(assertEqual (zeroConstraintSubsume (quote (AND (OR (AND $A $B) (OR)))) (quote (OR (AND $A $B) (OR)))) (quote ((AND (OR (AND $A $B))) (OR (AND $A $B)) true)))

;; Test 03
!(assertEqual (zeroConstraintSubsume (quote (AND (OR (AND $A $B) ($A)))) (quote (OR (AND $A $B) ($A)))) (quote ((AND (OR (AND $A $B) ($A))) (OR (AND $A $B) ($A)) False)))

;; Test 04
!(assertEqual (zeroConstraintSubsume (quote (AND (OR (AND $A $B) $A))) (quote (OR (AND $A $B) $A))) (quote ((AND (OR (AND $A $B) $A)) (OR (AND $A $B) $A) false)))

;; Test 05
!(assertEqual (zeroConstraintSubsume (quote (AND (OR (AND $A $B) (OR $A $B (AND $A $B $C)) (NOT $A)))) (quote (OR (AND $A $B) (OR $A $B (AND $A $B $C)) (NOT $A)))) (quote ((AND (OR (AND $A $B) (OR $A $B (AND $A $B $C)) (NOT $A))) (OR (AND $A $B) (OR $A $B (AND $A $B $C)) (NOT $A)) false)))

;; Test 06
!(assertEqual (zeroConstraintSubsume (quote (OR (AND $A $B))) (quote (AND $A $B))) (quote ((OR (AND $A $B)) (AND $A $B) False)))

;; Test 07
!(assertEqual (zeroConstraintSubsume (quote (AND (NOT (AND $A $B)))) (quote (NOT (AND $A $B)))) (quote ((AND (NOT (AND $A $B))) (NOT (AND $A $B)) False)))

;; Test 08
!(assertEqual (zeroConstraintSubsume (quote (AND (OR (OR (AND) $A) (AND)))) (quote (OR (OR (AND) $A) (AND)))) (quote ((AND (OR (OR (AND) $A))) (OR (OR (AND) $A)) true)))

;; Test 09
!(assertEqual (zeroConstraintSubsume (quote (OR (AND (OR) (OR (AND) $B)))) (quote (AND (OR) (OR (AND) $B)))) (quote ((OR (AND (OR) (OR (AND) $B))) (AND (OR) (OR (AND) $B)) False)))

;; Test 10: Test case from Holman paper page #43
!(assertEqual (zeroConstraintSubsume (quote (AND (OR $C (AND)))) (quote (OR $C (AND)))) (quote ((AND (OR $C)) (OR $C) true))) ;; FIX: This test case shouldn't be like this. It should ideally be (AND (OR C)), right?

;; Test case for AND node variation of 0Subsume 
;; Test 01
!(assertEqual (zeroConstraintSubsume' (quote (OR $A $B (AND) (OR $A $B) $F)) (quote (AND))) (quote ((AND) (AND) True)))

;; Test 02
!(assertEqual (zeroConstraintSubsume' (quote (AND $A $B (OR) (AND $A $B) $F)) (quote (OR))) (quote ((AND $A $B (AND $A $B) $F) () True)))

;; Test 03
!(assertEqual (zeroConstraintSubsume' (quote (OR $A $B (AND $A) (OR $A $B) $F)) (quote (AND $A))) (quote ((OR $A $B (AND $A) (OR $A $B) $F) (AND $A) False)))

;; Test 04
!(assertEqual (zeroConstraintSubsume' (quote (OR $A $B (AND (OR)) (OR $A $B) $F)) (quote (AND (OR)))) (quote ((OR $A $B (AND (OR)) (OR $A $B) $F) (AND (OR)) False)))

;; Test 05
!(assertEqual (zeroConstraintSubsume' (quote (OR $A $B (AND $A (OR)) (OR $A $B) $F)) (quote (AND $A (OR)))) (quote ((OR $A $B (AND $A (OR)) (OR $A $B) $F) (AND $A (OR)) False)))
