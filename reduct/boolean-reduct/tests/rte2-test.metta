! (register-module! ../../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-or)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-and)
! (import! &self metta-moses:reduct:boolean-reduct:delete-inconsistent-handle)
! (import! &self metta-moses:reduct:boolean-reduct:zero-constraint-subsumption)
! (import! &self metta-moses:reduct:boolean-reduct:one-constraint-subsumption)
! (import! &self metta-moses:reduct:boolean-reduct:promote-common-constraints)
! (import! &self metta-moses:reduct:boolean-reduct:reduce-to-elegance)


;; Test for filterTerminal function

!(assertEqualToResult (filterTerminalAndNode (AND A)) ((AND A)))
!(assertEqualToResult (filterTerminalAndNode (AND (NOT A))) ((AND (NOT A))))
!(assertEqualToResult (filterTerminalAndNode (AND A B (OR A B))) ())
!(assertEqualToResult (filterTerminalAndNode (AND A (NOT B) (OR A B))) ())
!(assertEqualToResult (filterTerminalAndNode (AND A (OR A B))) ())
!(assertEqualToResult (filterTerminalAndNode (AND (NOT A) (OR A B))) ())
!(assertEqualToResult (filterTerminalAndNode (AND (OR A B))) ())
!(assertEqualToResult (filterTerminalAndNode (AND (OR A B) (OR C D))) ())
!(assertEqualToResult (filterTerminalAndNode (AND)) ())
!(assertEqualToResult (filterTerminalAndNode (OR A)) ())
!(assertEqualToResult (filterTerminalAndNode (OR (NOT A))) ())
!(assertEqualToResult (filterTerminalAndNode (OR A B (AND A B))) ())
!(assertEqualToResult (filterTerminalAndNode (OR A (NOT B) (AND A B))) ())
!(assertEqualToResult (filterTerminalAndNode (OR A (AND A B))) ())
!(assertEqualToResult (filterTerminalAndNode (OR (NOT A) (AND A B))) ())
!(assertEqualToResult (filterTerminalAndNode (OR (AND A B))) ())
!(assertEqualToResult (filterTerminalAndNode (OR (AND A B) (AND C D))) ())
!(assertEqualToResult (filterTerminalAndNode (OR)) ())

;; Test for applyOrCut function

!(assertEqual (applyOrCut ((AND A (OR A) (OR A B) (OR C D) (OR E)) False ((OR A) ((OR A B) (OR C D) (OR E))))) ((AND A (OR A B) (OR C D) (OR E)) True ((OR A B) ((OR C D) (OR E)))))
!(assertEqual (applyOrCut ((AND A (OR A B) (OR C D) (OR E)) False ((OR A B) ((OR C D) (OR E))))) ((AND A (OR A B) (OR C D) (OR E)) False ((OR C D) ((OR E)))))
!(assertEqual (applyOrCut ((AND A (OR A B) (OR C D) (OR E)) False ((OR E) ()))) ((AND A E (OR A B) (OR C D)) True (() ())))
!(assertEqual (applyOrCut ((AND A (OR A B) (OR C D)) False (() ()))) ((AND A (OR A B) (OR C D)) False (() ())))
!(assertEqual (applyOrCut ((AND A (OR A B) (OR C D)) True (() ()))) ((AND A (OR A B) (OR C D)) True (() ())))


;; Test for RTE transformations functions
;; Delete Inconsistent Handle Test
!(assertEqual (reduceToElegance (AND A (OR (AND B) (AND (NOT A) (OR (AND B) (AND C))))) (OR (AND B) (AND (NOT A) (OR (AND B) (AND C)))) (A) (B)) ((AND A ) () False))

;; Promote Common Constraints Test
!(assertEqual (reduceToElegance (AND A (OR (AND (NOT B) C) (AND (NOT B))) (OR (AND (NOT C)) (AND (NOT B) (NOT D)))) (OR (AND (NOT B) C) (AND (NOT B))) (A) ()) ((AND A (NOT B) (OR (AND (NOT C)) (AND (NOT B) (NOT D)))) () True))

;; Subtract Redundant Test
!(assertEqual (reduceToElegance (OR (AND A) (AND A C (NOT D))) (AND A C (NOT D)) ((NOT B) C A) (A (NOT E))) ((OR (AND A) (AND (NOT D))) (AND (NOT D)) True))

;; Cut unnecessary OR Test
!(assertEqual (reduceToElegance (AND B (OR (AND (NOT D)))) (OR (AND (NOT D))) (A B) ()) ((AND B (NOT D)) () True))

;; Cut unnecessary AND Test
!(assertEqual (reduceToElegance (OR (AND C) (AND (OR (AND (NOT E)) (AND B D)))) (AND (OR (AND (NOT E)) (AND B D))) (A) (C)) ((OR (AND C) (AND (NOT E)) (AND B D)) () False))

;; 0-Constraint Subsumption Test
!(assertEqual (reduceToElegance (AND A (OR (AND A) (AND (NOT B) (OR (AND E) (AND F)))) (OR (AND C) (AND))) (OR (AND C) (AND)) (A) ()) ((AND A (OR (AND A) (AND (NOT B) (OR (AND E) (AND F))))) () False))

;; 1-Constraint Subsumption Test
!(assertEqual (reduceToElegance (OR (AND C) (AND E D)) (AND E D) (A B) (C D)) ((OR (AND C) (AND E)) (AND E) True))

;; 1-Constraint Complement Subtraction Test
!(assertEqual (reduceToElegance (OR (AND D) (AND B C)) (AND B C) (A B) (D (NOT B))) ((OR (AND D) (AND C)) (AND C) True))


