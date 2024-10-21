! (register-module! ../../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:boolean-reduct:rte-helpers)

 ;; Test for getGuardSetExp

 ;; Test 01 - getGuardSet of an empty set
! (assertEqualToResult (getGuardSetExp () () ()) ( ()))

 ;; Test 02 - getGuardSet of a literal
! (assertEqualToResult (getGuardSetExp A A ()) ( (A)))
! (assertEqualToResult (getGuardSetExp (A) (A) ()) ( (A)))

 ;; Test 02 - getGuardSet of OR and NOT expressions
! (assertEqualToResult (getGuardSetExp (OR) (OR) ()) ( ()))
! (assertEqualToResult (getGuardSetExp (OR A B (NOT A)) (OR A B (NOT A)) ()) ( ()))
! (assertEqualToResult (getGuardSetExp (OR (AND A B) (AND A B) (NOT A)) (OR (AND A B) (AND A B) (NOT A)) ()) ( ()))

 ;; Test 03 - getGuardSet of AND expressions
! (assertEqualToResult (getGuardSetExp (AND) (AND) ()) ( ()))
! (assertEqualToResult (getGuardSetExp (AND A) (AND A) ()) ( (A)))
! (assertEqualToResult (getGuardSetExp (AND (NOT A) (NOT B) A) (AND (NOT A) (NOT B) A) ()) ( (A (NOT B) (NOT A))))
! (assertEqualToResult (getGuardSetExp (AND A (AND A B) (OR A B) (NOT B)) (AND A (AND A B) (OR A B) (NOT B)) ()) ( ( (NOT B) A)))
! (assertEqualToResult (getGuardSetExp (AND (AND A B) A) (AND (AND A B) A) ()) ( (A)))
! (assertEqualToResult (getGuardSetExp (AND A B (NOT B)) (AND A B (NOT B)) ()) ( ( (NOT B) B A)))
! (assertEqualToResult (getGuardSetExp (AND A (NOT A) (NOT B)) (AND A (NOT A) (NOT B)) ()) ( ( (NOT B) (NOT A) A)))
! (assertEqualToResult (getGuardSetExp (AND (NOT A) A B) (AND (NOT A) A B) ()) ( (B A (NOT A))))

 ;; Test for isConsistentExp
! (assertEqualToResult (isConsistentExp ()) (True))
! (assertEqualToResult (isConsistentExp A) (True))
! (assertEqualToResult (isConsistentExp (A)) (True))
! (assertEqualToResult (isConsistentExp (AND)) (True))
! (assertEqualToResult (isConsistentExp (AND (OR A B) (AND A B) A B)) (True))
! (assertEqualToResult (isConsistentExp (AND (NOT A) (NOT B) A)) (False))
! (assertEqualToResult (isConsistentExp (AND A B (NOT B))) (False))
! (assertEqualToResult (isConsistentExp (OR A B (NOT A))) (True))
! (assertEqualToResult (isConsistentExp (OR (AND A B) (AND A B) (NOT A))) (True))
! (assertEqualToResult (isConsistentExp (AND A (NOT A) (NOT B))) (False))

! (assertEqualToResult (nodeHasChildExp (AND A B)) (True))
! (assertEqualToResult (nodeHasChildExp (AND A B C)) (True))
! (assertEqualToResult (nodeHasChildExp (OR A B C)) (True))
! (assertEqualToResult (nodeHasChildExp (A)) (False))
! (assertEqualToResult (nodeHasChildExp A) (False))
! (assertEqualToResult (nodeHasChildExp (AND)) (False))
! (assertEqualToResult (nodeHasChildExp AND) (False))

 ;; Tests for new getGuardSetExpression
 ;  ;; Test 02 - getGuardSet of a literal
! (assertEqualToResult (getGuardSetExpression A) ( (A)))
! (assertEqualToResult (getGuardSetExpression (A)) ( (A)))

 ;  ;  ;; Test 02 - getGuardSet of OR and NOT expressions
! (assertEqualToResult (getGuardSetExpression (OR)) ( ()))
! (assertEqualToResult (getGuardSetExpression (OR A B (NOT A))) ( ()))
! (assertEqualToResult (getGuardSetExpression (OR (AND A B) (AND A B) (NOT A))) ( ()))

 ;  ;  ;; Test 03 - getGuardSet of AND expressions
! (assertEqualToResult (getGuardSetExpression (AND)) ( ()))
! (assertEqualToResult (getGuardSetExpression (AND A)) ( (A)))
! (assertEqualToResult (getGuardSetExpression (AND (NOT A) (NOT B) A)) ( ( (NOT A) (NOT B) A)))
! (assertEqualToResult (getGuardSetExpression (AND A (AND A B) (OR A B) (NOT B))) ( ( A (NOT B))))
! (assertEqualToResult (getGuardSetExpression (AND (AND A B) A) ) ( (A)))
! (assertEqualToResult (getGuardSetExpression (AND A B (NOT B)) ) ( (  A B (NOT B) )))
! (assertEqualToResult (getGuardSetExpression (AND A (NOT A) (NOT B))) ( ( A (NOT A) (NOT B) )))
! (assertEqualToResult (getGuardSetExpression (AND (NOT A) A B)) ( ( (NOT A) A B)))