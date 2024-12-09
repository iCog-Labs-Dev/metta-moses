! (register-module! ../../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:delete-inconsistent-handle)
! (import! &self metta-moses:reduct:boolean-reduct:zero-constraint-subsumption)
! (import! &self metta-moses:reduct:boolean-reduct:cut-unnecessary-or)

 ;; Test for getGuardSet

 ;; Tests for new getGuardSet
 ;; Test 01 - getGuardSet of a literal
! (assertEqual (getGuardSet A) A)
! (assertEqualToResult (getGuardSet (A)) ((A)))

 ;; Test 02 - getGuardSet of OR and NOT expressions
! (assertEqualToResult (getGuardSet (OR)) ( ()))
! (assertEqualToResult (getGuardSet (OR A B (NOT A))) ( ()))
! (assertEqualToResult (getGuardSet (OR (AND A B) (AND A B) (NOT A))) ( ()))

 ;; Test 03 - getGuardSet of AND expressions
! (assertEqualToResult (getGuardSet (AND)) ( ()))
! (assertEqualToResult (getGuardSet (AND A)) ( (A)))
! (assertEqualToResult (getGuardSet (AND (NOT A) (NOT B) A)) ( ( (NOT A) (NOT B) A)))
! (assertEqualToResult (getGuardSet (AND A (AND A B) (OR A B) (NOT B))) ( ( A (NOT B))))
! (assertEqualToResult (getGuardSet (AND (AND A B) A) ) ( (A)))
! (assertEqualToResult (getGuardSet (AND A B (NOT B)) ) ( (  A B (NOT B) )))
! (assertEqualToResult (getGuardSet (AND A (NOT A) (NOT B))) ( ( A (NOT A) (NOT B) )))
! (assertEqualToResult (getGuardSet (AND (NOT A) A B)) ( ( (NOT A) A B)))

 ;; Tests for getGuardSetND
 ;; Test 01 - getGuardSet of a literal
! (assertEqual (getGuardSetND A) A)
! (assertEqualToResult (getGuardSetND (A)) (A))

 ;; Test 02 - getGuardSetND of OR and NOT expressions
! (assertEqualToResult (getGuardSetND (OR)) ())
! (assertEqualToResult (getGuardSetND (OR A B (NOT A))) ())
! (assertEqualToResult (getGuardSetND (OR (AND A B) (AND A B) (NOT A))) ())

 ;; Test 03 - getGuardSetND of AND expressions
! (assertEqualToResult (getGuardSetND (AND)) ())
! (assertEqualToResult (getGuardSetND (AND A)) (A))
! (assertEqualToResult (getGuardSetND (AND (NOT A) (NOT B) A)) ((NOT A) (NOT B) A))
! (assertEqualToResult (getGuardSetND (AND A (AND A B) (OR A B) (NOT B))) (A (NOT B)))
! (assertEqualToResult (getGuardSetND (AND (AND A B) A) ) (A))
! (assertEqualToResult (getGuardSetND (AND A B (NOT B)) ) (A B (NOT B)))
! (assertEqualToResult (getGuardSetND (AND A (NOT A) (NOT B))) (A (NOT A) (NOT B)))
! (assertEqualToResult (getGuardSetND (AND (NOT A) A B)) ((NOT A) A B))

;; Test for isConsistentExp
! (assertEqualToResult (isConsistentExp ()) (True))
! (assertEqualToResult (isConsistentExp A) (True))
! (assertEqualToResult (isConsistentExp (A)) (True))
! (assertEqualToResult (isConsistentExp (AND)) (True))
! (assertEqualToResult (isConsistentExp (AND (OR A B) (AND A B) A B)) (True))
! (assertEqualToResult (isConsistentExp (AND (NOT A) (NOT B) A)) (False))
! (assertEqualToResult (isConsistentExp (AND A B (NOT B))) (False))
! (assertEqualToResult (isConsistentExp (OR A B (NOT A))) (False))
! (assertEqualToResult (isConsistentExp (OR (AND A B) (AND A B) (NOT A))) (True))
! (assertEqualToResult (isConsistentExp (AND A (NOT A) (NOT B))) (False))

! (assertEqualToResult (nodeHasChildOrGuard (AND A B)) (True))
! (assertEqualToResult (nodeHasChildOrGuard (AND A B C)) (True))
! (assertEqualToResult (nodeHasChildOrGuard (OR A B C)) (True))
! (assertEqualToResult (nodeHasChildOrGuard (AND)) (False))

;; Test for filterLiterals
! (assertEqual (filterLiterals A) A)
! (assertEqual (filterLiterals (AND A B C)) (empty))
! (assertEqual (filterLiterals (NOT A)) (NOT A))
! (assertEqual (filterLiterals AND) (empty))
! (assertEqual (filterLiterals OR) (empty))

;; Test for filterChildren

! (assertEqual (filterChildren A) (empty))
! (assertEqual (filterChildren (NOT A)) (empty))
! (assertEqual (filterChildren (OR A B C)) (OR A B C))
! (assertEqual (filterChildren (AND A B C)) (AND A B C))
! (assertEqual (filterChildren (OR A)) (OR A))

;; Test for getChildren

! (assertEqual (getChildren ()) ())
! (assertEqual (getChildren (AND A B (OR A B) C E (OR E F) (OR A) (NOT F))) ((OR A B) (OR E F) (OR A)))
! (assertEqual (getChildren (AND (OR A B) A B C E (NOT F) (OR E F) (OR A))) ((OR A B) (OR E F) (OR A)))
! (assertEqual (getChildren (OR A B (AND A B) C E (AND E F) (AND A) (NOT F))) ((AND A B) (AND E F) (AND A)))
! (assertEqual (getChildren (OR (AND A B) A B C E (NOT F) (AND E F) (AND A))) ((AND A B) (AND E F) (AND A)))

;; Test for getLiterals
! (assertEqual (getLiterals ()) ())
! (assertEqual (getLiterals (AND A)) (A))
! (assertEqual (getLiterals (OR A)) (A))
! (assertEqual (getLiterals (AND A B (OR A B) C E (OR E F) (OR A) (NOT F))) (A B C E (NOT F)))
! (assertEqual (getLiterals (AND (OR A B) A B C E (NOT F) (OR E F) (OR A))) (A B C E (NOT F)))
! (assertEqual (getLiterals (OR A B (AND A B) C E (AND E F) (AND A) (NOT F))) (A B C E (NOT F)))
! (assertEqual (getLiterals (OR (AND A B) A B C E (NOT F) (AND E F) (AND A))) (A B C E (NOT F)))


;; Test for getLiteralsND
! (assertEqualToResult (getLiteralsND ()) (()))
! (assertEqualToResult (getLiteralsND (AND A)) (A))
! (assertEqualToResult (getLiteralsND (OR A)) (A))
! (assertEqualToResult (getLiteralsND (AND A B (OR A B) C E (OR E F) (OR A) (NOT F))) (A B C E (NOT F)))
! (assertEqualToResult (getLiteralsND (AND (OR A B) A B C E (NOT F) (OR E F) (OR A))) (A B C E (NOT F)))
! (assertEqualToResult (getLiteralsND (OR A B (AND A B) C E (AND E F) (AND A) (NOT F))) (A B C E (NOT F)))
! (assertEqualToResult (getLiteralsND (OR (AND A B) A B C E (NOT F) (AND E F) (AND A))) (A B C E (NOT F)))

;; Test for getLiteralChildren
! (assertEqual (getLiteralChildren ()) (() ()))
! (assertEqual (getLiteralChildren (AND A)) ((A) ()))
! (assertEqual (getLiteralChildren (OR A)) ((A) ()))
! (assertEqual (getLiteralChildren (AND A B (OR A B) C E (OR E F) (OR A) (NOT F))) ((A B C E (NOT F)) ((OR A B) (OR E F) (OR A))))
! (assertEqual (getLiteralChildren (AND (OR A B) A B C E (NOT F) (OR E F) (OR A))) ((A B C E (NOT F)) ((OR A B) (OR E F) (OR A))))
! (assertEqual (getLiteralChildren (OR A B (AND A B) C E (AND E F) (AND A) (NOT F))) ((A B C E (NOT F)) ((AND A B) (AND E F) (AND A))))
! (assertEqual (getLiteralChildren (OR (AND A B) A B C E (NOT F) (AND E F) (AND A))) ((A B C E (NOT F)) ((AND A B) (AND E F) (AND A))))

;; Test for addLiterals
! (assertEqual (addLiterals (AND A B C (OR A B) E F) (A B G)) (AND A B C E F G (OR A B)))
! (assertEqual (addLiterals (OR A B C (AND A B) E F) (A B G)) (OR A B C E F G (AND A B)))
! (assertEqual (addLiterals (AND A B (OR A B)) (Z)) (AND A B Z (OR A B)))
! (assertEqual (addLiterals (OR (AND A B) A B) (Z)) (OR A B Z (AND A B)))
! (assertEqual (addLiterals (AND A B C (OR A B)) (A B C)) (AND A B C (OR A B)))
! (assertEqual (addLiterals (AND A (OR A B) B C) (E F G)) (AND A B C E F G (OR A B)))

;; Test for addChildren
! (assertEqual (addChildren (AND A B C) ()) (AND A B C))
! (assertEqual (addChildren (OR A B C) ()) (OR A B C))
! (assertEqual (addChildren (OR) ((AND B C))) (OR (AND B C)))
! (assertEqual (addChildren (AND) ((OR B C))) (AND (OR B C)))
! (assertEqual (addChildren (AND (OR A B)) ((OR C D) (OR E F))) (AND (OR A B) (OR C D) (OR E F)))
! (assertEqual (addChildren (OR (AND A B)) ((AND C D) (AND E F))) (OR (AND A B) (AND C D) (AND E F)))
! (assertEqual (addChildren (AND A B C (OR A B)) ((OR A E) (OR B C) (OR A B E (AND A F)))) (AND A B C (OR A B) (OR A E) (OR B C) (OR A B E (AND A F))))
! (assertEqual (addChildren (OR A B C (AND A B)) ((AND A E) (AND B C) (AND A B E (OR A F)))) (OR A B C (AND A B) (AND A E) (AND B C) (AND A B E (OR A F))))
! (assertEqual (addChildren (AND A (OR A B) B C) ((OR B C))) (AND A B C (OR A B) (OR B C)))
! (assertEqual (addChildren (OR A (AND A B) B C) ((AND B C))) (OR A B C (AND A B) (AND B C)))
! (assertEqual (addChildren (OR A B C) ((AND A E) (AND B C) (AND A B E (OR A F)))) (OR A B C (AND A E) (AND B C) (AND A B E (OR A F))))

;; Test for foldl
!(assertEqual (foldl + 0 (1 2 3 4 5)) 15)
!(assertEqual (foldl * 1 (2 2 2 2)) 16)
!(assertEqual (foldl * 1 ()) 1)

;; Test for any
!(assertEqual (any (True False False)) True)
!(assertEqual (any (False True False)) True)
!(assertEqual (any (False False True)) True)
!(assertEqual (any (False False False)) False)
!(assertEqual (any (False False False False False False False)) False)
!(assertEqual (any (False False True False False False False)) True)

;; Test for getSubExpression
!(assertEqual (getSubExpression (NOT A)) ())
!(assertEqual (getSubExpression (OR A B (AND C D) (AND E F))) (A B (AND C D) (AND E F)))
!(assertEqual (getSubExpression (AND A B (OR C D) (OR E F))) (A B (OR C D) (OR E F)))
