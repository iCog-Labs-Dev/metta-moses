!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)
!(import! &self ../delete-inconsistent-handle)

; ;; Testcases

; ;; Test 01 - for an empty set and literal
!(assertEqual (deleteInconsistentHandle (AND) () ()) ((AND) () False))
!(assertEqual (deleteInconsistentHandle (AND (A)) (A) (B C)) ((AND (A)) (A) False))
!(assertEqual (deleteInconsistentHandle (AND (A)) (A) (B C)) ((AND (A)) (A) False))
!(assertEqual (deleteInconsistentHandle (AND (A)) (A) ((NOT A) B C)) ((AND (AND)) (AND) True)) ;; replaces A with AND
!(assertEqual (deleteInconsistentHandle (AND (A)) (A) (B C (NOT A))) ((AND (AND)) (AND) True)) ;; 
!(assertEqual (deleteInconsistentHandle (AND A) A (B C)) ((AND A) A False))

;; Test 02 - for OR and NOT expressions
!(assertEqual (deleteInconsistentHandle (AND (NOT (AND A B))) (NOT (AND A B)) ()) ((AND (NOT (AND A B))) (NOT (AND A B)) False))
!(assertEqual (deleteInconsistentHandle (AND (OR A B (NOT A))) (OR A B (NOT A)) ()) ((AND (OR A B (NOT A))) (OR A B (NOT A)) False))
!(assertEqual (deleteInconsistentHandle (AND (OR A B)) (OR A B) ((NOT A) B)) ((AND (OR A B)) (OR A B) False))
!(assertEqual (deleteInconsistentHandle (AND (OR (AND A B) (AND A B) (NOT A))) (OR (AND A B) (AND A B) (NOT A)) ()) ((AND (OR (AND A B) (AND A B) (NOT A))) (OR (AND A B) (AND A B) (NOT A)) False))

;; Test 03 - for different AND expressions
!(assertEqual (deleteInconsistentHandle (OR (AND)) (AND) ()) ((OR (AND)) (AND) False))
!(assertEqual (deleteInconsistentHandle (OR (AND (OR A B) (AND A B) A B)) (AND (OR A B) (AND A B) A B) ()) ((OR (AND (OR A B) (AND A B) A B)) (AND (OR A B) (AND A B) A B) False))
!(assertEqual (deleteInconsistentHandle (OR (AND (OR A B) (AND A B) A B)) (AND (OR A B) (AND A B) A B) ((NOT B) A C)) ((OR (AND)) (AND) True)) ;; replaces the entire child of the OR to (AND) 
!(assertEqual (deleteInconsistentHandle (OR (AND (NOT A) (NOT B) A)) (AND (NOT A) (NOT B) A) ()) ((OR (AND)) (AND) True)) ;; same with the above
!(assertEqual (deleteInconsistentHandle (OR A B (AND E A) (AND (NOT A) (NOT B) C)) (AND (NOT A) (NOT B) C) ()) ((OR A B (AND E A) (AND (NOT A) (NOT B) C)) (AND (NOT A) (NOT B) C) False))
!(assertEqual (deleteInconsistentHandle (OR A B (AND E A) (AND (NOT A) (NOT B) C)) (AND (NOT A) (NOT B) C) (F B G)) ((OR A B (AND E A) (AND)) (AND) True)) ;;
!(assertEqual (deleteInconsistentHandle (OR A B (AND A (AND A B) (OR A B) (NOT B))) (AND A (AND A B) (OR A B) (NOT B)) ()) ((OR A B (AND A (AND A B) (OR A B) (NOT B))) (AND A (AND A B) (OR A B) (NOT B)) False))
!(assertEqual (deleteInconsistentHandle (OR A B (AND A (AND A B) (OR A B) (NOT B))) (AND A (AND A B) (OR A B) (NOT B)) (B C E)) ((OR A B (AND)) (AND) True))
!(assertEqual (deleteInconsistentHandle (OR (AND A (AND A B) (NOT E) (OR A B) (NOT B))) (AND A (AND A B) (NOT E) (OR A B) (NOT B)) (C E)) ((OR (AND)) (AND) True))
!(assertEqual (deleteInconsistentHandle (OR (AND (AND A B) A)) (AND (AND A B) A) ()) ((OR (AND (AND A B) A)) (AND (AND A B) A) False))
!(assertEqual (deleteInconsistentHandle (OR (AND (AND A B) A)) (AND (AND A B) A) ((NOT B))) ((OR (AND (AND A B) A)) (AND (AND A B) A) False))
!(assertEqual (deleteInconsistentHandle (OR (AND A B (NOT B))) (AND A B (NOT B)) ()) ((OR (AND)) (AND) True))
!(assertEqual (deleteInconsistentHandle (OR (AND A (NOT B))) (AND A (NOT B)) (B)) ((OR (AND)) (AND) True))
!(assertEqual (deleteInconsistentHandle (OR (AND A (NOT B))) (AND A (NOT B)) (A)) ((OR (AND A (NOT B))) (AND A (NOT B)) False))
!(assertEqual (deleteInconsistentHandle (OR (AND A (NOT B))) (AND A (NOT B)) (D F G)) ((OR (AND A (NOT B))) (AND A (NOT B)) False))
!(assertEqual (deleteInconsistentHandle (OR (AND A (NOT A) (NOT B))) (AND A (NOT A) (NOT B)) ()) ((OR (AND)) (AND) True))
!(assertEqual (deleteInconsistentHandle (OR (AND (NOT A) (NOT B))) (AND (NOT A) (NOT B)) (C F A G)) ((OR (AND)) (AND) True))
!(assertEqual (deleteInconsistentHandle (OR (AND (NOT A) (NOT B))) (AND (NOT A) (NOT B)) (C B F G)) ((OR (AND)) (AND) True))
!(assertEqual (deleteInconsistentHandle (OR (AND (NOT A) (NOT B))) (AND (NOT A) (NOT B)) (C B A G)) ((OR (AND)) (AND) True))
!(assertEqual (deleteInconsistentHandle (OR (AND (NOT A) (NOT B) C G)) (AND (NOT A) (NOT B) C G) (C B A G)) ((OR (AND)) (AND) True))


!(assertEqual (applyDeleteIncons (OR (AND A B (NOT A) B)) (AND A B (NOT A) B) (A)) ((OR (AND)) (AND) True))
!(assertEqual (applyDeleteIncons (AND (OR (AND A B (NOT A) B))) (OR (AND A B (NOT A) B)) (A)) ((AND (OR (AND))) (OR (AND)) True))
