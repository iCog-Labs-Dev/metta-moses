!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)
!(import! &self ../delete-inconsistent-handle)
!(import! &self ../../../scoring/boolean-ops) ;; mirrors moses.metta: AND/OR/NOT become callable AFTER the reduct compiles

;; Testcases

;; ;; Test 01 - for an empty set and literal
!(assertEqual (deleteInconsistentHandle (quote (AND)) () ()) (quote ((AND) () False)))
!(assertEqual (deleteInconsistentHandle (quote (AND ($A))) ($A) ($B $C)) (quote ((AND ($A)) ($A) False)))
!(assertEqual (deleteInconsistentHandle (quote (AND ($A))) ($A) ($B $C)) (quote ((AND ($A)) ($A) False)))
!(assertEqual (deleteInconsistentHandle (quote (AND ($A))) ($A) (quote ((NOT $A) $B $C))) (quote ((AND) () True))) ;; replaces A with AND
!(assertEqual (deleteInconsistentHandle (quote (AND ($A))) ($A) (quote ($B $C (NOT $A)))) (quote ((AND) () True))) ;; 
!(assertEqual (deleteInconsistentHandle (quote (AND $A)) $A ($B $C)) (quote ((AND $A) $A False)))

;; Test 02 - for OR and NOT expressions
!(assertEqual (deleteInconsistentHandle (quote (AND (NOT (AND $A $B)))) (quote (NOT (AND $A $B))) ()) (quote ((AND (NOT (AND $A $B))) (NOT (AND $A $B)) False)))
!(assertEqual (deleteInconsistentHandle (quote (AND (OR $A $B (NOT $A)))) (quote (OR $A $B (NOT $A))) ()) (quote ((AND (OR $A $B (NOT $A))) (OR $A $B (NOT $A)) False)))
!(assertEqual (deleteInconsistentHandle (quote (AND (OR $A $B))) (quote (OR $A $B)) (quote ((NOT $A) $B))) (quote ((AND (OR $A $B)) (OR $A $B) False)))
!(assertEqual (deleteInconsistentHandle (quote (AND (OR (AND $A $B) (AND $A $B) (NOT $A)))) (quote (OR (AND $A $B) (AND $A $B) (NOT $A))) ()) (quote ((AND (OR (AND $A $B) (AND $A $B) (NOT $A))) (OR (AND $A $B) (AND $A $B) (NOT $A)) False)))

;; Test 03 - for different AND expressions
!(assertEqual (deleteInconsistentHandle (quote (OR (AND))) (quote (AND)) ()) (quote ((OR (AND)) (AND) False)))
!(assertEqual (deleteInconsistentHandle (quote (OR (AND (OR $A $B) (AND $A $B) $A $B))) (quote (AND (OR $A $B) (AND $A $B) $A $B)) ()) (quote ((OR (AND (OR $A $B) (AND $A $B) $A $B)) (AND (OR $A $B) (AND $A $B) $A $B) False)))
!(assertEqual (deleteInconsistentHandle (quote (OR (AND (OR $A $B) (AND $A $B) $A $B))) (quote (AND (OR $A $B) (AND $A $B) $A $B)) (quote ((NOT $B) $A $C))) (quote ((OR) () True))) ;; replaces the entire child of the OR to (AND) 
!(assertEqual (deleteInconsistentHandle (quote (OR (AND (NOT $A) (NOT $B) $A))) (quote (AND (NOT $A) (NOT $B) $A)) ()) (quote ((OR) () True))) ;; same with the above
!(assertEqual (deleteInconsistentHandle (quote (OR $A $B (AND $E $A) (AND (NOT $A) (NOT $B) $C))) (quote (AND (NOT $A) (NOT $B) $C)) ()) (quote ((OR $A $B (AND $E $A) (AND (NOT $A) (NOT $B) $C)) (AND (NOT $A) (NOT $B) $C) False)))
!(assertEqual (deleteInconsistentHandle (quote (OR $A $B (AND $E $A) (AND (NOT $A) (NOT $B) $C))) (quote (AND (NOT $A) (NOT $B) $C)) ($F $B $G)) (quote ((OR $A $B (AND $E $A)) () True))) ;;
!(assertEqual (deleteInconsistentHandle (quote (OR $A $B (AND $A (AND $A $B) (OR $A $B) (NOT $B)))) (quote (AND $A (AND $A $B) (OR $A $B) (NOT $B))) ()) (quote ((OR $A $B (AND $A (AND $A $B) (OR $A $B) (NOT $B))) (AND $A (AND $A $B) (OR $A $B) (NOT $B)) False)))
!(assertEqual (deleteInconsistentHandle (quote (OR $A $B (AND $A (AND $A $B) (OR $A $B) (NOT $B)))) (quote (AND $A (AND $A $B) (OR $A $B) (NOT $B))) ($B $C $E)) (quote ((OR $A $B) () True)))
!(assertEqual (deleteInconsistentHandle (quote (OR (AND $A (AND $A $B) (NOT $E) (OR $A $B) (NOT $B)))) (quote (AND $A (AND $A $B) (NOT $E) (OR $A $B) (NOT $B))) ($C $E)) (quote ((OR) () True)))
!(assertEqual (deleteInconsistentHandle (quote (OR (AND (AND $A $B) $A))) (quote (AND (AND $A $B) $A)) ()) (quote ((OR (AND (AND $A $B) $A)) (AND (AND $A $B) $A) False)))
!(assertEqual (deleteInconsistentHandle (quote (OR (AND (AND $A $B) $A))) (quote (AND (AND $A $B) $A)) (quote ((NOT $B)))) (quote ((OR (AND (AND $A $B) $A)) (AND (AND $A $B) $A) False)))
!(assertEqual (deleteInconsistentHandle (quote (OR (AND $A $B (NOT $B)))) (quote (AND $A $B (NOT $B))) ()) (quote ((OR) () True)))
!(assertEqual (deleteInconsistentHandle (quote (OR (AND $A (NOT $B)))) (quote (AND $A (NOT $B))) ($B)) (quote ((OR) () True)))
!(assertEqual (deleteInconsistentHandle (quote (OR (AND $A (NOT $B)))) (quote (AND $A (NOT $B))) ($A)) (quote ((OR (AND $A (NOT $B))) (AND $A (NOT $B)) False)))
!(assertEqual (deleteInconsistentHandle (quote (OR (AND $A (NOT $B)))) (quote (AND $A (NOT $B))) ($D $F $G)) (quote ((OR (AND $A (NOT $B))) (AND $A (NOT $B)) False)))
!(assertEqual (deleteInconsistentHandle (quote (OR (AND $A (NOT $A) (NOT $B)))) (quote (AND $A (NOT $A) (NOT $B))) ()) (quote ((OR) () True)))
!(assertEqual (deleteInconsistentHandle (quote (OR (AND (NOT $A) (NOT $B)))) (quote (AND (NOT $A) (NOT $B))) ($C $F $A $G)) (quote ((OR) () True)))
!(assertEqual (deleteInconsistentHandle (quote (OR (AND (NOT $A) (NOT $B)))) (quote (AND (NOT $A) (NOT $B))) ($C $B $F $G)) (quote ((OR) () True)))
!(assertEqual (deleteInconsistentHandle (quote (OR (AND (NOT $A) (NOT $B)))) (quote (AND (NOT $A) (NOT $B))) ($C $B $A $G)) (quote ((OR) () True)))
!(assertEqual (deleteInconsistentHandle (quote (OR (AND (NOT $A) (NOT $B) $C $G))) (quote (AND (NOT $A) (NOT $B) $C $G)) ($C $B $A $G)) (quote ((OR) () True)))


!(assertEqual (applyDeleteIncons (quote (OR (AND $A $B (NOT $A) $B))) (quote (AND $A $B (NOT $A) $B)) ($A)) (quote ((OR) () True)))
!(assertEqual (applyDeleteIncons (quote (AND (OR (AND $A $B (NOT $A) $B)))) (quote (OR (AND $A $B (NOT $A) $B))) ($A)) (quote ((AND (OR)) (OR) True)))
