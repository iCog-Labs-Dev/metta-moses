!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)
!(import! &self ../cut-unnecessary-or)
!(import! &self ../cut-unnecessary-and)
!(import! &self ../delete-inconsistent-handle)
!(import! &self ../zero-constraint-subsumption)
!(import! &self ../one-constraint-subsumption)
!(import! &self ../promote-common-constraints)
!(import! &self ../reduce-to-elegance)

;; Test for filterTerminal function

!(assertEqual (filterTerminalAndNode (AND A)) (AND A))
!(assertEqual (filterTerminalAndNode (AND (NOT A))) (AND (NOT A)))
!(assertEqual (collapse (filterTerminalAndNode (AND A B (OR A B)))) ())
!(assertEqual (collapse (filterTerminalAndNode (AND A (NOT B) (OR A B)))) ())
!(assertEqual (collapse (filterTerminalAndNode (AND A (OR A B)))) ())
!(assertEqual (collapse (filterTerminalAndNode (AND (NOT A) (OR A B)))) ())
!(assertEqual (collapse (filterTerminalAndNode (AND (OR A B)))) ())
!(assertEqual (collapse (filterTerminalAndNode (AND (OR A B) (OR C D)))) ())
!(assertEqual (collapse (filterTerminalAndNode (AND))) ())
!(assertEqual (collapse (filterTerminalAndNode (OR A))) ())
!(assertEqual (collapse (filterTerminalAndNode (OR (NOT A)))) ())
!(assertEqual (collapse (filterTerminalAndNode (OR A B (AND A B)))) ())
!(assertEqual (collapse (filterTerminalAndNode (OR A (NOT B) (AND A B)))) ())
!(assertEqual (collapse (filterTerminalAndNode (OR A (AND A B)))) ())
!(assertEqual (collapse (filterTerminalAndNode (OR (NOT A) (AND A B)))) ())
!(assertEqual (collapse (filterTerminalAndNode (OR (AND A B)))) ())
!(assertEqual (collapse (filterTerminalAndNode (OR (AND A B) (AND C D)))) ())
!(assertEqual (collapse (filterTerminalAndNode (OR))) ())

;; Test for applyOrCut function

!(assertEqual (applyOrCut ((AND A (OR A) (OR A B) (OR C D) (OR E)) False ((OR A) ((OR A B) (OR C D) (OR E))))) ((AND A (OR A B) (OR C D) (OR E)) True ((OR A B) ((OR C D) (OR E)))))
!(assertEqual (applyOrCut ((AND A (OR A B) (OR C D) (OR E)) False ((OR A B) ((OR C D) (OR E))))) ((AND A (OR A B) (OR C D) (OR E)) False ((OR C D) ((OR E)))))
!(assertEqual (applyOrCut ((AND A (OR A B) (OR C D) (OR E)) False ((OR E) ()))) ((AND A E (OR A B) (OR C D)) True (() ())))
!(assertEqual (applyOrCut ((AND A (OR A B) (OR C D)) False (() ()))) ((AND A (OR A B) (OR C D)) False (() ())))
!(assertEqual (applyOrCut ((AND A (OR A B) (OR C D)) True (() ()))) ((AND A (OR A B) (OR C D)) True (() ())))


;; Test for RTE transformations functions
;; Delete Inconsistent Handle Test
!(assertEqual (reduceToElegance (AND A (OR (AND B) (AND (NOT A) (OR (AND B) (AND C))))) (OR (AND B) (AND (NOT A) (OR (AND B) (AND C)))) (A) (B)) ((AND A ) () True))

;; Promote Common Constraints Test
!(assertEqual (reduceToElegance (AND A (OR (AND (NOT B) C) (AND (NOT B))) (OR (AND (NOT C)) (AND (NOT B) (NOT D)))) (OR (AND (NOT B) C) (AND (NOT B))) (A) ()) ((AND A (NOT B) (OR (AND (NOT C)) (AND (NOT B) (NOT D)))) () True))

;; Subtract Redundant Test
!(assertEqual (reduceToElegance (OR (AND A) (AND A C (NOT D))) (AND A C (NOT D)) ((NOT B) C A) (A (NOT E))) ((OR (AND A) (AND (NOT D))) (AND (NOT D)) True))

;; Cut unnecessary OR Test
!(assertEqual (reduceToElegance (AND B (OR (AND (NOT D)))) (OR (AND (NOT D))) (A B) ()) ((AND B (NOT D)) () True))

;; Cut unnecessary AND Test
!(assertEqual (reduceToElegance (OR (AND C) (AND (OR (AND (NOT E)) (AND B D)))) (AND (OR (AND (NOT E)) (AND B D))) (A) (C)) ((OR (AND C) (AND (NOT E)) (AND B D)) (AND C) False))

;; 0-Constraint Subsumption Test
!(assertEqual (reduceToElegance (AND A (OR (AND A) (AND (NOT B) (OR (AND E) (AND F)))) (OR (AND C) (AND))) (OR (AND C) (AND)) (A) ()) ((AND A (OR (AND A) (AND (NOT B) (OR (AND E) (AND F))))) () False))

;; 1-Constraint Subsumption Test
!(assertEqual (reduceToElegance (OR (AND C) (AND E D)) (AND E D) (A B) (C D)) ((OR (AND C) (AND E)) (AND E) True))

;; 1-Constraint Complement Subtraction Test
!(assertEqual (reduceToElegance (OR (AND D) (AND B C)) (AND B C) (A B) (D (NOT B))) ((OR (AND D) (AND C)) (AND C) True))


