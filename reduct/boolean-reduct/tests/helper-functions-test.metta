!(import! &self ../../../utilities/general-helpers)
!(import! &self ../rte-helpers)
!(import! &self ../delete-inconsistent-handle)
!(import! &self ../zero-constraint-subsumption)
!(import! &self ../cut-unnecessary-or)

;; To keep the tests consistent with the usage these unit tests should be updated here
!(callPredicate (Predicate (consult "moses/tests/rte-helpers-fast.pl")))
!(import! &self ../../../scoring/boolean-ops) ;; mirrors moses.metta: AND/OR/NOT become callable AFTER the reduct compiles

;; Test for getGuardSet

;; Tests for new getGuardSet
;; Test 01 - getGuardSet of a literal
!(assertEqual (getGuardSet $A) $A)
!(assertEqual (getGuardSet ($A)) ($A))

;; Test 02 - getGuardSet of OR and NOT expressions
!(assertEqual (getGuardSet (quote (OR))) ())
!(assertEqual (getGuardSet (quote (OR $A $B (NOT $A)))) ())
!(assertEqual (getGuardSet (quote (OR (AND $A $B) (AND $A $B) (NOT $A)))) ())

;; Test 03 - getGuardSet of AND expressions
!(assertEqual (getGuardSet (quote (AND))) ())
!(assertEqual (getGuardSet (quote (AND $A))) ($A))
!(assertEqual (getGuardSet (quote (AND (NOT $A) (NOT $B) $A))) (quote ((NOT $A) (NOT $B) $A)))
!(assertEqual (getGuardSet (quote (AND $A (AND $A $B) (OR $A $B) (NOT $B)))) (quote ($A (NOT $B))))
!(assertEqual (getGuardSet (quote (AND (AND $A $B) $A)) ) ($A))
!(assertEqual (getGuardSet (quote (AND $A $B (NOT $B))) ) (quote ($A $B (NOT $B) )))
!(assertEqual (getGuardSet (quote (AND $A (NOT $A) (NOT $B)))) (quote ($A (NOT $A) (NOT $B) )))
!(assertEqual (getGuardSet (quote (AND (NOT $A) $A $B))) (quote ((NOT $A) $A $B)))

;; Tests for getGuardSetND
;; Test 01 - getGuardSet of a literal
!(assertEqual (getGuardSetND $A) $A)
!(assertEqual (getGuardSetND ($A)) $A)

;; Test 02 - getGuardSetND of OR and NOT expressions
!(assertEqual (collapse (getGuardSetND (quote (OR)))) ())
!(assertEqual (collapse (getGuardSetND (quote (OR $A $B (NOT $A))))) ())
!(assertEqual (collapse (getGuardSetND (quote (OR (AND $A $B) (AND $A $B) (NOT $A))))) ())

;; Test 03 - getGuardSetND of AND expressions
;; NOTE (labels-as-vars): `collapse` is findall, which copy-renames the
;; variables of every collected solution. An expected value that uses the
;; same label var more than once (e.g. $A inside (NOT $A) and again as a
;; bare literal) can therefore never match — the sharing is destroyed by
;; collapse itself, not by the helper. Those assertions are commented out
;; below (user-approved); the single-occurrence ones still run.
!(assertEqual (collapse (getGuardSetND (quote (AND)))) ())
!(assertEqual (collapse (getGuardSetND (quote (AND $A)))) ($A))
;; !(assertEqual (collapse (getGuardSetND (quote (AND (NOT $A) (NOT $B) $A)))) ((quote (NOT $A)) (quote (NOT $B)) $A))
!(assertEqual (collapse (getGuardSetND (quote (AND $A (AND $A $B) (OR $A $B) (NOT $B))))) (quote ($A (NOT $B))))
!(assertEqual (collapse (getGuardSetND (quote (AND (AND $A $B) $A)))) ($A))
;; !(assertEqual (collapse (getGuardSetND (quote (AND $A $B (NOT $B))))) ($A $B (quote (NOT $B))))
;; !(assertEqual (collapse (getGuardSetND (quote (AND $A (NOT $A) (NOT $B))))) ($A (quote (NOT $A)) (quote (NOT $B))))
;; !(assertEqual (collapse (getGuardSetND (quote (AND (NOT $A) $A $B)))) ((quote (NOT $A)) $A $B))

;; Test for isConsistentExp ;; Not Tested because it uses deleteInconsistentHandle
!(assertEqual (isConsistentExp ()) True)
!(assertEqual (isConsistentExp $A) True)
!(assertEqual (isConsistentExp ($A)) True)
!(assertEqual (isConsistentExp (quote (AND))) True)
!(assertEqual (isConsistentExp (quote (AND (OR $A $B) (AND $A $B) $A $B))) True)
!(assertEqual (isConsistentExp (quote (AND (NOT $A) (NOT $B) $A))) False)
!(assertEqual (isConsistentExp (quote (AND $A $B (NOT $B)))) False)
!(assertEqual (isConsistentExp (quote (OR $A $B (NOT $A)))) False)
!(assertEqual (isConsistentExp (quote (OR (AND $A $B) (AND $A $B) (NOT $A)))) True)
!(assertEqual (isConsistentExp (quote (AND $A (NOT $A) (NOT $B)))) False)

!(assertEqual (nodeHasChildOrGuard (quote (AND $A $B))) True)
!(assertEqual (nodeHasChildOrGuard (quote (AND $A $B $C))) True)
!(assertEqual (nodeHasChildOrGuard (quote (OR $A $B $C))) True)
!(assertEqual (nodeHasChildOrGuard (quote (AND))) False)

;; Test for filterLiterals
!(assertEqual (filterLiterals $A) $A)
!(assertEqual (collapse (filterLiterals (quote (AND $A $B $C)))) (collapse (empty)))
!(assertEqual (filterLiterals (quote (NOT $A))) (quote (NOT $A)))
!(assertEqual (collapse (filterLiterals AND)) ())
!(assertEqual (collapse (filterLiterals OR)) (collapse (empty)))

;; Test for filterChildren

!(assertEqual (collapse (filterChildren $A)) (collapse (empty)))
!(assertEqual (collapse (filterChildren (quote (NOT $A)))) (collapse (empty)))
!(assertEqual (filterChildren (quote (OR $A $B $C))) (quote (OR $A $B $C)))
!(assertEqual (filterChildren (quote (AND $A $B $C))) (quote (AND $A $B $C)))
!(assertEqual (filterChildren (quote (OR $A))) (quote (OR $A)))

;; Test for getChildren

!(assertEqual (getChildrenExp ()) ())
!(assertEqual (getChildrenExp (quote (AND $A $B (OR $A $B) $C $E (OR $E $F) (OR $A) (NOT $F)))) (quote ((OR $A $B) (OR $E $F) (OR $A))))
!(assertEqual (getChildrenExp (quote (AND (OR $A $B) $A $B $C $E (NOT $F) (OR $E $F) (OR $A)))) (quote ((OR $A $B) (OR $E $F) (OR $A))))
!(assertEqual (getChildrenExp (quote (OR $A $B (AND $A $B) $C $E (AND $E $F) (AND $A) (NOT $F)))) (quote ((AND $A $B) (AND $E $F) (AND $A))))
!(assertEqual (getChildrenExp (quote (OR (AND $A $B) $A $B $C $E (NOT $F) (AND $E $F) (AND $A)))) (quote ((AND $A $B) (AND $E $F) (AND $A))))

;; Test for getLiterals
!(assertEqual (getLiterals ()) ())
!(assertEqual (getLiterals (quote (AND $A))) ($A))
!(assertEqual (getLiterals (quote (OR $A))) ($A))
!(assertEqual (getLiterals (quote (AND $A $B (OR $A $B) $C $E (OR $E $F) (OR $A) (NOT $F)))) (quote ($A $B $C $E (NOT $F))))
!(assertEqual (getLiterals (quote (AND (OR $A $B) $A $B $C $E (NOT $F) (OR $E $F) (OR $A)))) (quote ($A $B $C $E (NOT $F))))
!(assertEqual (getLiterals (quote (OR $A $B (AND $A $B) $C $E (AND $E $F) (AND $A) (NOT $F)))) (quote ($A $B $C $E (NOT $F))))
!(assertEqual (getLiterals (quote (OR (AND $A $B) $A $B $C $E (NOT $F) (AND $E $F) (AND $A)))) (quote ($A $B $C $E (NOT $F))))


;; Test for getLiteralsND
!(assertEqual (collapse (getLiteralsND ())) (()))
!(assertEqual (collapse (getLiteralsND (quote (AND $A)))) ($A))
!(assertEqual (collapse (getLiteralsND (quote (OR $A)))) ($A))
!(assertEqual (collapse (getLiteralsND (quote (AND $A $B (OR $A $B) $C $E (OR $E $F) (OR $A) (NOT $F))))) (quote ($A $B $C $E (NOT $F))))
!(assertEqual (collapse (getLiteralsND (quote (AND (OR $A $B) $A $B $C $E (NOT $F) (OR $E $F) (OR $A))))) (quote ($A $B $C $E (NOT $F))))
!(assertEqual (collapse (getLiteralsND (quote (OR $A $B (AND $A $B) $C $E (AND $E $F) (AND $A) (NOT $F))))) (quote ($A $B $C $E (NOT $F))))
!(assertEqual (collapse (getLiteralsND (quote (OR (AND $A $B) $A $B $C $E (NOT $F) (AND $E $F) (AND $A))))) (quote ($A $B $C $E (NOT $F))))

;; Test for getLiteralChildren
!(assertEqual (getLiteralChildren ()) (() ()))
!(assertEqual (getLiteralChildren (quote (AND $A))) (($A) ()))
!(assertEqual (getLiteralChildren (quote (OR $A))) (($A) ()))
!(assertEqual (getLiteralChildren (quote (AND $A $B (OR $A $B) $C $E (OR $E $F) (OR $A) (NOT $F)))) (quote (($A $B $C $E (NOT $F)) ((OR $A $B) (OR $E $F) (OR $A)))))
!(assertEqual (getLiteralChildren (quote (AND (OR $A $B) $A $B $C $E (NOT $F) (OR $E $F) (OR $A)))) (quote (($A $B $C $E (NOT $F)) ((OR $A $B) (OR $E $F) (OR $A)))))
!(assertEqual (getLiteralChildren (quote (OR $A $B (AND $A $B) $C $E (AND $E $F) (AND $A) (NOT $F)))) (quote (($A $B $C $E (NOT $F)) ((AND $A $B) (AND $E $F) (AND $A)))))
!(assertEqual (getLiteralChildren (quote (OR (AND $A $B) $A $B $C $E (NOT $F) (AND $E $F) (AND $A)))) (quote (($A $B $C $E (NOT $F)) ((AND $A $B) (AND $E $F) (AND $A)))))

;; Test for addLiterals
!(assertEqual (addLiterals (quote (AND $A $B $C (OR $A $B) $E $F)) ($A $B $G)) (quote (AND $A $B $C $E $F $G (OR $A $B))))
!(assertEqual (addLiterals (quote (OR $A $B $C (AND $A $B) $E $F)) ($A $B $G)) (quote (OR $A $B $C $E $F $G (AND $A $B))))
!(assertEqual (addLiterals (quote (AND $A $B (OR $A $B))) ($Z)) (quote (AND $A $B $Z (OR $A $B))))
!(assertEqual (addLiterals (quote (OR (AND $A $B) $A $B)) ($Z)) (quote (OR $A $B $Z (AND $A $B))))
!(assertEqual (addLiterals (quote (AND $A $B $C (OR $A $B))) ($A $B $C)) (quote (AND $A $B $C (OR $A $B))))
!(assertEqual (addLiterals (quote (AND $A (OR $A $B) $B $C)) ($E $F $G)) (quote (AND $A $B $C $E $F $G (OR $A $B))))

;; Test for addChildren
!(assertEqual (addChildren (quote (AND $A $B $C)) ()) (quote (AND $A $B $C)))
!(assertEqual (addChildren (quote (OR $A $B $C)) ()) (quote (OR $A $B $C)))
!(assertEqual (addChildren (quote (OR)) (quote ((AND $B $C)))) (quote (OR (AND $B $C))))
!(assertEqual (addChildren (quote (AND)) (quote ((OR $B $C)))) (quote (AND (OR $B $C))))
!(assertEqual (addChildren (quote (AND (OR $A $B))) (quote ((OR $C $D) (OR $E $F)))) (quote (AND (OR $A $B) (OR $C $D) (OR $E $F))))
!(assertEqual (addChildren (quote (OR (AND $A $B))) (quote ((AND $C $D) (AND $E $F)))) (quote (OR (AND $A $B) (AND $C $D) (AND $E $F))))
!(assertEqual (addChildren (quote (AND $A $B $C (OR $A $B))) (quote ((OR $A $E) (OR $B $C) (OR $A $B $E (AND $A $F))))) (quote (AND $A $B $C (OR $A $B) (OR $A $E) (OR $B $C) (OR $A $B $E (AND $A $F)))))
!(assertEqual (addChildren (quote (OR $A $B $C (AND $A $B))) (quote ((AND $A $E) (AND $B $C) (AND $A $B $E (OR $A $F))))) (quote (OR $A $B $C (AND $A $B) (AND $A $E) (AND $B $C) (AND $A $B $E (OR $A $F)))))
!(assertEqual (addChildren (quote (AND $A (OR $A $B) $B $C)) (quote ((OR $B $C)))) (quote (AND $A $B $C (OR $A $B) (OR $B $C))))
!(assertEqual (addChildren (quote (OR $A (AND $A $B) $B $C)) (quote ((AND $B $C)))) (quote (OR $A $B $C (AND $A $B) (AND $B $C))))
!(assertEqual (addChildren (quote (OR $A $B $C)) (quote ((AND $A $E) (AND $B $C) (AND $A $B $E (OR $A $F))))) (quote (OR $A $B $C (AND $A $E) (AND $B $C) (AND $A $B $E (OR $A $F)))))

;; Test for foldl
!(assertEqual (foldl-l + 0 (1 2 3 4 5)) 15)
!(assertEqual (foldl-l * 1 (2 2 2 2)) 16)
!(assertEqual (foldl-l * 1 ()) 1)

;; Test for any
!(assertEqual (any (True False False)) True)
!(assertEqual (any (False True False)) True)
!(assertEqual (any (False False True)) True)
!(assertEqual (any (False False False)) False)
!(assertEqual (any (False False False False False False False)) False)
!(assertEqual (any (False False True False False False False)) True)

;; Test for getSubExpression ;; Not tested because it uses cutUnnecessaryOr
!(assertEqual (getSubExpression (quote (NOT $A))) ())
!(assertEqual (getSubExpression (quote (OR $A $B (AND $C $D) (AND $E $F)))) (quote ($A $B (AND $C $D) (AND $E $F))))
!(assertEqual (getSubExpression (quote (AND $A $B (OR $C $D) (OR $E $F)))) (quote ($A $B (OR $C $D) (OR $E $F))))
