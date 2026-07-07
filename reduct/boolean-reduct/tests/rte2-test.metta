!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)
!(import! &self ../cut-unnecessary-or)
!(import! &self ../cut-unnecessary-and)
!(import! &self ../delete-inconsistent-handle)
!(import! &self ../zero-constraint-subsumption)
!(import! &self ../one-constraint-subsumption)
!(import! &self ../promote-common-constraints)
!(import! &self ../reduce-to-elegance)
!(import! &self ../../../scoring/boolean-ops) ;; mirrors moses.metta: AND/OR/NOT become callable AFTER the reduct compiles

;; Test for filterTerminal function

!(assertEqual (filterTerminalAndNode (quote (AND $A))) True)
!(assertEqual (filterTerminalAndNode (quote (AND (NOT $A)))) True)
!(assertEqual (filterTerminalAndNode (quote (AND $A $B (OR $A $B)))) False)
!(assertEqual (filterTerminalAndNode (quote (AND $A (NOT $B) (OR $A $B)))) False)
!(assertEqual (filterTerminalAndNode (quote (AND $A (OR $A $B)))) False)
!(assertEqual (filterTerminalAndNode (quote (AND (NOT $A) (OR $A $B)))) False)
!(assertEqual (filterTerminalAndNode (quote (AND (OR $A $B)))) False)
!(assertEqual (filterTerminalAndNode (quote (AND (OR $A $B) (OR $C $D)))) False)
!(assertEqual (filterTerminalAndNode (quote (AND))) False)
!(assertEqual (filterTerminalAndNode (quote (OR $A))) False)
!(assertEqual (filterTerminalAndNode (quote (OR (NOT $A)))) False)
!(assertEqual (filterTerminalAndNode (quote (OR $A $B (AND $A $B)))) False)
!(assertEqual (filterTerminalAndNode (quote (OR $A (NOT $B) (AND $A $B)))) False)
!(assertEqual (filterTerminalAndNode (quote (OR $A (AND $A $B)))) False)
!(assertEqual (filterTerminalAndNode (quote (OR (NOT $A) (AND $A $B)))) False)
!(assertEqual (filterTerminalAndNode (quote (OR (AND $A $B)))) False)
!(assertEqual (filterTerminalAndNode (quote (OR (AND $A $B) (AND $C $D)))) False)
!(assertEqual (filterTerminalAndNode (quote (OR))) False)

;; Test for applyOrCut function

!(assertEqual (applyOrCut (quote ((AND $A (OR $A) (OR $A $B) (OR $C $D) (OR $E)) False ((OR $A) ((OR $A $B) (OR $C $D) (OR $E)))))) (quote ((AND $A (OR $A $B) (OR $C $D) (OR $E)) True ((OR $A $B) ((OR $C $D) (OR $E))))))
!(assertEqual (applyOrCut (quote ((AND $A (OR $A $B) (OR $C $D) (OR $E)) False ((OR $A $B) ((OR $C $D) (OR $E)))))) (quote ((AND $A (OR $A $B) (OR $C $D) (OR $E)) False ((OR $C $D) ((OR $E))))))
!(assertEqual (applyOrCut (quote ((AND $A (OR $A $B) (OR $C $D) (OR $E)) False ((OR $E) ())))) (quote ((AND $A $E (OR $A $B) (OR $C $D)) True (() ()))))
!(assertEqual (applyOrCut (quote ((AND $A (OR $A $B) (OR $C $D)) False (() ())))) (quote ((AND $A (OR $A $B) (OR $C $D)) False (() ()))))
!(assertEqual (applyOrCut (quote ((AND $A (OR $A $B) (OR $C $D)) True (() ())))) (quote ((AND $A (OR $A $B) (OR $C $D)) True (() ()))))


;; Test for RTE transformations functions
;; Delete Inconsistent Handle Test
!(assertEqual (reduceToElegance (quote (AND $A (OR (AND $B) (AND (NOT $A) (OR (AND $B) (AND $C)))))) (quote (OR (AND $B) (AND (NOT $A) (OR (AND $B) (AND $C))))) ($A) ($B)) (quote ((AND $A ) () True)))

;; Promote Common Constraints Test
!(assertEqual (reduceToElegance (quote (AND $A (OR (AND (NOT $B) $C) (AND (NOT $B))) (OR (AND (NOT $C)) (AND (NOT $B) (NOT $D))))) (quote (OR (AND (NOT $B) $C) (AND (NOT $B)))) ($A) ()) (quote ((AND $A (NOT $B) (OR (AND (NOT $C)) (AND (NOT $B) (NOT $D))) $C) () True))) ;; FIX: Classic says this should be (AND)
;; Python's reduct says it should be (AND A (OR (AND (NOT B) C) (AND (NOT B))))

;; Subtract Redundant Test
!(assertEqual (reduceToElegance (quote (OR (AND $A) (AND $A $C (NOT $D)))) (quote (AND $A $C (NOT $D))) (quote ((NOT $B) $C $A)) (quote ($A (NOT $E)))) (quote ((OR (AND $A) (AND (NOT $D))) (AND (NOT $D)) True)))

;; Cut unnecessary OR Test
!(assertEqual (reduceToElegance (quote (AND $B (OR (AND (NOT $D))))) (quote (OR (AND (NOT $D)))) ($A $B) ()) (quote ((AND $B (NOT $D)) () True)))

;; Cut unnecessary AND Test
!(assertEqual (reduceToElegance (quote (OR (AND $C) (AND (OR (AND (NOT $E)) (AND $B $D))))) (quote (AND (OR (AND (NOT $E)) (AND $B $D)))) ($A) ($C)) (quote ((OR (AND $C) (AND (NOT $E)) (AND $B $D)) (AND $C) False)))

;; 0-Constraint Subsumption Test
!(assertEqual (reduceToElegance (quote (AND $A (OR (AND $A) (AND (NOT $B) (OR (AND $E) (AND $F)))) (OR (AND $C) (AND)))) (quote (OR (AND $C) (AND))) ($A) ()) (quote ((AND $A (OR (AND $A) (AND (NOT $B) (OR (AND $E) (AND $F)))) $C) () False))) ;; FIX: Classic says this should be (AND (OR (AND E) (AND F)) A (NOT B) C)
;; Python's reduct: (AND A (OR (AND A) (AND (NOT B) (OR (AND E) (AND F))))) 


;; 1-Constraint Subsumption Test
!(assertEqual (reduceToElegance (quote (OR (AND $C) (AND $E $D))) (quote (AND $E $D)) ($A $B) ($C $D)) (quote ((OR (AND $C) (AND $E)) (AND $E) True)))

;; 1-Constraint Complement Subtraction Test
!(assertEqual (reduceToElegance (quote (OR (AND $D) (AND $B $C))) (quote (AND $B $C)) ($A $B) (quote ($D (NOT $B)))) (quote ((OR (AND $D) (AND $C)) (AND $C) True)))


